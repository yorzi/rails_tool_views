# frozen_string_literal: true
require_relative "../test_helper"
require "rails_tool_views/adapters/ruby_llm"

# The demo's agent chat runs RubyLLM's real loop; only the network is scripted.
class DemoAgentTest < ActionDispatch::IntegrationTest
  setup { DemoSetup.call }

  def requests
    log = []
    reply = DemoLLM::Script.method(:reply)
    DemoLLM::Script.stub(:reply, ->(request) { log << request; reply.call(request) }) { yield }
    log
  end

  def choose(surface, key, revision: surface.reload.revision)
    post "/rails_tool_views/surfaces/#{surface.id}/actions", headers: { "Referer" => "http://www.example.com/agent" },
      params: { action_name: "select_option", arguments: { key: key }, base_revision: revision,
        idempotency_key: SecureRandom.uuid, source_component: "choice_card" }
  end

  def roles(conversation)
    conversation.messages.reload.map(&:role)
  end

  test "a model presents a trusted view and continues from the user's choice" do
    get "/agent"
    assert_response :success
    sent = requests { post "/agent/messages", params: { message: "Help me choose the next step" } }
    assert_redirected_to "/agent"
    tool = sent.first.fetch("tools").sole.fetch("function")
    assert_equal "present_ui", tool.fetch("name")
    assert_equal ["choice_card"], tool.dig("parameters", "properties", "component", "enum")
    assert_not tool.fetch("parameters").key?("strict"), "PresentUI's schema is sent as declared"
    conversation = DemoConversation.sole
    assert_equal %w[user assistant tool assistant], roles(conversation)
    surface = RailsToolViews::Surface.sole
    assert_equal conversation.context_ref, surface.context_ref
    assert_equal({ "adapter" => "ruby_llm", "call_id" => "call_demo_2" }, RailsToolViews::Presentation.sole.slice(:adapter, :call_id))
    get "/agent"
    assert_includes response.body, surface.dom_id
    choose(surface, "compare")
    assert_redirected_to "http://www.example.com/agent"
    interaction = RailsToolViews::AgentInteraction.sole
    assert_equal "completed", interaction.status
    assert DemoAgentReceipt.exists?(delivery_key: interaction.delivery_key)
    assert_equal %w[user assistant tool assistant user assistant], roles(conversation)
    assert_equal "compare", conversation.messages[-2].continuation.dig("values", "key")
    assert_equal DemoLLM::REPLIES.fetch("compare"), conversation.messages.last.content
    get "/agent"
    assert_includes response.body, "Selection saved: compare."
    assert_includes response.body, ERB::Util.html_escape(DemoLLM::REPLIES.fetch("compare"))
  end

  test "a repeated delivery adds no second reply" do
    post "/agent/messages", params: { message: "Help me choose" }
    choose(RailsToolViews::Surface.sole, "continue")
    interaction = RailsToolViews::AgentInteraction.sole
    conversation = DemoConversation.sole
    assert_no_difference -> { conversation.messages.count } do
      DemoLLM.deliver(interaction.payload, delivery_key: interaction.delivery_key)
    end
  end

  test "an option the model invented is shown but cannot be chosen" do
    post "/agent/messages", params: { message: "Help me choose" }
    conversation = DemoConversation.sole
    scope = conversation.scope
    tool = RailsToolViews::Adapters::RubyLLM::PresentUI.new(keys: [:choice_card], scope: scope, context: conversation.context_ref)
    call = RubyLLM::ToolCall.new(id: "call_invented", name: "present_ui", arguments: { "component" => "choice_card",
      "props" => { "title" => "Pick", "options" => [{ "key" => "drop_tables", "label" => "Drop every table" }] } })
    surface = RailsToolViews.restore(tool.call(tool_call: call, **call.arguments.symbolize_keys).fetch(:surface_id), scope: scope)
    choose(surface, "drop_tables")
    assert_response :forbidden
    assert_equal 1, surface.reload.revision
    assert_equal 0, RailsToolViews::AgentInteraction.count
  end

  test "a follow-up never reaches a conversation the Surface's owner does not own" do
    other = DemoConversation.create!(actor_ref: "demo:someone-else", tenant_ref: "local-demo")
    get "/agent"
    scope = RailsToolViews.configuration.scope_resolver.call(Struct.new(:session).new(session))
    surface = RailsToolViews.present(:choice_card, props: { title: "Pick", options: [{ key: "compare", label: "Compare" }] },
      scope: scope, context: other.context_ref)
    choose(surface, "compare")
    assert_equal "Selection saved: compare.", surface.reload.state["message"]
    interaction = RailsToolViews::AgentInteraction.sole
    assert_equal %w[failed AGENT_UNAVAILABLE], [interaction.status, interaction.error_code]
    assert_empty other.messages
    assert_equal 0, DemoAgentReceipt.count
  end

  test "a failed model turn stores nothing and reports the failure" do
    get "/agent"
    DemoLLM::Script.stub(:reply, ->(_request) { raise RubyLLM::UnauthorizedError, "offline failure" }) do
      post "/agent/messages", params: { message: "Help me choose" }
    end
    assert_redirected_to "/agent"
    assert_match "The model request failed", flash[:alert]
    assert_empty DemoConversation.sole.messages
    assert_equal 0, RailsToolViews::Surface.count
  end
end
