# frozen_string_literal: true
ENV['RAILS_ENV'] = 'test'
require 'bundler/setup'
require_relative '../support/offline'
require_relative '../dummy/config/environment'
DemoV1::Registration.call
scope = DemoV1::Access.scope_for(DemoStaff.find_by!(code: 'north-lead'))
command, id, key = ARGV
if %w[deliver crash_after_effect].include?(command)
  host_adapter = DemoV1::Agent.new
  RailsToolViews.configuration.agent_adapter = ->(payload, delivery_key:) {
    host_adapter.call(payload, delivery_key: delivery_key)
    # Simulate process death after the domain transaction, before acknowledgment.
    Process.exit!(73) if command == 'crash_after_effect'
  }
  result = DemoV1::ContinuationJob.perform_now(id, staff_id: DemoStaff.find_by!(code: 'north-lead').id)
  puts JSON.generate(status: result.status, attempts: result.attempts, delivery_key: result.delivery_key)
elsif command == 'submit'
  puts 'ready'; STDOUT.flush; STDIN.gets
  begin
    result = RailsToolViews.dispatch(id, scope: scope, action: 'submit_form', arguments: { name: 'Concurrent customer', email: 'parallel@example.test' }, base_revision: 1, idempotency_key: key)
    puts JSON.generate(result)
  rescue RailsToolViews::Error => error
    puts JSON.generate(error.to_h)
  end
else
  surface = RailsToolViews.restore(id, scope: scope)
  artifact = DemoV1::Access.artifact(scope, surface.props.fetch('artifact_id'))
  puts JSON.generate(surface: surface.snapshot, current_version: artifact.current_version, accepted_version: artifact.accepted_version,
    body: artifact.current.body, export_count: DemoExport.where(artifact: artifact).count, receipt_count: DemoAgentReceipt.count)
end
