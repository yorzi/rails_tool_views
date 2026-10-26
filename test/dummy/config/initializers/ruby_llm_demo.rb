# frozen_string_literal: true
# The agent chat page needs RubyLLM 2.0 or later; bin/demo runs with
# gemfiles/adapter.gemfile. Under the core Gemfile the rest of the demo runs.
begin
  require "rails_tool_views/adapters/ruby_llm"
rescue LoadError
  nil
else
  require Rails.root.join("lib/demo_llm").to_s
end
