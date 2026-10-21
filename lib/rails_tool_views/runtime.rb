# frozen_string_literal: true
module RailsToolViews
  class << self
    # Validates and authorizes props, then returns a persisted Surface. Correlation replays the original presentation.
    def present(key, props:, scope:, context: nil, correlation: nil)
      present_surface(key, props, scope, context, correlation)
    rescue Error => error
      notify("presentation.rejected", code: error.code)
      raise
    end

    # Returns a compatible Surface after checking scope and current read policy.
    def restore(id, scope:)
      check_scope!(scope)
      surface = Surface.find_by(id: id, actor_ref: scope.actor, tenant_ref: scope.tenant)
      # A database collation that is not binary (for example a case-insensitive
      # MySQL or PostgreSQL collation) can match a stored actor, tenant or id
      # that merely compares equal to the requested one. Only a byte-exact
      # match may stand in for this scope's Surface, or a lookup could disclose
      # another actor's or tenant's record.
      raise Error.new("NOT_FOUND", status: 404) unless surface && exact_match?(surface, id: id.to_s, actor_ref: scope.actor, tenant_ref: scope.tenant)
      ensure_not_purged!(surface)
      component = compatible_component!(surface)
      component.authorize!(access(scope, :read, surface: surface, props: surface.props, context_ref: surface.context_ref))
      surface
    end

    # Commits an authorized action and returns its receipt. Matching retries replay without executing the handler.
    def dispatch(id, scope:, action:, arguments:, base_revision:, idempotency_key:, source_component: nil, target: nil)
      surface = restore(id, scope: scope)
      raise Error.new("INVALID_SOURCE") if source_component && source_component.to_s != surface.component_key
      raise Error.new("INVALID_TARGET") if target && target != surface.dom_id
      component = compatible_component!(surface)
      definition = component.actions.fetch(action.to_s) { raise Error.new("UNKNOWN_ACTION") }
      arguments = definition.schema.validate!(arguments, code: "INVALID_ARGUMENTS")
      raise Error.new("INVALID_REVISION") unless base_revision.is_a?(Integer) && base_revision.positive?
      idempotency_key = Data.identifier(idempotency_key, code: "INVALID_IDEMPOTENCY_KEY")
      request_digest = Data.digest(action: definition.key, arguments: arguments, base_revision: base_revision)
      result = nil
      replayed = false
      surface.with_lock do
        ensure_not_purged!(surface)
        compatible_component!(surface).authorize!(access(scope, :read, surface: surface, props: surface.props, context_ref: surface.context_ref))
        request = access(scope, :action, surface: surface, props: surface.props, action: definition.key,
          arguments: arguments, context_ref: surface.context_ref)
        raise Error.new("NOT_ALLOWED", status: 403) unless definition.policy&.call(request) == true
        prior = ActionExecution.find_by(surface_id: surface.id, idempotency_key: idempotency_key)
        if prior
          # A non-binary collation could match a different key; only replay the
          # exact key, and keep the digest check as the second gate.
          raise Error.new("IDEMPOTENCY_CONFLICT", status: 409) unless prior.idempotency_key == idempotency_key && prior.request_digest == request_digest
          result = prior.result.symbolize_keys
          replayed = true
          next
        end
        raise Error.new("SURFACE_CLOSED", status: 410) if surface.closed?
        raise Error.new("CONFLICT", status: 409) unless surface.revision == base_revision
        if surface.action_executions.where("created_at >= ?", 1.minute.ago).count >= configuration.max_actions_per_minute
          raise Error.new("RATE_LIMITED", status: 429)
        end
        transition = definition.handler.call(request)
        raise Error.new("INVALID_TRANSITION", status: 422) unless transition.is_a?(Transition) && transition.state.is_a?(Hash)
        state = Data.bounded(transition.state)
        notice = normalize_notice(transition.notice)
        surface.update!(state: state, revision: base_revision + 1)
        result = { status: "completed", surface_id: surface.id, revision: surface.revision }
        result[:notice] = notice unless notice.nil?
        execution = ActionExecution.create!(surface: surface, actor_ref: scope.actor, action_key: definition.key,
          base_revision: base_revision, idempotency_key: idempotency_key, request_digest: request_digest, result: result)
        if transition.agent
          interaction = AgentInteraction.create!(surface: surface, action_execution: execution,
            payload: { type: "agent_interaction", surface_id: surface.id, action: definition.key, values: arguments,
              context_ref: surface.context_ref, revision: surface.revision }, status: configuration.agent_adapter ? "pending" : "skipped")
          result[:interaction_id] = interaction.id
          execution.update!(result: result)
        end
      end
      notify("action.executed", surface_id: surface.id, revision: result[:revision], action: definition.key, replayed: replayed)
      result
    rescue ActiveRecord::StaleObjectError, ActiveRecord::TransactionRollbackError, ActiveRecord::LockWaitTimeout
      # The database rolled the whole action back (deadlock, serialization failure,
      # lock timeout); retrying with the same key is safe.
      raise_action_conflict!
    rescue ActiveRecord::StatementInvalid => error
      raise_action_conflict! if error.cause.class.name.include?("Busy") || error.cause.class.name.include?("Locked")
      raise
    rescue Error => error
      notify(error.code == "CONFLICT" ? "action.conflict" : "action.rejected", code: error.code)
      raise
    end

    # The adapter must deduplicate by delivery_key. A crash after remote acceptance
    # can leave a lease in delivering state; retry is explicit and keeps the key.
    # Delivers a saved interaction after authorization; retry_failed explicitly retries failed delivery.
    # Call only after the host transaction commits. Stale attempts cannot acknowledge a newer claim.
    def deliver(id, scope:, adapter: configuration.agent_adapter, retry_failed: false)
      raise Error.new("DELIVERY_IN_TRANSACTION", status: 409) if AgentInteraction.connection.transaction_open?
      interaction = AgentInteraction.find_by(id: id)
      raise Error.new("NOT_FOUND", status: 404) unless interaction
      surface = restore(interaction.surface_id, scope: scope)
      claimed = false
      # Coordinate the claim with close/abandon/purge, using the same lock order
      # as actions. Never hold a database transaction during the adapter call.
      surface.with_lock do
        ensure_not_purged!(surface)
        component = compatible_component!(surface)
        component.authorize!(access(scope, :read, surface: surface, props: surface.props, context_ref: surface.context_ref))
        interaction.with_lock do
          definition = component.actions.fetch(interaction.payload.fetch("action")) { raise Error.new("INCOMPATIBLE_COMPONENT", status: 422) }
          arguments = definition.schema.validate!(interaction.payload.fetch("values"), code: "INVALID_ARGUMENTS")
          request = access(scope, :action, surface: surface, props: surface.props, action: definition.key, arguments: arguments, context_ref: surface.context_ref)
          raise Error.new("NOT_ALLOWED", status: 403) unless definition.policy&.call(request) == true
          next if %w[completed skipped abandoned].include?(interaction.status)
          raise Error.new("SURFACE_CLOSED", status: 410) if surface.closed?
          if interaction.status == "delivering" && interaction.claimed_at && interaction.claimed_at > Time.current - configuration.delivery_lease
            next
          end
          next if interaction.status == "failed" && !retry_failed
          # Reclaiming a lease does not prove that the previous callback ended.
          # This durable flag cannot be cleared by a stale worker's completion.
          uncertain = interaction.delivery_uncertain? || interaction.status == "delivering"
          # A worker without an adapter must not turn committed work terminal;
          # the interaction stays as it is for a configured worker.
          raise Error.new("AGENT_NOT_CONFIGURED", status: 503) if adapter.nil?
          interaction.update!(status: "delivering", claimed_at: Time.current, attempts: interaction.attempts + 1,
            error_code: nil, delivery_uncertain: uncertain)
          claimed = true
        end
      end
      return interaction.reload unless claimed
      attempt = interaction.attempts
      failure = nil
      begin
        adapter.call(Data.freeze_deep(Data.normalize(interaction.payload)), delivery_key: interaction.delivery_key)
      rescue StandardError => error
        failure = error
      end
      # Compare-and-set fences both success and failure. The lease may expire
      # while the callback runs; its acknowledgment belongs only to its attempt.
      acknowledged = AgentInteraction.where(id: interaction.id, status: "delivering", attempts: attempt).update_all(
        status: failure ? "failed" : "completed", error_code: failure ? "AGENT_UNAVAILABLE" : nil,
        claimed_at: nil, updated_at: Time.current)
      if acknowledged == 1
        metadata = { surface_id: interaction.surface_id, interaction_id: interaction.id }
        failure ? report(failure, "agent_failed", **metadata) : notify("agent_returned", **metadata)
      end
      interaction.reload
    end

    # Renders the trusted component after fresh authorization. Optional notice
    # is plain-text response feedback; it never changes the Surface snapshot.
    def render(surface, view_context:, scope:, error: nil, notice: nil)
      # Never trust an already-loaded object as an authorization decision.
      surface = restore(surface.id, scope: scope)
      component = compatible_component!(surface)
      view_context.render(partial: "rails_tool_views/surfaces/surface", formats: [:html], locals: { surface: surface, definition: component, error: error, notice: normalize_notice(notice) })
    rescue Error => failure
      view_context.render(partial: "rails_tool_views/surfaces/error", formats: [:html], locals: { error: failure })
    end

    def compatible_component!(surface) # :nodoc:
      component = registry.fetch(surface.component_key)
      raise Error.new("INCOMPATIBLE_COMPONENT", status: 422) unless surface.contract_version == 1 && component.digest == surface.component_digest
      component.schema.validate!(surface.props)
      component
    rescue Error => error
      raise Error.new("INCOMPATIBLE_COMPONENT", status: 422) if %w[UNKNOWN_COMPONENT INVALID_PROPS].include?(error.code)
      raise
    end

    # The mounted controller needs CSRF protection, helpers and HTML rendering.
    def parent_controller # :nodoc:
      parent = configuration.parent_controller.to_s.constantize
      return parent if parent <= ::ActionController::Base
      raise ArgumentError, "RailsToolViews parent_controller must inherit from ActionController::Base; #{parent} does not"
    end

    def access(scope, operation, **attributes) # :nodoc:
      Access.new(actor: scope.actor, tenant: scope.tenant, operation: operation, **attributes).freeze
    end

    def notify(event, **payload) # :nodoc:
      ActiveSupport::Notifications.instrument("#{event}.rails_tool_views", payload)
    end

    # Host renderer or adapter code failed behind a rescue. Surface it the way
    # Rails surfaces handled errors; the event itself stays metadata-only.
    def report(error, event, **payload) # :nodoc:
      notify(event, **payload, error_class: error.class.name)
      Rails.error.report(error, handled: true, severity: :error, context: payload, source: "rails_tool_views")
      Rails.logger&.error("RailsToolViews #{event} handled #{error.class}; inspect the host Rails.error report")
    end

    private
    def present_surface(key, props, scope, context, correlation) # :nodoc:
      check_scope!(scope)
      component = registry.fetch(key)
      props = component.schema.validate!(props)
      context = Data.identifier(context, code: "INVALID_CONTEXT") if context
      component.authorize!(access(scope, :present, props: props, context_ref: context))
      correlation = normalize_correlation(correlation) if correlation
      request_digest = Data.digest(component: component.key, digest: component.digest, props: props, context: context)
      lookup = correlation&.merge(actor_ref: scope.actor, tenant_ref: scope.tenant)
      if lookup && (prior = correlated_presentation(lookup))
        return correlated_surface(prior, request_digest, scope)
      end
      surface = nil
      Surface.transaction(requires_new: true) do
        surface = Surface.create!(actor_ref: scope.actor, tenant_ref: scope.tenant, context_ref: context,
          component_key: component.key, component_digest: component.digest, props: props, state: {})
        if lookup
          Presentation.create!(**lookup, surface: surface, request_digest: request_digest,
            result: { status: "presented", surface_id: surface.id, revision: surface.revision })
        end
      end
      notify("presentation.accepted", surface_id: surface.id, component: component.key, revision: surface.revision)
      surface
    rescue ActiveRecord::RecordNotUnique
      # A concurrent request committed the same correlation first.
      prior = lookup && correlated_presentation(lookup)
      raise unless prior
      correlated_surface(prior, request_digest, scope)
    end
    def raise_action_conflict! # :nodoc:
      notify("action.conflict", code: "CONFLICT")
      raise Error.new("CONFLICT", status: 409)
    end
    def normalize_notice(notice) # :nodoc:
      return if notice.nil?
      raise Error.new("INVALID_TRANSITION", status: 422) unless notice.is_a?(String) && notice.bytesize <= 500
      # A host SafeBuffer must still be rendered as escaped text.
      Data.bounded(String.new(notice))
    end
    def ensure_not_purged!(surface)
      raise Error.new("SURFACE_PURGED", status: 410) if surface.purged?
    end
    def check_scope!(scope)
      raise Error.new("INVALID_SCOPE", status: 403) unless scope.is_a?(Scope)
    end
    # True only when every attribute equals the requested value byte for byte,
    # regardless of the database collation used to find the row.
    def exact_match?(record, **expected)
      expected.all? { |attribute, value| record.public_send(attribute) == value }
    end
    # Returns the durable presentation for this exact correlation, or nil. A row
    # that a non-binary collation matched but that is not byte-identical is a
    # conflict, never a replay of another correlation.
    def correlated_presentation(lookup)
      prior = Presentation.find_by(lookup)
      return nil unless prior
      return prior if exact_match?(prior, **lookup)
      raise Error.new("IDEMPOTENCY_CONFLICT", status: 409)
    end
    def normalize_correlation(value)
      raise Error.new("INVALID_CORRELATION") unless value.is_a?(Hash) && (value.keys - %i[adapter call_id context]).empty? && value.keys.sort == %i[adapter call_id context].sort
      { adapter: Data.identifier(value[:adapter], code: "INVALID_CORRELATION"),
        call_id: Data.identifier(value[:call_id], code: "INVALID_CORRELATION"),
        context_ref: Data.identifier(value[:context], code: "INVALID_CORRELATION") }
    end
    def correlated_surface(prior, digest, scope)
      raise Error.new("IDEMPOTENCY_CONFLICT", status: 409) unless prior.request_digest == digest
      restore(prior.surface_id, scope: scope)
    end
  end
end
