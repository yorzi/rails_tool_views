# frozen_string_literal: true
# A controller class resolves its superclass once per process, so this runs apart.
ENV["RAILS_ENV"] = "test"
require "bundler/setup"
require_relative "../support/offline"
require_relative "../dummy/config/environment"
require_relative "../support/fixtures"
require "action_dispatch/testing/integration"
include TestFixtures

# Authentication lives on a subclass, not on ApplicationController.
class SignedInController < ApplicationController
  def signed_in_scope
    RailsToolViews::Scope.new(actor: "alice", tenant: "acme")
  end
end
RailsToolViews.reset!
RailsToolViews.configure do |config|
  config.parent_controller = "SignedInController"
  config.scope_resolver = ->(controller) { controller.signed_in_scope }
end
register_card
surface = present_card
client = ActionDispatch::Integration::Session.new(Rails.application)
client.post("/tool_views/surfaces/#{surface.id}/actions", as: :json,
  params: { action: "select_option", arguments: { key: "compare" }, base_revision: 1, idempotency_key: "parent-1" })
puts JSON.generate(superclass: RailsToolViews::SurfacesController.superclass.name, status: client.response.status,
  revision: JSON.parse(client.response.body)["revision"])
