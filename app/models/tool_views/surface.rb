# frozen_string_literal: true
module ToolViews
  class Surface < ActiveRecord::Base
    self.table_name = "tool_views_surfaces"
    self.filter_attributes += %i[props state]
    attribute :props, RedactedJson.new, default: -> { {} }
    attribute :state, RedactedJson.new, default: -> { {} }
    has_many :presentations, dependent: :destroy
    has_many :action_executions, dependent: :destroy
    has_many :agent_interactions, dependent: :destroy
    before_create { self.id ||= SecureRandom.uuid }
    validates :actor_ref, :tenant_ref, :component_key, :component_digest, presence: true
    def dom_id
      "tool_views_surface_#{id}"
    end
    def snapshot
      { id: id, component: component_key, component_digest: component_digest, props: props, state: state, revision: revision }
    end
  end
end
