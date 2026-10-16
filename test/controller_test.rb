# frozen_string_literal: true
require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  include TestFixtures
  setup do
    [RailsToolViews::AgentInteraction, RailsToolViews::ActionExecution, RailsToolViews::Presentation, RailsToolViews::Surface, DemoEffect].each(&:delete_all)
    RailsToolViews.reset!
    register_card
    RailsToolViews.configure { |config| config.scope_resolver = ->(_controller) { scope } }
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
    assert_equal 1, RailsToolViews::ActionExecution.count
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
    RailsToolViews.configure { |config| config.scope_resolver = ->(_controller) { scope("bob") } }
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
    RailsToolViews.reset!
    register_card(agent: true)
    RailsToolViews.configure do |config|
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
    assert_equal "pending", RailsToolViews::AgentInteraction.find(interaction_id).status
    get "/tool_views/surfaces/#{surface.id}"
    assert_includes response.body, "AI follow-up pending"
    RailsToolViews.deliver(interaction_id, scope: scope)
    assert_equal 2, surface.reload.revision
    assert_equal 1, DemoEffect.count
  end

  test "a native form for a zero-argument action posts no arguments field and still commits" do
    RailsToolViews.register(:toggle_card, description: "Open details", schema: PROPS_SCHEMA, partial: "choices/card", policy: ->(access) { access.actor == "alice" },
      actions: { open: { schema: { type: "object", additionalProperties: false, properties: {} }, policy: ->(access) { access.actor == "alice" },
        handler: ->(_access) { RailsToolViews::Transition.new(state: { message: "Details opened." }) } } })
    surface = RailsToolViews.present(:toggle_card, props: props, scope: scope)
    post path(surface), params: { action_name: "open", base_revision: 1, idempotency_key: "form-open" }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_includes response.body, "Details opened."
    assert_equal 2, surface.reload.revision
    required = present_card
    post path(required), params: { action_name: "select_option", base_revision: 1, idempotency_key: "form-missing" }, as: :json
    assert_response :bad_request
    assert_equal "INVALID_ARGUMENTS", response.parsed_body["code"]
    post path(surface), params: { action: "open", arguments: nil, base_revision: 2, idempotency_key: "json-null" }, as: :json
    assert_equal "INVALID_ARGUMENTS", response.parsed_body["code"]
    assert_equal 0, DemoEffect.count
  end

  test "Rails submit helper names are accepted while other unknown fields still reject" do
    RailsToolViews.register(:interactive_vc, description: "Interactive", schema: PROPS_SCHEMA, component: DemoChoiceComponent, policy: ->(access) { access.actor == "alice" },
      actions: { select_option: { schema: PARAMS_SCHEMA, policy: ->(access) { access.actor == "alice" },
        handler: ->(access) { RailsToolViews::Transition.new(state: { selected: access.arguments.fetch("key"), message: "Saved by a ViewComponent." }) } } })
    surface = RailsToolViews.present(:interactive_vc, props: props, scope: scope)
    get "/tool_views/surfaces/#{surface.id}"
    form = Nokogiri::HTML(response.body).at_css("form")
    assert_equal "commit", form.at_css("input[type=submit]")["name"]
    fields = form.css("input[type=hidden]").to_h { |input| [input["name"], input["value"]] }
    post form["action"], params: fields.merge("arguments[key]" => "continue", "commit" => "Save selection"), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_includes response.body, "Saved by a ViewComponent."
    assert_equal "continue", surface.reload.state["selected"]
    card = present_card
    post path(card), params: body(card, button: ""), as: :json
    assert_response :success
    post path(card), params: body(card, idempotency_key: "browser-2", base_revision: 2, commit: "Save", policy: "allow"), as: :json
    assert_equal "UNKNOWN_FIELD", response.parsed_body["code"]
    assert_equal 2, card.reload.revision
  end

  test "without Turbo a committed HTML action returns to the page that embeds the Surface" do
    html = { "Accept" => "text/html" }
    surface = present_card
    post path(surface), params: body(surface), headers: html.merge("Referer" => "http://www.example.com/v1/support?ticket_id=1")
    assert_response :see_other
    assert_equal "http://www.example.com/v1/support?ticket_id=1", response.headers["Location"]
    post path(surface), params: body(surface, idempotency_key: "browser-2", base_revision: 2), headers: html
    assert_equal "http://www.example.com/tool_views/surfaces/#{surface.id}", response.headers["Location"]
    post path(surface), params: body(surface, idempotency_key: "browser-3", base_revision: 3), headers: html.merge("Referer" => "https://elsewhere.example/phish")
    assert_response :see_other
    assert_equal "http://www.example.com/tool_views/surfaces/#{surface.id}", response.headers["Location"]
    assert_equal 4, surface.reload.revision
  end

  test "missing host identity resolver denies even authenticated-looking input" do
    surface = present_card
    RailsToolViews.configure { |config| config.scope_resolver = nil }
    get "/tool_views/surfaces/#{surface.id}", as: :json
    assert_response :forbidden
  end
end
