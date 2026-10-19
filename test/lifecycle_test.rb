# frozen_string_literal: true
require_relative "test_helper"
require "timeout"

class LifecycleTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers
  test "close preserves authorized reads and exact receipts but rejects new actions" do
    surface = present_card(correlation: { adapter: "ruby_llm", call_id: "call-1", context: "chat-1" })
    result = act(surface, idempotency: "first")
    deadline = 1.day.from_now
    closed = RailsToolViews.close(surface.id, scope: scope, retain_until: deadline)
    assert closed.closed?
    assert_equal 3, closed.revision
    assert_equal "closed", RailsToolViews.restore(surface.id, scope: scope).snapshot[:lifecycle][:status]
    assert_equal result, act(surface, revision: 1, idempotency: "first")
    assert_error("SURFACE_CLOSED") { act(surface, revision: 3, idempotency: "second") }
    assert_error("IDEMPOTENCY_CONFLICT") { act(surface, key: "continue", revision: 1, idempotency: "first") }
    assert_equal 1, DemoEffect.count
    assert_equal closed.id, present_card(correlation: { adapter: "ruby_llm", call_id: "call-1", context: "chat-1" }).id
    again = RailsToolViews.close(surface.id, scope: scope, retain_until: 2.days.from_now)
    assert_equal deadline.to_i, again.retain_until.to_i
    assert_equal 3, again.revision
    travel_to(3.days.from_now) do
      assert_equal closed.id, RailsToolViews.close(surface.id, scope: scope, retain_until: deadline).id
    end
  end

  test "lifecycle rechecks ownership and the separate host operation policy" do
    operations = []
    register_card(:restricted, policy: ->(access) { operations << access.operation; %i[present read].include?(access.operation) })
    surface = RailsToolViews.present(:restricted, props: props, scope: scope)
    assert_error("NOT_ALLOWED") { RailsToolViews.close(surface.id, scope: scope) }
    assert_includes operations, :close
    assert_error("NOT_ALLOWED") { RailsToolViews.abandon(surface.id, scope: scope) }
    assert_includes operations, :abandon
    assert_error("NOT_FOUND") { RailsToolViews.close(surface.id, scope: scope("bob")) }
    assert_error("NOT_FOUND") { RailsToolViews.abandon(surface.id, scope: scope("alice", "other")) }
    refute surface.reload.closed?
  end

  test "pending and failed continuation require explicit abandonment" do
    RailsToolViews.reset!; register_card(agent: true)
    RailsToolViews.configuration.agent_adapter = ->(*) { raise "offline failure" }
    surface = present_card
    interaction = RailsToolViews::AgentInteraction.find(act(surface).fetch(:interaction_id))
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.close(surface.id, scope: scope) }
    RailsToolViews.deliver(interaction.id, scope: scope)
    assert_equal "failed", interaction.reload.status
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.close(surface.id, scope: scope) }
    closed = RailsToolViews.abandon(surface.id, scope: scope)
    assert_equal "abandoned", closed.lifecycle_status
    assert_equal "abandoned", interaction.reload.status
    assert_equal "abandoned", RailsToolViews.deliver(interaction.id, scope: scope, adapter: ->(*) { flunk "abandoned work delivered" }, retry_failed: true).status
    assert_nil closed.retain_until
    assert_equal 1, DemoEffect.count
  end

  test "a delivery is protected even after its lease expires or an ambiguous reclaim completes" do
    RailsToolViews.reset!; register_card(agent: true)
    RailsToolViews.configuration.agent_adapter = ->(*) { }
    surface = present_card
    interaction = RailsToolViews::AgentInteraction.find(act(surface).fetch(:interaction_id))
    interaction.update!(status: "delivering", claimed_at: 1.hour.ago)
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.close(surface.id, scope: scope) }
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.abandon(surface.id, scope: scope) }
    RailsToolViews.deliver(interaction.id, scope: scope)
    assert interaction.reload.delivery_uncertain?
    assert_equal "completed", interaction.status
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.abandon(surface.id, scope: scope) }
    refute surface.reload.closed?
  end

  test "invalid retention deadlines never write and first termination wins" do
    surface = present_card
    [1.day.ago, "tomorrow", 42].each do |deadline|
      assert_error("INVALID_RETENTION_WINDOW") { RailsToolViews.close(surface.id, scope: scope, retain_until: deadline) }
      refute surface.reload.closed?
    end
    closed = RailsToolViews.close(surface.id, scope: scope)
    assert_nil closed.retain_until
    assert_equal "closed", RailsToolViews.abandon(surface.id, scope: scope).lifecycle_status
    assert_equal 2, surface.reload.revision
  end
  test "a live callback stays outside transactions and blocks lifecycle termination" do
    RailsToolViews.reset!; register_card(agent: true)
    entered, release = Queue.new, Queue.new
    RailsToolViews.configuration.agent_adapter = ->(*) { entered << ActiveRecord::Base.connection.transaction_open?; release.pop }
    surface = present_card
    interaction_id = act(surface).fetch(:interaction_id)
    worker = Thread.new { ActiveRecord::Base.connection_pool.with_connection { RailsToolViews.deliver(interaction_id, scope: scope) } }
    assert_equal false, Timeout.timeout(5) { entered.pop }
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.close(surface.id, scope: scope) }
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.abandon(surface.id, scope: scope) }
    release << true
    assert_equal "completed", Timeout.timeout(5) { worker.value }.status
    assert RailsToolViews.close(surface.id, scope: scope).closed?
  ensure
    release << true if release
    worker&.kill if worker&.alive?
    worker&.join
  end

  test "a stale delivery completion never clears the lifecycle uncertainty guard" do
    RailsToolViews.reset!; register_card(agent: true)
    entered, first_release, second_release = Queue.new, Queue.new, Queue.new
    counter, mutex = 0, Mutex.new
    RailsToolViews.configuration.agent_adapter = ->(*) {
      number = mutex.synchronize { counter += 1 }
      entered << number
      (number == 1 ? first_release : second_release).pop
    }
    surface = present_card
    interaction_id = act(surface).fetch(:interaction_id)
    first = Thread.new { ActiveRecord::Base.connection_pool.with_connection { RailsToolViews.deliver(interaction_id, scope: scope) } }
    assert_equal 1, Timeout.timeout(5) { entered.pop }
    RailsToolViews::AgentInteraction.find(interaction_id).update!(claimed_at: 1.hour.ago)
    second = Thread.new { ActiveRecord::Base.connection_pool.with_connection { RailsToolViews.deliver(interaction_id, scope: scope) } }
    assert_equal 2, Timeout.timeout(5) { entered.pop }
    first_release << true
    Timeout.timeout(5) { first.value }
    assert RailsToolViews::AgentInteraction.find(interaction_id).delivery_uncertain?
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.close(surface.id, scope: scope) }
    second_release << true
    Timeout.timeout(5) { second.value }
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.abandon(surface.id, scope: scope) }
  ensure
    first_release << true if first_release
    second_release << true if second_release
    [first, second].compact.each { |worker| worker.kill if worker.alive?; worker.join }
  end

  test "both installer migration templates match the shipped engine migrations" do
    root = File.expand_path("..", __dir__)
    assert_equal File.read(File.join(root, "db/migrate/20261019000000_add_rails_tool_views_lifecycle.rb")),
      File.read(File.join(root, "lib/generators/rails_tool_views/install/templates/add_rails_tool_views_lifecycle.rb"))
  end

end
