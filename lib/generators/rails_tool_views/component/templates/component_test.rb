# frozen_string_literal: true
require "test_helper"

class <%= name.camelize %>ComponentTest < ActiveSupport::TestCase
  test "<%= name %> denies presentation until host policies are configured" do
    error = assert_raises(RailsToolViews::Error) do
      RailsToolViews.present(:<%= name %>, props: { title: "Review" },
        scope: RailsToolViews::Scope.new(actor: "test-user", tenant: "test-tenant"))
    end
    assert_equal "NOT_ALLOWED", error.code
  end

  # Replace the denial test when you configure host policies. Add an allowed
  # actor/tenant, a denied actor/tenant, action validation and persisted-state tests.
end
