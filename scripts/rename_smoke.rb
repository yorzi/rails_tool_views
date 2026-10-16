# frozen_string_literal: true
# Real pre-rename code writes the database; current code reads it in a new process.
require "bundler/setup"
require "tmpdir"
require "fileutils"
require "open3"
require "json"
root = File.expand_path("..", __dir__)
base = "26825cb"
worker = <<~'CODE'
  ENV["RAILS_ENV"] = "test"
  require "bundler/setup"
  require File.join(Dir.pwd, "test/support/offline")
  require File.join(Dir.pwd, "test/dummy/config/environment")
  require File.join(Dir.pwd, "test/support/fixtures")
  include TestFixtures
  ToolViews.reset!
  register_card(agent: true)
  scope_value = scope
  if ARGV[0] == "write"
    ActiveRecord::MigrationContext.new(Rails.application.paths["db/migrate"].to_a).migrate
    surface = ToolViews.present(:choice_card, props: props, scope: scope_value,
      correlation: { adapter: "ruby_llm", call_id: "old-call", context: "old-context" })
    result = act(surface, idempotency: "old-action")
    interaction = ToolViews::AgentInteraction.find(result[:interaction_id])
    File.write(ARGV[1], JSON.generate(id: surface.id, snapshot: surface.reload.snapshot,
      result: result, delivery_key: interaction.delivery_key, dom_id: surface.dom_id))
  else
    require "tool_views"
    require "toolviews"
    raise "Alias split" unless ToolViews.equal?(RailsToolViews) && ToolViews.registry.equal?(RailsToolViews.registry)
    old = JSON.parse(File.read(ARGV[1]))
    surface = RailsToolViews.restore(old.fetch("id"), scope: scope_value)
    raise "Snapshot changed" unless JSON.parse(JSON.generate(surface.snapshot)) == old.fetch("snapshot")
    raise "DOM changed" unless surface.dom_id == old.fetch("dom_id")
    result = act(surface, revision: 1, idempotency: "old-action")
    raise "Replay changed" unless JSON.parse(JSON.generate(result)) == old.fetch("result")
    raise "Duplicate host write" unless DemoEffect.count == 1
    interaction = RailsToolViews::AgentInteraction.find(result[:interaction_id])
    raise "Delivery key changed" unless interaction.delivery_key == old.fetch("delivery_key")
    presented = RailsToolViews.present(:choice_card, props: props, scope: scope_value,
      correlation: { adapter: "ruby_llm", call_id: "old-call", context: "old-context" })
    raise "Presentation replay changed" unless presented.id == surface.id && RailsToolViews::Surface.count == 1
    begin
      RailsToolViews.restore(surface.id, scope: scope("mallory"))
      raise "Foreign actor accepted"
    rescue RailsToolViews::Error => error
      raise unless error.code == "NOT_FOUND"
    end
    surface.update!(component_digest: "sha256:changed")
    begin
      RailsToolViews.restore(surface.id, scope: scope_value)
      raise "Changed digest accepted"
    rescue RailsToolViews::Error => error
      raise unless error.code == "INCOMPATIBLE_COMPONENT"
    end
    puts "RENAME_COMPATIBILITY_PASS: old snapshot, action/presentation replay, host write count, delivery/DOM identity, actor and digest guards"
  end
CODE
Dir.mktmpdir("rails-tool-views-upgrade-") do |dir|
  old_root = File.join(dir, "old")
  FileUtils.mkdir_p(old_root)
  archive, error, status = Open3.capture3("git", "archive", base, chdir: root)
  abort error unless status.success?
  _, error, status = Open3.capture3("tar", "-x", "-C", old_root, stdin_data: archive)
  abort error unless status.success?
  program = File.join(dir, "worker.rb")
  File.write(program, worker)
  [ [old_root, "write"], [root, "read"] ].each do |checkout, operation|
    env = { "BUNDLE_GEMFILE" => File.join(checkout, "Gemfile"),
      "BUNDLE_PATH" => File.join(root, "vendor/bundle"), "DATABASE_URL" => "sqlite3:#{dir}/upgrade.sqlite3" }
    output, error, status = Open3.capture3(env, RbConfig.ruby, program, operation, File.join(dir, "receipt.json"), chdir: checkout)
    puts output
    warn error unless error.empty?
    abort "Upgrade #{operation} failed" unless status.success?
  end
end
