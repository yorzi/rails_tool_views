# frozen_string_literal: true
require_relative "test_helper"

class ContinuationTest < ActiveSupport::TestCase
  test "structured delivery happens after commit once and contains no HTML or actor data" do
    ToolViews.reset!; register_card(agent: true)
    received = []
    ToolViews.configure { |config| config.agent_adapter = ->(payload, delivery_key:) {
      assert_equal 2, ToolViews::Surface.find(payload.fetch("surface_id")).revision
      assert_equal 1, DemoEffect.count
      received << [payload, delivery_key]
    } }
    surface = present_card(context: "chat-1")
    result = act(surface)
    interaction = ToolViews.deliver(result.fetch(:interaction_id), scope: scope)
    assert_equal "completed", interaction.status
    ToolViews.deliver(interaction.id, scope: scope)
    assert_equal 1, received.length
    assert_equal %w[action context_ref revision surface_id type values], received.first.first.keys.sort
    assert_equal({ "key" => "compare" }, received.first.first["values"])
    assert received.first.first.frozen?
    assert_equal "chat-1", received.first.first["context_ref"]
    assert_error("NOT_FOUND") { ToolViews.deliver(interaction.id, scope: scope("bob")) }
  end
  test "provider failure preserves action and explicit retry uses same delivery key" do
    ToolViews.reset!; register_card(agent: true)
    keys = []
    ToolViews.configure { |config| config.agent_adapter = ->(_payload, delivery_key:) { keys << delivery_key; raise "provider unavailable with secret context" } }
    surface = present_card
    interaction_id = act(surface).fetch(:interaction_id)
    assert_equal "failed", ToolViews.deliver(interaction_id, scope: scope).status
    ToolViews.deliver(interaction_id, scope: scope)
    assert_equal 1, keys.length
    ToolViews.configure { |config| config.agent_adapter = ->(_payload, delivery_key:) { keys << delivery_key } }
    assert_equal "completed", ToolViews.deliver(interaction_id, scope: scope, retry_failed: true).status
    assert_equal 1, keys.uniq.length
    assert_equal 2, surface.reload.revision
    assert_equal "compare", surface.state["selected"]
    assert_equal 1, DemoEffect.count
  end
  test "continuation retry recomputes the host action permission" do
    ToolViews.reset!; register_card(agent: true)
    ToolViews.configuration.agent_adapter = ->(_payload, delivery_key:) { flunk "revoked action was delivered" }
    surface = present_card
    interaction_id = act(surface).fetch(:interaction_id)
    surface.reload.update!(props: props.merge(options: []))
    assert_error("NOT_ALLOWED") { ToolViews.deliver(interaction_id, scope: scope) }
    assert_equal "pending", ToolViews::AgentInteraction.find(interaction_id).status
  end

  test "active delivery lease cannot be forwarded twice and expired lease is recoverable" do
    ToolViews.reset!; register_card(agent: true)
    count = 0
    ToolViews.configure { |config| config.agent_adapter = ->(_payload, delivery_key:) { count += 1 } }
    surface = present_card
    interaction = ToolViews::AgentInteraction.find(act(surface).fetch(:interaction_id))
    interaction.update!(status: "delivering", claimed_at: Time.current)
    assert_equal "delivering", ToolViews.deliver(interaction.id, scope: scope).status
    assert_equal 0, count
    interaction.update!(claimed_at: 6.minutes.ago)
    assert_equal "completed", ToolViews.deliver(interaction.id, scope: scope).status
    assert_equal 1, count
  end
end
