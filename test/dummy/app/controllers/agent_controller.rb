# frozen_string_literal: true
# An agent chat whose model presents trusted components through RubyLLM.
class AgentController < ApplicationController
  MESSAGE_LIMIT = 500
  before_action :require_agent_demo, except: :show

  def show
    @scope = playground_scope
    @available = agent_demo?
    @conversation = conversations.last
  end

  def create
    text = params[:message].to_s.strip
    if text.empty? || text.length > MESSAGE_LIMIT
      return redirect_to agent_path, status: :see_other, alert: "Write a message of 1 to #{MESSAGE_LIMIT} characters."
    end
    DemoLLM.chat_for(conversations.last || conversations.create!).ask(text)
    redirect_to agent_path, status: :see_other
  rescue StandardError => error
    raise unless error.is_a?(::RubyLLM::Error)
    redirect_to agent_path, status: :see_other, alert: "The model request failed (#{error.class.name.demodulize})."
  end

  def restart
    conversations.create!
    redirect_to agent_path, status: :see_other
  end

  private
  def agent_demo?
    defined?(::DemoLLM) ? true : false
  end

  def require_agent_demo
    redirect_to agent_path, status: :see_other unless agent_demo?
  end

  # The same signed-session identity as the playground, so Engine actions on
  # presented views resolve this scope.
  def playground_scope
    session.delete(:v1_identity)
    session[:demo_actor] ||= "demo:#{SecureRandom.uuid}"
    RailsToolViews::Scope.new(actor: session[:demo_actor], tenant: "local-demo")
  end

  def conversations
    scope = @scope || playground_scope
    DemoConversation.where(actor_ref: scope.actor, tenant_ref: scope.tenant).order(:id)
  end
end
