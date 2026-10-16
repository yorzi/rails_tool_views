# frozen_string_literal: true
require "generators/rails_tool_views/install/install_generator"
module RailsToolViews
  module Generators
    class LegacyInstallGenerator < InstallGenerator
      namespace "tool_views:install"
      source_root InstallGenerator.source_root
    end
  end
end
