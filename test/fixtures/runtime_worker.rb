# frozen_string_literal: true
ENV["RAILS_ENV"] = "test"
require "bundler/setup"
require_relative "../support/offline"
require_relative "../dummy/config/environment"
require_relative "../support/fixtures"
include TestFixtures
ToolViews.reset!
register_card
command, id, key = ARGV
if command == "act"
  STDOUT.sync = true
  puts "ready"
  STDIN.gets
  begin
    puts JSON.generate(ToolViews.dispatch(id, scope: scope, action: "select_option", arguments: { key: "compare" }, base_revision: 1, idempotency_key: key))
  rescue ToolViews::Error => error
    puts JSON.generate(error.to_h)
  end
else
  puts JSON.generate(ToolViews.restore(id, scope: scope).snapshot)
end
