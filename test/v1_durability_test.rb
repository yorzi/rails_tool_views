# frozen_string_literal: true
require_relative 'test_helper'
require 'open3'
class V1DurabilityTest < ActiveSupport::TestCase
  setup do
    DemoV1::Seeds.call
    DemoV1::Registration.call
  end
  def v1_scope
    DemoV1::Access.scope_for(DemoStaff.find_by!(code: 'north-lead'))
  end
  test 'independent customer submit workers create one authoritative record and durable receipt' do
    surface = ToolViews.present(:customer_form, props: { values: { name: '', email: '' } }, scope: v1_scope)
    before = DemoCustomer.count
    workers = 2.times.map { Open3.popen3(RbConfig.ruby, 'test/fixtures/v1_worker.rb', 'submit', surface.id, 'create-once') }
    workers.each { |_input, output, _error, _thread| assert_equal "ready\n", output.gets }
    workers.each { |input, _output, _error, _thread| input.puts('start'); input.close }
    results = workers.map do |_input, output, error, thread|
      result = JSON.parse(output.read)
      assert thread.value.success?, error.read
      result
    end
    assert results.any? { |result| result['status'] == 'completed' }
    assert results.all? { |result| result['status'] == 'completed' || result['code'] == 'CONFLICT' }
    # Other processes wrote the database; bypass the parent's earlier count cache.
    assert_equal before + 1, DemoCustomer.uncached { DemoCustomer.count }
    assert_equal 1, ToolViews::ActionExecution.count
    assert_equal 2, surface.reload.revision
    result = ToolViews.dispatch(surface.id, scope: v1_scope, action: 'submit_form', arguments: { name: 'Concurrent customer', email: 'parallel@example.test' }, base_revision: 1, idempotency_key: 'create-once')
    assert_equal 2, result[:revision]
  ensure
    workers&.each { |input, output, error, thread| [input, output, error].each { |io| io.close unless io.closed? }; Process.kill('TERM', thread.pid) if thread.alive? }
  end
  test 'separate boot restores regenerated accepted exported artifact and its host receipt' do
    artifact = DemoArtifact.find_by!(code: 'north-artifact')
    surface = ToolViews.present(:result_review, props: { artifact_id: artifact.id.to_s }, scope: v1_scope)
    ToolViews.configuration.agent_adapter = DemoV1::Agent.new
    args = { feedback: 'Concise', artifact_version: '1' }
    result = ToolViews.dispatch(surface.id, scope: v1_scope, action: 'regenerate', arguments: args, base_revision: 1, idempotency_key: 'regenerate')
    ToolViews.deliver(result.fetch(:interaction_id), scope: v1_scope)
    ToolViews.dispatch(surface.id, scope: v1_scope, action: 'accept', arguments: { artifact_version: '2' }, base_revision: 2, idempotency_key: 'accept')
    ToolViews.dispatch(surface.id, scope: v1_scope, action: 'export', arguments: { artifact_version: '2' }, base_revision: 3, idempotency_key: 'export')
    output, error, status = Open3.capture3(RbConfig.ruby, 'test/fixtures/v1_worker.rb', 'restore', surface.id)
    assert status.success?, error
    restored = JSON.parse(output)
    assert_equal 4, restored.fetch('surface').fetch('revision')
    assert_equal 2, restored.fetch('current_version')
    assert_equal 2, restored.fetch('accepted_version')
    assert_equal 1, restored.fetch('export_count')
    assert_equal 1, restored.fetch('receipt_count')
    assert_equal 'Revised campaign draft. Feedback: Concise', restored.fetch('body')
  end
end
