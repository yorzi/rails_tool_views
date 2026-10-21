# frozen_string_literal: true
# Internal shared fixture: exercise the installed gem, never the source checkout.
require "fileutils"
require "json"

host = File.expand_path(ARGV.fetch(1))
FileUtils.mkdir_p(File.join(host, "config"))
FileUtils.mkdir_p(File.join(host, "app", "views", "choices"))
FileUtils.mkdir_p(File.join(host, "app", "helpers"))
FileUtils.mkdir_p(File.join(host, "storage"))
File.write(File.join(host, "config", "database.yml"), "test:\n  adapter: sqlite3\n  database: #{host}/storage/test.sqlite3\n")
File.write(File.join(host, "config", "routes.rb"), "Rails.application.routes.draw do\nend\n")
File.write(File.join(host, "app", "helpers", "packaged_helper.rb"), 'module PackagedHelper; def packaged_title(value); value; end; ' \
  'def definition_has_action?(surface); RailsToolViews.registry.fetch(surface.component_key).actions.key?("select_option"); end; end')
File.write(File.join(host, "app", "views", "choices", "_card.html.erb"), '<h2><%= packaged_title(props.fetch("title")) %></h2><p><%= state["selected"] %></p>' \
  '<%= rails_tool_views_action_button(surface, :select_option, "Pick a", arguments: { key: "a" }) if definition_has_action?(surface) %>')
ENV["RAILS_ENV"] = "test"
require "bundler/setup" if ENV["RAILS_TOOL_VIEWS_PACKAGE_BUNDLE"] == "1"
RailsToolViews.send(:remove_const, :VERSION) if defined?(RailsToolViews::VERSION)
$LOAD_PATH.unshift(ARGV.fetch(0))
require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "turbo-rails"
# The development bundle includes ViewComponent; an isolated runtime-only install does not.
begin
  require "view_component"
rescue LoadError
  nil
end
require "rails_tool_views"
require "generators/rails_tool_views/install/install_generator"
require "action_dispatch/testing/integration"
require "rails/zeitwerk_checker"
raise "Loaded source checkout instead of installed gem" unless $LOADED_FEATURES.any? { |path| path.end_with?("/rails_tool_views.rb") && File.realpath(path) == File.realpath(File.join(ARGV[0], "rails_tool_views.rb")) }
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
RailsToolViews::Generators::InstallGenerator.start([], destination_root: ARGV.fetch(1))
Rails.application.reload_routes!
ActiveRecord::MigrationContext.new(File.join(ARGV[1], "db", "migrate")).migrate
class ApplicationController < ActionController::Base
  def host_authenticated_scope
    RailsToolViews::Scope.new(actor: "alice", tenant: "acme")
  end
end
scope = RailsToolViews::Scope.new(actor: "alice", tenant: "acme")
RailsToolViews.configure { |config| config.scope_resolver = ->(controller) { controller.host_authenticated_scope } }
schema = { type: "object", additionalProperties: false, required: ["title"], properties: { title: { type: "string" } } }
params_schema = { type: "object", additionalProperties: false, required: ["key"], properties: { key: { type: "string", enum: ["a"] } } }
RailsToolViews.register(:choice_card, description: "Packaged ChoiceCard", schema: schema, partial: "choices/card", policy: ->(_access) { true },
  actions: { select_option: { schema: params_schema, policy: ->(_access) { true }, handler: ->(access) { RailsToolViews::Transition.new(state: { selected: access.arguments.fetch("key") }) } } })
