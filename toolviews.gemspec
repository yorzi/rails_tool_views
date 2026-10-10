# frozen_string_literal: true
require_relative "lib/tool_views/version"
Gem::Specification.new do |spec|
  spec.name = "toolviews"
  spec.version = ToolViews::VERSION
  spec.authors = ["Andy Wang"]
  spec.summary = "Trusted Rails components as persistent, interactive presentation tools"
  spec.description = "A Rails engine for strict component registration, scoped surfaces, durable actions and optional AI adapters."
  spec.required_ruby_version = ">= 3.3"
  spec.files = Dir["{app,config,db,lib}/**/*", "README.md", "CHANGELOG.md", "SECURITY.md", "LICENSE_PENDING.md"].select { |path| File.file?(path) }
  spec.require_paths = ["lib"]
  spec.metadata["allowed_push_host"] = "https://release-not-approved.invalid"
  spec.add_dependency "rails", ">= 7.2", "< 9"
  spec.add_dependency "json_schemer", "~> 2.5"
  spec.add_dependency "turbo-rails", "~> 2.0"
end
