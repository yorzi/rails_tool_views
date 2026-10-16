# frozen_string_literal: true
module RailsToolViews
  # A committed action receipt used to replay requests without repeating handlers.
  class ActionExecution < ActiveRecord::Base
    self.table_name = "tool_views_action_executions"
    belongs_to :surface
    has_one :agent_interaction, dependent: :destroy
    self.filter_attributes += %i[result]
    attribute :result, RedactedJson.new
  end
end
