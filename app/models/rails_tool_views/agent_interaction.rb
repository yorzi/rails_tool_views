# frozen_string_literal: true
module RailsToolViews
  # A durable continuation request delivered after its action commits.
  class AgentInteraction < ActiveRecord::Base
    self.table_name = "rails_tool_views_agent_interactions"
    belongs_to :surface
    belongs_to :action_execution
    self.filter_attributes += %i[payload]
    # Rails 7.2 cannot infer a SQLite boolean default written by Rails 8.1.
    attribute :delivery_uncertain, :boolean, default: false
    attribute :payload, RedactedJson.new
    # Returns the stable host deduplication key across delivery retries.
    def delivery_key
      "rails_tool_views:interaction:#{id}"
    end
  end
end
