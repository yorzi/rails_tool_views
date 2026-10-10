# frozen_string_literal: true
Rails.application.config.to_prepare do
  unless Rails.env.test?
    ToolViews.reset!
    ToolViews.configure do |config|
      config.scope_resolver = ->(controller) {
        actor = controller.session[:demo_actor]
        actor && ToolViews::Scope.new(actor: actor, tenant: "local-demo")
      }
      # A deterministic host callback, never a simulated live provider claim.
      config.agent_adapter = ->(payload, delivery_key:) {
        DemoEffect.find_or_create_by!(surface_id: delivery_key, value: "Continuation received: #{payload.fetch('values').fetch('key')}")
      }
    end
    schema = {
      type: "object", additionalProperties: false, required: %w[title options], properties: {
        title: { type: "string", maxLength: 120 },
        options: { type: "array", maxItems: 10, items: {
          type: "object", additionalProperties: false, required: %w[key label],
          properties: { key: { type: "string" }, label: { type: "string" } }
        } }
      }
    }
    policy = ->(access) { access.tenant == "local-demo" && access.actor.start_with?("demo:") }
    selection = { schema: { type: "object", additionalProperties: false, required: ["key"], properties: { key: { type: "string" } } },
      policy: ->(access) { policy.call(access) && %w[compare continue].include?(access.arguments.fetch("key")) && access.props.fetch("options").any? { |option| option.fetch("key") == access.arguments.fetch("key") } },
      handler: ->(access) {
        DemoEffect.create!(surface_id: access.surface.id, value: access.arguments.fetch("key"))
        ToolViews::Transition.new(state: { selected: access.arguments.fetch("key") }, agent: access.surface.context_ref == "demo-chat")
      } }
    ToolViews.register(:choice_card, description: "Select a workflow", schema: schema, partial: "choices/card", policy: policy, expose_to: [:agent], actions: { select_option: selection })
    ToolViews.register(:component_card, description: "Existing ViewComponent", schema: schema, component: DemoCardComponent, policy: policy)
  end
end
