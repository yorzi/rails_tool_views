# frozen_string_literal: true
require "bundler/setup"
require "rubygems/package"
require "rubygems/installer"
require "tmpdir"
require "fileutils"
require "open3"

root = File.expand_path("..", __dir__)
Dir.chdir(root)
FileUtils.mkdir_p("pkg")
spec = Gem::Specification.load("rails_tool_views.gemspec")
package = Gem::Package.build(spec, true, false, "pkg/rails_tool_views-#{spec.version}.gem")
contents = Gem::Package.new(package).contents
%w[app/controllers/rails_tool_views/surfaces_controller.rb app/helpers/rails_tool_views/surfaces_helper.rb app/models/rails_tool_views/redacted_json.rb app/views/rails_tool_views/surfaces/_surface.html.erb app/assets/javascripts/rails_tool_views_controller.js lib/generators/rails_tool_views/install/templates/create_rails_tool_views.rb].each do |path|
  abort "Missing packaged runtime file: #{path}" unless contents.include?(path)
end
abort "Core depends on RubyLLM" if spec.runtime_dependencies.any? { |dependency| dependency.name == "ruby_llm" }

Dir.mktmpdir("rails_tool_views-package-") do |temporary|
  installed = Gem::Installer.at(File.expand_path(package), install_dir: File.join(temporary, "gems"), ignore_dependencies: true, wrappers: false).install
  host = File.join(temporary, "host")
  output, error, status = Open3.capture3({ "RAILS_TOOL_VIEWS_PACKAGE_BUNDLE" => "1" }, RbConfig.ruby,
    File.join(root, "scripts/support/packaged_host.rb"), File.join(installed.full_gem_path, "lib"), host)
  puts output
  warn error unless error.empty?
  abort "Packaged install failed" unless status.success?
end
