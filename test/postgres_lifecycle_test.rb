# frozen_string_literal: true
require_relative "test_helper"
require "timeout"

# SQLite's deferred transactions do not provide SELECT FOR UPDATE. Real
# serialization is exercised in the PostgreSQL matrix, not simulated by mocks.
if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
  class PostgresLifecycleTest < ActiveSupport::TestCase
    include ActiveSupport::Testing::TimeHelpers

    test "competing delivery claims invoke only one callback while the lease is fresh" do
      RailsToolViews.reset!; register_card(agent: true)
      entered, release, start, workers = Queue.new, Queue.new, Queue.new, []
      RailsToolViews.configuration.agent_adapter = ->(*) { entered << true; Timeout.timeout(5) { release.pop } }
      interaction_id = act(present_card).fetch(:interaction_id)
      2.times do
        workers << Thread.new { ActiveRecord::Base.connection_pool.with_connection {
          start.pop
          RailsToolViews.deliver(interaction_id, scope: scope)
        } }
      end
      2.times { start << true }
      Timeout.timeout(5) { entered.pop }
      # The skipped contender returns while the active callback is still blocked.
      Timeout.timeout(5) { Thread.pass until workers.any? { |worker| !worker.alive? } }
      assert entered.empty?, "both claimants invoked the adapter"
      assert_equal 1, RailsToolViews::AgentInteraction.find(interaction_id).attempts
      release << true
      results = Timeout.timeout(5) { workers.map(&:value) }
      assert_equal %w[completed delivering], results.map(&:status).sort
      assert_equal "completed", RailsToolViews::AgentInteraction.uncached { RailsToolViews::AgentInteraction.find(interaction_id).status }
    ensure
      release << true if release
      workers&.each { |worker| worker.kill if worker.alive?; worker.join }
    end

    test "a reclaiming worker waits for reconciliation and honors the attested failure" do
      RailsToolViews.reset!; register_card(agent: true)
      called = Queue.new
      RailsToolViews.configuration.agent_adapter = ->(*) { called << true }
      interaction_id = act(present_card).fetch(:interaction_id)
      RailsToolViews::AgentInteraction.where(id: interaction_id).update_all(status: "delivering", claimed_at: 1.hour.ago, attempts: 1)
      entered, release, workers = Queue.new, Queue.new, []
      # The policy runs while reconciliation holds the Surface and interaction locks.
      RailsToolViews.configuration.reconciliation_policy = ->(_) { entered << true; Timeout.timeout(5) { release.pop }; true }
      workers << Thread.new { ActiveRecord::Base.connection_pool.with_connection {
        RailsToolViews.reconcile_delivery(interaction_id, scope: scope, outcome: :failed)
      } }
      Timeout.timeout(5) { entered.pop }
      workers << Thread.new { ActiveRecord::Base.connection_pool.with_connection { RailsToolViews.deliver(interaction_id, scope: scope) } }
      sleep 0.3
      assert workers.last.alive?, "the claim did not wait for the reconciliation lock"
      release << true
      results = Timeout.timeout(5) { workers.map(&:value) }
      assert_equal %w[failed failed], results.map(&:status)
      assert called.empty?, "a reclaim overrode the attested outcome"
      final = RailsToolViews::AgentInteraction.uncached { RailsToolViews::AgentInteraction.find(interaction_id) }
      assert_equal ["failed", 1, false], [final.status, final.attempts, final.delivery_uncertain?]
    ensure
      release << true if release
      workers&.each { |worker| worker.kill if worker.alive?; worker.join }
    end

    test "two cleanup workers serialize on the same Surface and retain business effects" do
      surface = present_card
      act(surface)
      RailsToolViews.close(surface.id, scope: scope, retain_until: 1.hour.from_now)
      entered, release, fetched = Queue.new, Queue.new, Queue.new
      workers = []
      RailsToolViews.configuration.retention_policy = ->(_) {
        entered << true
        Timeout.timeout(5) { release.pop }
        true
      }
      original = RailsToolViews::Surface.method(:find_by)
      travel_to 2.hours.from_now do
        RailsToolViews::Surface.stub(:find_by, ->(**query) {
          row = original.call(**query)
          fetched << true
          row
        }) do
          workers << Thread.new {
            ActiveRecord::Base.connection_pool.with_connection {
              RailsToolViews.purge_closed(scope: scope, closed_before: Time.current, dry_run: false)
            }
          }
          Timeout.timeout(5) { entered.pop }
          Timeout.timeout(5) { fetched.pop }
          workers << Thread.new {
            ActiveRecord::Base.connection_pool.with_connection {
              RailsToolViews.purge_closed(scope: scope, closed_before: Time.current, dry_run: false)
            }
          }
          Timeout.timeout(5) { fetched.pop }
          release << true
          results = Timeout.timeout(5) { workers.map(&:value) }
          assert_equal 1, results.sum { |r| r[:purged] }
          assert_equal 1, results.sum { |r| r[:protected] }
        end
      end
      assert surface.reload.purged?
      assert_equal 1, DemoEffect.count
      assert_equal 0, RailsToolViews::ActionExecution.count
    ensure
      workers&.each { |worker| worker.kill if worker.alive?; worker.join }
    end

    test "close waits for an action commit and preserves the exact historical receipt" do
      entered, release = Queue.new, Queue.new
      workers = []
      register_card(:slow_card) do |access|
        entered << true
        Timeout.timeout(5) { release.pop }
        DemoEffect.create!(surface_id: access.surface.id, value: "committed")
        RailsToolViews::Transition.new(state: { saved: true })
      end
      surface = RailsToolViews.present(:slow_card, props: props, scope: scope)
      workers << Thread.new { ActiveRecord::Base.connection_pool.with_connection { act(surface, idempotency: "slow") } }
      Timeout.timeout(5) { entered.pop }
      # Loading a pre-commit Surface in the closer must not preserve stale data.
      restored = RailsToolViews.restore(surface.id, scope: scope)
      original = RailsToolViews.method(:restore)
      RailsToolViews.stub(:restore, ->(id, scope:) { Thread.current == workers.first ? original.call(id, scope: scope) : restored }) do
        workers << Thread.new { ActiveRecord::Base.connection_pool.with_connection { RailsToolViews.close(surface.id, scope: scope) } }
        release << true
        Timeout.timeout(5) { workers.each(&:value) }
      end
      assert surface.reload.closed?
      assert_equal 3, surface.revision
      assert_equal true, surface.state["saved"]
      assert_equal 1, DemoEffect.count
      assert_equal 2, act(surface, revision: 1, idempotency: "slow")[:revision]
      assert_error("SURFACE_CLOSED") { act(surface, revision: 3) }
    ensure
      workers&.each { |worker| worker.kill if worker.alive?; worker.join }
    end
  end
end
