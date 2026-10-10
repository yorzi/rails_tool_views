# frozen_string_literal: true
module ToolViews
  module SurfacesHelper
    def tool_views_surface(surface, scope:, error: nil)
      ToolViews.render(surface, view_context: self, scope: scope, error: error)
    end

    def tool_views_body(surface, definition, error: nil)
      if definition.partial
        render(partial: definition.partial, locals: { props: surface.props, state: surface.state, surface: surface, error: error })
      else
        render(definition.component.new(**surface.props.symbolize_keys))
      end
    rescue StandardError
      render(partial: "tool_views/surfaces/error", formats: [:html], locals: { error: ToolViews::Error.new("RENDER_FAILED", status: 422) })
    end

    def tool_views_routes
      # Rails' mounted helper honors a custom mount path; host must name mount :tool_views.
      respond_to?(:tool_views) ? tool_views : main_app.tool_views
    end
  end
end
