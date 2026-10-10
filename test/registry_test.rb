# frozen_string_literal: true
require_relative "test_helper"

class RegistryTest < ActiveSupport::TestCase
  test "strict immutable registration and scoped catalog" do
    component = ToolViews.registry.fetch(:choice_card)
    assert_equal "choice_card", component.key
    assert component.schema.json.frozen?
    assert_raises(FrozenError) { component.schema.json["properties"]["title"]["type"].replace("object") }
    assert_equal ["choice_card"], ToolViews.registry.catalog(keys: [:choice_card], scope: scope).map(&:key)
    assert_empty ToolViews.registry.catalog(keys: [:choice_card], scope: scope("bob"))
    assert_error("DUPLICATE_COMPONENT") { register_card }
  end

  test "unknown fields invalid schemas and untrusted renderer are rejected" do
    assert_error("INVALID_PROPS") { ToolViews.present(:choice_card, props: props.merge(code: "eval"), scope: scope) }
    assert_error("UNKNOWN_COMPONENT") { ToolViews.present("Kernel", props: {}, scope: scope) }
    assert_error("INVALID_SCHEMA") { ToolViews.register(:bad, description: "Bad", schema: { type: "object" }, partial: "x") }
    assert_error("INVALID_RENDERER") { ToolViews.register(:bad, description: "Bad", schema: PROPS_SCHEMA, component: "Kernel") }
    assert_equal 0, ToolViews::Surface.count
  end

  test "default deny and bounded payloads" do
    ToolViews.register(:private_card, description: "Private", schema: PROPS_SCHEMA, partial: "choices/card")
    assert_error("NOT_ALLOWED") { ToolViews.present(:private_card, props: props, scope: scope) }
    assert_error("NOT_ALLOWED") { ToolViews.present(:choice_card, props: props, scope: scope("bob")) }
    assert_error("INVALID_SCOPE") { ToolViews::Scope.new(actor: nil, tenant: "acme") }
    assert_error("PAYLOAD_TOO_LARGE") { ToolViews.present(:choice_card, props: props.merge(title: "x" * 40_000), scope: scope) }
    nested = {}; cursor = nested
    20.times { cursor["nested"] = {}; cursor = cursor["nested"] }
    assert_error("PAYLOAD_TOO_DEEP") { ToolViews.present(:choice_card, props: nested, scope: scope) }
    assert_error("INVALID_SCHEMA") { ToolViews::Schema.new(PROPS_SCHEMA.merge("$ref" => "https://example.org/schema")) }
  end
end
