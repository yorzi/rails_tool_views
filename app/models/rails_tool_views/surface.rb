# frozen_string_literal: true
module RailsToolViews
  # A persisted UI snapshot whose read and action access is checked by RailsToolViews.
  class Surface < ActiveRecord::Base
    self.table_name = "rails_tool_views_surfaces"
    self.filter_attributes += %i[props state]
    attribute :props, RedactedJson.new, default: -> { {} }
    attribute :state, RedactedJson.new, default: -> { {} }
    has_many :presentations, dependent: :destroy
    has_many :action_executions, dependent: :destroy
    has_many :agent_interactions, dependent: :destroy
    before_create { self.id ||= SecureRandom.uuid }
    validates :actor_ref, :tenant_ref, :component_key, :component_digest, presence: true
    # Returns the stable browser target identifier.
    def dom_id
      "rails_tool_views_surface_#{id}"
    end
    # True once the host closes or abandons the view. Closed views cannot reopen.
    def closed?
      closed_at.present?
    end
    # True when payload cleanup has retained only the durable tombstone.
    def purged?
      purged_at.present?
    end
    # Returns the lifecycle independently of domain record or delivery status.
    def lifecycle_status
      return "purged" if purged?
      return "abandoned" if abandoned_at
      closed? ? "closed" : "active"
    end
    # Returns the UI projection; it is not a permission grant.
    def snapshot
      { id: id, component: component_key, component_digest: component_digest, props: props, state: state, revision: revision,
        lifecycle: { status: lifecycle_status, closed_at: closed_at&.iso8601(6),
          retain_until: retain_until&.iso8601(6), purged_at: purged_at&.iso8601(6) } }
    end
  end
end
