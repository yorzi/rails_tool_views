# frozen_string_literal: true
abort "Opt in with TOOLVIEWS_LIVE_SMOKE=1; this makes a billable provider request." unless ENV["TOOLVIEWS_LIVE_SMOKE"] == "1"
abort "Load the provider credential from your secret manager or protected env file." if ENV["OPENAI_API_KEY"].to_s.empty?
require "bundler/setup"
ENV["RAILS_ENV"] = "development"
require_relative "../test/dummy/config/environment"
require "tool_views/adapters/ruby_llm"
RubyLLM.configure { |config| config.openai_api_key = ENV.fetch("OPENAI_API_KEY") }
scope = ToolViews::Scope.new(actor: "demo:provider-smoke", tenant: "local-demo")
tool = ToolViews::Adapters::RubyLLM::PresentUI.new(keys: [:choice_card], scope: scope, context: "provider-smoke:#{SecureRandom.uuid}")
chat = RubyLLM.chat(model: ENV.fetch("TOOLVIEWS_MODEL", "gpt-4.1-mini"), provider: :openai).with_tools(tool)
chat.ask('Use present_ui once with component choice_card. Props: title "Choose a workflow" and options [{"key":"compare","label":"Compare options"},{"key":"continue","label":"Continue analysis"}].')
abort "Provider did not present exactly one Surface" unless tool.references.length == 1
puts "LIVE_PROVIDER_PRESENTED: #{tool.references.first[:surface_id]}"
# A provider call is distinct from the browser action/continuation tests.
