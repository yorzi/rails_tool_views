# frozen_string_literal: true

# Resolve dependencies from RubyGems in a fresh GEM_HOME, outside Bundler and the
# source tree. Does not borrow the development bundle or use ignore-dependencies.
require "tmpdir"
require "rbconfig"
require "json"
require "fileutils"
require "digest"
require_relative "../lib/rails_tool_views/version"

if ARGV.include?("--audit")
  require "bundler/audit/database"
  advisory_database = Bundler::Audit::Database.new
  abort "Refresh the advisory database before --audit" if advisory_database.size.zero?
end

version = RailsToolViews::VERSION
source_package = File.expand_path("../pkg/rails_tool_views-#{version}.gem", __dir__)
abort "Build #{source_package} first" unless File.file?(source_package)

Dir.mktmpdir("rails-tool-views-install-") do |temporary|
  # Freeze the input before network resolution; another build must not change
  # the artifact while RubyGems is installing its dependencies.
  package = File.join(temporary, File.basename(source_package))
  FileUtils.cp(source_package, package)
  puts "CLEAN_INSTALL_ARTIFACT_SHA256: #{Digest::SHA256.file(package).hexdigest}"
  $stdout.flush
  gems = File.join(temporary, "gems")
  env = ENV.keys.grep(/\ABUNDLE_/).to_h { |key| [key, nil] }.merge(
    "GEM_HOME" => gems, "GEM_PATH" => gems, "RUBYOPT" => nil, "RUBYLIB" => nil, "RAILS_TOOL_VIEWS_PACKAGE_BUNDLE" => nil
  )
  commands = [
    [RbConfig.ruby, "-S", "gem", "install", package, "--no-document", "--source", "https://rubygems.org"],
    [RbConfig.ruby, "-S", "gem", "install", "sqlite3", "--version", "~> 2.0", "--no-document", "--source", "https://rubygems.org"],
    [RbConfig.ruby, "-e", <<~'RUBY', version, gems, File.join(temporary, "activated.json")],
      require "rubygems"
      require "json"
      gem "rails_tool_views", ARGV.fetch(0)
      require "rails_tool_views"
      require "generators/rails_tool_views/install/install_generator"
      expected = File.realpath(File.join(ARGV.fetch(1), "gems", "rails_tool_views-#{ARGV.fetch(0)}", "lib", "rails_tool_views.rb"))
      abort "Loaded the checkout" unless $LOADED_FEATURES.any? { |path| path.end_with?("/rails_tool_views.rb") && File.realpath(path) == expected }
      abort "RubyLLM loaded in core" if defined?(RubyLLM)
      abort "Wrong version" unless RailsToolViews::VERSION == ARGV.fetch(0)
      Gem.loaded_specs.sort.each { |name, spec| puts "#{name} #{spec.version} license=#{spec.licenses.join(',')}" }
      File.write(ARGV.fetch(2), JSON.generate(Gem.loaded_specs.values.map { |spec| { name: spec.name, version: spec.version.to_s } }))
      puts "CLEAN_INSTALL_PASS: network-resolved dependencies, isolated artifact require and installer load"
    RUBY
    [RbConfig.ruby, File.expand_path("support/packaged_host.rb", __dir__),
      File.join(gems, "gems", "rails_tool_views-#{version}", "lib"), File.join(temporary, "host"), File.join(temporary, "activated.json")]
  ]
  commands.each do |command|
    success = system(env, *command, chdir: temporary)
    abort "Clean installation failed" unless success
  end
  if advisory_database
    findings = JSON.parse(File.read(File.join(temporary, "activated.json"))).flat_map do |entry|
      spec = Gem::Specification.new { |item| item.name = entry.fetch("name"); item.version = entry.fetch("version") }
      advisory_database.check_gem(spec).map { |advisory| "#{spec.full_name}: #{advisory.id}" }
    end
    abort "Activated dependency advisories: #{findings.join(', ')}" unless findings.empty?
    puts "ACTIVATED_DEPENDENCIES_AUDIT_PASS: #{advisory_database.commit_id}"
  end
end
