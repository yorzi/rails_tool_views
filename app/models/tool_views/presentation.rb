# frozen_string_literal: true
module ToolViews
  class Presentation < ActiveRecord::Base
    self.table_name = "tool_views_presentations"
    belongs_to :surface
    attribute :result, :json
  end
end
