# frozen_string_literal: true
class DemoChatMessage < ActiveRecord::Base
  belongs_to :conversation, class_name: "DemoConversation", inverse_of: :messages

  # The structured follow-up that RubyLLM::Continuation sends as a user turn.
  def continuation
    return unless role == "user"
    payload = JSON.parse(content.to_s)
    payload if payload.is_a?(Hash) && payload["type"] == "agent_interaction"
  rescue JSON::ParserError
    nil
  end

  # The Surface acknowledged by a present_ui tool result, if any.
  def presented_surface_id
    return unless role == "tool"
    result = JSON.parse(content.to_s)
    result["surface_id"] if result.is_a?(Hash) && result["status"] == "presented"
  rescue JSON::ParserError
    nil
  end
end
