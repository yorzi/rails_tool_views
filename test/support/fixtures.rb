# frozen_string_literal: true
module TestFixtures
  PROPS_SCHEMA = {
    type: "object", additionalProperties: false, required: %w[title options],
    properties: {
      title: { type: "string", maxLength: 120 },
      options: { type: "array", maxItems: 10, items: {
        type: "object", additionalProperties: false, required: %w[key label],
        properties: { key: { type: "string" }, label: { type: "string" } }
      } }
    }
  }.freeze
  PARAMS_SCHEMA = { type: "object", additionalProperties: false, required: ["key"], properties: { key: { type: "string" } } }.freeze

  def scope(actor = "alice", tenant = "acme")
    ToolViews::Scope.new(actor: actor, tenant: tenant)
  end

  def props
    { title: "Choose a workflow", options: [{ key: "compare", label: "Compare options" }, { key: "continue", label: "Continue analysis" }] }
  end

  def register_card(key = :choice_card, agent: false, policy: ->(access) { access.actor == "alice" }, &handler)
    ToolViews.register(key, description: "Choose one allowed workflow", schema: PROPS_SCHEMA,
      partial: "choices/card", policy: policy, expose_to: [:agent], actions: {
        select_option: { schema: PARAMS_SCHEMA, policy: ->(access) {
          access.actor == "alice" && %w[compare continue].include?(access.arguments["key"]) && access.surface.props["options"].any? { |option| option["key"] == access.arguments["key"] }
        }, handler: handler || ->(access) {
          DemoEffect.create!(surface_id: access.surface.id, value: access.arguments.fetch("key"))
          key = access.arguments.fetch("key")
          ToolViews::Transition.new(state: { selected: key, message: "Selection saved: #{key}." }, agent: agent)
        } }
      })
  end

  def present_card(**options)
    ToolViews.present(:choice_card, props: props, scope: scope, **options)
  end

  def act(surface, key: "compare", revision: surface.revision, idempotency: SecureRandom.uuid, **extra)
    ToolViews.dispatch(surface.id, scope: scope, action: "select_option", arguments: { key: key },
      base_revision: revision, idempotency_key: idempotency, **extra)
  end

  def assert_error(code, &block)
    error = assert_raises(ToolViews::Error, &block)
    assert_equal code, error.code
    error
  end
end
