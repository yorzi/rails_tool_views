# frozen_string_literal: true
require "rails/generators"
require "rails/generators/migration"
module RailsToolViews
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path("templates", __dir__)
      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        [Time.now.utc.strftime("%Y%m%d%H%M%S"), format("%014d", next_migration_number)].max
      end
      def install
        migration_template "create_rails_tool_views.rb", "db/migrate/create_rails_tool_views.rb"
        migration_template "add_rails_tool_views_lifecycle.rb", "db/migrate/add_rails_tool_views_lifecycle.rb"
        template "rails_tool_views.rb", "config/initializers/rails_tool_views.rb"
        if behavior == :invoke && engine_mounted?
          say_status :skip, "config/routes.rb already mounts RailsToolViews::Engine", :yellow
        else
          route 'mount RailsToolViews::Engine => "/rails_tool_views", as: :rails_tool_views'
        end
      end

      private
      # A host may keep the :rails_tool_views name under its own path; a second
      # mount with that name stops the routes from loading.
      def engine_mounted?
        routes = File.join(destination_root, "config/routes.rb")
        File.file?(routes) && File.read(routes).match?(/^\s*mount\s+(::)?RailsToolViews::Engine\b/)
      end
    end
  end
end
