# frozen_string_literal: true
require_relative "test_helper"

class ReconciliationTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    register_card(:agent_card, agent: true)
    RailsToolViews.configuration.agent_adapter = ->(_payload, delivery_key:) {}
  end

  def pending_interaction
    surface = RailsToolViews.present(:agent_card, props: props, scope: scope)
    RailsToolViews::AgentInteraction.find(act(surface).fetch(:interaction_id))
  end

  # A lease takeover after a worker stopped mid-call leaves durable uncertainty.
  def uncertain_interaction
    interaction = pending_interaction
    interaction.update!(status: "delivering", claimed_at: 10.minutes.ago, attempts: 1)
    RailsToolViews.deliver(interaction.id, scope: scope)
  end

  def reconcile(interaction, outcome, as: scope)
    RailsToolViews.reconcile_delivery(interaction.id, scope: as, outcome: outcome)
  end

  def allow_reconciliation
    RailsToolViews.configuration.reconciliation_policy = ->(access) { access.operation == :reconcile && access.actor == "alice" }
  end

  test "reconciliation is denied by default and the policy receives a frozen reconcile request" do
    interaction = uncertain_interaction
    assert_error("NOT_ALLOWED") { reconcile(interaction, :completed) }
    seen = nil
    RailsToolViews.configuration.reconciliation_policy = ->(access) { seen = access; "true" }
    assert_error("NOT_ALLOWED") { reconcile(interaction, :completed) }
    assert seen.frozen?
    assert_equal [:reconcile, "select_option", interaction.surface_id], [seen.operation, seen.action, seen.surface.id]
    assert interaction.reload.delivery_uncertain?
  end

  test "an attested outcome clears uncertainty so the view can close and be cleaned up" do
    allow_reconciliation
    interaction = uncertain_interaction
    assert_equal ["completed", true], [interaction.status, interaction.delivery_uncertain?]
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.close(interaction.surface_id, scope: scope) }
    events = []
    token = ActiveSupport::Notifications.subscribe("agent_reconciled.rails_tool_views") { |*_timing, payload| events << payload }
    reconciled = reconcile(interaction, :completed)
    assert_equal ["completed", false, nil, 2], [reconciled.status, reconciled.delivery_uncertain?, reconciled.error_code, reconciled.attempts]
    assert_equal [{ surface_id: interaction.surface_id, interaction_id: interaction.id, outcome: "completed" }], events
    RailsToolViews.close(interaction.surface_id, scope: scope, retain_until: 1.hour.from_now)
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    travel 2.hours do
      assert_equal 1, RailsToolViews.purge_closed(scope: scope, closed_before: Time.current, dry_run: false)[:purged]
    end
  ensure
    ActiveSupport::Notifications.unsubscribe(token) if token
  end

  test "a fresh lease is never overridden and a stale callback cannot undo an attested failure" do
    allow_reconciliation
    interaction = pending_interaction
    keys, results = [], []
    RailsToolViews.configuration.agent_adapter = ->(_payload, delivery_key:) {
      keys << delivery_key
      next if keys.length > 1
      results << assert_error("DELIVERY_ACTIVE") { reconcile(interaction, :failed) }.code
      # The lease expires while this callback still runs; the host attests no effect.
      RailsToolViews::AgentInteraction.where(id: interaction.id).update_all(claimed_at: 10.minutes.ago)
      results << reconcile(interaction, :failed).status
    }
    events = []
    token = ActiveSupport::Notifications.subscribe(/agent_(returned|failed)\.rails_tool_views/) { |name, *| events << name }
    stale = RailsToolViews.deliver(interaction.id, scope: scope)
    assert_equal %w[DELIVERY_ACTIVE failed], results
    assert_equal ["failed", "AGENT_UNAVAILABLE", false, 1], [stale.status, stale.error_code, stale.delivery_uncertain?, stale.attempts]
    assert_empty events
    retried = RailsToolViews.deliver(interaction.id, scope: scope, retry_failed: true)
    assert_equal ["completed", 2, false], [retried.status, retried.attempts, retried.delivery_uncertain?]
    assert_equal [interaction.delivery_key] * 2, keys
  ensure
    ActiveSupport::Notifications.unsubscribe(token) if token
  end

  test "repeating an outcome is idempotent and anything else with nothing to resolve conflicts" do
    allow_reconciliation
    interaction = uncertain_interaction
    reconcile(interaction, :completed)
    events = []
    token = ActiveSupport::Notifications.subscribe("agent_reconciled.rails_tool_views") { |*_timing, payload| events << payload }
    assert_equal "completed", reconcile(interaction, :completed).status
    assert_empty events
    assert_error("RECONCILIATION_CONFLICT") { reconcile(interaction, :failed) }
    pending = pending_interaction
    %i[completed failed].each { |outcome| assert_error("RECONCILIATION_CONFLICT") { reconcile(pending, outcome) } }
    assert_equal "pending", pending.reload.status
    ["completed", :skipped, nil].each { |outcome| assert_error("INVALID_RECONCILIATION") { reconcile(pending, outcome) } }
  ensure
    ActiveSupport::Notifications.unsubscribe(token) if token
  end

  test "another scope, a missing interaction and a purged view are not found" do
    allow_reconciliation
    interaction = uncertain_interaction
    assert_error("NOT_FOUND") { reconcile(interaction, :completed, as: scope("bob")) }
    assert_error("NOT_FOUND") { reconcile(interaction, :completed, as: scope("alice", "ACME")) }
    assert_error("NOT_FOUND") { RailsToolViews.reconcile_delivery(0, scope: scope, outcome: :completed) }
    assert_error("INVALID_SCOPE") { RailsToolViews.reconcile_delivery(interaction.id, scope: nil, outcome: :completed) }
    assert interaction.reload.delivery_uncertain?
    reconcile(interaction, :completed)
    RailsToolViews.close(interaction.surface_id, scope: scope, retain_until: 1.hour.from_now)
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    travel 2.hours do
      RailsToolViews.purge_closed(scope: scope, closed_before: Time.current, dry_run: false)
      assert_error("NOT_FOUND") { reconcile(interaction, :completed) }
    end
  end

  test "an obsolete component's uncertain history can still be resolved" do
    allow_reconciliation
    interaction = uncertain_interaction
    RailsToolViews.reset_registry!
    assert_error("INCOMPATIBLE_COMPONENT") { RailsToolViews.restore(interaction.surface_id, scope: scope) }
    assert_equal ["failed", false], reconcile(interaction, :failed).values_at(:status, :delivery_uncertain)
  end
end
