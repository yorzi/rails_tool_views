# frozen_string_literal: true
module DemoV1
  module Registration
    module_function
    def object(properties)
      { type: "object", additionalProperties: false, required: properties.keys.map(&:to_s), properties: properties }
    end
    def text(max = 200)
      { type: "string", maxLength: max }
    end
    def identifier
      { type: "string", pattern: "^[1-9][0-9]{0,9}$" }
    end
    def revision
      { type: "string", pattern: "^(0|[1-9][0-9]{0,9})$" }
    end
    def register(key, description, props, actions)
      definitions = actions.transform_values do |schema|
        { schema: schema, handler: ->(access) { Workflows.call(access) } }
      end
      definitions.each do |name, definition|
        definition[:policy] = ->(access) { Access.allowed?(access, component: key, action: name.to_s) }
      end
      ToolViews.register(key, description: description, schema: props, partial: "v1/#{key}", version: "1",
        policy: ->(access) { Access.allowed?(access, component: key) }, expose_to: [:agent], actions: definitions)
    end
    def call
      register(:customer_form, "Review proposed customer fields", object(values: object(name: text(120), email: text(200))),
        submit_form: object(name: text(120), email: text(200)))
      register(:ticket_card, "Review a scoped support ticket", object(ticket_id: identifier),
        view_account: object({}),
        assign_ticket: object(assignee_id: identifier, ticket_version: revision),
        draft_reply: object(reply_version: revision),
        review_reply: object(body: text(2000), reply_version: revision),
        send_reply: object(reply_version: revision, confirmation: { type: "string", enum: ["yes"] }))
      register(:result_review, "Review a versioned result", object(artifact_id: identifier),
        edit: object(body: text(4000), artifact_version: identifier),
        accept: object(artifact_version: identifier),
        regenerate: object(feedback: text(500), artifact_version: identifier),
        export: object(artifact_version: identifier))
    end
  end
end
