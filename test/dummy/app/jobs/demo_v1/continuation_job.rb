# frozen_string_literal: true
module DemoV1
  # Host-owned example. A job re-resolves the current staff identity; it does
  # not treat serialized actor/tenant strings or browser input as authority.
  class ContinuationJob < ActiveJob::Base
    def perform(interaction_id, staff_id:, retry_failed: false)
      staff = DemoStaff.find_by(id: staff_id, active: true)
      raise RailsToolViews::Error.new("NOT_ALLOWED", status: 403) unless staff
      RailsToolViews.deliver(interaction_id, scope: Access.scope_for(staff), retry_failed: retry_failed)
    end
  end
end
