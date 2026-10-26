# frozen_string_literal: true
# The reference host's configuration and playground components. The initializer
# runs it on every reload; integration tests run it to exercise the same setup.
module DemoSetup
  PROPS_SCHEMA = {
    type: "object", additionalProperties: false, required: %w[title options], properties: {
      title: { type: "string", maxLength: 120 },
      options: { type: "array", maxItems: 10, items: {
        type: "object", additionalProperties: false, required: %w[key label],
        properties: { key: { type: "string" }, label: { type: "string" } }
      } }
    }
  }.freeze

  module_function

  def call
    RailsToolViews.reset!
    RailsToolViews.configure do |config|
      config.retention_policy = ->(access) { access.operation == :purge && playground?(access) }
      config.scope_resolver = DemoV1::Session.method(:scope)
      # Deterministic host callbacks and an offline model, never a live provider claim.
      config.agent_adapter = method(:deliver)
    end
    policy = ->(access) { playground?(access) }
    RailsToolViews.register(:choice_card, description: "Select a workflow", schema: PROPS_SCHEMA, partial: "choices/card",
      policy: policy, expose_to: [:agent], actions: { select_option: selection(policy) })
    RailsToolViews.register(:component_card, description: "Existing ViewComponent", schema: PROPS_SCHEMA,
      component: DemoChoiceComponent, policy: policy, actions: { select_option: selection(policy) })
    DemoV1::Registration.call
  end

  def playground?(access)
    access.tenant == "local-demo" && access.actor.start_with?("demo:")
  end

  # Model-proposed props may list any option; only these keys can be chosen.
  def selection(policy)
    { schema: { type: "object", additionalProperties: false, required: ["key"], properties: { key: { type: "string" } } },
      policy: ->(access) {
        key = access.arguments.fetch("key")
        policy.call(access) && %w[compare continue].include?(key) && access.props.fetch("options").any? { |option| option.fetch("key") == key }
      },
      handler: ->(access) {
        DemoEffect.create!(surface_id: access.surface.id, value: access.arguments.fetch("key"))
        key = access.arguments.fetch("key")
        context = access.surface.context_ref.to_s
        if context == "demo-notice"
          RailsToolViews::Transition.new(state: { selected: key }, notice: "Selection saved for this request.")
        else
          RailsToolViews::Transition.new(state: { selected: key, message: "Selection saved: #{key}." },
            agent: context == "demo-chat" || context.start_with?(DemoConversation::CONTEXT_PREFIX))
        end
      } }
  end

  def deliver(payload, delivery_key:)
    if payload.fetch("context_ref").to_s.start_with?(DemoConversation::CONTEXT_PREFIX)
      # Present only when the RubyLLM bundle loaded the agent demo.
      raise RailsToolViews::Error.new("AGENT_UNAVAILABLE", status: 503) unless defined?(DemoLLM)
      DemoLLM.deliver(payload, delivery_key: delivery_key)
    elsif payload.fetch("action") == "select_option"
      DemoEffect.find_or_create_by!(surface_id: delivery_key, value: "Continuation received: #{payload.fetch('values').fetch('key')}")
    else
      DemoV1::Agent.new.call(payload, delivery_key: delivery_key)
    end
  end
end
