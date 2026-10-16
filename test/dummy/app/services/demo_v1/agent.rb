# frozen_string_literal: true
module DemoV1
  # Deterministic offline host adapter, not a live model. The receipt and domain
  # write share a transaction, so a crash before core acknowledgment is replay-safe.
  class Agent
    def call(payload, delivery_key:)
      interaction = RailsToolViews::AgentInteraction.find_by(id: delivery_key.split(":").last)
      unless interaction && interaction.delivery_key == delivery_key && RailsToolViews::Data.digest(interaction.payload) == RailsToolViews::Data.digest(payload)
        raise RailsToolViews::Error.new("INVALID_CORRELATION")
      end
      surface = interaction.surface
      scope = RailsToolViews::Scope.new(actor: surface.actor_ref, tenant: surface.tenant_ref)
      RailsToolViews.restore(surface.id, scope: scope)
      request = RailsToolViews.access(scope, :action, surface: surface, props: surface.props, arguments: payload.fetch("values"), action: payload.fetch("action"))
      unless Access.allowed?(request, component: surface.component_key.to_sym, action: request.action)
        raise RailsToolViews::Error.new("NOT_ALLOWED", status: 403)
      end
      DemoAgentReceipt.transaction(requires_new: true) do
        next if DemoAgentReceipt.exists?(delivery_key: delivery_key)
        raise RailsToolViews::Error.new("AGENT_UNAVAILABLE", status: 503) if ENV["TOOLVIEWS_DEMO_AGENT_FAILURE"] == "1"
        case [surface.component_key, request.action]
        when ["ticket_card", "draft_reply"] then draft_reply(request)
        when ["result_review", "regenerate"] then regenerate(request)
        else raise RailsToolViews::Error.new("UNKNOWN_ACTION")
        end
        DemoAgentReceipt.create!(delivery_key: delivery_key)
      end
    end
    private
    def draft_reply(access)
      ticket = Access.ticket(Access.scope(access), access.props.fetch("ticket_id"))
      ticket.with_lock do
        reply = ticket.reply
        Workflows.version!(reply&.lock_version || 0, access.arguments.fetch("reply_version"))
        raise RailsToolViews::Error.new("REVIEW_REQUIRED", status: 409) if reply && reply.status != "draft"
        reply ||= DemoReply.new(ticket: ticket)
        reply.body = "Hello #{ticket.customer.name}, thank you for your billing question. We are reviewing your request and will follow up shortly."
        reply.status = "draft"
        reply.save!
      end
    end
    def regenerate(access)
      artifact = Access.artifact(Access.scope(access), access.props.fetch("artifact_id"))
      artifact.with_lock do
        Workflows.version!(artifact.current_version, access.arguments.fetch("artifact_version"))
        raise RailsToolViews::Error.new("ALREADY_ACCEPTED", status: 409) if artifact.accepted_version
        number = artifact.current_version + 1
        # Fixture text makes the explicit feedback boundary inspectable offline.
        body = "Revised campaign draft. Feedback: #{access.arguments.fetch('feedback')}"
        artifact.versions.create!(number: number, body: body, origin: "offline_regeneration")
        artifact.update!(current_version: number)
      end
    end
  end
end