surface = RailsToolViews.present(:choice_card, props: { title: "Packaged <safe> card" }, scope: scope)
controller = ApplicationController.new
controller.request = ActionDispatch::TestRequest.create
controller.response = ActionDispatch::TestResponse.new
html = RailsToolViews.render(surface, view_context: controller.view_context, scope: scope)
raise "Installed partial did not render" unless html.include?("Packaged &lt;safe&gt; card")
raise "Installed action helper did not render a form" unless html.include?(%(action="/rails_tool_views/surfaces/#{surface.id}/actions")) && html.include?(%(name="arguments[key]")) && html.include?(%(name="idempotency_key"))
client = ActionDispatch::Integration::Session.new(Rails.application)
client.post("/rails_tool_views/surfaces/#{surface.id}/actions", params: { action: "select_option", arguments: { key: "a" }, base_revision: 1, idempotency_key: "packaged-1" }, as: :json)
raise "Installed action controller failed: #{client.response.body}" unless client.response.status == 200
raise "Installed persistence failed" unless RailsToolViews.restore(surface.id, scope: scope).state["selected"] == "a"
# Same receipt through Turbo must replace only the authorized Surface once.
client.post("/rails_tool_views/surfaces/#{surface.id}/actions", params: { action_name: "select_option", arguments: { key: "a" }, base_revision: 1, idempotency_key: "packaged-1" }, headers: { "Accept" => "text/vnd.turbo-stream.html" })
raise "Installed Turbo replay failed" unless client.response.status == 200 && client.response.body.include?(%(target="#{surface.dom_id}")) && surface.reload.revision == 2 && RailsToolViews::ActionExecution.where(surface_id: surface.id).count == 1
client.post("/rails_tool_views/surfaces/#{surface.id}/actions", params: { action_name: "select_option", arguments: { key: "a" }, base_revision: 1, idempotency_key: "packaged-stale" }, headers: { "Accept" => "text/html" })
raise "Installed stale HTML guard failed" unless client.response.status == 409 && client.response.body.match?(/<!doctype html>/i) && surface.reload.revision == 2
RailsToolViews.configure { |config| config.scope_resolver = ->(_controller) { RailsToolViews::Scope.new(actor: "other", tenant: "acme") } }
client.get("/rails_tool_views/surfaces/#{surface.id}", headers: { "Accept" => "text/html" })
raise "Installed scoped denial failed" unless client.response.status == 404 && client.response.body.match?(/<!doctype html>/i) && !client.response.body.include?("Packaged &lt;safe&gt; card") && !client.response.body.include?("<form")
RailsToolViews.configure { |config| config.scope_resolver = ->(controller) { controller.host_authenticated_scope } }
# Without Turbo and without a referrer, the action returns to the Surface under the installer's mount.
client.post("/rails_tool_views/surfaces/#{surface.id}/actions", params: { action_name: "select_option", arguments: { key: "a" }, base_revision: 2, idempotency_key: "packaged-2" }, headers: { "Accept" => "text/html" })
raise "Installed HTML fallback failed: #{client.response.status} #{client.response.location}" unless client.response.status == 303 && client.response.location == "http://www.example.com/rails_tool_views/surfaces/#{surface.id}"
client.follow_redirect!
raise "Installed Surface is not a complete HTML page" unless client.response.status == 200 && client.response.body.match?(/<!doctype html>/i) && client.response.body.include?("<main")
RailsToolViews.register(:invalid_form, description: "Validation feedback", schema: schema, partial: "choices/card", policy: ->(_access) { true },
  actions: { submit_form: { schema: params_schema, policy: ->(_access) { true }, handler: ->(access) {
    raise RailsToolViews::ValidationError.new(fields: { key: "needs correction" }, values: access.arguments)
  } } })
