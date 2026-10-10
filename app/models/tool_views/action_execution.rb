# frozen_string_literal: true
module ToolViews
  class ActionExecution < ActiveRecord::Base
    self.table_name = "tool_views_action_executions"
    belongs_to :surface
    has_one :agent_interaction, dependent: :destroy
    attribute :result, :json
  end
end
