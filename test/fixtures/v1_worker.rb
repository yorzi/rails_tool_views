# frozen_string_literal: true
ENV['RAILS_ENV'] = 'test'
require 'bundler/setup'
require_relative '../support/offline'
require_relative '../dummy/config/environment'
DemoV1::Registration.call
scope = DemoV1::Access.scope_for(DemoStaff.find_by!(code: 'north-lead'))
command, id, key = ARGV
if command == 'submit'
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
