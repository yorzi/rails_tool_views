# frozen_string_literal: true
module ToolViews
  class Presentation < ActiveRecord::Base
    self.table_name = "tool_views_presentations"
    belongs_to :surface
    self.filter_attributes += %i[result]
    attribute :result, RedactedJson.new
  end
end
