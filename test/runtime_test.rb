# frozen_string_literal: true
require_relative "test_helper"

class RuntimeTest < ActiveSupport::TestCase
  test "persist action restore and canonical replay" do
    surface = present_card
    result = act(surface, idempotency: "request-1")
    assert_equal "completed", result[:status]
    assert_equal 2, result[:revision]
    assert_equal "compare", ToolViews.restore(surface.id, scope: scope).state["selected"]
    assert_equal result, act(surface, revision: 1, idempotency: "request-1")
    assert_equal 1, DemoEffect.count
    assert_equal 1, ToolViews::ActionExecution.count
    assert_error("IDEMPOTENCY_CONFLICT") { act(surface, key: "continue", revision: 1, idempotency: "request-1") }
  end

  test "stale unknown action forged source and denied resource have no effects" do
    surface = present_card
    assert_error("NOT_ALLOWED") { act(surface, key: "admin") }
    assert_error("UNKNOWN_ACTION") { ToolViews.dispatch(surface.id, scope: scope, action: "eval", arguments: {}, base_revision: 1, idempotency_key: "x") }
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
      assert_error("NOT_FOUND") { ToolViews.restore(surface.id, scope: other) }
      assert_error("NOT_FOUND") { ToolViews.dispatch(surface.id, scope: other, action: "select_option", arguments: { key: "compare" }, base_revision: 1, idempotency_key: "x") }
    end
    ToolViews.reset!
    register_card(policy: ->(_access) { false })
    assert_error("NOT_ALLOWED") { ToolViews.restore(surface.id, scope: scope) }
    assert_equal 0, DemoEffect.count
  end

  test "contract changes fail recoverably" do
    surface = present_card
    ToolViews.reset!
    assert_error("INCOMPATIBLE_COMPONENT") { ToolViews.restore(surface.id, scope: scope) }
    register_card
    component = ToolViews.registry.fetch(:choice_card)
    surface.update!(component_digest: "old")
    assert_error("INCOMPATIBLE_COMPONENT") { ToolViews.restore(surface.id, scope: scope) }
    assert_equal 1, ToolViews::Surface.count
    assert_match /sha256:/, component.digest
  end

  test "model proposed options cannot expand trusted host business permissions" do
    malicious = ToolViews.present(:choice_card, props: props.merge(options: [{ key: "admin", label: "Privileged option" }]), scope: scope)
    assert_error("NOT_ALLOWED") { act(malicious, key: "admin") }
    assert_equal 0, DemoEffect.count
    assert_equal 1, malicious.reload.revision
  end

  test "an action with no host policy denies a valid payload" do
    ToolViews.register(:deny_action, description: "Default deny", schema: PROPS_SCHEMA, partial: "choices/card", policy: ->(_access) { true },
      actions: { select_option: { schema: PARAMS_SCHEMA, handler: ->(_access) { flunk "handler ran without permission" } } })
    surface = ToolViews.present(:deny_action, props: props, scope: scope)
    assert_error("NOT_ALLOWED") { ToolViews.dispatch(surface.id, scope: scope, action: "select_option", arguments: { key: "compare" }, base_revision: 1, idempotency_key: "denied") }
    assert_equal 1, surface.reload.revision
    assert_equal 0, ToolViews::ActionExecution.count
  end

  test "handler failure rolls back host data surface and receipt" do
    ToolViews.reset!
    register_card do |access|
      DemoEffect.create!(surface_id: access.surface.id, value: "rolled back")
      raise ToolViews::Error.new("DOMAIN_REJECTED", status: 422)
    end
    surface = present_card
    assert_error("DOMAIN_REJECTED") { act(surface) }
    assert_equal 1, surface.reload.revision
    assert_equal 0, DemoEffect.count
    assert_equal 0, ToolViews::ActionExecution.count
  end

  test "a database rollback of the action is a retryable conflict with nothing committed" do
    [ActiveRecord::Deadlocked, ActiveRecord::SerializationFailure, ActiveRecord::LockWaitTimeout].each do |rollback|
      ToolViews.reset!
      attempts = 0
      register_card do |access|
        DemoEffect.create!(surface_id: access.surface.id, value: "rolled back")
        raise rollback, "simulated by the database" if (attempts += 1) == 1
        ToolViews::Transition.new(state: { selected: access.arguments.fetch("key") })
      end
      surface = present_card
      assert_error("CONFLICT") { act(surface, idempotency: "retry-me") }
      assert_equal [1, 0, 0], [surface.reload.revision, DemoEffect.where(surface_id: surface.id).count, ToolViews::ActionExecution.where(surface_id: surface.id).count]
      assert_equal 2, act(surface, idempotency: "retry-me")[:revision]
      assert_equal 1, DemoEffect.where(surface_id: surface.id).count
    end
  end

  test "correlation is durable and isolated by actor tenant adapter and context" do
    correlation = { adapter: "test", call_id: "call-1", context: "chat-1" }
    first = present_card(correlation: correlation)
    second = present_card(correlation: correlation)
    assert_equal first.id, second.id
    assert_equal 1, ToolViews::Surface.count
    assert_error("IDEMPOTENCY_CONFLICT") { ToolViews.present(:choice_card, props: props.merge(title: "Different"), scope: scope, correlation: correlation) }
    assert_not_equal first.id, present_card(correlation: correlation.merge(context: "chat-2")).id
    assert_not_equal first.id, present_card(correlation: correlation.merge(adapter: "other")).id
  end

  test "configured per-surface action budget limits new mutations while allowing replay" do
    ToolViews.configuration.max_actions_per_minute = 1
    surface = present_card
    result = act(surface, idempotency: "first")
    assert_equal result, act(surface, revision: 1, idempotency: "first")
    assert_error("RATE_LIMITED") { act(surface, revision: 2) }
    assert_equal 1, DemoEffect.count
    assert_equal 2, surface.reload.revision
  end

  test "no continuation adapter still commits selection" do
    ToolViews.reset!; register_card(agent: true)
    surface = present_card
    result = act(surface)
    assert_equal "completed", result[:status]
    assert_equal "skipped", ToolViews::AgentInteraction.first.status
    assert_equal 2, surface.reload.revision
  end
end
