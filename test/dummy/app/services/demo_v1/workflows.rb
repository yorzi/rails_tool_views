# frozen_string_literal: true
module DemoV1
  module Workflows
    module_function
    def call(access)
      component = access.surface.component_key.to_sym
      unless access.operation == :action && Access.allowed?(access, component: component, action: access.action)
        raise ToolViews::Error.new("NOT_ALLOWED", status: 403)
      end
      case component
      when :customer_form then customer(access)
      when :ticket_card then ticket(access)
      when :result_review then artifact(access)
      else raise ToolViews::Error.new("UNKNOWN_COMPONENT")
      end
    end
    def transition(access, **state)
      ToolViews::Transition.new(state: access.surface.state.merge(state.transform_keys(&:to_s)))
    end
    def version!(actual, expected)
      raise ToolViews::Error.new("CONFLICT", status: 409) unless actual.to_s == expected
    end
    def customer(access)
      raise ToolViews::Error.new("ALREADY_SUBMITTED", status: 409) if access.surface.state["customer_id"]
      values = access.arguments
      record = DemoCustomer.new(tenant_ref: access.tenant, name: values.fetch("name").strip, email: values.fetch("email").strip.downcase)
      unless record.valid?
        fields = record.errors.to_hash.transform_values { |messages| messages.join(". ") }
        raise ToolViews::ValidationError.new(fields: fields, values: values)
      end
      record.save!
      transition(access, customer_id: record.id, message: "Customer created once. The host database owns this record.")
    rescue ActiveRecord::RecordNotUnique
      raise ToolViews::ValidationError.new(fields: { email: "has already been used in this tenant" }, values: values)
    end
    def ticket(access)
      record = Access.ticket(Access.scope(access), access.props.fetch("ticket_id"))
      result = nil
      record.with_lock do
        case access.action
        when "view_account"
          result = transition(access, account_id: record.customer_id, message: "Authorized account details opened.")
        when "assign_ticket"
          version!(record.lock_version, access.arguments.fetch("ticket_version"))
          assignee = DemoStaff.find_by(id: access.arguments.fetch("assignee_id"), tenant_ref: access.tenant, active: true, role: %w[lead agent])
          raise ToolViews::Error.new("NOT_ALLOWED", status: 403) unless assignee
          record.update!(assignee: assignee)
          result = transition(access, message: "Ticket assigned to #{assignee.name}.")
        when "draft_reply"
          reply = record.reply
          version!(reply&.lock_version || 0, access.arguments.fetch("reply_version"))
          raise ToolViews::Error.new("REVIEW_REQUIRED", status: 409) if reply && reply.status != "draft"
          result = transition(access, message: "Reply drafting requested. Human review is required.")
          result.agent = true
        when "review_reply"
          reply = record.reply || raise(ToolViews::Error.new("NOT_FOUND", status: 404))
          reply.with_lock do
            version!(reply.lock_version, access.arguments.fetch("reply_version"))
            raise ToolViews::Error.new("REVIEW_REQUIRED", status: 409) if reply.status == "queued"
            body = access.arguments.fetch("body").strip
            raise ToolViews::ValidationError.new(fields: { body: "must not be blank" }, values: access.arguments) if body.empty?
            reply.update!(body: body, status: "reviewed")
          end
          result = transition(access, message: "Reply reviewed. It has not been sent.")
        when "send_reply"
          reply = record.reply || raise(ToolViews::Error.new("REVIEW_REQUIRED", status: 422))
          reply.with_lock do
            version!(reply.lock_version, access.arguments.fetch("reply_version"))
            raise ToolViews::Error.new("REVIEW_REQUIRED", status: 422) unless reply.status == "reviewed" && access.arguments.fetch("confirmation") == "yes"
            DemoOutboundReply.create!(reply: reply, reply_version: reply.lock_version, body: reply.body)
            reply.update!(status: "queued")
          end
          result = transition(access, message: "Reviewed reply queued in the local outbox. No customer was contacted.")
        else raise ToolViews::Error.new("UNKNOWN_ACTION")
        end
      end
      result
    end
    def artifact(access)
      record = Access.artifact(Access.scope(access), access.props.fetch("artifact_id"))
      result = nil
      record.with_lock do
        version!(record.current_version, access.arguments.fetch("artifact_version"))
        case access.action
        when "edit"
          raise ToolViews::Error.new("ALREADY_ACCEPTED", status: 409) if record.accepted_version
          body = access.arguments.fetch("body").strip
          raise ToolViews::ValidationError.new(fields: { body: "must not be blank" }, values: access.arguments) if body.empty?
          number = record.current_version + 1
          record.versions.create!(number: number, body: body, origin: "human_edit")
          record.update!(current_version: number)
          result = transition(access, message: "Human edit saved as artifact version #{number}.")
        when "accept"
          raise ToolViews::Error.new("ALREADY_ACCEPTED", status: 409) if record.accepted_version
          record.update!(accepted_version: record.current_version)
          result = transition(access, message: "Artifact version #{record.current_version} accepted. Further edits are locked.")
        when "regenerate"
          raise ToolViews::Error.new("ALREADY_ACCEPTED", status: 409) if record.accepted_version
          feedback = access.arguments.fetch("feedback").strip
          raise ToolViews::ValidationError.new(fields: { feedback: "must not be blank" }, values: access.arguments) if feedback.empty?
          result = transition(access, message: "Regeneration requested explicitly for artifact version #{record.current_version}.")
          result.agent = true
        when "export"
          raise ToolViews::Error.new("REVIEW_REQUIRED", status: 422) unless record.accepted_version == record.current_version
          export = Exports.call(record)
          result = transition(access, export_id: export.id, message: "Accepted artifact version #{record.current_version} is ready to download.")
        else raise ToolViews::Error.new("UNKNOWN_ACTION")
        end
      end
      result
    end
  end
end
