# frozen_string_literal: true
module ToolViews
  class AgentInteraction < ActiveRecord::Base
    self.table_name = "tool_views_agent_interactions"
    belongs_to :surface
    belongs_to :action_execution
    attribute :payload, :json
    def delivery_key
      "toolviews:interaction:#{id}"
    end
  end
end
