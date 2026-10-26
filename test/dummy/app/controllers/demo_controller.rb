# frozen_string_literal: true
class DemoController < ApplicationController
  def index
    session.delete(:v1_identity)
    session[:demo_actor] ||= "demo:#{SecureRandom.uuid}"
    @scope = RailsToolViews::Scope.new(actor: session[:demo_actor], tenant: "local-demo")
    all = RailsToolViews::Surface.where(actor_ref: @scope.actor, tenant_ref: @scope.tenant).order(:created_at)
    @purged_count = all.where.not(purged_at: nil).count
    @surfaces = all.where(purged_at: nil).map { |surface| RailsToolViews.restore(surface.id, scope: @scope) }
    @effects = DemoEffect.where(surface_id: all.pluck(:id)).order(:id)
  end
  def lifecycle
    scope = RailsToolViews.configuration.scope_resolver.call(self)
    operation = params[:operation] == "abandon" ? :abandon : :close
    # A short deadline lets a visitor watch cleanup become eligible; hosts choose their own.
    RailsToolViews.public_send(operation, params[:surface_id], scope: scope, retain_until: 1.minute.from_now)
    redirect_to root_path, status: :see_other
  end
  def cleanup
    scope = RailsToolViews.configuration.scope_resolver.call(self)
    result = RailsToolViews.purge_closed(scope: scope, closed_before: Time.current, dry_run: params[:apply] != "yes")
    redirect_to root_path, status: :see_other, notice: "Cleanup: #{result[:eligible]} eligible, #{result[:purged]} purged."
  end
  def create
    scope = RailsToolViews.configuration.scope_resolver.call(self)
    raise RailsToolViews::Error.new("NOT_ALLOWED", status: 403) unless scope
    context = { "chat" => "demo-chat", "notice" => "demo-notice" }.fetch(params[:mode], "demo-page")
    key = params[:mode] == "component" ? :component_card : :choice_card
    options = params[:mode] == "empty" ? [] : [{ key: "compare", label: "Compare options" }, { key: "continue", label: "Continue analysis" }]
    RailsToolViews.present(key, props: { title: "Choose your next step", options: options }, scope: scope, context: context)
    redirect_to root_path, status: :see_other
  end
end
