# frozen_string_literal: true
# Reference-host example; load after its environment, under the optional SDK bundle.
require "ruby_llm"
class DemoTicketsQueryTool < RubyLLM::Tool
  description "Find up to five display-safe support tickets in the authenticated staff tenant."
  def self.tool_name
    "find_support_tickets"
  end
  def initialize(scope:)
    @scope = scope
  end
  def parameters_schema
    { type: "object", additionalProperties: false, required: ["query"], properties: { query: { type: "string", maxLength: 80 } } }
  end
  def execute(query:)
    { tickets: DemoV1::TicketsQuery.call(scope: @scope, query: query) }
  rescue RailsToolViews::Error => error
    error.to_h
  end
end
