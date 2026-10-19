# frozen_string_literal: true
module RailsToolViews
  class << self
    # Closes a view after host authorization. Outstanding continuation work blocks
    # closure. nil retain_until keeps data indefinitely; the first closure wins.
    def close(id, scope:, retain_until: nil)
      finish_surface(id, scope: scope, retain_until: retain_until, abandon: false)
    end

    # Explicitly abandons pending/failed continuation work before closing a view.
    # In-flight or historically uncertain delivery is never abandoned implicitly.
    def abandon(id, scope:, retain_until: nil)
      finish_surface(id, scope: scope, retain_until: retain_until, abandon: true)
    end

    private
    def finish_surface(id, scope:, retain_until:, abandon:)
      validate_retention_deadline!(retain_until, future: false)
      surface = restore(id, scope: scope)
      surface.with_lock do
        ensure_not_purged!(surface)
        component = compatible_component!(surface)
        component.authorize!(access(scope, :read, surface: surface, props: surface.props, context_ref: surface.context_ref))
        component.authorize!(access(scope, abandon ? :abandon : :close, surface: surface, props: surface.props, context_ref: surface.context_ref))
        next if surface.closed?
        validate_retention_deadline!(retain_until, future: true)
        interactions = surface.agent_interactions
        protected_delivery = interactions.where(status: "delivering").exists? || interactions.where(delivery_uncertain: true).exists?
        allowed = abandon ? %w[completed skipped pending failed abandoned] : %w[completed skipped abandoned]
        raise Error.new("LIFECYCLE_BUSY", status: 409) if protected_delivery || interactions.where.not(status: allowed).exists?
        if abandon
          interactions.where(status: %w[pending failed]).update_all(status: "abandoned", claimed_at: nil, error_code: nil, updated_at: Time.current)
        end
        now = Time.current
        surface.update!(closed_at: now, abandoned_at: abandon ? now : nil, retain_until: retain_until, revision: surface.revision + 1)
      end
      surface
    end
    def validate_retention_deadline!(deadline, future:)
      return if deadline.nil?
      valid_type = deadline.is_a?(Time) || deadline.is_a?(ActiveSupport::TimeWithZone)
      raise Error.new("INVALID_RETENTION_WINDOW") unless valid_type && (!future || deadline > Time.current)
    end
  end
end
