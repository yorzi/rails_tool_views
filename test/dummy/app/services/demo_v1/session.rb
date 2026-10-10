# frozen_string_literal: true
module DemoV1
  module Session
    module_function
    def scope(controller)
      if controller.session[:v1_identity]
        staff = DemoStaff.find_by(code: controller.session[:v1_identity], active: true)
        staff && Access.scope_for(staff)
      else
        actor = controller.session[:demo_actor]
        actor && ToolViews::Scope.new(actor: actor, tenant: "local-demo")
      end
    end
  end
end
