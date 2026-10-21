# frozen_string_literal: true
require_relative "test_helper"

class RegistryTest < ActiveSupport::TestCase
  test "strict immutable registration and scoped catalog" do
    component = RailsToolViews.registry.fetch(:choice_card)
    assert_equal "choice_card", component.key
    assert component.schema.json.frozen?
    assert_raises(FrozenError) { component.schema.json["properties"]["title"]["type"].replace("object") }
    assert_equal ["choice_card"], RailsToolViews.registry.catalog(keys: [:choice_card], scope: scope).map(&:key)
    assert_empty RailsToolViews.registry.catalog(keys: [:choice_card], scope: scope("bob"))
    assert_error("DUPLICATE_COMPONENT") { register_card }
  end

  test "unknown fields invalid schemas and untrusted renderer are rejected" do
    assert_error("INVALID_PROPS") { RailsToolViews.present(:choice_card, props: props.merge(code: "eval"), scope: scope) }
    assert_error("UNKNOWN_COMPONENT") { RailsToolViews.present("Kernel", props: {}, scope: scope) }
    assert_error("INVALID_SCHEMA") { RailsToolViews.register(:bad, description: "Bad", schema: { type: "object" }, partial: "x") }
    assert_error("INVALID_RENDERER") { RailsToolViews.register(:bad, description: "Bad", schema: PROPS_SCHEMA, component: "Kernel") }
    assert_equal 0, RailsToolViews::Surface.count
  end

  test "default deny and bounded payloads" do
    RailsToolViews.register(:private_card, description: "Private", schema: PROPS_SCHEMA, partial: "choices/card")
    assert_error("NOT_ALLOWED") { RailsToolViews.present(:private_card, props: props, scope: scope) }
    assert_error("NOT_ALLOWED") { RailsToolViews.present(:choice_card, props: props, scope: scope("bob")) }
    assert_error("INVALID_SCOPE") { RailsToolViews::Scope.new(actor: nil, tenant: "acme") }
    # Stored, indexed identifiers are capped in bytes so they always fit their
    # byte-limited columns and multi-column index keys.
    assert_equal 150, RailsToolViews::Data::IDENTIFIER_BYTES
    assert_equal "a" * 150, RailsToolViews::Data.identifier("a" * 150)
    assert_error("INVALID_SCOPE") { RailsToolViews::Data.identifier("a" * 151) }
    assert_equal "é" * 75, RailsToolViews::Data.identifier("é" * 75)
    assert_error("INVALID_SCOPE") { RailsToolViews::Data.identifier("é" * 76) }
    assert_error("INVALID_SCOPE") { RailsToolViews::Scope.new(actor: "a" * 151, tenant: "acme") }
    # Descriptions and versions are not indexed and keep the wider 255-byte cap.
    assert_equal "d" * 255, RailsToolViews::Data.reference("d" * 255)
    assert_error("INVALID_SCOPE") { RailsToolViews::Data.reference("d" * 256) }
    assert_error("PAYLOAD_TOO_LARGE") { RailsToolViews.present(:choice_card, props: props.merge(title: "x" * 40_000), scope: scope) }
    nested = {}; cursor = nested
    20.times { cursor["nested"] = {}; cursor = cursor["nested"] }
    assert_error("PAYLOAD_TOO_DEEP") { RailsToolViews.present(:choice_card, props: nested, scope: scope) }
    assert_error("INVALID_SCHEMA") { RailsToolViews::Schema.new(PROPS_SCHEMA.merge("$ref" => "https://example.org/schema")) }
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
      error = assert_raises(RailsToolViews::Error, label) { RailsToolViews::Schema.new(closed(value: shape)) }
      assert_equal "INVALID_SCHEMA", error.code, label
    end
  end

  test "closed nested shapes unions nullable types and bounded branches still register" do
    schema = RailsToolViews::Schema.new(closed(
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
    assert_equal "The request was rejected (OUT_OF_STOCK).", RailsToolViews::Error.new("OUT_OF_STOCK", status: 422).message
    assert_equal "Only two left.", RailsToolViews::Error.new("OUT_OF_STOCK", status: 422, message: "Only two left.").message
    assert_equal "Fix the form.", RailsToolViews::ValidationError.new(fields: { name: "is required" }, message: "Fix the form.").to_h[:message]
    assert_equal "This form has already been submitted.", RailsToolViews::Error.new("ALREADY_SUBMITTED", status: 409).message
    I18n.backend.store_translations(:en, rails_tool_views: { errors: { out_of_stock: "Sold out.", not_found: "Nothing here." } })
    assert_equal "Sold out.", RailsToolViews::Error.new("OUT_OF_STOCK").message
    assert_equal "Nothing here.", RailsToolViews::Error.new("NOT_FOUND", status: 404).to_h[:message]
  ensure
    I18n.backend.reload!
  end

  test "malformed registration input fails with a stable code" do
    empty = { type: "object", additionalProperties: false }
    assert_error("INVALID_SCHEMA") { RailsToolViews::Schema.new(closed(code: { type: "string", pattern: "(" })) }
    assert_error("INVALID_ACTION") { RailsToolViews.register(:no_schema, description: "D", schema: empty, partial: "x/y", actions: { go: { handler: ->(_) {} } }) }
    assert_error("INVALID_ACTION") { RailsToolViews.register(:not_hash, description: "D", schema: empty, partial: "x/y", actions: { go: :handler }) }
    assert_error("INVALID_COMPONENT") { RailsToolViews.register(:one_exposure, description: "D", schema: empty, partial: "x/y", expose_to: :agent) }
    assert_raises(RailsToolViews::Error) { RailsToolViews.registry.fetch(:no_schema) }
  end

  test "normalized values and digests match what the database stores" do
    assert_error("INVALID_SCOPE") { RailsToolViews::Scope.new(actor: "\xFF".dup.force_encoding(Encoding::UTF_8), tenant: "acme") }
    binary = RailsToolViews::Scope.new(actor: "é".b, tenant: "acme")
    assert_equal Encoding::UTF_8, binary.actor.encoding
    assert_equal "é", binary.actor
    # A reloaded value is a plain String, so the in-memory copy must be one too.
    label = RailsToolViews::Data.bounded("label" => ActiveSupport::SafeBuffer.new("<b>x</b>"))["label"]
    assert_equal String, label.class
    refute label.html_safe?
    # Canonical bytes are pinned: stored component digests and receipts depend on them.
    assert_equal "sha256:#{Digest::SHA256.hexdigest('{"a":[1,"x"],"b":null}')}", RailsToolViews::Data.digest(b: nil, a: [1, "x"])
    # An accepted value stays digestible inside its envelope.
    nested = "leaf"
    15.times { nested = [nested] }
    deep = RailsToolViews::Data.bounded("a" => nested)
    large = RailsToolViews::Data.bounded("t" => "x" * 32_700)
    assert_match(/\Asha256:\h{64}\z/, RailsToolViews::Data.digest(action: "go", arguments: deep, base_revision: 1))
    assert_match(/\Asha256:\h{64}\z/, RailsToolViews::Data.digest(component: "c", props: large, context: nil))
  end

  test "discovery policies receive an immutable request" do
    seen = nil
    RailsToolViews.register(:spy, description: "Spy", schema: { type: "object", additionalProperties: false }, partial: "x/y",
      expose_to: [:agent], policy: ->(access) { seen = access; true })
    RailsToolViews.registry.catalog(keys: [:spy], scope: scope)
    assert seen.frozen?
    assert seen.props.frozen?
  end
end
