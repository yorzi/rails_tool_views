# frozen_string_literal: true
module RailsToolViews
  class Engine < ::Rails::Engine
    isolate_namespace RailsToolViews
    # Log redaction lives on this engine's own controller and models, not in the
    # host-wide filter list, where names like `state` would redact host data too.
    initializer "rails_tool_views.helpers" do
      ActiveSupport.on_load(:action_controller_base) { helper RailsToolViews::SurfacesHelper }
    end
  end
end
