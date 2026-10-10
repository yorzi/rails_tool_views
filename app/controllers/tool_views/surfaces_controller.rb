# frozen_string_literal: true
module ToolViews
  class SurfacesController < ActionController::Base
    protect_from_forgery with: :exception
    wrap_parameters false
    before_action :limit_payload
    helper ToolViews::SurfacesHelper
    rescue_from ToolViews::Error, with: :reject_request
    rescue_from ActionController::InvalidAuthenticityToken do
      reject_request(Error.new("INVALID_CSRF", status: 403))
    end

    def show
      surface = ToolViews.restore(params[:id], scope: current_scope)
      respond_to do |format|
        format.json { render json: surface.snapshot }
        format.html { render html: ToolViews.render(surface, view_context: view_context, scope: current_scope) }
      end
    end

    def act
      reject_unknown_fields(%w[action action_name arguments base_revision idempotency_key source_component target])
      result = ToolViews.dispatch(params[:id], scope: current_scope, action: input["action"] || input["action_name"],
        arguments: input["arguments"],
        base_revision: parse_revision(input["base_revision"]), idempotency_key: input["idempotency_key"],
        source_component: input["source_component"], target: input["target"])
      if result[:interaction_id] && ToolViews.configuration.agent_adapter && ToolViews.configuration.auto_deliver
        ToolViews.deliver(result[:interaction_id], scope: current_scope)
      end
      respond_with_surface(result)
    end

    def retry_agent
      reject_unknown_fields(%w[])
      surface = ToolViews.restore(params[:id], scope: current_scope)
      interaction = surface.agent_interactions.find_by(id: params[:interaction_id])
      raise Error.new("NOT_FOUND", status: 404) unless interaction
      ToolViews.deliver(interaction.id, scope: current_scope, retry_failed: true)
      respond_with_surface(status: "completed", surface_id: surface.id, revision: surface.revision, interaction_id: interaction.id)
    end

    private
    def current_scope
      @current_scope ||= ToolViews.configuration.scope_resolver&.call(self)
      raise Error.new("NOT_ALLOWED", status: 403) unless @current_scope.is_a?(Scope)
      @current_scope
    end
    def limit_payload
      raise Error.new("PAYLOAD_TOO_LARGE", status: 413) if request.content_length.to_i > ToolViews.configuration.max_payload_bytes || request.raw_post.to_s.bytesize > ToolViews.configuration.max_payload_bytes
    end
    def reject_unknown_fields(allowed)
      extra = input.keys - allowed - %w[authenticity_token]
      raise Error.new("UNKNOWN_FIELD") unless extra.empty?
      raise Error.new("UNKNOWN_FIELD") if input.key?("action") && input.key?("action_name")
    end
    def input
      @input ||= Data.bounded(request.request_parameters)
    end
    def parse_revision(value)
      return value if value.is_a?(Integer)
      raise Error.new("INVALID_REVISION") unless value.is_a?(String) && value.match?(/\A[1-9][0-9]{0,9}\z/)
      value.to_i
    end
    def respond_with_surface(result)
      surface = ToolViews.restore(result[:surface_id], scope: current_scope)
      interaction = result[:interaction_id] && surface.agent_interactions.find_by(id: result[:interaction_id])
      response = result.merge(current_revision: surface.revision)
      response[:agent_status] = interaction.status if interaction
      response[:status] = "pending" if interaction && %w[pending delivering].include?(interaction.status)
      status = response[:status] == "pending" ? 202 : 200
      respond_to do |format|
        format.json { render json: response, status: status }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(surface.dom_id, ToolViews.render(surface, view_context: view_context, scope: current_scope)), status: status }
        format.html { redirect_to tool_views.surface_path(surface), status: :see_other }
      end
    end
    def reject_request(error)
      respond_to do |format|
        format.json { render json: error.to_h, status: error.status }
        format.turbo_stream do
          # Failed authorization never renders props, and supplied targets never reach Turbo.
          begin
            surface = ToolViews.restore(params[:id], scope: current_scope)
            html = ToolViews.render(surface, view_context: view_context, scope: current_scope, error: error)
            render turbo_stream: turbo_stream.replace(surface.dom_id, html), status: error.status
          rescue ToolViews::Error
            render plain: error.message, status: error.status
          end
        end
        format.html { render partial: "tool_views/surfaces/error", locals: { error: error }, status: error.status }
      end
    end
  end
end
