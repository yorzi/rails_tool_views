# frozen_string_literal: true
require_relative "test_helper"
require "timeout"

class DeliveryRecoveryTest < ActiveSupport::TestCase
  [false, true].each do |old_fails|
    test "a stale #{old_fails ? 'failure' : 'success'} cannot acknowledge a newer delivery" do
      RailsToolViews.reset!; register_card(agent: true)
      entered, old_release, new_release = Queue.new, Queue.new, Queue.new
      calls, mutex = 0, Mutex.new
      RailsToolViews.configuration.agent_adapter = ->(*) {
        attempt = mutex.synchronize { calls += 1 }
        entered << attempt
        (attempt == 1 ? old_release : new_release).pop
        raise "old callback failed" if attempt == 1 && old_fails
      }
      interaction_id = act(present_card).fetch(:interaction_id)
      workers = []
      workers << Thread.new { ActiveRecord::Base.connection_pool.with_connection { RailsToolViews.deliver(interaction_id, scope: scope) } }
      assert_equal 1, Timeout.timeout(5) { entered.pop }
      RailsToolViews::AgentInteraction.find(interaction_id).update!(claimed_at: 1.hour.ago)
      workers << Thread.new { ActiveRecord::Base.connection_pool.with_connection { RailsToolViews.deliver(interaction_id, scope: scope) } }
      assert_equal 2, Timeout.timeout(5) { entered.pop }
      old_release << true
      Timeout.timeout(5) { workers.first.value }
      current = RailsToolViews::AgentInteraction.find(interaction_id)
      assert_equal "delivering", current.status
      assert_not_nil current.claimed_at
      assert_nil current.error_code
      assert_equal 2, current.attempts
      assert current.delivery_uncertain?
      assert_equal "delivering", RailsToolViews.deliver(interaction_id, scope: scope, retry_failed: true).status
      assert_equal 2, calls
      new_release << true
      assert_equal "completed", Timeout.timeout(5) { workers.last.value }.status
    ensure
      old_release << true if old_release
      new_release << true if new_release
      workers&.each { |worker| worker.kill if worker.alive?; worker.join }
    end
  end

  test "a late failing worker cannot undo the newer completed result or emit a false failure" do
    RailsToolViews.reset!; register_card(agent: true)
    entered, release, workers, events = Queue.new, Queue.new, [], []
    old_adapter = ->(*) { entered << true; release.pop; raise "late failure" }
    RailsToolViews.configuration.agent_adapter = old_adapter
    interaction_id = act(present_card).fetch(:interaction_id)
    token = ActiveSupport::Notifications.subscribe(/agent_(returned|failed)\.rails_tool_views/) { |name, *| events << name }
    workers << Thread.new { ActiveRecord::Base.connection_pool.with_connection { RailsToolViews.deliver(interaction_id, scope: scope) } }
    Timeout.timeout(5) { entered.pop }
    RailsToolViews::AgentInteraction.find(interaction_id).update!(claimed_at: 1.hour.ago)
    assert_equal "completed", RailsToolViews.deliver(interaction_id, scope: scope, adapter: ->(*) {}).status
    release << true
    assert_equal "completed", Timeout.timeout(5) { workers.first.value }.status
    assert_equal ["agent_returned.rails_tool_views"], events
    assert_nil RailsToolViews::AgentInteraction.find(interaction_id).error_code
  ensure
    release << true if release
    workers&.each { |worker| worker.kill if worker.alive?; worker.join }
    ActiveSupport::Notifications.unsubscribe(token) if token
  end

  test "delivery refuses an outer transaction before calling the adapter" do
    RailsToolViews.reset!; register_card(agent: true)
    calls = 0
    RailsToolViews.configuration.agent_adapter = ->(*) { calls += 1 }
    RailsToolViews::Surface.transaction do
      interaction_id = act(present_card).fetch(:interaction_id)
      assert_error("DELIVERY_IN_TRANSACTION") { RailsToolViews.deliver(interaction_id, scope: scope) }
      assert_equal "pending", RailsToolViews::AgentInteraction.find(interaction_id).status
      raise ActiveRecord::Rollback
    end
    assert_equal 0, calls
    assert_equal 0, RailsToolViews::AgentInteraction.count
    assert_equal 0, DemoEffect.count
  end
end
