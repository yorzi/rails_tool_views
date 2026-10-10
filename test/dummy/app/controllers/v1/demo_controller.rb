# frozen_string_literal: true
module V1
  class DemoController < BaseController
    def customer
      raise ToolViews::Error.new("NOT_ALLOWED", status: 403) unless @staff.role == "lead"
      @surface = ToolViews::Surface.where(actor_ref: @scope.actor, tenant_ref: @scope.tenant, component_key: "customer_form").order(:created_at).last
      @surface ||= present(:customer_form, { values: { name: "Proposed Customer", email: "proposed@example.test" } }, call_id: "initial-customer")
      @surface = ToolViews.restore(@surface.id, scope: @scope)
      render "v1/customer"
    end
    def new_customer
      present(:customer_form, { values: { name: "Proposed Customer", email: "proposed-#{SecureRandom.hex(3)}@example.test" } }, call_id: SecureRandom.uuid)
      redirect_to v1_customer_path, status: :see_other
    end
    def support
      @query = params[:q] || ""
      @tickets = DemoV1::TicketsQuery.call(scope: @scope, query: @query)
      if params[:ticket_id]
        record = DemoV1::Access.ticket(@scope, params[:ticket_id])
        @surface = present(:ticket_card, { ticket_id: record.id.to_s }, call_id: "ticket:#{record.id}")
      end
      render "v1/support"
    end
    def review
      id = params[:artifact_id] || DemoArtifact.where(tenant_ref: @scope.tenant).order(id: :desc).first.id
      artifact = DemoV1::Access.artifact(@scope, id)
      @surface = present(:result_review, { artifact_id: artifact.id.to_s }, call_id: "artifact:#{artifact.id}")
      render "v1/review"
    end
    def new_artifact
      record = nil
      DemoArtifact.transaction do
        record = DemoArtifact.create!(code: "draft-#{SecureRandom.uuid}", tenant_ref: @scope.tenant, title: "New campaign draft")
        record.versions.create!(number: 1, body: "A new campaign draft ready for review.", origin: "fixture")
        @surface = present(:result_review, { artifact_id: record.id.to_s }, call_id: "artifact:#{record.id}")
      end
      redirect_to v1_review_path(artifact_id: record.id), status: :see_other
    end
    def identity
      unless %w[north-lead north-agent south-lead south-agent].include?(params[:code])
        raise ToolViews::Error.new("NOT_ALLOWED", status: 403)
      end
      session[:v1_identity] = params[:code]
      redirect_to v1_support_path, status: :see_other
    end
  end
end
