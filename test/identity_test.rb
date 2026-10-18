# frozen_string_literal: true
require_relative "test_helper"
require "open3"

class IdentityTest < ActiveSupport::TestCase
  test "one public identity: no legacy constant, entrypoint or table prefix" do
    assert_nil defined?(::ToolViews)
    %w[toolviews tool_views tool_views/core tool_views/adapters/ruby_llm].each do |path|
      assert_raises(LoadError, path) { require path }
    end
    assert_equal "rails_tool_views_surfaces", RailsToolViews::Surface.table_name
    assert_equal "rails_tool_views_presentations", RailsToolViews::Presentation.table_name
    assert_equal "rails_tool_views_action_executions", RailsToolViews::ActionExecution.table_name
    assert_equal "rails_tool_views_agent_interactions", RailsToolViews::AgentInteraction.table_name
    assert_match(/\Arails_tool_views_surface_/, RailsToolViews::Surface.new(id: "x").dom_id)
    assert_equal "rails_tool_views:interaction:7", RailsToolViews::AgentInteraction.new(id: 7).delivery_key
  end

  test "core-only entrypoint stays independent of Rails and optional adapters" do
    code = 'require ARGV.fetch(0); abort "Rails loaded" if defined?(Rails); abort "RubyLLM loaded" if defined?(RubyLLM); abort "legacy alias" if defined?(ToolViews)'
    output, error, status = Open3.capture3(RbConfig.ruby, "-Ilib", "-e", code, "rails_tool_views/core")
    assert status.success?, output + error
  end

  test "only the rails_tool_views install command is discoverable" do
    require "rails/generators"
    generator = Rails::Generators.find_by_namespace("install", "rails_tool_views")
    assert generator, "Missing rails_tool_views:install"
    assert generator <= RailsToolViews::Generators::InstallGenerator
    assert_nil Rails::Generators.find_by_namespace("install", "tool_views")
  end

  test "view helpers use only the rails_tool_views_ prefix" do
    methods = RailsToolViews::SurfacesHelper.instance_methods
    assert_includes methods, :rails_tool_views_surface
    assert_includes methods, :rails_tool_views_action_form
    assert_empty methods.grep(/\Atool_views_/)
  end

  test "installer migration remains identical to the original database contract" do
    root = File.expand_path("..", __dir__)
    assert_equal File.read(File.join(root, "db/migrate/20261010000000_create_rails_tool_views.rb")),
      File.read(File.join(root, "lib/generators/rails_tool_views/install/templates/create_rails_tool_views.rb"))
  end

  # MySQL/InnoDB refuses a table whose index keys exceed 3072 bytes under
  # utf8mb4 (4 bytes per character). Rails maps `limit:` to varchar(n) on every
  # adapter, so checking each index's worst-case width here keeps the generated
  # migration installable on MySQL as well as SQLite.
  test "every index key stays within the MySQL utf8mb4 byte limit" do
    connection = RailsToolViews::Surface.connection
    tables = %w[rails_tool_views_surfaces rails_tool_views_presentations rails_tool_views_action_executions rails_tool_views_agent_interactions]
    indexes = tables.flat_map { |table| connection.indexes(table).map { |index| [table, index] } }
    assert_not_empty indexes
    indexes.each do |table, index|
      bytes = index.columns.sum do |name|
        column = connection.columns(table).find { |candidate| candidate.name == name }
        %i[integer bigint datetime date].include?(column.type) ? 8 : (column.limit || 255) * 4
      end
      assert_operator bytes, :<=, 3072, "#{table}.#{index.name} needs #{bytes} bytes under utf8mb4"
      # PostgreSQL truncates identifiers past 63 bytes; MySQL rejects past 64.
      assert_operator index.name.bytesize, :<=, 63, "#{index.name} is too long for PostgreSQL"
    end
  end
end
