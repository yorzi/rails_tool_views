# frozen_string_literal: true
ENV["RAILS_ENV"] = "test"
require "bundler/setup"
require_relative "support/offline"
require_relative "dummy/config/environment"
require "rails/test_help"
require "minitest/mock"

require_relative "support/fixtures"

class ActiveSupport::TestCase
  include TestFixtures
  self.use_transactional_tests = false
  setup do
    [RailsToolViews::AgentInteraction, RailsToolViews::ActionExecution, RailsToolViews::Presentation, RailsToolViews::Surface, DemoEffect,
      DemoAgentReceipt, DemoOutboundReply, DemoReply, DemoTicket, DemoExport, DemoArtifactVersion, DemoArtifact, DemoCustomer, DemoStaff].each(&:delete_all)
    RailsToolViews.reset!
    register_card
  end
end
