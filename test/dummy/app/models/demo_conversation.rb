# frozen_string_literal: true
# One agent chat owned by a demo actor. Its ID is the RailsToolViews context.
class DemoConversation < ActiveRecord::Base
  CONTEXT_PREFIX = "agent:"
  has_many :messages, -> { order(:id) }, class_name: "DemoChatMessage", foreign_key: :conversation_id, dependent: :destroy, inverse_of: :conversation

  def self.for_context(context_ref)
    id = context_ref.to_s.delete_prefix(CONTEXT_PREFIX)
    find_by(id: id) if context_ref.to_s.start_with?(CONTEXT_PREFIX) && id.match?(/\A[1-9][0-9]*\z/)
  end

  def context_ref
    "#{CONTEXT_PREFIX}#{id}"
  end

  # The owner's scope comes from host data, never from a model or browser payload.
  def scope
    RailsToolViews::Scope.new(actor: actor_ref, tenant: tenant_ref)
  end
end
