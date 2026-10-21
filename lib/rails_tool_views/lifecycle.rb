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

    # Scrubs eligible closed payloads in one bounded batch, preserving replay
    # tombstones. Requires an explicit scope, cutoff and host retention policy.
    # Defaults to a read-only preview. Each applied Surface commits atomically.
    # Pass the returned next_after as after: to continue past this batch.
    def purge_closed(scope:, closed_before:, batch_size: 100, dry_run: true, after: nil)
      check_scope!(scope)
      valid_time = closed_before.is_a?(Time) || closed_before.is_a?(ActiveSupport::TimeWithZone)
      unless valid_time && closed_before <= Time.current && batch_size.is_a?(Integer) && batch_size.between?(1, 1000) && [true, false].any? { |v| dry_run.equal?(v) }
        raise Error.new("INVALID_RETENTION_REQUEST")
      end
      position = retention_position(after) unless after.nil?
      policy = configuration.retention_policy
      raise Error.new("NOT_ALLOWED", status: 403) unless policy.respond_to?(:call)
      now = Time.current
      relation = Surface.where(actor_ref: scope.actor, tenant_ref: scope.tenant, purged_at: nil)
        .where("closed_at < ? AND retain_until <= ?", closed_before, now)
      # Keyset paging only narrows the scoped query; a forged cursor can skip
      # rows but never reach another scope.
      relation = relation.where("closed_at > ? OR (closed_at = ? AND id > ?)", position[0], position[0], position[1]) if position
      rows = relation.order(:closed_at, :id).limit(batch_size).pluck(:id, :closed_at)
      counts = { examined: 0, eligible: 0, purged: 0, protected: 0, dry_run: dry_run,
        next_after: rows.length == batch_size ? retention_cursor(*rows.last) : nil }
      rows.each do |id, _closed_at|
        surface = Surface.find_by(id: id)
        next unless surface
        surface.with_lock do
          counts[:examined] += 1
          eligible = exact_match?(surface, actor_ref: scope.actor, tenant_ref: scope.tenant) &&
            !surface.purged? && surface.closed? && surface.closed_at < closed_before &&
            surface.retain_until && surface.retain_until <= now
          if eligible
            request = access(scope, :purge, surface: surface, props: surface.props, context_ref: surface.context_ref)
            eligible = policy.call(request) == true && !protected_interactions?(surface, abandon: false)
          end
          unless eligible
            counts[:protected] += 1
            next
          end
          counts[:eligible] += 1
          next if dry_run
          # The Surface lock excludes action commits, delivery claims and other
          # cleanup workers. Only known terminal children are removed together.
          surface.agent_interactions.delete_all
          surface.action_executions.delete_all
          surface.update!(props: {}, state: {}, context_ref: nil, purged_at: now)
          counts[:purged] += 1
        end
      end
      counts
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
        raise Error.new("LIFECYCLE_BUSY", status: 409) if protected_interactions?(surface, abandon: abandon)
        if abandon
          interactions.where(status: %w[pending failed]).update_all(status: "abandoned", claimed_at: nil, error_code: nil, updated_at: Time.current)
        end
        now = Time.current
        surface.update!(closed_at: now, abandoned_at: abandon ? now : nil, retain_until: retain_until, revision: surface.revision + 1)
      end
      surface
    end
    # An opaque cursor: the last candidate's closing time and Surface ID.
    def retention_cursor(id, closed_at)
      "#{closed_at.utc.iso8601(6)}/#{id}"
    end
    def retention_position(cursor)
      match = cursor.is_a?(String) && cursor.match(%r{\A(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}Z)/([^/\s]{1,150})\z})
      raise Error.new("INVALID_RETENTION_REQUEST") unless match
      [Time.iso8601(match[1]), match[2]]
    rescue ArgumentError
      raise Error.new("INVALID_RETENTION_REQUEST")
    end
    def protected_interactions?(surface, abandon:)
      interactions = surface.agent_interactions
      allowed = abandon ? %w[completed skipped pending failed abandoned] : %w[completed skipped abandoned]
      interactions.where(delivery_uncertain: true).exists? || interactions.where.not(status: allowed).exists?
    end
    def validate_retention_deadline!(deadline, future:)
      return if deadline.nil?
      valid_type = deadline.is_a?(Time) || deadline.is_a?(ActiveSupport::TimeWithZone)
      raise Error.new("INVALID_RETENTION_WINDOW") unless valid_type && (!future || deadline > Time.current)
    end
  end
end
