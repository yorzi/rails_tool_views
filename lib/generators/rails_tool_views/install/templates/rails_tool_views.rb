# frozen_string_literal: true
RailsToolViews.configure do |config|
  # Fail closed until host authentication resolves stable actor AND tenant refs.
  # config.scope_resolver = ->(controller) {
  #   RailsToolViews::Scope.new(actor: controller.current_user.id.to_s,
  #     tenant: controller.current_account.id.to_s)
  # }
  # Mounted controllers inherit this host controller's filters and helpers.
  # config.parent_controller = "::ApplicationController"
end
# Register trusted components and explicit policies in Rails.application.config.to_prepare.
# Generate a safe scaffold: bin/rails generate rails_tool_views:component review_card
# See https://rails-tool-views.wangyaodi.com/component-generator/ for registration and policies.
