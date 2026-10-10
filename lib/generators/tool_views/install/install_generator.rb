# frozen_string_literal: true
require "rails/generators"
require "rails/generators/migration"
module ToolViews
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path("templates", __dir__)
      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        [Time.now.utc.strftime("%Y%m%d%H%M%S"), format("%014d", next_migration_number)].max
      end
      def install
        migration_template "create_tool_views.rb", "db/migrate/create_tool_views.rb"
        template "tool_views.rb", "config/initializers/tool_views.rb"
        route 'mount ToolViews::Engine => "/tool_views", as: :tool_views'
      end
    end
  end
end
