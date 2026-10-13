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

  def closed(**properties)
    { type: "object", additionalProperties: false, properties: properties }
  end

  test "every nested value position must declare what it accepts" do
    open_shapes = {
      "untyped object" => { properties: { name: { type: "string" } } },
      "empty schema" => {},
      "array without items" => { type: "array" },
      "untyped array items" => { type: "array", items: {} },
      "open nested object" => { type: "object", properties: { name: { type: "string" } } },
      "schema-valued additionalProperties" => { type: "object", additionalProperties: { type: "string" }, properties: {} },
      "reference under an untyped parent" => { properties: { inner: { "$ref" => "#" } } },
      "unconstrained union branch" => { anyOf: [{ type: "string" }, {}] },
      "empty union" => { anyOf: [] },
      "unknown type" => { type: "anything" }
    }
    open_shapes.each do |label, shape|
      error = assert_raises(ToolViews::Error, label) { ToolViews::Schema.new(closed(value: shape)) }
      assert_equal "INVALID_SCHEMA", error.code, label
    end
  end

  test "closed nested shapes unions nullable types and bounded branches still register" do
    schema = ToolViews::Schema.new(closed(
      tags: { type: "array", maxItems: 3, items: { type: "string" } },
      owner: { type: %w[object null], additionalProperties: false, properties: { id: { type: "string" } } },
      amount: { anyOf: [{ type: "integer" }, { type: "string", pattern: "^[0-9]+$" }] },
      mode: { enum: %w[draft final] }, version: { const: 1 }
    ).merge(anyOf: [{ required: ["tags"] }, { required: ["mode"] }]))
    assert_equal({ "tags" => ["a"], "owner" => nil, "amount" => "12", "version" => 1 },
      schema.validate!({ tags: ["a"], owner: nil, amount: "12", version: 1 }))
    assert_error("INVALID_PROPS") { schema.validate!({ owner: { id: "1", role: "admin" }, mode: "draft" }) }
    assert_error("INVALID_PROPS") { schema.validate!({ amount: 3 }) }
  end

  test "hosts word their own rejection codes and can translate built-in ones" do
    assert_equal "The request was rejected (OUT_OF_STOCK).", ToolViews::Error.new("OUT_OF_STOCK", status: 422).message
    assert_equal "Only two left.", ToolViews::Error.new("OUT_OF_STOCK", status: 422, message: "Only two left.").message
    assert_equal "Fix the form.", ToolViews::ValidationError.new(fields: { name: "is required" }, message: "Fix the form.").to_h[:message]
    assert_equal "This form has already been submitted.", ToolViews::Error.new("ALREADY_SUBMITTED", status: 409).message
    I18n.backend.store_translations(:en, tool_views: { errors: { out_of_stock: "Sold out.", not_found: "Nothing here." } })
    assert_equal "Sold out.", ToolViews::Error.new("OUT_OF_STOCK").message
    assert_equal "Nothing here.", ToolViews::Error.new("NOT_FOUND", status: 404).to_h[:message]
  ensure
    I18n.backend.reload!
  end
end
