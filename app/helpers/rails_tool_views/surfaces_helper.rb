# frozen_string_literal: true
module RailsToolViews
  # Rails view helpers for authorized rendering and action forms.
  # Canonical rails_tool_views_* names alias the legacy tool_views_* methods.
  module SurfacesHelper
    # Engine-owned copy. Translate or reword any of it under tool_views.surface.<key>.
    TEXT = {
      ready: "View ready.", saved: "Changes saved.", revision: "Saved revision %{revision}",
      saving: "Saving changes…", save_failed: "Changes could not be saved. Review the message and try again.",
      agent_pending: "AI follow-up pending.", agent_completed: "AI follow-up completed.",
      agent_failed: "Your changes were saved, but the AI follow-up could not complete.",
      agent_unavailable: "AI follow-up unavailable.", agent_retry: "Retry AI follow-up"
    }.freeze

    # Renders the Surface with a fresh scope and optional field feedback.
    def tool_views_surface(surface, scope:, error: nil)
      RailsToolViews.render(surface, view_context: self, scope: scope, error: error)
    end

    def tool_views_text(key, **values)
      t(key, scope: %i[tool_views surface], default: TEXT.fetch(key), **values)
    end

    # The accessible name of a registered component: the translation under
    # tool_views.components.<key>, or its registered description. Looked up
    # per render, so it follows the request's locale.
    def tool_views_component_name(key)
      t(key.to_s, scope: %i[tool_views components], default: RailsToolViews.registry.fetch(key).description)
    end

    # Form for one registered action of this Surface. Fields built from the
    # yielded builder are named +arguments[...]+, ids are unique per Surface, and
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
      unless RailsToolViews.registry.fetch(surface.component_key).actions.key?(key)
        raise ArgumentError, "#{surface.component_key} does not register the action #{key.inspect}"
      end
      safe_join({ action_name: key, base_revision: surface.revision, idempotency_key: SecureRandom.uuid, source_component: surface.component_key }
        .map { |name, value| hidden_field_tag(name, value, id: nil) })
    end

    def tool_views_body(surface, definition, error: nil) # :nodoc:
      html = if definition.partial
        render(partial: definition.partial, locals: { props: surface.props, state: surface.state, surface: surface, error: error })
      else
        context = { surface: surface, state: surface.state, error: error }.slice(*definition.context)
        render(definition.component.new(**surface.props.symbolize_keys, **context))
      end
      RailsToolViews.notify("surface.rendered", surface_id: surface.id, component: definition.key, revision: surface.revision)
      html
    rescue StandardError => failure
      # A host renderer may reject deliberately; anything else is a host bug to report.
      rejection = [failure, failure.cause].find { |candidate| candidate.is_a?(RailsToolViews::Error) }
      RailsToolViews.report(failure, "surface.render_failed", surface_id: surface.id, component: definition.key) unless rejection
      render(partial: "rails_tool_views/surfaces/error", formats: [:html], locals: { error: rejection || RailsToolViews::Error.new("RENDER_FAILED", status: 422) })
    end

    def tool_views_routes # :nodoc:
      view = respond_to?(:rails_tool_views) || respond_to?(:tool_views) || respond_to?(:main_app) ? self : helpers
      routes = view.respond_to?(:rails_tool_views) || view.respond_to?(:tool_views) ? view : view.main_app
      routes.respond_to?(:rails_tool_views) ? routes.rails_tool_views : routes.tool_views
    end

    %i[surface text component_name action_form action_button action_fields body routes].each do |suffix|
      alias_method "rails_tool_views_#{suffix}", "tool_views_#{suffix}"
    end
  end
end
