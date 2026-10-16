# frozen_string_literal: true
require_relative 'test_helper'

class V1Test < ActiveSupport::TestCase
  setup do
    DemoV1::Seeds.call
    DemoV1::Registration.call
  end

  def staff_scope(code = 'north-lead')
    DemoV1::Access.scope_for(DemoStaff.find_by!(code: code))
  end

  def present_v1(key, props, code: 'north-lead')
    RailsToolViews.present(key, props: props, scope: staff_scope(code), context: 'v1:test')
  end

  def run_action(surface, action, args = {}, code: 'north-lead', key: SecureRandom.uuid, revision: surface.reload.revision)
    RailsToolViews.dispatch(surface.id, scope: staff_scope(code), action: action, arguments: args, base_revision: revision, idempotency_key: key)
  end

  def ticket
    DemoTicket.find_by!(code: 'north-ticket')
  end

  def artifact
    DemoArtifact.find_by!(code: 'north-artifact')
  end

  test 'corrected form keeps field errors, rejects protected fields and creates once' do
    surface = present_v1(:customer_form, { values: { name: 'Proposed customer', email: 'proposal@example.test' } })
    error = assert_raises(RailsToolViews::ValidationError) { run_action(surface, 'submit_form', { name: '', email: 'invalid' }) }
    assert_equal %w[email name], error.fields.keys.sort
    assert_equal 'invalid', error.values['email']
    assert_equal 1, surface.reload.revision
    count = DemoCustomer.count
    assert_error('INVALID_ARGUMENTS') { run_action(surface, 'submit_form', { name: 'New customer', email: 'new@example.test', tenant_ref: 'south' }) }
    assert_error('INVALID_ARGUMENTS') { run_action(surface, 'submit_form', { name: 'New customer', email: 'new@example.test', role: 'admin' }) }
    args = { name: 'Corrected customer', email: 'corrected@example.test' }
    first = run_action(surface, 'submit_form', args, key: 'create-once', revision: 1)
    assert_equal first, run_action(surface, 'submit_form', args, key: 'create-once', revision: 1)
    assert_equal count + 1, DemoCustomer.count
    created = DemoCustomer.find(surface.reload.state.fetch('customer_id'))
    assert_equal 'north', created.tenant_ref
    assert_equal 'Corrected customer', created.name
    assert_error('ALREADY_SUBMITTED') { run_action(surface, 'submit_form', args) }
  end

  test 'query, discovery, presentation and action permissions independently enforce role and tenant' do
    assert_equal [ticket.id.to_s], DemoV1::TicketsQuery.call(scope: staff_scope, query: 'Billing').map { |item| item.fetch('id') }
    refute_includes DemoV1::TicketsQuery.call(scope: staff_scope('south-lead'), query: '').map { |item| item.fetch('id') }, ticket.id.to_s
    projection = DemoV1::TicketsQuery.call(scope: staff_scope, query: '').first
    refute_includes projection.keys, 'email'
    refute_includes projection.keys, 'body'
    catalog = RailsToolViews.registry.catalog(keys: %i[customer_form ticket_card result_review], scope: staff_scope('north-agent'))
    assert_equal %w[ticket_card result_review], catalog.map(&:key)
    assert_error('NOT_ALLOWED') { present_v1(:customer_form, { values: { name: '', email: '' } }, code: 'north-agent') }
    assert_error('NOT_ALLOWED') { present_v1(:ticket_card, { ticket_id: ticket.id.to_s }, code: 'south-lead') }
    surface = present_v1(:ticket_card, { ticket_id: ticket.id.to_s }, code: 'north-agent')
    other = DemoStaff.find_by!(code: 'south-agent')
    assert_error('NOT_ALLOWED') { run_action(surface, 'assign_ticket', { assignee_id: other.id.to_s, ticket_version: ticket.lock_version.to_s }, code: 'north-agent') }
    lead_surface = present_v1(:ticket_card, { ticket_id: ticket.id.to_s })
    assert_error('NOT_ALLOWED') { run_action(lead_surface, 'assign_ticket', { assignee_id: other.id.to_s, ticket_version: ticket.lock_version.to_s }) }
    assert_error('NOT_FOUND') { RailsToolViews.restore(lead_surface.id, scope: staff_scope('north-agent')) }
  end

  test 'trusted assignment, current domain version, source and action checks preserve business state' do
    surface = present_v1(:ticket_card, { ticket_id: ticket.id.to_s })
    agent = DemoStaff.find_by!(code: 'north-agent')
    args = { assignee_id: agent.id.to_s, ticket_version: ticket.lock_version.to_s }
    initial = run_action(surface, 'assign_ticket', args, key: 'assignment', revision: 1)
    assert_equal agent.id, ticket.reload.assignee_id
    assert_equal initial, run_action(surface, 'assign_ticket', args, key: 'assignment', revision: 1)
    assert_error('CONFLICT') { run_action(surface, 'assign_ticket', args) }
    assert_error('INVALID_SOURCE') { RailsToolViews.dispatch(surface.id, scope: staff_scope, action: 'view_account', arguments: {}, base_revision: surface.reload.revision, idempotency_key: 'forged-source', source_component: 'customer_form') }
    assert_error('UNKNOWN_ACTION') { run_action(surface, 'delete_ticket') }
    assert_error('INVALID_ARGUMENTS') { run_action(surface, 'view_account', { account_id: DemoCustomer.find_by!(tenant_ref: 'south').id.to_s }) }
    run_action(surface, 'view_account')
    assert_equal ticket.customer_id, surface.reload.state.fetch('account_id')
  end

  test 'reply drafting is explicit, durable, reviewed and only queues a local outbox after confirmation' do
    surface = present_v1(:ticket_card, { ticket_id: ticket.id.to_s })
    RailsToolViews.configuration.agent_adapter = DemoV1::Agent.new
    result = run_action(surface, 'draft_reply', { reply_version: '0' })
    assert_equal 0, DemoReply.count
    interaction = RailsToolViews.deliver(result.fetch(:interaction_id), scope: staff_scope)
    assert_equal 'completed', interaction.status
    reply = DemoReply.find_by!(ticket_id: ticket.id)
    assert_equal 'draft', reply.status
    RailsToolViews.deliver(interaction.id, scope: staff_scope)
    assert_equal 1, DemoReply.count
    assert_equal 1, DemoAgentReceipt.count
    assert_error('REVIEW_REQUIRED') { run_action(surface, 'send_reply', { reply_version: reply.lock_version.to_s, confirmation: 'yes' }) }
    run_action(surface, 'review_reply', { body: 'Human corrected reply.', reply_version: reply.lock_version.to_s })
    reply.reload
    assert_equal 'reviewed', reply.status
    assert_error('INVALID_ARGUMENTS') { run_action(surface, 'send_reply', { reply_version: reply.lock_version.to_s, confirmation: 'no' }) }
    args = { reply_version: reply.lock_version.to_s, confirmation: 'yes' }
    before = surface.reload.revision
    queued = run_action(surface, 'send_reply', args, key: 'send-once', revision: before)
    assert_equal queued, run_action(surface, 'send_reply', args, key: 'send-once', revision: before)
    assert_equal 1, DemoOutboundReply.count
    assert_equal 'Human corrected reply.', DemoOutboundReply.first.body
    assert_equal 'queued_locally', DemoOutboundReply.first.status
  end

  test 'artifact editing and accepting use independent immutable domain versions' do
    surface = present_v1(:result_review, { artifact_id: artifact.id.to_s })
    run_action(surface, 'edit', { body: 'Human edited result', artifact_version: '1' })
    assert_equal 2, artifact.reload.current_version
    assert_equal 'Original campaign draft.', artifact.versions.find_by!(number: 1).body
    assert_equal 'Human edited result', artifact.current.body
    assert_error('CONFLICT') { run_action(surface, 'accept', { artifact_version: '1' }) }
    run_action(surface, 'accept', { artifact_version: '2' })
    assert_equal 2, artifact.reload.accepted_version
    assert_error('ALREADY_ACCEPTED') { run_action(surface, 'edit', { body: 'Overwrite approved copy', artifact_version: '2' }) }
    assert_error('ALREADY_ACCEPTED') { run_action(surface, 'regenerate', { feedback: 'Rework', artifact_version: '2' }) }
    assert_equal 2, artifact.versions.count
  end

  test 'regeneration explicitly emits continuation, rejects intervening edits and survives failed delivery' do
    surface = present_v1(:result_review, { artifact_id: artifact.id.to_s })
    RailsToolViews.configuration.agent_adapter = ->(_payload, delivery_key:) { raise 'offline failure' }
    result = run_action(surface, 'regenerate', { feedback: 'More concise', artifact_version: '1' })
    id = result.fetch(:interaction_id)
    assert_equal 1, artifact.reload.current_version
    assert_equal 'failed', RailsToolViews.deliver(id, scope: staff_scope).status
    RailsToolViews.configuration.agent_adapter = DemoV1::Agent.new
    assert_equal 'completed', RailsToolViews.deliver(id, scope: staff_scope, retry_failed: true).status
    assert_equal 2, artifact.reload.current_version
    assert_match /More concise/, artifact.current.body
    delayed = run_action(surface, 'regenerate', { feedback: 'Delayed', artifact_version: '2' }).fetch(:interaction_id)
    run_action(surface, 'edit', { body: 'New human revision', artifact_version: '2' })
    assert_equal 'failed', RailsToolViews.deliver(delayed, scope: staff_scope).status
    assert_equal 3, artifact.reload.current_version
    assert_equal 'New human revision', artifact.current.body
  end

  test 'export failures roll back and retries bind to the accepted artifact version' do
    surface = present_v1(:result_review, { artifact_id: artifact.id.to_s })
    assert_error('REVIEW_REQUIRED') { run_action(surface, 'export', { artifact_version: '1' }) }
    run_action(surface, 'accept', { artifact_version: '1' })
    revision = surface.reload.revision
    DemoV1::Exports.stub(:render, ->(_version) { raise RailsToolViews::Error.new('EXPORT_FAILED', status: 503) }) do
      assert_error('EXPORT_FAILED') { run_action(surface, 'export', { artifact_version: '1' }, key: 'export', revision: revision) }
    end
    assert_equal revision, surface.reload.revision
    assert_equal 0, DemoExport.count
    result = run_action(surface, 'export', { artifact_version: '1' }, key: 'export', revision: revision)
    assert_equal result, run_action(surface, 'export', { artifact_version: '1' }, key: 'export', revision: revision)
    assert_equal 1, DemoExport.count
    assert_equal 'Original campaign draft.', DemoExport.first.body
    assert_equal 1, DemoExport.first.artifact_version
  end

  test 'host continuation receipt handles a crash after domain commit before acknowledgment' do
    surface = present_v1(:result_review, { artifact_id: artifact.id.to_s })
    RailsToolViews.configuration.agent_adapter = DemoV1::Agent.new
    id = run_action(surface, 'regenerate', { feedback: 'Clearer', artifact_version: '1' }).fetch(:interaction_id)
    RailsToolViews.deliver(id, scope: staff_scope)
    interaction = RailsToolViews::AgentInteraction.find(id)
    interaction.update!(status: 'failed') # uncertain acknowledgment, durable host write already exists
    assert_equal 'completed', RailsToolViews.deliver(id, scope: staff_scope, retry_failed: true).status
    assert_equal 2, artifact.reload.current_version
    assert_equal 2, artifact.versions.count
    assert_equal 1, DemoAgentReceipt.count
    forged = interaction.payload.merge('values' => { 'feedback' => 'Forged', 'artifact_version' => '2' })
    assert_error('INVALID_CORRELATION') { DemoV1::Agent.new.call(forged, delivery_key: interaction.delivery_key) }
  end

  test 'accepted result rejects an earlier pending regeneration without creating a version' do
    surface = present_v1(:result_review, { artifact_id: artifact.id.to_s })
    RailsToolViews.configuration.agent_adapter = DemoV1::Agent.new
    id = run_action(surface, 'regenerate', { feedback: 'Delayed', artifact_version: '1' }).fetch(:interaction_id)
    run_action(surface, 'accept', { artifact_version: '1' })
    assert_equal 'failed', RailsToolViews.deliver(id, scope: staff_scope).status
    assert_equal 1, artifact.reload.current_version
    assert_equal 1, artifact.accepted_version
    assert_equal 0, DemoAgentReceipt.count
  end

  test 'independent surfaces enforce current domain versions and current staff permissions' do
    lead = present_v1(:result_review, { artifact_id: artifact.id.to_s })
    agent = present_v1(:result_review, { artifact_id: artifact.id.to_s }, code: 'north-agent')
    run_action(lead, 'edit', { body: 'Lead revision', artifact_version: '1' })
    assert_error('CONFLICT') { run_action(agent, 'edit', { body: 'Stale agent revision', artifact_version: '1' }, code: 'north-agent') }
    assert_equal 'Lead revision', artifact.reload.current.body
    assert_error('NOT_ALLOWED') { run_action(agent, 'accept', { artifact_version: '2' }, code: 'north-agent') }
    DemoStaff.find_by!(code: 'north-agent').update!(active: false)
    assert_error('NOT_ALLOWED') { RailsToolViews.restore(agent.id, scope: staff_scope('north-agent')) }
  end

  test 'domain association changes cannot leak another tenant through a stored reference' do
    surface = present_v1(:ticket_card, { ticket_id: ticket.id.to_s })
    ticket.update!(customer: DemoCustomer.find_by!(tenant_ref: 'south'))
    assert_error('NOT_ALLOWED') { RailsToolViews.restore(surface.id, scope: staff_scope) }
    assert_error('NOT_ALLOWED') { run_action(surface, 'view_account') }
    assert_empty DemoV1::TicketsQuery.call(scope: staff_scope, query: '')
  end

  test 'customer service participates in the Surface transaction and reports duplicate email locally' do
    surface = present_v1(:customer_form, { values: { name: '', email: '' } })
    before = DemoCustomer.count
    DemoV1::Workflows.stub(:transition, ->(*_args, **_options) { raise RailsToolViews::Error.new('DOMAIN_REJECTED', status: 422) }) do
      assert_error('DOMAIN_REJECTED') { run_action(surface, 'submit_form', { name: 'Rolled back', email: 'rollback@example.test' }) }
    end
    assert_equal before, DemoCustomer.count
    assert_equal 1, surface.reload.revision
    assert_equal 0, RailsToolViews::ActionExecution.count
    error = assert_raises(RailsToolViews::ValidationError) { run_action(surface, 'submit_form', { name: 'Duplicate', email: 'north@example.test' }) }
    assert_includes error.fields.keys, 'email'
    assert_equal before, DemoCustomer.count
  end

  test 'query input remains bounded and role authorization comes from trusted staff records' do
    assert_empty DemoV1::TicketsQuery.call(scope: staff_scope, query: '%')
    assert_error('INVALID_ARGUMENTS') { DemoV1::TicketsQuery.call(scope: staff_scope, query: 'x' * 81) }
    assert_error('NOT_ALLOWED') { DemoV1::TicketsQuery.call(scope: RailsToolViews::Scope.new(actor: 'staff:999999', tenant: 'north'), query: '') }
    surface = present_v1(:ticket_card, { ticket_id: ticket.id.to_s }, code: 'north-agent')
    assert_equal({ 'ticket_id' => ticket.id.to_s }, surface.props)
    refute_includes JSON.generate(surface.snapshot), 'north@example.test'
  end
end
