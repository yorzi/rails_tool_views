# frozen_string_literal: true
module RailsToolViews
  # Preserve the host's authentication methods, filters and view helpers.
  class SurfacesController < RailsToolViews.parent_controller
    # Request logs for these routes keep routing metadata only. Everything else,
    # including unknown injected fields, is masked here rather than in the host's
    # global filter list, which would also redact the host's own parameters.
    LOGGED_PARAMETERS = %w[controller action id interaction_id format action_name base_revision idempotency_key source_component target].freeze
    UNLOGGED_PARAMETER = /\A(?!(?:#{LOGGED_PARAMETERS.join('|')})\z)/
    # Rails' own form and submit helpers post these names; their values are never read.
    FORM_FURNITURE = %w[authenticity_token commit button].freeze

    protect_from_forgery with: :exception
    wrap_parameters false
    before_action :limit_payload
    helper RailsToolViews::SurfacesHelper
    rescue_from RailsToolViews::Error, with: :reject_request
    rescue_from ActionController::InvalidAuthenticityToken do
      reject_request(Error.new("INVALID_CSRF", status: 403))
    end

    def show
      surface = RailsToolViews.restore(params[:id], scope: current_scope)
      respond_to do |format|
        format.json { render json: surface.snapshot }
        format.html { render_surface_page(surface) }
      end
    end

    def act
      reject_unknown_fields(%w[action action_name arguments base_revision idempotency_key source_component target])
      result = RailsToolViews.dispatch(params[:id], scope: current_scope, action: input["action"] || input["action_name"],
        # A native form for an action without arguments cannot post an empty object.
        arguments: input.fetch("arguments", {}),
        base_revision: parse_revision(input["base_revision"]), idempotency_key: input["idempotency_key"],
        source_component: input["source_component"], target: input["target"])
      if result[:interaction_id] && RailsToolViews.configuration.agent_adapter && RailsToolViews.configuration.auto_deliver
        RailsToolViews.deliver(result[:interaction_id], scope: current_scope)
      end
      respond_with_surface(result)
    end

    def retry_agent
      reject_unknown_fields(%w[])
      surface = RailsToolViews.restore(params[:id], scope: current_scope)
      interaction = surface.agent_interactions.find_by(id: params[:interaction_id])
      raise Error.new("NOT_FOUND", status: 404) unless interaction
      RailsToolViews.deliver(interaction.id, scope: current_scope, retry_failed: true)
      respond_with_surface(status: "completed", surface_id: surface.id, revision: surface.revision, interaction_id: interaction.id)
    end

    private
    # Runs before Rails reads the filtered parameters for its request log.
    def process_action(*)
      request.set_header("action_dispatch.parameter_filter", Array(request.get_header("action_dispatch.parameter_filter")) + [UNLOGGED_PARAMETER])
      super
    end
    def current_scope
      @current_scope ||= RailsToolViews.configuration.scope_resolver&.call(self)
      raise Error.new("NOT_ALLOWED", status: 403) unless @current_scope.is_a?(Scope)
      @current_scope
    end
    def limit_payload
      raise Error.new("PAYLOAD_TOO_LARGE", status: 413) if request.content_length.to_i > RailsToolViews.configuration.max_payload_bytes || request.raw_post.to_s.bytesize > RailsToolViews.configuration.max_payload_bytes
    end
    def reject_unknown_fields(allowed)
      extra = input.keys - allowed - FORM_FURNITURE
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
      surface = RailsToolViews.restore(result[:surface_id], scope: current_scope)
      interaction = result[:interaction_id] && surface.agent_interactions.find_by(id: result[:interaction_id])
      response = result.merge(current_revision: surface.revision)
      response[:agent_status] = interaction.status if interaction
      response[:status] = "pending" if interaction && %w[pending delivering].include?(interaction.status)
      status = response[:status] == "pending" ? 202 : 200
      respond_to do |format|
        format.json { render json: response, status: status }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(surface.dom_id, RailsToolViews.render(surface, view_context: view_context, scope: current_scope, notice: result[:notice])), status: status }
        # Without Turbo, return to the page that embeds the Surface; it re-renders saved state.
        # The Engine's own helper keeps whatever mount path and name the host chose.
        format.html do
          if result[:notice]
            flash[:rails_tool_views_notice] = { "surface_id" => surface.id.to_s, "actor" => current_scope.actor,
              "tenant" => current_scope.tenant, "text" => result[:notice] }
          end
          redirect_after_action(surface)
        end
      end
    end
    def redirect_after_action(surface)
      # After correcting a full-page error, Referer can be a POST-only Engine
      # route. Redirect to the readable Surface instead of GET /actions (404).
      referrer_path = begin
        URI.parse(request.referer.to_s).path.to_s
      rescue URI::InvalidURIError
        ""
      end
      if referrer_path.start_with?("#{surface_path(surface)}/")
        redirect_to surface_path(surface), status: :see_other
      else
        redirect_back_or_to surface_path(surface), allow_other_host: false, status: :see_other
      end
    end
    def render_surface_page(surface, error: nil)
      html = surface && view_context.rails_tool_views_surface(surface, scope: current_scope, error: error)
      render template: "rails_tool_views/surfaces/page", layout: "rails_tool_views/application",
        locals: { surface_html: html, reload_path: surface && surface_path(surface), error: error },
        status: error ? error.status : :ok
    end
    def reject_request(error)
      respond_to do |format|
        format.json { render json: error.to_h, status: error.status }
        format.turbo_stream do
          # Failed authorization never renders props, and supplied targets never reach Turbo.
          begin
            surface = RailsToolViews.restore(params[:id], scope: current_scope)
            html = RailsToolViews.render(surface, view_context: view_context, scope: current_scope, error: error)
            render turbo_stream: turbo_stream.replace(surface.dom_id, html), status: error.status
          rescue RailsToolViews::Error
            render plain: error.message, status: error.status
          end
        end
        format.html do
          begin
            surface = RailsToolViews.restore(params[:id], scope: current_scope)
            render_surface_page(surface, error: error)
          rescue RailsToolViews::Error
            render_surface_page(nil, error: error)
          end
        end
      end
    end
  end
end
