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
spec = Gem::Specification.load("toolviews.gemspec")
package = Gem::Package.build(spec, true, false, "pkg/toolviews-#{spec.version}.gem")
contents = Gem::Package.new(package).contents
%w[app/controllers/tool_views/surfaces_controller.rb app/helpers/tool_views/surfaces_helper.rb app/models/tool_views/redacted_json.rb app/views/tool_views/surfaces/_surface.html.erb app/assets/javascripts/tool_views_controller.js lib/generators/tool_views/install/templates/create_tool_views.rb].each do |path|
  abort "Missing packaged runtime file: #{path}" unless contents.include?(path)
end
abort "Core depends on RubyLLM" if spec.runtime_dependencies.any? { |dependency| dependency.name == "ruby_llm" }

Dir.mktmpdir("toolviews-package-") do |temporary|
  installed = Gem::Installer.at(File.expand_path(package), install_dir: File.join(temporary, "gems"), ignore_dependencies: true, wrappers: false).install
  host = File.join(temporary, "host")
  FileUtils.mkdir_p(File.join(host, "config"))
  FileUtils.mkdir_p(File.join(host, "app", "views", "choices"))
  FileUtils.mkdir_p(File.join(host, "app", "helpers"))
  FileUtils.mkdir_p(File.join(host, "storage"))
  File.write(File.join(host, "config", "database.yml"), "test:\n  adapter: sqlite3\n  database: #{host}/storage/test.sqlite3\n")
  File.write(File.join(host, "config", "routes.rb"), "Rails.application.routes.draw do\nend\n")
  File.write(File.join(host, "app", "helpers", "packaged_helper.rb"), 'module PackagedHelper; def packaged_title(value); value; end; ' \
    'def definition_has_action?(surface); ToolViews.registry.fetch(surface.component_key).actions.key?("select_option"); end; end')
  File.write(File.join(host, "app", "views", "choices", "_card.html.erb"), '<h2><%= packaged_title(props.fetch("title")) %></h2><p><%= state["selected"] %></p>' \
    '<%= tool_views_action_button(surface, :select_option, "Pick a", arguments: { key: "a" }) if definition_has_action?(surface) %>')
  probe = <<~'CODE'
    ENV["RAILS_ENV"] = "test"
    require "bundler/setup"
    ToolViews.send(:remove_const, :VERSION) if defined?(ToolViews::VERSION)
    $LOAD_PATH.unshift(ARGV.fetch(0))
    require "rails"
    require "active_record/railtie"
    require "action_controller/railtie"
    require "action_view/railtie"
    require "turbo-rails"
    require "tool_views"
    require "generators/tool_views/install/install_generator"
    require "action_dispatch/testing/integration"
    require "rails/zeitwerk_checker"
    raise "Loaded source checkout instead of installed gem" unless $LOADED_FEATURES.any? { |path| path.end_with?("/tool_views.rb") && File.realpath(path) == File.realpath(File.join(ARGV[0], "tool_views.rb")) }
    raise "RubyLLM loaded" if defined?(RubyLLM)
    class PackagedHost < Rails::Application
      config.root = ARGV.fetch(1)
      config.load_defaults 7.2
      config.eager_load = false
      config.secret_key_base = "isolated-package-fixture-#{'0' * 64}"
      config.hosts = ["www.example.com"]
      config.action_controller.allow_forgery_protection = false
    end
    Rails.application.initialize!
    ToolViews::Generators::InstallGenerator.start([], destination_root: ARGV.fetch(1))
    Rails.application.reload_routes!
    ActiveRecord::MigrationContext.new(File.join(ARGV[1], "db", "migrate")).migrate
    class ApplicationController < ActionController::Base
      def host_authenticated_scope
        ToolViews::Scope.new(actor: "alice", tenant: "acme")
      end
    end
    scope = ToolViews::Scope.new(actor: "alice", tenant: "acme")
    ToolViews.configure { |config| config.scope_resolver = ->(controller) { controller.host_authenticated_scope } }
    schema = { type: "object", additionalProperties: false, required: ["title"], properties: { title: { type: "string" } } }
    params_schema = { type: "object", additionalProperties: false, required: ["key"], properties: { key: { type: "string", enum: ["a"] } } }
    ToolViews.register(:choice_card, description: "Packaged ChoiceCard", schema: schema, partial: "choices/card", policy: ->(_access) { true },
      actions: { select_option: { schema: params_schema, policy: ->(_access) { true }, handler: ->(access) { ToolViews::Transition.new(state: { selected: access.arguments.fetch("key") }) } } })
    surface = ToolViews.present(:choice_card, props: { title: "Packaged <safe> card" }, scope: scope)
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.response = ActionDispatch::TestResponse.new
    html = ToolViews.render(surface, view_context: controller.view_context, scope: scope)
    raise "Installed partial did not render" unless html.include?("Packaged &lt;safe&gt; card")
    raise "Installed action helper did not render a form" unless html.include?(%(action="/tool_views/surfaces/#{surface.id}/actions")) && html.include?(%(name="arguments[key]")) && html.include?(%(name="idempotency_key"))
    client = ActionDispatch::Integration::Session.new(Rails.application)
    client.post("/tool_views/surfaces/#{surface.id}/actions", params: { action: "select_option", arguments: { key: "a" }, base_revision: 1, idempotency_key: "packaged-1" }, as: :json)
    raise "Installed action controller failed: #{client.response.body}" unless client.response.status == 200
    raise "Installed persistence failed" unless ToolViews.restore(surface.id, scope: scope).state["selected"] == "a"
    ToolViews.register(:invalid_form, description: "Validation feedback", schema: schema, partial: "choices/card", policy: ->(_access) { true },
      actions: { submit_form: { schema: params_schema, policy: ->(_access) { true }, handler: ->(access) {
        raise ToolViews::ValidationError.new(fields: { key: "needs correction" }, values: access.arguments)
      } } })
    invalid = ToolViews.present(:invalid_form, props: { title: "Correct this form" }, scope: scope)
    client.post("/tool_views/surfaces/#{invalid.id}/actions", params: { action: "submit_form", arguments: { key: "a" }, base_revision: 1, idempotency_key: "invalid-1" }, as: :json)
    feedback = JSON.parse(client.response.body)
    raise "Installed validation feedback failed" unless client.response.status == 422 && feedback["fields"] == { "key" => "needs correction" } && feedback["values"] == { "key" => "a" }
    raise "Rejected form changed persistence" unless invalid.reload.revision == 1
    Rails::ZeitwerkChecker.check
    puts "PACKAGED_INSTALL_PASS: installer -> fresh Rails host -> host authentication/helper -> escaped partial -> action form helper -> HTTP action -> validation feedback -> durable restore -> eager load"
  CODE
  program = File.join(temporary, "probe.rb")
  File.write(program, probe)
  output, error, status = Open3.capture3(RbConfig.ruby, program, File.join(installed.full_gem_path, "lib"), host)
  puts output
  warn error unless error.empty?
  abort "Packaged install failed" unless status.success?
end
