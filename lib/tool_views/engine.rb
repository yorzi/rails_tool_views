# frozen_string_literal: true
module ToolViews
  class Engine < ::Rails::Engine
    isolate_namespace ToolViews
    # Log redaction lives on this engine's own controller and models, not in the
    # host-wide filter list, where names like `state` would redact host data too.
    initializer "tool_views.helpers" do
      ActiveSupport.on_load(:action_controller_base) { helper ToolViews::SurfacesHelper }
    end
  end
end
