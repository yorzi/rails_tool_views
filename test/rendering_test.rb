# frozen_string_literal: true
require_relative "test_helper"

class RenderingTest < ActiveSupport::TestCase
  def view
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.response = ActionDispatch::TestResponse.new
    controller.view_context
  end
  test "partial rendering escapes model props and restores checked choice" do
    surface = ToolViews.present(:choice_card, props: props.merge(title: '<script>alert("x")</script>'), scope: scope)
    html = ToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, "&lt;script&gt;"
    refute_includes html, "<script>"
    assert_includes html, "/tool_views/surfaces/#{surface.id}/actions"
    assert_includes html, "Choose a workflow"
    act(surface)
    html = ToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, 'checked="checked"'
    assert_includes html, "Saved revision 2"
    assert_includes html, "Selection saved"
  end
  test "trusted ViewComponent receives validated props" do
    ToolViews.register(:vc_card, description: "Existing component", schema: PROPS_SCHEMA, component: DemoCardComponent, policy: ->(_access) { true })
    surface = ToolViews.present(:vc_card, props: props, scope: scope)
    html = ToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, "Trusted ViewComponent"
    assert_includes html, "Choose a workflow"
  end
  test "renderer errors and denied access visibly preserve state without leaking props" do
    surface = present_card
    html = ToolViews.render(surface, view_context: view, scope: scope("bob"))
    assert_includes html, "This view is unavailable"
    refute_includes html, "Choose a workflow"
    ToolViews.reset!
    html = ToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, "contract changed"
    assert_equal 1, ToolViews::Surface.count
    ToolViews.register(:missing, description: "Missing renderer", schema: PROPS_SCHEMA, partial: "choices/missing", policy: ->(_access) { true })
    missing = ToolViews.present(:missing, props: props, scope: scope)
    assert_includes ToolViews.render(missing, view_context: view, scope: scope), "cannot be rendered"
  end
  test "empty options state has no submit controls" do
    surface = ToolViews.present(:choice_card, props: props.merge(options: []), scope: scope)
    html = ToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, "No options are available"
    refute_includes html, "type=\"submit\""
  end
end