invalid = RailsToolViews.present(:invalid_form, props: { title: "Correct this form" }, scope: scope)
client.post("/rails_tool_views/surfaces/#{invalid.id}/actions", params: { action: "submit_form", arguments: { key: "a" }, base_revision: 1, idempotency_key: "invalid-1" }, as: :json)
feedback = JSON.parse(client.response.body)
raise "Installed validation feedback failed" unless client.response.status == 422 && feedback["fields"] == { "key" => "needs correction" } && feedback["values"] == { "key" => "a" }
raise "Rejected form changed persistence" unless invalid.reload.revision == 1
renderers = "Partial"
if defined?(ViewComponent::Base)
  # The second trusted renderer, opting into Surface context by keyword.
  Object.const_set(:PackagedChoiceComponent, Class.new(ViewComponent::Base) {
    include RailsToolViews::SurfacesHelper
    def initialize(title:, surface:, state:)
      @title, @surface, @state = title, surface, state
    end
    def call
      safe_join([content_tag(:h2, @title), content_tag(:p, @state["selected"]),
        rails_tool_views_action_button(@surface, :select_option, "Pick a", arguments: { key: "a" })])
    end
  })
  RailsToolViews.register(:component_card, description: "Packaged ViewComponent", schema: schema, component: PackagedChoiceComponent, policy: ->(_access) { true },
    actions: { select_option: { schema: params_schema, policy: ->(_access) { true }, handler: ->(access) { RailsToolViews::Transition.new(state: { selected: access.arguments.fetch("key") }) } } })
  component = RailsToolViews.present(:component_card, props: { title: "Component <safe> card" }, scope: scope)
  html = RailsToolViews.render(component, view_context: controller.view_context, scope: scope)
  raise "Installed ViewComponent did not render" unless html.include?("Component &lt;safe&gt; card") && html.include?(%(action="/rails_tool_views/surfaces/#{component.id}/actions"))
  client.post("/rails_tool_views/surfaces/#{component.id}/actions", params: { action_name: "select_option", arguments: { key: "a" }, base_revision: 1, idempotency_key: "component-1" }, headers: { "Accept" => "text/vnd.turbo-stream.html" })
  raise "Installed ViewComponent action failed" unless client.response.status == 200 && client.response.body.include?(%(target="#{component.dom_id}")) && component.reload.state["selected"] == "a"
  client.get("/rails_tool_views/surfaces/#{component.id}", headers: { "Accept" => "text/html" })
  raise "Installed ViewComponent did not restore" unless client.response.status == 200 && client.response.body.include?("<p>a</p>")
  renderers = "Partial/ViewComponent"
end
# The installed component generator must produce a runnable, closed-by-default scaffold.
require "generators/rails_tool_views/component/component_generator"
RailsToolViews::Generators::ComponentGenerator.start(["review_card"], destination_root: host)
registration = File.join(host, "config/rails_tool_views/components/review_card.rb")
load registration
begin
  RailsToolViews.present(:review_card, props: { title: "Review" }, scope: scope)
  raise "Generated component was allowed by default"
rescue RailsToolViews::Error => error
  raise unless error.code == "NOT_ALLOWED"
end
# Host-authorized fixture policies replace both denied defaults explicitly.
File.write(registration, File.read(registration).gsub("->(_access) { false }", '->(access) { access.actor == "alice" && access.tenant == "acme" }'))
RailsToolViews.reset_registry!
load registration
review = RailsToolViews.present(:review_card, props: { title: "Generated <safe> review" }, scope: scope)
html = RailsToolViews.render(review, view_context: controller.view_context, scope: scope)
raise "Generated partial/form failed" unless html.include?("Generated &lt;safe&gt; review") && html.include?('name="arguments[value]"')
client.post("/rails_tool_views/surfaces/#{review.id}/actions", params: { action_name: "set_value", arguments: { value: "invalid", injected: "rejected" }, base_revision: 1, idempotency_key: "generated-invalid" }, headers: { "Accept" => "text/html" })
raise "Generated invalid action is not a full correction page" unless client.response.status == 400 && client.response.body.match?(/<!doctype html>/i) && client.response.body.include?('name="arguments[value]"') && review.reload.revision == 1
client.post("/rails_tool_views/surfaces/#{review.id}/actions", params: { action_name: "set_value", arguments: { value: "reviewed" }, base_revision: 1, idempotency_key: "generated-1" }, headers: { "Accept" => "text/html", "Referer" => "http://www.example.com/rails_tool_views/surfaces/#{review.id}/actions" })
raise "Generated HTML correction failed" unless client.response.status == 303 && client.response.location == "http://www.example.com/rails_tool_views/surfaces/#{review.id}" && review.reload.state["value"] == "reviewed"
client.follow_redirect!
raise "Generated saved view did not restore" unless client.response.status == 200 && client.response.body.include?('value="reviewed"')
# Exercise delivery from the installed artifact with a durable host receipt.
RailsToolViews.register(:recovery_card, description: "Host recovery fixture", schema: schema, partial: "choices/card", policy: ->(_) { true },
  actions: { save: { schema: params_schema, policy: ->(_) { true }, handler: ->(_) {
    RailsToolViews::Transition.new(state: { saved: true }, agent: true, notice: "Host work saved.")
  } } })
