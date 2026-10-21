# frozen_string_literal: true
require_relative "test_helper"

class HtmlPageTest < ActionDispatch::IntegrationTest
  include TestFixtures
  setup do
    [RailsToolViews::AgentInteraction, RailsToolViews::ActionExecution, RailsToolViews::Presentation, RailsToolViews::Surface, DemoEffect].each(&:delete_all)
    RailsToolViews.reset!
    register_card
    RailsToolViews.configure { |config| config.scope_resolver = ->(_controller) { scope } }
  end

  def surface_path(surface)
    "/rails_tool_views/surfaces/#{surface.id}"
  end

  def arguments(revision: 1, key: SecureRandom.uuid)
    { action_name: "select_option", arguments: { key: "compare" }, base_revision: revision, idempotency_key: key }
  end

  def assert_page
    assert_match(/<!doctype html>/i, response.body)
    assert_select "html[lang] head title", count: 1
    assert_select 'meta[name=viewport]', count: 1
    assert_select "main h1", count: 1
  end

  test "direct HTML read is a complete page and embedded rendering remains a fragment" do
    surface = present_card
    get surface_path(surface)
    assert_response :ok
    assert_page
    assert_select "form[action='#{surface_path(surface)}/actions']"
    fragment = RailsToolViews.render(surface, view_context: ApplicationController.new.view_context, scope: scope)
    refute_match(/<!doctype/i, fragment)
  end

  test "the complete page style carries the host's CSP nonce" do
    surface = present_card
    policy = ActionDispatch::ContentSecurityPolicy.new { |content| content.style_src :self }
    config = Rails.application.env_config.merge("action_dispatch.content_security_policy" => policy,
      "action_dispatch.content_security_policy_nonce_generator" => ->(_request) { "page-nonce" },
      "action_dispatch.content_security_policy_nonce_directives" => %w[style-src])
    Rails.application.stub(:env_config, config) { get surface_path(surface) }
    assert_response :ok
    assert_includes response.headers["Content-Security-Policy"], "'nonce-page-nonce'"
    assert_select "head style[nonce=page-nonce]", count: 1
    get surface_path(surface)
    assert_select "head style", count: 1
    assert_select "head style[nonce]", count: 0
  end

  test "conflict keeps current authorized form and safe reload link then corrects without a POST redirect loop" do
    surface = present_card
    post "#{surface_path(surface)}/actions", params: arguments
    assert_response :see_other
    post "#{surface_path(surface)}/actions", params: arguments
    assert_response :conflict
    assert_page
    assert_select 'input[name=base_revision][value="2"]'
    assert_select "a[href='#{surface_path(surface)}']", text: "Reload saved view"
    post "#{surface_path(surface)}/actions", params: arguments(revision: 2), headers: { "Referer" => "http://www.example.com#{surface_path(surface)}/actions" }
    assert_response :see_other
    assert_equal "http://www.example.com#{surface_path(surface)}", response.location
    follow_redirect!
    assert_page
    assert_equal 2, DemoEffect.count
  end

  test "unavailable and forbidden HTML pages contain no component data or correction link" do
    surface = present_card
    RailsToolViews.configure { |config| config.scope_resolver = ->(_controller) { scope("other") } }
    get surface_path(surface)
    assert_response :not_found
    assert_page
    refute_includes response.body, props[:title]
    assert_select "form", count: 0
    assert_select "a", count: 0
    RailsToolViews.configure { |config| config.scope_resolver = nil }
    post "#{surface_path(surface)}/actions", params: arguments
    assert_response :forbidden
    assert_page
    refute_includes response.body, props[:title]
    assert_select "form", count: 0
    assert_equal 0, DemoEffect.count
  end

  test "full HTML validation retains escaped fields and their accessible descriptions" do
    DemoV1::Seeds.call
    DemoV1::Registration.call
    actor = DemoV1::Access.scope_for(DemoStaff.find_by!(code: "north-lead"))
    RailsToolViews.configure { |config| config.scope_resolver = ->(_controller) { actor } }
    surface = RailsToolViews.present(:customer_form, props: { values: { name: "Draft", email: "draft@example.test" } }, scope: actor)
    post "#{surface_path(surface)}/actions", params: { action_name: "submit_form", arguments: { name: '<script>alert("x")</script>', email: "invalid" }, base_revision: 1, idempotency_key: "invalid-html" }
    assert_response :unprocessable_content
    assert_page
    assert_select 'input[name="arguments[name]"]' do |inputs|
      assert_equal '<script>alert("x")</script>', inputs.first["value"]
    end
    assert_select 'input[aria-invalid=true][aria-describedby]'
    refute_includes response.body, '<script>alert("x")</script>'
    assert_equal 1, surface.reload.revision
  end
  test "HTML CSRF rejection is a full page without a committed action" do
    surface = present_card
    old = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    post "#{surface_path(surface)}/actions", params: arguments
    assert_response :forbidden
    assert_page
    assert_select 'input[name=authenticity_token]'
    assert_equal 0, DemoEffect.count
  ensure
    ActionController::Base.allow_forgery_protection = old
  end

  test "a closed view is readable without actionable forms and new HTTP actions return gone" do
    surface = present_card
    RailsToolViews.close(surface.id, scope: scope)
    get surface_path(surface)
    assert_response :ok
    assert_page
    assert_select "h2", text: "View closed."
    assert_select "form", count: 0
    post "#{surface_path(surface)}/actions", params: arguments(revision: 2), as: :json
    assert_response :gone
    assert_equal "SURFACE_CLOSED", response.parsed_body["code"]
    assert_equal 0, DemoEffect.count
  end

end
