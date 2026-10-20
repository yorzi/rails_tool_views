# frozen_string_literal: true
require_relative "test_helper"
require "open3"

class HostJobRecoveryTest < ActiveSupport::TestCase
  setup do
    DemoV1::Seeds.call
    DemoV1::Registration.call
    RailsToolViews.configuration.agent_adapter = DemoV1::Agent.new
    RailsToolViews.configuration.auto_deliver = false
    @staff = DemoStaff.find_by!(code: "north-lead")
    @scope = DemoV1::Access.scope_for(@staff)
    @ticket = DemoTicket.find_by!(code: "north-ticket")
    @surface = RailsToolViews.present(:ticket_card, props: { ticket_id: @ticket.id.to_s }, scope: @scope)
    @result = RailsToolViews.dispatch(@surface.id, scope: @scope, action: "draft_reply", arguments: { reply_version: "0" },
      base_revision: 1, idempotency_key: "job-draft")
    @interaction = RailsToolViews::AgentInteraction.find(@result.fetch(:interaction_id))
  end

  test "a host job resumes committed pending work after a separate boot" do
    assert_equal "pending", @interaction.status
    assert_equal 0, DemoReply.count
    output, error, status = Open3.capture3(RbConfig.ruby, "test/fixtures/v1_worker.rb", "deliver", @interaction.id.to_s)
    assert status.success?, error
    assert_equal "completed", JSON.parse(output).fetch("status")
    assert_equal "completed", @interaction.reload.status
    assert_equal 1, DemoReply.uncached { DemoReply.count }
    assert_equal 1, DemoAgentReceipt.uncached { DemoAgentReceipt.count }
    assert_equal 2, @surface.reload.revision
  end

  test "process death after a durable host effect recovers with the same key and no duplicate effect" do
    _output, error, status = Open3.capture3(RbConfig.ruby, "test/fixtures/v1_worker.rb", "crash_after_effect", @interaction.id.to_s)
    assert_equal 73, status.exitstatus, error
    assert_equal "delivering", @interaction.reload.status
    assert_equal 1, DemoReply.uncached { DemoReply.count }
    receipt = DemoAgentReceipt.uncached { DemoAgentReceipt.find_by!(delivery_key: @interaction.delivery_key) }
    reply = DemoReply.uncached { DemoReply.find_by!(ticket_id: @ticket.id) }
    before = reply.attributes
    assert_equal "delivering", DemoV1::ContinuationJob.perform_now(@interaction.id, staff_id: @staff.id).status
    @interaction.update!(claimed_at: 1.hour.ago)
    output, error, status = Open3.capture3(RbConfig.ruby, "test/fixtures/v1_worker.rb", "deliver", @interaction.id.to_s)
    assert status.success?, error
    result = JSON.parse(output)
    assert_equal "completed", result.fetch("status")
    assert_equal receipt.delivery_key, result.fetch("delivery_key")
    assert_equal 2, result.fetch("attempts")
    assert_equal before, reply.reload.attributes
    assert_equal 1, DemoAgentReceipt.uncached { DemoAgentReceipt.count }
    assert @interaction.reload.delivery_uncertain?
    assert_error("LIFECYCLE_BUSY") { RailsToolViews.close(@surface.id, scope: @scope) }
  end

  test "failed work requires explicit job retry and preserves the committed action" do
    RailsToolViews.configuration.agent_adapter = ->(*) { raise "offline failure" }
    assert_equal "failed", DemoV1::ContinuationJob.perform_now(@interaction.id, staff_id: @staff.id).status
    RailsToolViews.configuration.agent_adapter = DemoV1::Agent.new
    assert_equal "failed", DemoV1::ContinuationJob.perform_now(@interaction.id, staff_id: @staff.id).status
    assert_equal 0, DemoReply.count
    assert_equal "completed", DemoV1::ContinuationJob.perform_now(@interaction.id, staff_id: @staff.id, retry_failed: true).status
    assert_equal 1, DemoReply.count
    assert_equal 1, DemoAgentReceipt.count
    assert_equal 1, RailsToolViews::ActionExecution.count
    assert_equal 2, @surface.reload.revision
    refute @interaction.reload.delivery_uncertain?
  end

  test "jobs recheck active staff and scoped permissions instead of trusting the queued identity" do
    @staff.update!(active: false)
    assert_error("NOT_ALLOWED") { DemoV1::ContinuationJob.perform_now(@interaction.id, staff_id: @staff.id) }
    other = DemoStaff.find_by!(code: "south-lead")
    assert_error("NOT_FOUND") { DemoV1::ContinuationJob.perform_now(@interaction.id, staff_id: other.id) }
    @staff.update!(active: true)
    @ticket.update!(tenant_ref: "south")
    assert_error("NOT_ALLOWED") { DemoV1::ContinuationJob.perform_now(@interaction.id, staff_id: @staff.id) }
    assert_equal "pending", @interaction.reload.status
    assert_equal 0, DemoAgentReceipt.count
    assert_equal 0, DemoReply.count
  end
end
