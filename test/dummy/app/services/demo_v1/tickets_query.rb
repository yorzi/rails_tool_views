# frozen_string_literal: true
module DemoV1
  module TicketsQuery
    module_function
    def call(scope:, query: "")
      Access.staff(scope)
      raise ToolViews::Error.new("INVALID_ARGUMENTS") unless query.is_a?(String) && query.length <= 80
      pattern = "%#{DemoTicket.sanitize_sql_like(query)}%"
      DemoTicket.joins(:customer).where(tenant_ref: scope.tenant, demo_customers: { tenant_ref: scope.tenant })
        .where("demo_tickets.subject LIKE ?", pattern).order(:id).limit(5).map do |record|
        { "id" => record.id.to_s, "subject" => record.subject, "status" => record.status }
      end
    end
  end
end
