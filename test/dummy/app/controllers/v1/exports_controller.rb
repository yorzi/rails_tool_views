# frozen_string_literal: true
module V1
  class ExportsController < BaseController
    def show
      raise RailsToolViews::Error.new("NOT_ALLOWED", status: 403) unless @staff.role == "lead"
      export = DemoExport.joins(:artifact).find_by(id: params[:id], demo_artifacts: { tenant_ref: @scope.tenant })
      raise RailsToolViews::Error.new("NOT_FOUND", status: 404) unless export
      send_data export.body, type: "text/plain; charset=utf-8", disposition: "attachment", filename: "artifact-#{export.artifact_id}-v#{export.artifact_version}.txt"
    end
  end
end
