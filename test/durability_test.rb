# frozen_string_literal: true
require_relative "test_helper"
require "open3"

class DurabilityTest < ActiveSupport::TestCase
  def workers(surface, keys)
    workers = keys.map { |key| Open3.popen3(RbConfig.ruby, "test/fixtures/runtime_worker.rb", "act", surface.id, key) }
    workers.each { |_input, output, _errors, _thread| assert_equal "ready\n", output.gets }
    workers.each { |input, _output, _errors, _thread| input.puts("start"); input.close }
    workers.map do |_input, output, errors, thread|
      result = JSON.parse(output.read)
      assert thread.value.success?, errors.read
      result
    end
  ensure
    workers&.each { |input, output, errors, thread| [input, output, errors].each { |io| io.close unless io.closed? }; Process.kill("TERM", thread.pid) if thread.alive? }
  end
  test "fresh Ruby process reconstructs the same committed state without an agent" do
    surface = present_card
    act(surface)
    output, errors, status = Open3.capture3(RbConfig.ruby, "test/fixtures/runtime_worker.rb", "restore", surface.id)
    assert status.success?, errors
    snapshot = JSON.parse(output)
    assert_equal 2, snapshot["revision"]
    assert_equal "compare", snapshot["state"]["selected"]
    assert_equal ToolViews::Data.normalize(surface.reload.snapshot), snapshot
  end
  test "the mounted controller inherits the host controller the configuration names" do
    surface = present_card
    output, errors, status = Open3.capture3(RbConfig.ruby, "test/fixtures/parent_controller_worker.rb")
    assert status.success?, errors
    assert_equal({ "superclass" => "SignedInController", "status" => 200, "revision" => 2 }, JSON.parse(output.lines.last))
    assert_equal "::ApplicationController", ToolViews.configuration.parent_controller
    ToolViews.configuration.parent_controller = "ActionController::API"
    error = assert_raises(ArgumentError) { ToolViews.parent_controller }
    assert_includes error.message, "must inherit from ActionController::Base"
    assert_equal 1, surface.reload.revision
  end
  test "separate concurrent workers never repeat host effects for one key" do
    surface = present_card
    results = workers(surface, ["same-request", "same-request"])
    assert results.any? { |result| result["status"] == "completed" }
    assert results.all? { |result| result["status"] == "completed" || result["code"] == "CONFLICT" }
    assert_equal 1, DemoEffect.count
    assert_equal 1, ToolViews::ActionExecution.count
    assert_equal 2, surface.reload.revision
    assert_equal 2, act(surface, revision: 1, idempotency: "same-request")[:revision]
  end
  test "concurrent different requests at the same revision commit one transition" do
    surface = present_card
    results = workers(surface, ["first-request", "second-request"])
    assert_equal 1, results.count { |result| result["status"] == "completed" }
    assert_equal 1, results.count { |result| result["code"] == "CONFLICT" }
    assert_equal 1, DemoEffect.count
    assert_equal 2, surface.reload.revision
  end
end