ActiveRecord::Base.connection.create_table(:host_delivery_receipts) { |t| t.string :delivery_key, null: false; t.index :delivery_key, unique: true }
host_receipt = Class.new(ActiveRecord::Base) { self.table_name = "host_delivery_receipts" }
calls = 0
RailsToolViews.configuration.agent_adapter = ->(_payload, delivery_key:) {
  calls += 1
  host_receipt.create_or_find_by!(delivery_key: delivery_key)
  raise "offline failure after host commit" if calls == 1
}
recovery = RailsToolViews.present(:recovery_card, props: { title: "Recovery" }, scope: scope)
receipt = RailsToolViews.dispatch(recovery.id, scope: scope, action: "save", arguments: { key: "a" }, base_revision: 1, idempotency_key: "recover-once")
raise "Installed notice missing" unless receipt[:notice] == "Host work saved." && !recovery.reload.snapshot.to_json.include?("notice")
interaction_id = receipt.fetch(:interaction_id)
ActiveRecord::Base.transaction do
  begin
    RailsToolViews.deliver(interaction_id, scope: scope)
    raise "Installed delivery ran inside a transaction"
  rescue RailsToolViews::Error => error
    raise unless error.code == "DELIVERY_IN_TRANSACTION"
  end
end
raise "Installed failed outcome lost" unless RailsToolViews.deliver(interaction_id, scope: scope).status == "failed"
raise "Installed delivery retried implicitly" unless RailsToolViews.deliver(interaction_id, scope: scope).status == "failed" && calls == 1
delivered = RailsToolViews.deliver(interaction_id, scope: scope, retry_failed: true)
raise "Installed recovery duplicated the host effect" unless delivered.status == "completed" && delivered.attempts == 2 &&
  !delivered.delivery_uncertain? && host_receipt.count == 1 && host_receipt.first.delivery_key == delivered.delivery_key && recovery.reload.revision == 2
# A worker without an adapter keeps the work; a takeover after a lost worker
# leaves uncertainty that only the host's own receipt can resolve.
takeover = RailsToolViews.present(:recovery_card, props: { title: "Takeover" }, scope: scope)
lost = RailsToolViews::AgentInteraction.find(RailsToolViews.dispatch(takeover.id, scope: scope, action: "save", arguments: { key: "a" },
  base_revision: 1, idempotency_key: "takeover").fetch(:interaction_id))
begin
  RailsToolViews.deliver(lost.id, scope: scope, adapter: nil)
  raise "Installed delivery dropped work without an adapter"
rescue RailsToolViews::Error => error
  raise unless error.code == "AGENT_NOT_CONFIGURED" && lost.reload.status == "pending"
end
lost.update!(status: "delivering", claimed_at: 1.hour.ago, attempts: 1)
uncertain = RailsToolViews.deliver(lost.id, scope: scope)
raise "Installed takeover lost uncertainty" unless uncertain.status == "completed" && uncertain.delivery_uncertain?
begin
  RailsToolViews.close(takeover.id, scope: scope)
  raise "Installed uncertain view closed"
rescue RailsToolViews::Error => error
  raise unless error.code == "LIFECYCLE_BUSY"
