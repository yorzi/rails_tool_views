# frozen_string_literal: true
require_relative "test_helper"

class RuntimeTest < ActiveSupport::TestCase
  test "persist action restore and canonical replay" do
    surface = present_card
    result = act(surface, idempotency: "request-1")
    assert_equal "completed", result[:status]
    assert_equal 2, result[:revision]
    assert_equal "compare", RailsToolViews.restore(surface.id, scope: scope).state["selected"]
    assert_equal result, act(surface, revision: 1, idempotency: "request-1")
    assert_equal 1, DemoEffect.count
    assert_equal 1, RailsToolViews::ActionExecution.count
    assert_error("IDEMPOTENCY_CONFLICT") { act(surface, key: "continue", revision: 1, idempotency: "request-1") }
  end

  test "stale unknown action forged source and denied resource have no effects" do
    surface = present_card
    assert_error("NOT_ALLOWED") { act(surface, key: "admin") }
    assert_error("UNKNOWN_ACTION") { RailsToolViews.dispatch(surface.id, scope: scope, action: "eval", arguments: {}, base_revision: 1, idempotency_key: "x") }
    assert_error("INVALID_SOURCE") { act(surface, source_component: "other") }
    assert_error("INVALID_TARGET") { act(surface, target: "body") }
    assert_equal 0, DemoEffect.count
    act(surface)
    assert_error("CONFLICT") { act(surface, revision: 1) }
    assert_equal 1, DemoEffect.count
  end

  test "read and write require same actor tenant and current policy" do
    surface = present_card
    [scope("bob"), scope("alice", "other")].each do |other|
      assert_error("NOT_FOUND") { RailsToolViews.restore(surface.id, scope: other) }
      assert_error("NOT_FOUND") { RailsToolViews.dispatch(surface.id, scope: other, action: "select_option", arguments: { key: "compare" }, base_revision: 1, idempotency_key: "x") }
    end
    RailsToolViews.reset!
    register_card(policy: ->(_access) { false })
    assert_error("NOT_ALLOWED") { RailsToolViews.restore(surface.id, scope: scope) }
    assert_equal 0, DemoEffect.count
  end

  test "contract changes fail recoverably" do
    surface = present_card
    RailsToolViews.reset!
    assert_error("INCOMPATIBLE_COMPONENT") { RailsToolViews.restore(surface.id, scope: scope) }
    register_card
    component = RailsToolViews.registry.fetch(:choice_card)
    surface.update!(component_digest: "old")
    assert_error("INCOMPATIBLE_COMPONENT") { RailsToolViews.restore(surface.id, scope: scope) }
    assert_equal 1, RailsToolViews::Surface.count
    assert_match /sha256:/, component.digest
  end

  test "model proposed options cannot expand trusted host business permissions" do
    malicious = RailsToolViews.present(:choice_card, props: props.merge(options: [{ key: "admin", label: "Privileged option" }]), scope: scope)
    assert_error("NOT_ALLOWED") { act(malicious, key: "admin") }
    assert_equal 0, DemoEffect.count
    assert_equal 1, malicious.reload.revision
  end

  test "an action with no host policy denies a valid payload" do
    RailsToolViews.register(:deny_action, description: "Default deny", schema: PROPS_SCHEMA, partial: "choices/card", policy: ->(_access) { true },
      actions: { select_option: { schema: PARAMS_SCHEMA, handler: ->(_access) { flunk "handler ran without permission" } } })
    surface = RailsToolViews.present(:deny_action, props: props, scope: scope)
    assert_error("NOT_ALLOWED") { RailsToolViews.dispatch(surface.id, scope: scope, action: "select_option", arguments: { key: "compare" }, base_revision: 1, idempotency_key: "denied") }
    assert_equal 1, surface.reload.revision
    assert_equal 0, RailsToolViews::ActionExecution.count
  end

  test "handler failure rolls back host data surface and receipt" do
    RailsToolViews.reset!
    register_card do |access|
      DemoEffect.create!(surface_id: access.surface.id, value: "rolled back")
      raise RailsToolViews::Error.new("DOMAIN_REJECTED", status: 422)
    end
    surface = present_card
    assert_error("DOMAIN_REJECTED") { act(surface) }
    assert_equal 1, surface.reload.revision
    assert_equal 0, DemoEffect.count
    assert_equal 0, RailsToolViews::ActionExecution.count
  end

  test "a database rollback of the action is a retryable conflict with nothing committed" do
    events = []
    token = ActiveSupport::Notifications.subscribe("action.conflict.rails_tool_views") { |*args| events << args.last }
    [ActiveRecord::Deadlocked, ActiveRecord::SerializationFailure, ActiveRecord::LockWaitTimeout].each do |rollback|
      RailsToolViews.reset!
      attempts = 0
      register_card do |access|
        DemoEffect.create!(surface_id: access.surface.id, value: "rolled back")
        raise rollback, "simulated by the database" if (attempts += 1) == 1
        RailsToolViews::Transition.new(state: { selected: access.arguments.fetch("key") })
      end
      surface = present_card
      assert_error("CONFLICT") { act(surface, idempotency: "retry-me") }
      assert_equal [1, 0, 0], [surface.reload.revision, DemoEffect.where(surface_id: surface.id).count, RailsToolViews::ActionExecution.where(surface_id: surface.id).count]
      assert_equal 2, act(surface, idempotency: "retry-me")[:revision]
      assert_equal 1, DemoEffect.where(surface_id: surface.id).count
    end
    assert_equal [{ code: "CONFLICT" }] * 3, events
  ensure
    ActiveSupport::Notifications.unsubscribe(token) if token
  end

  test "correlation is durable and isolated by actor tenant adapter and context" do
    correlation = { adapter: "test", call_id: "call-1", context: "chat-1" }
    first = present_card(correlation: correlation)
    second = present_card(correlation: correlation)
    assert_equal first.id, second.id
    assert_equal 1, RailsToolViews::Surface.count
    assert_error("IDEMPOTENCY_CONFLICT") { RailsToolViews.present(:choice_card, props: props.merge(title: "Different"), scope: scope, correlation: correlation) }
    assert_not_equal first.id, present_card(correlation: correlation.merge(context: "chat-2")).id
    assert_not_equal first.id, present_card(correlation: correlation.merge(adapter: "other")).id
  end

  test "a correlated presentation that loses the insert race still reports its rejection" do
    correlation = { adapter: "test", call_id: "call-1", context: "chat-1" }
    present_card(correlation: correlation)
    events = []
    token = ActiveSupport::Notifications.subscribe("presentation.rejected.rails_tool_views") { |*_timing, payload| events << payload }
    lookup = RailsToolViews.method(:correlated_presentation)
    calls = 0
    # The first lookup runs before the competing request commits its receipt.
    RailsToolViews.stub(:correlated_presentation, ->(key) { (calls += 1) == 1 ? nil : lookup.call(key) }) do
      assert_error("IDEMPOTENCY_CONFLICT") { RailsToolViews.present(:choice_card, props: props.merge(title: "Different"), scope: scope, correlation: correlation) }
    end
    assert_equal 2, calls
    assert_equal [{ code: "IDEMPOTENCY_CONFLICT" }], events
    assert_equal 1, RailsToolViews::Surface.count
  ensure
    ActiveSupport::Notifications.unsubscribe(token) if token
  end

  test "configured per-surface action budget limits new mutations while allowing replay" do
    RailsToolViews.configuration.max_actions_per_minute = 1
    surface = present_card
    result = act(surface, idempotency: "first")
    assert_equal result, act(surface, revision: 1, idempotency: "first")
    assert_error("RATE_LIMITED") { act(surface, revision: 2) }
    assert_equal 1, DemoEffect.count
    assert_equal 2, surface.reload.revision
  end

  test "no continuation adapter still commits selection" do
    RailsToolViews.reset!; register_card(agent: true)
    surface = present_card
    result = act(surface)
    assert_equal "completed", result[:status]
    assert_equal "skipped", RailsToolViews::AgentInteraction.first.status
    assert_equal 2, surface.reload.revision
  end

  # A database collation that is not binary (MySQL's default utf8mb4 collation,
  # for example) can return a row that only compares equal to the requested
  # value. These tests hand the runtime such a row and prove the guards reject
  # it, so a case difference can never cross an actor, tenant or correlation
  # boundary. A byte-exact match must still resolve normally.
  test "a surface only a non-binary collation could match is refused" do
    surface = present_card
    RailsToolViews::Surface.stub(:find_by, surface) do
      assert_error("NOT_FOUND") { RailsToolViews.restore(surface.id, scope: scope("alice", "ACME")) }
      assert_error("NOT_FOUND") { RailsToolViews.restore(surface.id, scope: scope("Alice", "acme")) }
      assert_equal surface, RailsToolViews.restore(surface.id, scope: scope("alice", "acme"))
    end
  end

  test "a correlation only a non-binary collation could match is a conflict not a replay" do
    correlation = { adapter: "test", call_id: "call-1", context: "chat-1" }
    present_card(correlation: correlation)
    prior = RailsToolViews::Presentation.first
    RailsToolViews::Presentation.stub(:find_by, prior) do
      assert_error("IDEMPOTENCY_CONFLICT") { present_card(correlation: correlation.merge(call_id: "CALL-1")) }
    end
    assert_equal 1, RailsToolViews::Surface.count
  end

  test "an idempotency key only a non-binary collation could match is a conflict" do
    surface = present_card
    act(surface, idempotency: "request-1")
    prior = RailsToolViews::ActionExecution.first
    RailsToolViews::ActionExecution.stub(:find_by, prior) do
      # Same action, arguments and revision, so only the byte difference in the
      # key can raise the conflict.
      assert_error("IDEMPOTENCY_CONFLICT") { act(surface, revision: 1, idempotency: "REQUEST-1") }
    end
    assert_equal 1, RailsToolViews::ActionExecution.count
    assert_equal 1, DemoEffect.count
  end
end
