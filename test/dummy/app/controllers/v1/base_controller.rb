# frozen_string_literal: true
module V1
  class BaseController < ApplicationController
    protect_from_forgery with: :exception
    before_action :resolve_demo_identity
    helper V1Helper
    rescue_from ToolViews::Error do |error|
      render partial: "tool_views/surfaces/error", locals: { error: error }, status: error.status
    end
    rescue_from ActionController::InvalidAuthenticityToken do
      render plain: "The request was rejected (INVALID_CSRF).", status: :forbidden
    end
    private
    def resolve_demo_identity
      DemoV1::Seeds.call
      session[:v1_identity] ||= "north-lead"
      @staff = DemoStaff.find_by!(code: session[:v1_identity], active: true)
      @scope = DemoV1::Access.scope_for(@staff)
    end
    def present(key, props, call_id:)
      ToolViews.present(key, props: props, scope: @scope, context: "v1:#{key}",
        correlation: { adapter: "rails-demo", call_id: call_id, context: "v1:#{key}" })
    end
  end
end
