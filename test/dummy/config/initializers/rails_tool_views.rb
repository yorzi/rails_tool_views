# frozen_string_literal: true
Rails.application.config.to_prepare do
  DemoSetup.call if !Rails.env.test? || ENV["RAILS_TOOL_VIEWS_SYSTEM_TEST"] == "1"
end
