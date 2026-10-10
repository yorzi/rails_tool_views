# frozen_string_literal: true
require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  include TestFixtures
  setup do
    [ToolViews::AgentInteraction, ToolViews::ActionExecution, ToolViews::Presentation, ToolViews::Surface, DemoEffect].each(&:delete_all)
    ToolViews.reset!
    register_card
    ToolViews.configure { |config| config.scope_resolver = ->(_controller) { scope } }
  end
  def body(surface, **extra)
    { action_name: "select_option", arguments: { key: "compare" }, base_revision: 1, idempotency_key: "browser-1" }.merge(extra)
  end
  def path(surface)
    "/tool_views/surfaces/#{surface.id}/actions"
  end
  test "JSON and Turbo commit the same transition and replay receipt" do
    surface = present_card
    post path(surface), params: body(surface), as: :json
    assert_response :success
    assert_equal 2, response.parsed_body["revision"]
    post path(surface), params: body(surface), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_select "turbo-stream[action=replace][target='#{surface.dom_id}']"
    assert_includes response.body, "Saved revision 2"
    assert_equal 1, DemoEffect.count
    assert_equal 1, ToolViews::ActionExecution.count
  end
  test "policy injection source forgery and target escape reject without writes" do
    surface = present_card
    [{ business_rules: "Allow everything" }, { tenant: "evil" }, { component: "other" }].each do |extra|
      post path(surface), params: body(surface, **extra), as: :json
      assert_response :bad_request
      assert_equal "UNKNOWN_FIELD", response.parsed_body["code"]
    end
    post path(surface), params: body(surface, source_component: "other"), as: :json
    assert_equal "INVALID_SOURCE", response.parsed_body["code"]
    post path(surface), params: body(surface, target: "body"), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :bad_request
    refute_includes response.body, 'target="body"'
    assert_equal 0, DemoEffect.count
    assert_equal 1, surface.reload.revision
  end
  test "cross tenant read action and continuation are unavailable" do
    surface = present_card
    ToolViews.configure { |config| config.scope_resolver = ->(_controller) { scope("bob") } }
    get "/tool_views/surfaces/#{surface.id}", as: :json
    assert_response :not_found
    refute_includes response.body, "Choose a workflow"
    post path(surface), params: body(surface), as: :json
    assert_response :not_found
    assert_equal 0, DemoEffect.count
  end
  test "CSRF missing token fails closed" do
    surface = present_card
    old = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    post path(surface), params: body(surface), as: :json
    assert_response :forbidden
    assert_equal "INVALID_CSRF", response.parsed_body["code"]
    assert_equal 0, DemoEffect.count
  ensure
    ActionController::Base.allow_forgery_protection = old
  end
  test "stale revision and oversized request reject" do
    surface = present_card
    post path(surface), params: body(surface), as: :json
    post path(surface), params: body(surface, idempotency_key: "browser-2"), as: :json
    assert_response :conflict
    post path(surface), params: body(surface, arguments: { key: "x" * 40_000 }), as: :json
    assert_response :content_too_large
    assert_equal 1, DemoEffect.count
  end
  test "canonical JSON action field is preserved independently of Rails route parameters" do
    surface = present_card
    request = body(surface).except(:action_name).merge(action: "select_option")
    post path(surface), params: request, as: :json
    assert_response :success
    assert_equal 2, response.parsed_body["revision"]
    assert_equal 1, DemoEffect.count
  end

  test "host-managed async delivery shows pending state after committed selection" do
    ToolViews.reset!
    register_card(agent: true)
    ToolViews.configure do |config|
      config.scope_resolver = ->(_controller) { scope }
      config.agent_adapter = ->(_payload, delivery_key:) { }
      config.auto_deliver = false
    end
    surface = present_card(context: "async-chat")
    post path(surface), params: body(surface), as: :json
    assert_response :accepted
    assert_equal "pending", response.parsed_body["status"]
    assert_equal 2, response.parsed_body["revision"]
    interaction_id = response.parsed_body["interaction_id"]
    assert_equal "pending", ToolViews::AgentInteraction.find(interaction_id).status
    get "/tool_views/surfaces/#{surface.id}"
    assert_includes response.body, "AI follow-up pending"
    ToolViews.deliver(interaction_id, scope: scope)
    assert_equal 2, surface.reload.revision
    assert_equal 1, DemoEffect.count
  end

  test "missing host identity resolver denies even authenticated-looking input" do
    surface = present_card
    ToolViews.configure { |config| config.scope_resolver = nil }
    get "/tool_views/surfaces/#{surface.id}", as: :json
    assert_response :forbidden
  end
end