end
RailsToolViews.configuration.reconciliation_policy = ->(access) { access.operation == :reconcile && access.actor == "alice" }
outcome = host_receipt.exists?(delivery_key: lost.delivery_key) ? :completed : :failed
reconciled = RailsToolViews.reconcile_delivery(lost.id, scope: scope, outcome: outcome)
raise "Installed reconciliation failed" unless outcome == :completed && reconciled.status == "completed" && !reconciled.delivery_uncertain?
RailsToolViews.close(takeover.id, scope: scope, retain_until: 1.day.from_now)

# Exercise actual lifecycle code from the installed artifact.
RailsToolViews.close(review.id, scope: scope, retain_until: 1.day.from_now)
raise "Installed lifecycle did not close" unless review.reload.closed? && review.revision == 3
client.get("/rails_tool_views/surfaces/#{review.id}", headers: { "Accept" => "text/html" })
raise "Installed closed view still accepts forms" unless client.response.body.include?("View closed.") && !client.response.body.include?("<form")
replay = RailsToolViews.dispatch(review.id, scope: scope, action: "set_value", arguments: { value: "reviewed" }, base_revision: 1, idempotency_key: "generated-1")
raise "Installed closed receipt failed" unless replay[:revision] == 2 && review.reload.revision == 3
RailsToolViews.configure { |config| config.retention_policy = ->(access) { access.operation == :purge && access.actor == "alice" } }
# The fixture advances its clock after exercising the real future-deadline API.
require "active_support/testing/time_helpers"
Object.new.extend(ActiveSupport::Testing::TimeHelpers).travel_to(2.days.from_now) do
  preview = RailsToolViews.purge_closed(scope: scope, closed_before: Time.current, batch_size: 1)
  raise "Installed preview mutated data" unless preview[:eligible] == 1 && preview[:purged] == 0 && preview[:next_after] && review.reload.props.any?
  purged, after = 0, nil
  loop do
    applied = RailsToolViews.purge_closed(scope: scope, closed_before: Time.current, batch_size: 1, dry_run: false, after: after)
    purged += applied[:purged]
    after = applied[:next_after] or break
  end
  raise "Installed cleanup failed" unless purged == 2 && takeover.reload.purged? && review.reload.purged? && review.props.empty? && review.state.empty? && review.action_executions.count.zero?
  client.get("/rails_tool_views/surfaces/#{review.id}", headers: { "Accept" => "text/html" })
  raise "Installed tombstone response failed" unless client.response.status == 410
end
require "rake"
Rails.application.load_tasks
ENV["FROM"] = "rails_tool_views"
Rake::Task["railties:install:migrations"].invoke
raise "Standard migration task duplicated installer files" unless Dir[File.join(host, "db/migrate/*.rb")].size == 2
# Run the actual generated Minitest file after restoring its safe default.
File.write(registration, File.read(registration).gsub('->(access) { access.actor == "alice" && access.tenant == "acme" }', "->(_access) { false }"))
FileUtils.mkdir_p(File.join(host, "test"))
File.write(File.join(host, "test/test_helper.rb"), 'require "rails/test_help"')
$LOAD_PATH.unshift(File.join(host, "test"))
# Load the safe registration exactly as the documented host reload hook does.
RailsToolViews.reset_registry!
load registration
# This fixture already ran its timestamped installer migration above.
ActiveRecord.maintain_test_schema = false
load File.join(host, "test/rails_tool_views/components/review_card_test.rb")
Rails::ZeitwerkChecker.check
puts "PACKAGED_INSTALL_PASS: installer -> fresh Rails host -> host authentication/helper -> #{renderers} renderers -> escaped partial -> action form helper -> HTTP JSON/Turbo replay/conflict/denial -> no-Turbo HTML redirect -> validation feedback -> durable restore -> generated HTML rejection/correction -> delivery transaction guard/durable host retry -> missing adapter/takeover reconciliation -> closed replay/paged payload cleanup/migration task -> generated scaffold/test -> eager load"
if ARGV[2]
  File.write(ARGV[2], JSON.generate(Gem.loaded_specs.values.map { |item| { name: item.name, version: item.version.to_s } }))
end
