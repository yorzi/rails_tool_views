# frozen_string_literal: true
module ToolViews
  module SurfacesHelper
    # Engine-owned copy. Translate or reword any of it under tool_views.surface.<key>.
    TEXT = {
      ready: "View ready.", saved: "Changes saved.", revision: "Saved revision %{revision}",
      saving: "Saving changes…", save_failed: "Changes could not be saved. Review the message and try again.",
      agent_pending: "AI follow-up pending.", agent_completed: "AI follow-up completed.",
      agent_failed: "Your changes were saved, but the AI follow-up could not complete.",
      agent_unavailable: "AI follow-up unavailable.", agent_retry: "Retry AI follow-up"
    }.freeze

    def tool_views_surface(surface, scope:, error: nil)
      ToolViews.render(surface, view_context: self, scope: scope, error: error)
    end

    def tool_views_text(key, **values)
      t(key, scope: %i[tool_views surface], default: TEXT.fetch(key), **values)
    end

    # Form for one registered action of this Surface. Fields built from the
    # yielded builder are named arguments[...], ids are unique per Surface, and
    # the action, revision, replay key and source fields are filled in.
    def tool_views_action_form(surface, action, **options, &block)
      fields = tool_views_action_fields(surface, action)
      form_with(url: tool_views_routes.surface_actions_path(surface), method: :post, scope: :arguments, namespace: surface.dom_id, **options) do |form|
        safe_join([fields, (capture(form, &block) if block)])
      end
    end

    # One-button form for an action whose arguments, if any, are fixed.
    def tool_views_action_button(surface, action, label, arguments: {}, form: {}, **button)
      tool_views_action_form(surface, action, **form) do |builder|
        safe_join(arguments.map { |name, value| builder.hidden_field(name, value: value, id: nil) } << builder.button(label, name: nil, **button))
      end
    end

    # The routing fields alone, for a form the host builds itself.
    def tool_views_action_fields(surface, action)
      key = action.to_s
      unless ToolViews.registry.fetch(surface.component_key).actions.key?(key)
        raise ArgumentError, "#{surface.component_key} does not register the action #{key.inspect}"
      end
      safe_join({ action_name: key, base_revision: surface.revision, idempotency_key: SecureRandom.uuid, source_component: surface.component_key }
        .map { |name, value| hidden_field_tag(name, value, id: nil) })
    end

    def tool_views_body(surface, definition, error: nil)
      html = if definition.partial
        render(partial: definition.partial, locals: { props: surface.props, state: surface.state, surface: surface, error: error })
      else
        context = { surface: surface, state: surface.state, error: error }.slice(*definition.context)
        render(definition.component.new(**surface.props.symbolize_keys, **context))
      end
      ToolViews.notify("surface.rendered", surface_id: surface.id, component: definition.key, revision: surface.revision)
      html
    rescue StandardError => failure
      # A host renderer may reject deliberately; anything else is a host bug to report.
      rejection = [failure, failure.cause].find { |candidate| candidate.is_a?(ToolViews::Error) }
      ToolViews.report(failure, "surface.render_failed", surface_id: surface.id, component: definition.key) unless rejection
      render(partial: "tool_views/surfaces/error", formats: [:html], locals: { error: rejection || ToolViews::Error.new("RENDER_FAILED", status: 422) })
    end

    def tool_views_routes
      # Rails' mounted helper honors a custom mount path; host must name mount :tool_views.
      # A ViewComponent that includes this module reaches it through its view context.
      view = respond_to?(:tool_views) || respond_to?(:main_app) ? self : helpers
      view.respond_to?(:tool_views) ? view.tool_views : view.main_app.tool_views
    end
  end
end
