# frozen_string_literal: true
require_relative "test_helper"
class V1ControllerTest < ActionDispatch::IntegrationTest
  setup do
    DemoV1::Seeds.call
    DemoV1::Registration.call
    RailsToolViews.configuration.scope_resolver = DemoV1::Session.method(:scope)
    RailsToolViews.configuration.agent_adapter = DemoV1::Agent.new
  end
  def surface
    RailsToolViews::Surface.order(:created_at).last
  end
  def payload(action, arguments, key = SecureRandom.uuid)
    { action: action, arguments: arguments, base_revision: surface.reload.revision, idempotency_key: key }
  end
  test "JSON Turbo and HTML validation retain approved submitted input without committing" do
    get "/v1/customer"
    assert_response :success
    assert_includes response.body, "Review proposed customer"
    assert_includes response.body, "Create customer"
    id = surface.id
    args = { name: "Human corrected name", email: "not-an-email" }
    post "/tool_views/surfaces/#{id}/actions", params: payload("submit_form", args), as: :json
    assert_response :unprocessable_entity
    assert_equal "VALIDATION_FAILED", response.parsed_body["code"]
    assert_equal args.transform_keys(&:to_s), response.parsed_body["values"]
    post "/tool_views/surfaces/#{id}/actions", params: payload("submit_form", args).except(:action).merge(action_name: "submit_form"), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :unprocessable_entity
    assert_includes response.body, 'aria-invalid="true"'
    assert_includes response.body, 'value="not-an-email"'
    assert_includes response.body, 'value="Human corrected name"'
    assert_includes response.body, "#{surface.dom_id}_email_error"
    assert_includes response.body, "#{surface.dom_id}_error"
    post "/tool_views/surfaces/#{id}/actions", params: payload("submit_form", args).except(:action).merge(action_name: "submit_form")
    assert_response :unprocessable_entity
    assert_includes response.body, "Create customer"
    assert_equal 1, surface.reload.revision
    assert_equal 2, DemoCustomer.count
    post "/tool_views/surfaces/#{id}/actions", params: payload("submit_form", { name: "Human corrected name", email: "corrected@example.test" }), as: :json
    assert_response :success
    assert_equal 3, DemoCustomer.count
    get "/v1/customer"
    assert_includes response.body, "Human corrected name"
    refute_includes response.body, "Create customer</button>"
  end
  test "actual session role and tenant changes deny old surfaces and unscoped ticket IDs" do
    get "/v1/support", params: { ticket_id: DemoTicket.find_by!(code: "north-ticket").id }
    assert_response :success
    original = surface
    post "/v1/identity", params: { code: "north-agent" }
    get "/tool_views/surfaces/#{original.id}", as: :json
    assert_response :not_found
    get "/v1/support", params: { ticket_id: DemoTicket.find_by!(code: "north-ticket").id }
    assert_response :success
    refute_includes response.body, ">Assign ticket</button>"
    id = surface.id
    post "/tool_views/surfaces/#{id}/actions", params: payload("assign_ticket", { assignee_id: DemoStaff.find_by!(code: "north-agent").id.to_s, ticket_version: "0" }), as: :json
    assert_response :forbidden
    post "/v1/identity", params: { code: "south-lead" }
    get "/v1/support", params: { ticket_id: DemoTicket.find_by!(code: "north-ticket").id }
    assert_response :forbidden
    refute_includes response.body, "North Workshop"
  end
  test "ticket workflow renders draft review and local queue from committed domain data" do
    get "/v1/support", params: { ticket_id: DemoTicket.find_by!(code: "north-ticket").id }
    id = surface.id
    post "/tool_views/surfaces/#{id}/actions", params: payload("draft_reply", { reply_version: "0" }), as: :json
    assert_response :success
    assert_equal "completed", response.parsed_body["agent_status"]
    get "/tool_views/surfaces/#{id}"
    assert_includes response.body, "Reply to review"
    assert_includes response.body, "Hello North Workshop"
    reply = DemoReply.first
    post "/tool_views/surfaces/#{id}/actions", params: payload("review_reply", { body: "Reviewed & approved.", reply_version: reply.lock_version.to_s }), as: :json
    get "/tool_views/surfaces/#{id}"
    assert_includes response.body, "Queue this reviewed reply in the local outbox"
    post "/tool_views/surfaces/#{id}/actions", params: payload("send_reply", { confirmation: "yes", reply_version: reply.reload.lock_version.to_s }), as: :json
    assert_response :success
    get "/tool_views/surfaces/#{id}"
    assert_includes response.body, "No external delivery service is configured"
    assert_includes response.body, "Reviewed &amp; approved."
  end
  test "accepted artifact export is downloadable only by the authorized tenant and role" do
    get "/v1/review"
    id = surface.id
    post "/tool_views/surfaces/#{id}/actions", params: payload("accept", { artifact_version: "1" }), as: :json
    assert_response :success
    post "/tool_views/surfaces/#{id}/actions", params: payload("export", { artifact_version: "1" }), as: :json
    assert_response :success
    get "/tool_views/surfaces/#{id}"
    assert_includes response.body, "Download accepted result"
    exported = DemoExport.first
    get "/v1/exports/#{exported.id}"
    assert_response :success
    assert_equal "Original campaign draft.", response.body
    assert_match /attachment/, response.headers["Content-Disposition"]
    post "/v1/identity", params: { code: "south-lead" }
    get "/v1/exports/#{exported.id}"
    assert_response :not_found
    refute_includes response.body, "Original campaign"
    post "/v1/identity", params: { code: "north-agent" }
    get "/v1/exports/#{exported.id}"
    assert_response :forbidden
  end
  test "new draft has a separate artifact instead of overwriting the accepted one" do
    get "/v1/review"
    id = surface.id
    post "/tool_views/surfaces/#{id}/actions", params: payload("accept", { artifact_version: "1" }), as: :json
    post "/v1/review/new"
    follow_redirect!
    assert_response :success
    assert_includes response.body, "New campaign draft"
    assert_equal 3, DemoArtifact.count
    assert_equal 1, DemoArtifact.find_by!(code: "north-artifact").accepted_version
    assert_not_equal id, surface.id
  end
  test "Engine requests use the host controller authentication method" do
    ApplicationController.define_method(:demo_authenticated_staff) { DemoStaff.find_by!(code: session.fetch(:v1_identity)) }
    RailsToolViews.configuration.scope_resolver = ->(controller) { DemoV1::Access.scope_for(controller.demo_authenticated_staff) }
    get "/v1/customer"
    post "/tool_views/surfaces/#{surface.id}/actions", params: payload("submit_form", { name: "Host authenticated", email: "host@example.test" }), as: :json
    assert_response :success
    assert_equal "north", DemoCustomer.find_by!(email: "host@example.test").tenant_ref
  ensure
    ApplicationController.remove_method(:demo_authenticated_staff)
  end
  test "host identity mutation retains CSRF protection" do
    # Toggle only this controller. Changing the application config here would be
    # copied onto ActionController::Base if this test is the first to load it,
    # leaving forgery protection on for every later test in the process.
    original = V1::BaseController.allow_forgery_protection
    V1::BaseController.allow_forgery_protection = true
    post "/v1/identity", params: { code: "south-lead" }
    assert_response :forbidden
    assert_includes response.body, "INVALID_CSRF"
  ensure
    V1::BaseController.allow_forgery_protection = original
  end
end
