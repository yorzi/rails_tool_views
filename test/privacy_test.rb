# frozen_string_literal: true
require_relative "test_helper"
require "open3"
require "stringio"

class PrivacyTest < ActiveSupport::TestCase
  test "core load excludes RubyLLM even when separately installed" do
    program = 'require "rails_tool_views"; abort if defined?(RubyLLM); begin; require "ruby_llm"; abort; rescue LoadError; puts "isolated"; end'
    output, errors, status = Open3.capture3(RbConfig.ruby, "-Ilib", "-e", program)
    assert status.success?, errors
    assert_equal "isolated\n", output
  end
  test "notifications hide presentation data and snapshots exclude identity" do
    events = []
    token = ActiveSupport::Notifications.subscribe(/\.rails_tool_views\z/) { |*args| events << args.last }
    surface = present_card
    act(surface)
    assert_equal %i[component component_digest id lifecycle props revision state], surface.snapshot.keys.sort
    assert_equal %i[closed_at purged_at retain_until status], surface.snapshot[:lifecycle].keys.sort
    refute_includes JSON.generate(events), "Choose a workflow"
    refute_includes JSON.generate(events), "alice"
    inspected = surface.reload.inspect + RailsToolViews::ActionExecution.first.inspect
    assert_includes inspected, "props: [FILTERED]"
    assert_includes inspected, "state: [FILTERED]"
    assert_includes inspected, "result: [FILTERED]"
    refute_includes inspected, "Choose a workflow"
  ensure
    ActiveSupport::Notifications.unsubscribe(token) if token
  end
  test "SQL bind logging redacts presentation state and continuation payloads" do
    RailsToolViews.reset!
    register_card(agent: true) { |_access| RailsToolViews::Transition.new(state: { selected: "private-state-sentinel" }, agent: true) }
    stream = StringIO.new
    original_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = ActiveSupport::Logger.new(stream)
    surface = present_card
    act(surface)
    refute_includes stream.string, "Choose a workflow"
    refute_includes stream.string, "private-state-sentinel"
    refute_includes stream.string, '\"type\":\"agent_interaction\"'
    assert_includes stream.string, "[FILTERED]"
    assert_equal "private-state-sentinel", surface.reload.state["selected"]
    assert_equal "agent_interaction", RailsToolViews::AgentInteraction.first.payload["type"]
  ensure
    ActiveRecord::Base.logger = original_logger
  end
  test "installing the engine leaves host columns that share its attribute names visible" do
    assert_empty Rails.application.config.filter_parameters & %i[props state payload result arguments values]
    ActiveRecord::Base.connection.create_table(:privacy_probe_orders, temporary: true, force: true) { |table| table.string :state; table.string :result }
    order = Class.new(ActiveRecord::Base) { self.table_name = "privacy_probe_orders" }
    stream = StringIO.new
    original_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = ActiveSupport::Logger.new(stream)
    record = order.create!(state: "host-state-sentinel", result: "host-result-sentinel")
    assert_includes stream.string, "host-state-sentinel"
    assert_includes stream.string, "host-result-sentinel"
    assert_includes record.inspect, "host-state-sentinel"
  ensure
    ActiveRecord::Base.logger = original_logger
    ActiveRecord::Base.connection.drop_table(:privacy_probe_orders, if_exists: true)
  end
  test "host retention deletion removes namespaced receipts and interactions" do
    RailsToolViews.reset!; register_card(agent: true)
    surface = present_card(correlation: { adapter: "test", call_id: "1", context: "chat" })
    act(surface)
    assert_raises(ActiveRecord::StaleObjectError) { surface.destroy! }
    surface.reload.destroy!
    assert_equal 0, RailsToolViews::Surface.count
    assert_equal 0, RailsToolViews::ActionExecution.count
    assert_equal 0, RailsToolViews::AgentInteraction.count
    assert_equal 0, RailsToolViews::Presentation.count
    assert_equal 1, DemoEffect.count # host domain history is a separate authority
  end
end

class RequestLogPrivacyTest < ActionDispatch::IntegrationTest
  include TestFixtures
  setup do
    [RailsToolViews::AgentInteraction, RailsToolViews::ActionExecution, RailsToolViews::Presentation, RailsToolViews::Surface, DemoEffect].each(&:delete_all)
    RailsToolViews.reset!
    register_card
    RailsToolViews.configure { |config| config.scope_resolver = ->(_controller) { scope } }
    @stream = StringIO.new
    @original_logger = ActionController::Base.logger
    ActionController::Base.logger = ActiveSupport::Logger.new(@stream)
  end
  teardown { ActionController::Base.logger = @original_logger }
  test "engine request logs keep routing metadata and mask every other field" do
    surface = present_card
    post "/rails_tool_views/surfaces/#{surface.id}/actions", as: :json, params: { action_name: "select_option", arguments: { key: "compare" },
      base_revision: 1, idempotency_key: "logged-request-1", business_rules: "injected-policy-sentinel" }
    assert_equal "UNKNOWN_FIELD", response.parsed_body["code"]
    post "/rails_tool_views/surfaces/#{surface.id}/actions", as: :json, params: { action_name: "select_option", arguments: { key: "compare" },
      base_revision: 1, idempotency_key: "logged-request-2" }
    assert_response :success
    assert_match(/"arguments"\s*=>\s*"\[FILTERED\]"/, @stream.string)
    assert_match(/"business_rules"\s*=>\s*"\[FILTERED\]"/, @stream.string)
    assert_match(/"idempotency_key"\s*=>\s*"logged-request-2"/, @stream.string)
    assert_match(/"base_revision"\s*=>\s*1/, @stream.string)
    refute_includes @stream.string, "injected-policy-sentinel"
    refute_match(/"key"\s*=>\s*"compare"/, @stream.string)
  end
  test "host request logs keep parameters that share engine field names" do
    post "/demo/present", params: { mode: "page", state: "host-state-sentinel", result: "host-result-sentinel", arguments: "host-arguments-sentinel" }
    assert_response :see_other
    %w[host-state-sentinel host-result-sentinel host-arguments-sentinel].each { |value| assert_includes @stream.string, value }
  end
end
