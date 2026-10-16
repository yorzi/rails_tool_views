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
    surface = RailsToolViews.present(:choice_card, props: props.merge(title: '<script>alert("x")</script>'), scope: scope)
    html = RailsToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, "&lt;script&gt;"
    refute_includes html, "<script>"
    assert_includes html, "/tool_views/surfaces/#{surface.id}/actions"
    assert_includes html, "Choose a workflow"
    act(surface)
    html = RailsToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, 'checked="checked"'
    assert_includes html, "Saved revision 2"
    assert_includes html, "Selection saved"
  end
  test "trusted ViewComponent receives validated props" do
    RailsToolViews.register(:vc_card, description: "Existing component", schema: PROPS_SCHEMA, component: DemoCardComponent, policy: ->(_access) { true })
    surface = RailsToolViews.present(:vc_card, props: props, scope: scope)
    html = RailsToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, "Trusted ViewComponent"
    assert_includes html, "Choose a workflow"
  end
  test "renderer errors and denied access visibly preserve state without leaking props" do
    surface = present_card
    html = RailsToolViews.render(surface, view_context: view, scope: scope("bob"))
    assert_includes html, "This view is unavailable"
    refute_includes html, "Choose a workflow"
    RailsToolViews.reset!
    html = RailsToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, "contract changed"
    assert_equal 1, RailsToolViews::Surface.count
    RailsToolViews.register(:missing, description: "Missing renderer", schema: PROPS_SCHEMA, partial: "choices/missing", policy: ->(_access) { true })
    missing = RailsToolViews.present(:missing, props: props, scope: scope)
    assert_includes RailsToolViews.render(missing, view_context: view, scope: scope), "cannot be rendered"
  end
  test "empty options state has no submit controls" do
    surface = RailsToolViews.present(:choice_card, props: props.merge(options: []), scope: scope)
    html = RailsToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, "No options are available"
    refute_includes html, "type=\"submit\""
  end

  def observe
    reports, events = [], []
    subscriber = Class.new { define_method(:report) { |error, **details| reports << [error, details] } }.new
    Rails.error.subscribe(subscriber)
    token = ActiveSupport::Notifications.subscribe(/\.tool_views\z/) { |name, *_timing, payload| events << [name, payload] }
    yield
    [reports, events]
  ensure
    Rails.error.unsubscribe(subscriber)
    ActiveSupport::Notifications.unsubscribe(token)
  end
  test "a broken host renderer is reported instead of failing silently" do
    RailsToolViews.register(:missing, description: "Missing renderer", schema: PROPS_SCHEMA, partial: "choices/missing", policy: ->(_access) { true })
    missing = RailsToolViews.present(:missing, props: props.merge(title: "private-title-sentinel"), scope: scope)
    html = nil
    reports, events = observe { html = RailsToolViews.render(missing, view_context: view, scope: scope) }
    assert_includes html, "cannot be rendered"
    assert_equal 1, reports.length
    error, details = reports.first
    assert_kind_of ActionView::MissingTemplate, error
    assert_equal [true, "tool_views", missing.id], [details[:handled], details[:source], details[:context][:surface_id]]
    assert_equal ["surface.render_failed.tool_views"], events.map(&:first)
    assert_equal({ surface_id: missing.id, component: "missing", error_class: "ActionView::MissingTemplate" }, events.first.last)
    refute_includes events.inspect, "private-title-sentinel"
  end
  test "a successful render is announced once and a host renderer rejection is shown as itself" do
    surface = present_card
    reports, events = observe { RailsToolViews.render(surface, view_context: view, scope: scope) }
    assert_empty reports
    assert_equal ["surface.rendered.tool_views"], events.map(&:first)
    RailsToolViews.register(:guarded, description: "Host guarded renderer", partial: "v1/ticket_card", policy: ->(_access) { true },
      schema: { type: "object", additionalProperties: false, properties: { ticket_id: { type: "string" } } })
    guarded = RailsToolViews.present(:guarded, props: { ticket_id: "1" }, scope: scope)
    html = nil
    reports, events = observe { html = RailsToolViews.render(guarded, view_context: view, scope: scope) }
    assert_includes html, "You do not have permission to use this view."
    refute_includes html, "cannot be rendered"
    assert_empty reports
    assert_empty events
  end
  test "status copy is generic by default and host translations replace engine wording" do
    RailsToolViews.reset!
    register_card { |access| RailsToolViews::Transition.new(state: { selected: access.arguments.fetch("key") }) }
    surface = present_card
    assert_includes RailsToolViews.render(surface, view_context: view, scope: scope), "View ready."
    act(surface)
    html = RailsToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, "Changes saved."
    refute_includes html, "Selection saved"
    I18n.backend.store_translations(:en, tool_views: { surface: { saved: "已保存更改。", revision: "第 %{revision} 版", saving: "正在保存…" } })
    html = RailsToolViews.render(surface, view_context: view, scope: scope)
    assert_includes html, "已保存更改。"
    assert_includes html, "第 2 版"
    assert_includes html, 'data-tool-views-saving-value="正在保存…"'
    refute_includes html, "Saved revision"
  ensure
    I18n.backend.reload!
  end

  test "action form helper scopes fields keeps ids unique per Surface and fills routing fields" do
    first, second = present_card, present_card
    act(second)
    documents = [first, second].map { |surface| Nokogiri::HTML(RailsToolViews.render(surface, view_context: view, scope: scope)) }
    ids = documents.flat_map { |document| document.css("[id]").map { |node| node["id"] } }
    assert_equal ids.uniq, ids
    documents.zip([first, second]).each do |document, surface|
      form = document.at_css("form")
      assert_equal "/tool_views/surfaces/#{surface.id}/actions", form["action"]
      hidden = form.css("input[type=hidden]").to_h { |input| [input["name"], input["value"]] }
      assert_equal ["select_option", surface.reload.revision.to_s, "choice_card"], hidden.values_at("action_name", "base_revision", "source_component")
      assert_match(/\A[0-9a-f-]{36}\z/, hidden["idempotency_key"])
      assert_equal %w[arguments[key]], form.css("input[type=radio]").map { |input| input["name"] }.uniq
      form.css("label").each { |label| assert document.at_css("##{label['for']}"), "label targets a control in this Surface" }
    end
    assert_equal "compare", documents.last.at_css("input[type=radio][checked]")["value"]
  end
  test "button helper posts fixed arguments and a mistyped action fails at render with its name" do
    surface = present_card
    form = Nokogiri::HTML(view.tool_views_action_button(surface, :select_option, "Compare now", arguments: { key: "compare" }, class: "primary")).at_css("form")
    assert_equal "compare", form.at_css("input[name='arguments[key]']")["value"]
    button = form.at_css("button")
    assert_equal ["Compare now", "submit", "primary", nil], [button.text, button["type"], button["class"], button["name"]]
    error = assert_raises(ArgumentError) { view.tool_views_action_fields(surface, :select_optoin) }
    assert_equal 'choice_card does not register the action "select_optoin"', error.message
  end
  test "a ViewComponent receives only the Surface context its initializer names" do
    plain = RailsToolViews.register(:plain_vc, description: "Props only", schema: PROPS_SCHEMA, component: DemoCardComponent, policy: ->(_access) { true })
    assert_empty plain.context
    interactive = RailsToolViews.register(:interactive_vc, description: "Interactive", schema: PROPS_SCHEMA, component: DemoChoiceComponent, policy: ->(access) { access.actor == "alice" },
      actions: { select_option: { schema: PARAMS_SCHEMA, policy: ->(access) { access.actor == "alice" },
        handler: ->(access) { RailsToolViews::Transition.new(state: { selected: access.arguments.fetch("key") }) } } })
    assert_equal %i[surface state error], interactive.context
    surface = RailsToolViews.present(:interactive_vc, props: props, scope: scope)
    RailsToolViews.dispatch(surface.id, scope: scope, action: "select_option", arguments: { key: "continue" }, base_revision: 1, idempotency_key: "vc-1")
    document = Nokogiri::HTML(RailsToolViews.render(surface, view_context: view, scope: scope))
    assert_equal "/tool_views/surfaces/#{surface.id}/actions", document.at_css("form")["action"]
    assert_equal "2", document.at_css("input[name=base_revision]")["value"]
    assert_equal "continue", document.at_css("input[type=radio][checked]")["value"]
    ambiguous = { type: "object", additionalProperties: false, properties: { title: { type: "string" }, options: { type: "array", items: { type: "string" } }, state: { type: "string" } } }
    assert_error("INVALID_COMPONENT") { RailsToolViews.register(:ambiguous_vc, description: "Ambiguous", schema: ambiguous, component: DemoChoiceComponent, policy: ->(_access) { true }) }
  end
end
