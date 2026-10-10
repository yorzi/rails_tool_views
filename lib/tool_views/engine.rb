# frozen_string_literal: true
module ToolViews
  class Engine < ::Rails::Engine
    isolate_namespace ToolViews
    initializer "tool_views.privacy", before: "active_record.set_filter_attributes" do |app|
      app.config.filter_parameters += %i[props state payload result arguments values business_rules authenticity_token]
    end
    initializer "tool_views.helpers" do
      ActiveSupport.on_load(:action_controller_base) { helper ToolViews::SurfacesHelper }
    end
  end
end
