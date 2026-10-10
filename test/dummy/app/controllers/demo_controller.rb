# frozen_string_literal: true
class DemoController < ApplicationController
  def index
    session[:demo_actor] ||= "demo:#{SecureRandom.uuid}"
    @scope = ToolViews::Scope.new(actor: session[:demo_actor], tenant: "local-demo")
    @surfaces = ToolViews::Surface.where(actor_ref: @scope.actor, tenant_ref: @scope.tenant).order(:created_at).map { |surface| ToolViews.restore(surface.id, scope: @scope) }
    @effects = DemoEffect.where(surface_id: @surfaces.map(&:id)).order(:id)
  end
  def create
    scope = ToolViews.configuration.scope_resolver.call(self)
    raise ToolViews::Error.new("NOT_ALLOWED", status: 403) unless scope
    context = params[:mode] == "chat" ? "demo-chat" : "demo-page"
    key = params[:mode] == "component" ? :component_card : :choice_card
    options = params[:mode] == "empty" ? [] : [{ key: "compare", label: "Compare options" }, { key: "continue", label: "Continue analysis" }]
    ToolViews.present(key, props: { title: "Choose your next step", options: options }, scope: scope, context: context)
    redirect_to root_path, status: :see_other
  end
end
