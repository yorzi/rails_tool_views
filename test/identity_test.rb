# frozen_string_literal: true
require_relative "test_helper"
require "open3"

class IdentityTest < ActiveSupport::TestCase
  test "legacy and canonical entrypoints share the registry and configuration" do
    require "toolviews"
    require "tool_views"
    require "tool_views/core"
    assert_same RailsToolViews, ToolViews
    assert_same RailsToolViews.registry, ToolViews.registry
    assert_same RailsToolViews.configuration, ToolViews.configuration
    assert_equal "RailsToolViews::Surface", ToolViews::Surface.name
    assert_equal "tool_views_surfaces", RailsToolViews::Surface.table_name
    assert_equal "tool_views_presentations", RailsToolViews::Presentation.table_name
    assert_equal "tool_views_action_executions", RailsToolViews::ActionExecution.table_name
    assert_equal "tool_views_agent_interactions", RailsToolViews::AgentInteraction.table_name
  end

  test "core-only entrypoint stays independent of Rails and optional adapters" do
    %w[rails_tool_views/core tool_views/core].each do |entrypoint|
      code = 'require ARGV.fetch(0); abort "Rails loaded" if defined?(Rails); abort "RubyLLM loaded" if defined?(RubyLLM); abort "alias split" unless ToolViews.equal?(RailsToolViews)'
      output, error, status = Open3.capture3(RbConfig.ruby, "-Ilib", "-e", code, entrypoint)
      assert status.success?, output + error
    end
  end

  test "legacy and canonical install commands are discoverable" do
    require "rails/generators"
    %w[rails_tool_views tool_views].each do |name|
      generator = Rails::Generators.find_by_namespace("install", name)
      assert generator, "Missing #{name}:install"
      assert generator <= RailsToolViews::Generators::InstallGenerator
    end
  end

  test "canonical and legacy form helpers share implementation" do
    helper = RailsToolViews::SurfacesHelper
    %i[surface action_form action_button action_fields].each do |suffix|
      assert_equal helper.instance_method("tool_views_#{suffix}"), helper.instance_method("rails_tool_views_#{suffix}")
    end
  end

  test "installer migration remains identical to the original database contract" do
    root = File.expand_path("..", __dir__)
    assert_equal File.read(File.join(root, "db/migrate/20261010000000_create_tool_views.rb")),
      File.read(File.join(root, "lib/generators/rails_tool_views/install/templates/create_tool_views.rb"))
  end

  # MySQL/InnoDB refuses a table whose index keys exceed 3072 bytes under
  # utf8mb4 (4 bytes per character). Rails maps `limit:` to varchar(n) on every
  # adapter, so checking each index's worst-case width here keeps the generated
  # migration installable on MySQL as well as SQLite.
  test "every index key stays within the MySQL utf8mb4 byte limit" do
    connection = RailsToolViews::Surface.connection
    tables = %w[tool_views_surfaces tool_views_presentations tool_views_action_executions tool_views_agent_interactions]
    indexes = tables.flat_map { |table| connection.indexes(table).map { |index| [table, index] } }
    assert_not_empty indexes
    indexes.each do |table, index|
      bytes = index.columns.sum do |name|
        column = connection.columns(table).find { |candidate| candidate.name == name }
        %i[integer bigint datetime date].include?(column.type) ? 8 : (column.limit || 255) * 4
      end
      assert_operator bytes, :<=, 3072, "#{table}.#{index.name} needs #{bytes} bytes under utf8mb4"
    end
  end
end
