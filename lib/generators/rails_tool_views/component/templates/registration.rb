# frozen_string_literal: true
# Load from the host's shared to_prepare block. Do not reset the registry here.
RailsToolViews.register(:<%= name %>,
  description: "<%= name.humanize %>",
  partial: "rails_tool_views/components/<%= name %>",
  schema: {
    type: "object", additionalProperties: false, required: ["title"],
    properties: { title: { type: "string", maxLength: 120 } }
  },
  # Replace with host authorization using access.actor and access.tenant.
  policy: ->(_access) { false },
  actions: {
    set_value: {
      schema: {
        type: "object", additionalProperties: false, required: ["value"],
        properties: { value: { type: "string", maxLength: 120 } }
      },
      # Recheck host authorization and trusted allowed values on every action.
      policy: ->(_access) { false },
      handler: ->(access) {
        RailsToolViews::Transition.new(state: { value: access.arguments.fetch("value") })
      }
    }
  })
