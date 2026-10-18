# frozen_string_literal: true
require "rails/generators"

module RailsToolViews
  module Generators
    # Generates a trusted Partial definition with closed schemas and denied policies.
    class ComponentGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)
      argument :name, type: :string, required: true, desc: "Flat snake_case component key"
      desc "Generate a Partial, registration and Minitest scaffold. Policies deny access until configured."

      def create_component
        unless name.match?(/\A[a-z][a-z0-9_]{0,63}\z/)
          raise Thor::Error, "Use a flat snake_case name of 1 to 64 characters, starting with a letter."
        end
        outputs = {
          "registration.rb" => "config/rails_tool_views/components/#{name}.rb",
          "partial.html.erb" => "app/views/rails_tool_views/components/_#{name}.html.erb",
          "component_test.rb" => "test/rails_tool_views/components/#{name}_test.rb"
        }
        # Preflight every output before writing any file. Even --force must not
        # destroy host code or follow a symlink outside the destination root.
        root = File.realpath(destination_root)
        outputs.each_value do |relative|
          path = File.join(root, relative)
          if File.exist?(path) || File.symlink?(path)
            raise Thor::Error, "Destination exists: #{relative}. Resolve the conflict before generating."
          end
          parent = File.dirname(path)
          parent = File.dirname(parent) until File.exist?(parent) || File.symlink?(parent)
          begin
            real = File.realpath(parent)
          rescue Errno::ENOENT, Errno::ELOOP
            raise Thor::Error, "Invalid destination parent: #{relative}"
          end
          unless File.directory?(real) && (real == root || real.start_with?(root + File::SEPARATOR))
            raise Thor::Error, "Destination escapes the application: #{relative}"
          end
        end
        outputs.each { |source, target| template(source, target) }
        say "Load config/rails_tool_views/components/*.rb inside your shared to_prepare block after reset_registry!."
        say "Replace BOTH denied policies with host authorization before presenting this component."
      end
    end
  end
end
