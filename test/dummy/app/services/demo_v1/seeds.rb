# frozen_string_literal: true
module DemoV1
  module Seeds
    module_function
    def call
      %w[north south].each do |tenant|
        %w[lead agent].each do |role|
          DemoStaff.find_or_create_by!(code: "#{tenant}-#{role}") do |staff|
            staff.tenant_ref, staff.name, staff.role = tenant, "#{tenant.capitalize} #{role.capitalize}", role
          end
        end
        customer = DemoCustomer.find_or_create_by!(tenant_ref: tenant, email: "#{tenant}@example.test") { |record| record.name = "#{tenant.capitalize} Workshop" }
        DemoTicket.find_or_create_by!(code: "#{tenant}-ticket") do |record|
          record.tenant_ref, record.customer, record.subject = tenant, customer, "Billing question · #{tenant.capitalize} Workshop"
        end
        artifact = DemoArtifact.find_or_create_by!(code: "#{tenant}-artifact") do |record|
          record.tenant_ref, record.title = tenant, "#{tenant.capitalize} campaign copy"
        end
        artifact.versions.find_or_create_by!(number: 1) do |version|
          version.body, version.origin = "Original campaign draft.", "fixture"
        end
      end
    end
  end
end
