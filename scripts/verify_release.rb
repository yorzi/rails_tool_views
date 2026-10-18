# frozen_string_literal: true

# Release-only checks. Run after `bundle exec rake build`, before any upload.
require "rubygems/package"
require "yaml"
require_relative "../lib/rails_tool_views/version"

version = RailsToolViews::VERSION
tag = ENV.fetch("GITHUB_REF_NAME", "v#{version}")
abort "Tag #{tag} does not match v#{version}" unless tag == "v#{version}"
config = YAML.load_file("docs/site/_config.yml")
abort "Docs version differs" unless config.fetch("version") == version
abort "Docs are not marked released" unless config.fetch("released") == true
abort "Missing changelog section" unless File.readlines("CHANGELOG.md").any? { |line| line.start_with?("## [#{version}]") }

package = Gem::Package.new("pkg/rails_tool_views-#{version}.gem")
package.verify
spec = package.spec
abort "Wrong package identity" unless spec.name == "rails_tool_views" && spec.version.to_s == version
abort "Missing license" unless spec.licenses == ["MIT"]
abort "Wrong push host" unless spec.metadata["allowed_push_host"] == "https://rubygems.org"
abort "MFA metadata required" unless spec.metadata["rubygems_mfa_required"] == "true"
abort "Missing documentation URL" unless spec.metadata.fetch("documentation_uri").start_with?("https://")
files = package.contents
required = %w[LICENSE.txt README.md CHANGELOG.md SECURITY.md lib/rails_tool_views.rb lib/rails_tool_views/version.rb]
abort "Missing package files: #{required - files}" unless (required - files).empty?
unexpected = files.reject { |path| path.match?(%r{\A(?:app|config|db|lib)/}) || required.include?(path) }
abort "Unexpected package files: #{unexpected}" unless unexpected.empty?
forbidden = files.select do |path|
  path.match?(%r{(?:\A|/)(?:\.env[^/]*|credentials[^/]*|master\.key|[^/]*\.(?:pem|key|sqlite3?|db|gem))\z}i) ||
    path.match?(%r{(?:\A|/)(?:storage|log|tmp|vendor|node_modules|\.git)(?:/|\z)})
end
abort "Forbidden package files: #{forbidden}" unless forbidden.empty?
abort "Core must not depend on RubyLLM" if spec.runtime_dependencies.any? { |dependency| dependency.name == "ruby_llm" }
puts "RELEASE_PACKAGE_PASS: #{spec.full_name}, #{files.length} reviewed files, tag/docs/changelog/license/MFA metadata aligned"
