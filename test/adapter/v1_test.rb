# frozen_string_literal: true
require_relative "../test_helper"
require "tool_views/adapters/ruby_llm"
require_relative "../../examples/tickets_query_tool"
class V1AdapterTest < ActiveSupport::TestCase
  setup do
    DemoV1::Seeds.call
    DemoV1::Registration.call
  end
  test "real SDK scoped query and presentation use safe host references without privileged mutations" do
    scope = DemoV1::Access.scope_for(DemoStaff.find_by!(code: "north-agent"))
    query = DemoTicketsQueryTool.new(scope: scope)
    results = query.call(query: "Billing").fetch(:tickets)
    assert_equal 1, results.length
    assert_equal %w[id status subject], results.first.keys.sort
    props = { "ticket_id" => results.first.fetch("id") }
    presenter = ToolViews::Adapters::RubyLLM::PresentUI.new(keys: %i[ticket_card customer_form result_review], scope: scope, context: "v1-chat")
    assert_equal %w[ticket_card result_review], presenter.parameters_schema.fetch("properties").fetch("component").fetch("enum")
    call = RubyLLM::ToolCall.new(id: "v1-present", name: "present_ui", arguments: { "component" => "ticket_card", "props" => props })
    result = presenter.call(tool_call: call, **call.arguments)
    assert_equal "presented", result[:status]
    assert_equal props, ToolViews.restore(result.fetch(:surface_id), scope: scope).props
    assert_equal result, presenter.call(tool_call: call, **call.arguments)
    assert_equal 0, DemoReply.count
    assert_equal 0, DemoOutboundReply.count
    foreign = DemoTicket.find_by!(code: "south-ticket")
    call = RubyLLM::ToolCall.new(id: "v1-foreign", name: "present_ui", arguments: { "component" => "ticket_card", "props" => { "ticket_id" => foreign.id.to_s } })
    assert_equal "NOT_ALLOWED", presenter.call(tool_call: call, **call.arguments)[:code]
    assert_equal 1, ToolViews::Surface.count
  end
end
