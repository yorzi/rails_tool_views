# frozen_string_literal: true
require "bundler/setup"
require "json"
require "fileutils"
ENV["RAILS_ENV"] = "test"
code, host, phase = ARGV
$LOAD_PATH.unshift(File.join(code, "lib"))
require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
RailsToolViews.send(:remove_const, :VERSION) if phase == "old" && defined?(RailsToolViews::VERSION)
require "rails_tool_views"
raise "Wrong runtime" unless $LOADED_FEATURES.any? { |path| path.end_with?("/rails_tool_views.rb") && File.realpath(path) == File.realpath(File.join(code, "lib/rails_tool_views.rb")) }
class UpgradeHost < Rails::Application # :nodoc:
  config.root = ARGV.fetch(1)
  config.load_defaults 7.2
  config.eager_load = false
  config.secret_key_base = "upgrade-fixture-#{'0' * 64}"
end
Rails.application.initialize!
class ApplicationController < ActionController::Base; end
if phase == "new"
  # Exercise the documented existing-host task, preserving its original migration.
  require "rake"
  Rails.application.load_tasks
  ENV["FROM"] = "rails_tool_views"
  Rake::Task["railties:install:migrations"].invoke
  raise "Incorrect migration copy" unless Dir[File.join(host, "db/migrate/*.rb")].size == 2
end
ActiveRecord::MigrationContext.new(File.join(host, "db/migrate")).migrate
schema = { type: "object", additionalProperties: false, required: ["title"], properties: { title: { type: "string" } } }
args = { type: "object", additionalProperties: false, properties: {} }
# The host table is an independent business record, outside the Engine graph.
if phase == "old"
  ActiveRecord::Base.connection.create_table(:host_business_records) { |t| t.string :surface_id }
end
class HostBusinessRecord < ActiveRecord::Base # :nodoc:
end
RailsToolViews.configure do |config|
  config.auto_deliver = false
  config.agent_adapter = ->(*) { raise "Provider must stay offline" }
end
RailsToolViews.register(:upgrade_card, description: "Upgrade fixture", schema: schema, partial: "choices/card", policy: ->(_) { true }, actions: {
  save: { schema: args, policy: ->(_) { true }, handler: ->(access) {
    HostBusinessRecord.create!(surface_id: access.surface.id)
    RailsToolViews::Transition.new(state: { saved: true }, agent: true)
  } }
})
scope = RailsToolViews::Scope.new(actor: "alice", tenant: "acme")
fixture = File.join(host, "fixture.json")
if phase == "old"
  rows = %w[completed pending failed delivering retried].map do |status|
    correlation = { adapter: "fixture", call_id: status, context: "chat" }
    surface = RailsToolViews.present(:upgrade_card, props: { title: status }, scope: scope, context: "private", correlation: correlation)
    result = RailsToolViews.dispatch(surface.id, scope: scope, action: "save", arguments: {}, base_revision: 1, idempotency_key: "saved")
    interaction = RailsToolViews::AgentInteraction.find(result[:interaction_id])
    interaction.update!(status: status == "retried" ? "completed" : status, attempts: status == "retried" ? 2 : 1)
    { id: surface.id, label: status, snapshot: surface.reload.snapshot, receipt: result, correlation: correlation }
  end
  File.write(fixture, JSON.generate(rows))
  puts "UPGRADE_OLD_PASS: #{RailsToolViews::VERSION}, five genuine runtime graphs/business writes"
else
  rows = JSON.parse(File.read(fixture))
  rows.each do |row|
    surface = RailsToolViews.restore(row.fetch("id"), scope: scope)
    raise "Old payload/revision changed" unless JSON.parse(JSON.generate(surface.snapshot.except(:lifecycle))) == row.fetch("snapshot")
    raise "Old row closed implicitly" if surface.closed?
    receipt = RailsToolViews.dispatch(surface.id, scope: scope, action: "save", arguments: {}, base_revision: 1, idempotency_key: "saved")
    raise "Old receipt changed" unless receipt.stringify_keys == row.fetch("receipt")
    interaction = surface.agent_interactions.first
    uncertain = %w[delivering retried].include?(row.fetch("label"))
    raise "Unsafe backfill" unless interaction.delivery_uncertain == uncertain
    correlated = RailsToolViews.present(:upgrade_card, props: { title: row.fetch("label") }, scope: scope, context: "private", correlation: row.fetch("correlation").symbolize_keys)
    raise "Correlation recreated" unless correlated.id == surface.id
  end
  # Migration down is safe before use, then reapply/backfill in a new process schema.
  migration = ActiveRecord::MigrationContext.new(File.join(host, "db/migrate"))
  migration.down(20261010000000)
  migration.up
  RailsToolViews::Surface.reset_column_information
  RailsToolViews::AgentInteraction.reset_column_information
  complete = rows.find { |r| r["label"] == "completed" }
  RailsToolViews.close(complete.fetch("id"), scope: scope, retain_until: 1.hour.from_now)
  begin
    migration.down(20261010000000)
    raise "Unsafe rollback succeeded"
  rescue StandardError => error
    raise unless error.message.include?("Restore a pre-upgrade backup")
  end
  RailsToolViews.configure { |config| config.retention_policy = ->(_) { true } }
  require "active_support/testing/time_helpers"
  Object.new.extend(ActiveSupport::Testing::TimeHelpers).travel_to(2.hours.from_now) do
    result = RailsToolViews.purge_closed(scope: scope, closed_before: Time.current, dry_run: false)
    raise "Upgraded cleanup failed" unless result[:purged] == 1
  end
  raise "Business data lost or replayed" unless HostBusinessRecord.count == 5
  raise "Guards lost" unless RailsToolViews::Surface.count == 5 && RailsToolViews::Presentation.count == 5
  puts "UPGRADE_NEW_PASS: #{RailsToolViews::VERSION}, migration/replay/correlation/quarantine/rollback/purge/business preservation"
end
