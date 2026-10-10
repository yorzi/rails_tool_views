# frozen_string_literal: true
ToolViews.configure do |config|
  # Fail closed until host authentication resolves stable actor AND tenant refs.
  # config.scope_resolver = ->(controller) {
  #   ToolViews::Scope.new(actor: controller.current_user.id.to_s,
  #     tenant: controller.current_account.id.to_s)
  # }
end
# Register trusted components and explicit policies in Rails.application.config.to_prepare.
# Read the gem README for a complete ChoiceCard definition and optional adapter.
