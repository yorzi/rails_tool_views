# frozen_string_literal: true
module DemoV1
  module Access
    module_function
    def scope_for(staff)
      RailsToolViews::Scope.new(actor: staff.actor_ref, tenant: staff.tenant_ref)
    end
    def staff(scope)
      raise RailsToolViews::Error.new("NOT_ALLOWED", status: 403) unless scope.actor.match?(/\Astaff:[1-9][0-9]*\z/)
      record = DemoStaff.find_by(id: scope.actor.delete_prefix("staff:"), tenant_ref: scope.tenant, active: true)
      raise RailsToolViews::Error.new("NOT_ALLOWED", status: 403) unless record && %w[lead agent].include?(record.role)
      record
    end
    def scope(access)
      RailsToolViews::Scope.new(actor: access.actor, tenant: access.tenant)
    end
    def ticket(scope, id)
      staff(scope)
      record = DemoTicket.find_by(id: id, tenant_ref: scope.tenant)
      raise RailsToolViews::Error.new("NOT_ALLOWED", status: 403) unless record && record.customer.tenant_ref == scope.tenant
      record
    end
    def artifact(scope, id)
      staff(scope)
      record = DemoArtifact.find_by(id: id, tenant_ref: scope.tenant)
      raise RailsToolViews::Error.new("NOT_ALLOWED", status: 403) unless record
      record
    end
    def allowed?(access, component:, action: nil)
      owner = staff(scope(access))
      return false if component == :customer_form && owner.role != "lead"
      return true if access.operation == :discover
      case component
      when :ticket_card
        record = ticket(scope(access), access.props.fetch("ticket_id"))
        return false if %w[assign_ticket send_reply].include?(action) && owner.role != "lead"
        if action == "assign_ticket"
          return DemoStaff.exists?(id: access.arguments.fetch("assignee_id"), tenant_ref: record.tenant_ref, active: true, role: %w[lead agent])
        end
      when :result_review
        artifact(scope(access), access.props.fetch("artifact_id"))
        return false if %w[accept export].include?(action) && owner.role != "lead"
      end
      true
    rescue RailsToolViews::Error, KeyError
      false
    end
  end
end
