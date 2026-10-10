# frozen_string_literal: true
require "bundler/setup"
require "rubygems/package"
require "open3"
require "tmpdir"
require "json"

generative, a2ui = ARGV
abort "Pass the two pinned upstream checkout paths" unless generative && a2ui
pins = { generative => "994410c95042b9c8da660fbf425cee99fb3e2066", a2ui => "d409b71670febabc46d64694461ec1adddd5996f" }
results = {}
pins.each do |directory, pin|
  actual, error, status = Open3.capture3("git", "-C", directory, "rev-parse", "HEAD")
  abort error unless status.success? && actual.strip == pin
  Dir.chdir(directory) do
    spec = Gem::Specification.load(Dir["*.gemspec"].first)
    Dir.mktmpdir("toolviews-upstream-package-") do |temporary|
      package = Gem::Package.build(spec, true, false, File.join(temporary, "#{spec.name}.gem"))
      files = Gem::Package.new(package).contents
      results[spec.name] = { sha: pin, files: files.size, app_files: files.count { |path| path.start_with?("app/") }, mandatory: spec.runtime_dependencies.map(&:name) }
    end
  end
end
control = <<~'CODE'
  require "generative_ui"
  class ProbeCatalog < GenerativeUI::Catalog
    component "ChoiceCard" do
      description "A trusted choice"
      attributes { string :title }
      present_with :partial, "choices/card"
    end
  end
  catalog = ProbeCatalog.new
  raise "Catalog unavailable" unless catalog.names == ["ChoiceCard"] && catalog.tool_arguments_schema[:additionalProperties] == false
  puts "UPSTREAM_CONTROL_PASS"
CODE
output, error, status = Open3.capture3(RbConfig.ruby, "-I#{generative}/lib", "-e", control)
abort error unless status.success?
results["generative_ui"][:normal_load_and_catalog] = output.strip
blocked = <<~'CODE'
  module Kernel
    alias toolviews_require require
    def require(path)
      raise LoadError, "optional SDK blocked by probe" if path == "ruby_llm"
      toolviews_require(path)
    end
  end
  require "generative_ui"
CODE
_output, error, status = Open3.capture3(RbConfig.ruby, "-I#{generative}/lib", "-e", blocked)
abort "Expected an SDK-coupled upstream loader" unless !status.success? && error.include?("optional SDK blocked by probe")
results["generative_ui"][:sdk_blocked_loader] = "EXPECTED_LOAD_FAILURE"
results["limitations"] = ["Blocked SDK load is a require-graph probe, not an upstream neutral-core extraction", "A2UI package inspected; DSPy runtime security not executed", "No upstream maintainer contact, external trials or live provider benchmark"]
puts JSON.pretty_generate(results)
