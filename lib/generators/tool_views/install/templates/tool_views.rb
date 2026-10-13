# frozen_string_literal: true
ToolViews.configure do |config|
  # Fail closed until host authentication resolves stable actor AND tenant refs.
  # config.scope_resolver = ->(controller) {
  #   ToolViews::Scope.new(actor: controller.current_user.id.to_s,
  #     tenant: controller.current_account.id.to_s)
  # }
  # Mounted controllers inherit this host controller's filters and helpers.
  # config.parent_controller = "::ApplicationController"
end
# Register trusted components and explicit policies in Rails.application.config.to_prepare.
# Read the gem README for a complete ChoiceCard definition and optional adapter.
