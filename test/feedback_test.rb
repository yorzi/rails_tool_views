# frozen_string_literal: true
require_relative "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "notice belongs to the action receipt while replay telemetry distinguishes execution" do
    RailsToolViews.reset!
    register_card { |access|
      DemoEffect.create!(surface_id: access.surface.id, value: "one effect")
      RailsToolViews::Transition.new(state: { message: "Persistent result" }, notice: "Temporary <private> notice")
    }
    events = []
    token = ActiveSupport::Notifications.subscribe("action.executed.rails_tool_views") { |*args| events << args.last }
    surface = present_card
    first = act(surface, revision: 1, idempotency: "notice-once")
    assert_equal "Temporary <private> notice", first[:notice]
    assert_equal first, act(surface, revision: 1, idempotency: "notice-once")
    assert_equal [false, true], events.map { |payload| payload.fetch(:replayed) }
    assert_equal %i[action replayed revision surface_id], events.first.keys.sort
    refute_includes events.inspect, "private"
    assert_equal({ "message" => "Persistent result" }, surface.reload.state)
    refute_includes surface.snapshot.to_json, "notice"
    assert_equal 1, DemoEffect.count
  ensure
    ActiveSupport::Notifications.unsubscribe(token) if token
  end

  test "invalid notices roll back host effects and Surface writes" do
    [true, {}, "界" * 167].each do |notice|
      RailsToolViews.reset!
      register_card { |access|
        DemoEffect.create!(surface_id: access.surface.id, value: "rollback")
        RailsToolViews::Transition.new(state: { selected: "compare" }, notice: notice)
      }
      surface = present_card
      assert_error("INVALID_TRANSITION") { act(surface) }
      assert_equal 1, surface.reload.revision
      assert_empty surface.state
      assert_equal 0, DemoEffect.count
      assert_equal 0, RailsToolViews::ActionExecution.count
    end
  end

  test "rendered notice escapes even a marked-safe host string and does not survive restore" do
    surface = present_card
    act(surface)
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.response = ActionDispatch::TestResponse.new
    html = RailsToolViews.render(surface, view_context: controller.view_context, scope: scope, notice: "<script>secret</script>".html_safe)
    assert_includes html, "&lt;script&gt;secret&lt;/script&gt;"
    refute_includes html, "<script>"
    restored = RailsToolViews.render(surface, view_context: controller.view_context, scope: scope)
    refute_includes restored, "secret"
    assert_includes restored, "Selection saved: compare."
  end
end

class FeedbackControllerTest < ActionDispatch::IntegrationTest
  include TestFixtures
  setup do
    [RailsToolViews::AgentInteraction, RailsToolViews::ActionExecution, RailsToolViews::Presentation, RailsToolViews::Surface, DemoEffect].each(&:delete_all)
    RailsToolViews.reset!
    register_card { |access| RailsToolViews::Transition.new(state: { selected: access.arguments.fetch("key") }, notice: "Saved <private> notice") }
    RailsToolViews.configuration.scope_resolver = ->(_) { scope }
    @surface = present_card
    @path = "/rails_tool_views/surfaces/#{@surface.id}"
    @body = { action_name: "select_option", arguments: { key: "compare" }, base_revision: 1, idempotency_key: "notice" }
  end

  test "JSON and Turbo replay carry the same notice but snapshots do not" do
    post "#{@path}/actions", params: @body, as: :json
    assert_response :success
    assert_equal "Saved <private> notice", response.parsed_body["notice"]
    post "#{@path}/actions", params: @body, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_includes response.body, "Saved &lt;private&gt; notice"
    get @path, as: :json
    refute_includes response.body, "notice"
    get @path
    refute_includes response.body, "private"
    assert_equal 1, RailsToolViews::ActionExecution.count
  end

  test "HTML notice appears once after redirect and never in the URL" do
    post "#{@path}/actions", params: @body
    assert_response :see_other
    assert_equal "http://www.example.com#{@path}", response.location
    follow_redirect!
    assert_response :success
    assert_includes response.body, "Saved &lt;private&gt; notice"
    get @path
    refute_includes response.body, "private"
    assert_equal({ "selected" => "compare" }, @surface.reload.state)
  end

  test "HTML flash cannot disclose a notice to another Surface or changed identity" do
    other = present_card
    post "#{@path}/actions", params: @body
    get "/rails_tool_views/surfaces/#{other.id}"
    assert_response :success
    refute_includes response.body, "private"
    # A subsequent authorized read cannot resurrect expired flash.
    get @path
    refute_includes response.body, "private"
    post "#{@path}/actions", params: @body
    RailsToolViews.configuration.scope_resolver = ->(_) { scope("bob") }
    get @path
    assert_response :not_found
    refute_includes response.body, "private"
  end
end
