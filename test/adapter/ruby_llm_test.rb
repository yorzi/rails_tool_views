# frozen_string_literal: true
require_relative "../test_helper"
require "tool_views/adapters/ruby_llm"

class RubyLLMAdapterTest < ActiveSupport::TestCase
  def tool(context = "chat-1", **options)
    ToolViews::Adapters::RubyLLM::PresentUI.new(keys: [:choice_card], scope: scope, context: context, **options)
  end
  def tool_call(id = "call-1", component: "choice_card", properties: props)
    RubyLLM::ToolCall.new(id: id, name: "present_ui", arguments: { "component" => component, "props" => properties })
  end
  def chat
    RubyLLM.context { |config| config.openai_api_key = "offline-test-fixture" }.chat(model: "gpt-4.1-mini", provider: :openai, assume_model_exists: true)
  end
  test "actual RubyLLM Chat loop preserves call history and explicit UI reference" do
    presenter = tool
    conversation = chat.with_tools(presenter)
    call = tool_call
    responses = [RubyLLM::Message.new(role: :assistant, content: nil, tool_calls: { call.id => call }),
      RubyLLM::Message.new(role: :assistant, content: "Choose a workflow in the card.")]
    conversation.provider.stub(:complete, ->(*_args, **_options) { responses.shift }) do
      result = conversation.ask("Help me choose")
      assert_equal "Choose a workflow in the card.", result.content
    end
    assert_equal [:user, :assistant, :tool, :assistant], conversation.messages.map(&:role)
    tool_result = conversation.messages.find { |message| message.role == :tool }
    assert_equal call.id, tool_result.tool_call_id
    acknowledgment = JSON.parse(tool_result.content)
    assert_equal %w[revision status surface_id], acknowledgment.keys.sort
    assert_equal acknowledgment["surface_id"], presenter.references.first[:surface_id]
    assert_equal 1, ToolViews::Surface.count
    assert_equal 1, acknowledgment["revision"]
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.response = ActionDispatch::TestResponse.new
    surface = ToolViews.restore(presenter.references.first.fetch(:surface_id), scope: scope)
    html = ToolViews.render(surface, view_context: controller.view_context, scope: scope)
    assert_includes html, surface.dom_id
    assert_includes html, "Choose a workflow"
    assert_equal 1, html.scan(/<section /).length
  end
  test "tool retry returns original receipt even after user acts" do
    presenter = tool
    call = tool_call
    original = presenter.call(tool_call: call, **call.arguments)
    surface = ToolViews.restore(original.fetch(:surface_id), scope: scope)
    act(surface)
    assert_equal original, presenter.call(tool_call: call, **call.arguments)
    assert_equal 1, ToolViews::Surface.count
    assert_equal 1, presenter.references.length
    assert_not_equal surface.id, tool("chat-2").call(tool_call: call, **call.arguments)[:surface_id]
  end
  test "invalid or uncorrelated tool arguments do not persist" do
    presenter = tool
    assert_equal "MISSING_TOOL_CALL", presenter.call(component: "choice_card", props: props)[:code]
    call = tool_call(component: "admin")
    assert_equal "NOT_ALLOWED", presenter.call(tool_call: call, **call.arguments)[:code]
    call = tool_call(properties: props.merge("owner" => "admin"))
    assert_equal "INVALID_PROPS", presenter.call(tool_call: call, **call.arguments)[:code]
    assert_equal 0, ToolViews::Surface.count
    assert_empty presenter.references
  end
  test "catalog schemas stay bounded at 1 5 and 20 components" do
    [1, 5, 20].each do |size|
      ToolViews.reset!
      size.times { |index| register_card("card_#{index}") }
      presenter = ToolViews::Adapters::RubyLLM::PresentUI.new(keys: size.times.map { |index| "card_#{index}" }, scope: scope, context: "measure")
      assert_equal size, presenter.parameters_schema.fetch("properties").fetch("component").fetch("enum").length
      assert JSONSchemer.schema(presenter.parameters_schema).valid?({ "component" => "card_0", "props" => DataForSchema.stringify(props) })
    end
    assert_error("CATALOG_TOO_LARGE") { ToolViews::Adapters::RubyLLM::PresentUI.new(keys: 21.times.map { |index| "card_#{index}" }, scope: scope, context: "measure") }
  end
  test "continuation starts a supported new user turn and refuses pending tools" do
    conversation = chat
    call = tool_call
    conversation.add_message(role: :assistant, content: nil, tool_calls: { call.id => call })
    delivery = ->(_key, &block) { block.call }
    adapter = ToolViews::Adapters::RubyLLM::Continuation.new(chat_resolver: ->(_context) { conversation }, delivery: delivery)
    payload = { "context_ref" => "chat-1", "type" => "agent_interaction", "values" => { "key" => "compare" } }
    assert_raises(RubyLLM::PendingToolCallsError) { adapter.call(payload, delivery_key: "delivery-1") }
    assert_equal [:assistant], conversation.messages.map(&:role)
    conversation.with_tools(tool).run_tools
    response = RubyLLM::Message.new(role: :assistant, content: "Selection received.")
    conversation.provider.stub(:complete, response) { adapter.call(payload, delivery_key: "delivery-1") }
    assert_equal [:assistant, :tool, :user, :assistant], conversation.messages.map(&:role)
    assert_equal payload, JSON.parse(conversation.messages[-2].content)
  end
  module DataForSchema
    def self.stringify(value)
      ToolViews::Data.normalize(value)
    end
  end
end
