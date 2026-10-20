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
lifecycle_fixture = File.join(host, "lifecycle.json")
if phase == "old"
  rows = %w[completed pending failed delivering retried].map do |status|
    correlation = { adapter: "fixture", call_id: status, context: "chat" }
    surface = RailsToolViews.present(:upgrade_card, props: { title: status }, scope: scope, context: "private", correlation: correlation)
    result = RailsToolViews.dispatch(surface.id, scope: scope, action: "save", arguments: {}, base_revision: 1, idempotency_key: "saved")
    interaction = RailsToolViews::AgentInteraction.find(result[:interaction_id])
    interaction.update!(status: status == "retried" ? "completed" : status, attempts: status == "retried" ? 2 : 1)
    { id: surface.id, label: status, snapshot: surface.reload.snapshot, receipt: result, correlation: correlation,
      uncertain: interaction.has_attribute?(:delivery_uncertain) ? interaction.delivery_uncertain : %w[delivering retried].include?(status) }
  end
  File.write(fixture, JSON.generate(rows))
  if RailsToolViews.respond_to?(:purge_closed)
    lifecycle = %w[closed purged].map do |label|
      correlation = { adapter: "fixture", call_id: label, context: "chat" }
      surface = RailsToolViews.present(:upgrade_card, props: { title: label }, scope: scope, context: "private", correlation: correlation)
      receipt = RailsToolViews.dispatch(surface.id, scope: scope, action: "save", arguments: {}, base_revision: 1, idempotency_key: "saved")
      RailsToolViews.deliver(receipt.fetch(:interaction_id), scope: scope, adapter: ->(*) {})
      RailsToolViews.close(surface.id, scope: scope, retain_until: label == "purged" ? 1.hour.from_now : nil)
      { id: surface.id, label: label, receipt: receipt, correlation: correlation }
    end
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    require "active_support/testing/time_helpers"
    Object.new.extend(ActiveSupport::Testing::TimeHelpers).travel_to(2.hours.from_now) do
      RailsToolViews.purge_closed(scope: scope, closed_before: Time.current, dry_run: false)
    end
    File.write(lifecycle_fixture, JSON.generate(lifecycle))
  end
  puts "UPGRADE_OLD_PASS: #{RailsToolViews::VERSION}, #{rows.size} action graphs, #{File.file?(lifecycle_fixture) ? 2 : 0} lifecycle guards/business writes"
else
  rows = JSON.parse(File.read(fixture))
  lifecycle = File.file?(lifecycle_fixture) ? JSON.parse(File.read(lifecycle_fixture)) : []
  lifecycle.each do |row|
    if row.fetch("label") == "closed"
      surface = RailsToolViews.restore(row.fetch("id"), scope: scope)
      raise "Old closure lost" unless surface.closed? && surface.revision == 3 && surface.retain_until.nil?
      receipt = RailsToolViews.dispatch(surface.id, scope: scope, action: "save", arguments: {}, base_revision: 1, idempotency_key: "saved")
      raise "Closed receipt changed" unless receipt.stringify_keys == row.fetch("receipt")
      begin
        RailsToolViews.dispatch(surface.id, scope: scope, action: "save", arguments: {}, base_revision: 3, idempotency_key: "new")
        raise "Old closed Surface reopened"
      rescue RailsToolViews::Error => error
        raise unless error.code == "SURFACE_CLOSED"
      end
    else
      [:restore, :present].each do |operation|
        begin
          operation == :restore ? RailsToolViews.restore(row.fetch("id"), scope: scope) :
            RailsToolViews.present(:upgrade_card, props: { title: "purged" }, scope: scope, context: "private", correlation: row.fetch("correlation").symbolize_keys)
          raise "Old purge tombstone lost"
        rescue RailsToolViews::Error => error
          raise unless error.code == "SURFACE_PURGED"
        end
      end
    end
  end
  rows.each do |row|
    surface = RailsToolViews.restore(row.fetch("id"), scope: scope)
    old_snapshot = row.fetch("snapshot")
    raise "Old payload/revision changed" unless JSON.parse(JSON.generate(surface.snapshot.except(:lifecycle))) == old_snapshot.except("lifecycle")
    raise "Old lifecycle changed" if old_snapshot.key?("lifecycle") && JSON.parse(JSON.generate(surface.snapshot[:lifecycle])) != old_snapshot.fetch("lifecycle")
    raise "Old row closed implicitly" if surface.closed?
    receipt = RailsToolViews.dispatch(surface.id, scope: scope, action: "save", arguments: {}, base_revision: 1, idempotency_key: "saved")
    raise "Old receipt changed" unless receipt.stringify_keys == row.fetch("receipt")
    interaction = surface.agent_interactions.first
    uncertain = row.fetch("uncertain")
    raise "Unsafe backfill" unless interaction.delivery_uncertain == uncertain
    correlated = RailsToolViews.present(:upgrade_card, props: { title: row.fetch("label") }, scope: scope, context: "private", correlation: row.fetch("correlation").symbolize_keys)
    raise "Correlation recreated" unless correlated.id == surface.id
  end
  # Migration down is safe before use, then reapply/backfill in a new process schema.
  migration = ActiveRecord::MigrationContext.new(File.join(host, "db/migrate"))
  if lifecycle.empty?
    migration.down(20261010000000)
    migration.up
  end
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
  expected = rows.size + lifecycle.size
  raise "Business data lost or replayed" unless HostBusinessRecord.count == expected
  raise "Guards lost" unless RailsToolViews::Surface.count == expected && RailsToolViews::Presentation.count == expected
  puts "UPGRADE_NEW_PASS: #{RailsToolViews::VERSION}, migration/replay/correlation/quarantine/rollback/purge/business preservation, #{lifecycle.size} old lifecycle guards"
end
