# frozen_string_literal: true
require_relative "test_helper"
require "open3"
require "stringio"

class PrivacyTest < ActiveSupport::TestCase
  test "core load excludes RubyLLM even when separately installed" do
    program = 'require "toolviews"; abort if defined?(RubyLLM); begin; require "ruby_llm"; abort; rescue LoadError; puts "isolated"; end'
    output, errors, status = Open3.capture3(RbConfig.ruby, "-Ilib", "-e", program)
    assert status.success?, errors
    assert_equal "isolated\n", output
  end
  test "notifications hide presentation data and snapshots exclude identity" do
    events = []
    token = ActiveSupport::Notifications.subscribe(/\.tool_views\z/) { |*args| events << args.last }
    surface = present_card
    act(surface)
    assert_equal %i[component component_digest id props revision state], surface.snapshot.keys.sort
    refute_includes JSON.generate(events), "Choose a workflow"
    refute_includes JSON.generate(events), "alice"
    filtered = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters).filter({ "props" => "sensitive", "arguments" => "sensitive" })
    assert_equal "[FILTERED]", filtered["props"]
    assert_equal "[FILTERED]", filtered["arguments"]
  ensure
    ActiveSupport::Notifications.unsubscribe(token) if token
  end
  test "SQL bind logging redacts presentation state and continuation payloads" do
    ToolViews.reset!
    register_card(agent: true) { |_access| ToolViews::Transition.new(state: { selected: "private-state-sentinel" }, agent: true) }
    stream = StringIO.new
    original_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = ActiveSupport::Logger.new(stream)
    surface = present_card
    act(surface)
    refute_includes stream.string, "Choose a workflow"
    refute_includes stream.string, "private-state-sentinel"
    refute_includes stream.string, '\"type\":\"agent_interaction\"'
    assert_includes stream.string, "[FILTERED]"
    filtered = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters).filter({ "state" => "private", "payload" => "private", "result" => "private" })
    assert_equal ["[FILTERED]"] * 3, filtered.values
  ensure
    ActiveRecord::Base.logger = original_logger
  end
  test "host retention deletion removes namespaced receipts and interactions" do
    ToolViews.reset!; register_card(agent: true)
    surface = present_card(correlation: { adapter: "test", call_id: "1", context: "chat" })
    act(surface)
    assert_raises(ActiveRecord::StaleObjectError) { surface.destroy! }
    surface.reload.destroy!
    assert_equal 0, ToolViews::Surface.count
    assert_equal 0, ToolViews::ActionExecution.count
    assert_equal 0, ToolViews::AgentInteraction.count
    assert_equal 0, ToolViews::Presentation.count
    assert_equal 1, DemoEffect.count # host domain history is a separate authority
  end
end
