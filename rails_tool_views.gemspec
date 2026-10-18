# frozen_string_literal: true
require_relative "lib/rails_tool_views/version"
Gem::Specification.new do |spec|
  spec.name = "rails_tool_views"
  spec.version = RailsToolViews::VERSION
  spec.authors = ["Andy Wang"]
  spec.email = ["wangyaodi@gmail.com"]
  spec.license = "MIT"
  spec.summary = "Trusted Rails components as persistent, interactive presentation tools"
  spec.description = "A Rails engine for strict component registration, scoped surfaces, durable actions and optional AI adapters."
  spec.required_ruby_version = ">= 3.3"
  spec.files = Dir["{app,config,db,lib}/**/*", "README.md", "CHANGELOG.md", "SECURITY.md", "LICENSE.txt"].select { |path| File.file?(path) }
  spec.require_paths = ["lib"]
  spec.homepage = "https://github.com/yorzi/rails_tool_views"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rails-tool-views.wangyaodi.com"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.add_dependency "rails", ">= 7.2", "< 9"
  spec.add_dependency "json_schemer", "~> 2.5"
  spec.add_dependency "turbo-rails", "~> 2.0"
  # A clean Ruby 3.3 install otherwise accepts vulnerable bundled/default gems.
  spec.add_dependency "cgi", ">= 0.4.2", "< 1"
  spec.add_dependency "erb", ">= 6.0.4", "< 7"
  spec.add_dependency "resolv", ">= 0.7.2", "< 1"
  spec.add_dependency "uri", ">= 1.0.4", "< 2"
  spec.add_dependency "zlib", ">= 3.2.3", "< 4"
end
