# frozen_string_literal: true
require "json"
require "digest"
require "securerandom"
require "json_schemer"
require_relative "version"

# Registers trusted Rails views and orchestrates persistent, authorized interactions.
module RailsToolViews
  # A recoverable rejection with a stable code and HTTP status.
  class Error < StandardError
    attr_reader :code, :status
    MESSAGES = {
      "NOT_FOUND" => "This view is unavailable.", "NOT_ALLOWED" => "You do not have permission to use this view.",
      "CONFLICT" => "This view changed. Refresh to continue.", "INVALID_ARGUMENTS" => "Check the submitted values and try again.",
      "VALIDATION_FAILED" => "Check the highlighted fields and try again.",
      "INCOMPATIBLE_COMPONENT" => "This view's contract changed. Ask the application owner to migrate or recreate it.",
      "RENDER_FAILED" => "This view cannot be rendered. Your saved state is preserved.",
      "AGENT_UNAVAILABLE" => "Your changes were saved, but the AI follow-up could not complete.",
      "IDEMPOTENCY_CONFLICT" => "This request identifier was already used for a different request."
    }.freeze
    # Hosts own the wording of their codes: pass message:, or translate
    # rails_tool_views.errors.<downcased code>. Built-in codes translate the same way.
    def self.message_for(code)
      fallback = MESSAGES.fetch(code) { "The request was rejected (#{code})." }
      defined?(::I18n) ? ::I18n.t(code.downcase, scope: %i[rails_tool_views errors], default: fallback) : fallback
    end
    # Creates a rejection; message overrides the default or translated wording.
    def initialize(code, status: 400, message: nil)
      @code, @status = code, status
      super(message || self.class.message_for(code))
    end
    # Returns a bounded rejection payload for the caller.
    def to_h
      { status: "rejected", code: code, message: message }
    end
  end

  module Data # :nodoc:
    module_function
    def normalize(value, depth = 0)
      raise Error.new("PAYLOAD_TOO_DEEP") if depth > RailsToolViews.configuration.max_depth
      case value
      when Hash
        result = {}
        value.each do |key, item|
          raise Error.new("INVALID_JSON") unless key.is_a?(String) || key.is_a?(Symbol)
          raise Error.new("INVALID_JSON") if result.key?(key.to_s)
          result[key.to_s] = normalize(item, depth + 1)
        end
        result
      when Array then value.map { |item| normalize(item, depth + 1) }
      when String then value.dup
      when Integer, TrueClass, FalseClass, NilClass then value
      when Float
        raise Error.new("INVALID_JSON") unless value.finite?
        value
      else raise Error.new("INVALID_JSON")
      end
    end
    def bounded(value)
      normalized = normalize(value)
      raise Error.new("PAYLOAD_TOO_LARGE", status: 413) if JSON.generate(normalized).bytesize > RailsToolViews.configuration.max_payload_bytes
      normalized
    rescue JSON::GeneratorError, EncodingError
      raise Error.new("INVALID_JSON")
    end
    def freeze_deep(value)
      case value
      when Hash then value.each { |key, item| key.freeze; freeze_deep(item) }
      when Array then value.each { |item| freeze_deep(item) }
      end
      value.freeze
    end
    def canonical(value)
      case value
      when Hash then value.keys.sort.to_h { |key| [key, canonical(value[key])] }
      when Array then value.map { |item| canonical(item) }
      else value
      end
    end
    def digest(value)
      "sha256:#{Digest::SHA256.hexdigest(JSON.generate(canonical(bounded(value))))}"
    end
    # Actor, tenant, context, adapter, call and replay references are persisted
    # in string columns that carry multi-column indexes. Cap them in bytes so a
    # value can never overflow a byte-limited column and every unique key fits
    # utf8mb4's 3072-byte index limit on MySQL/InnoDB. A byte cap also bounds the
    # character count, which is what a varchar length actually limits.
    IDENTIFIER_BYTES = 150
    def reference(value, code: "INVALID_SCOPE", limit: 255)
      raise Error.new(code) unless value.is_a?(String) && !value.strip.empty? && value.bytesize <= limit
      value.dup.freeze
    end
    # A bounded reference for a stored, indexed identifier.
    def identifier(value, code: "INVALID_SCOPE")
      reference(value, code: code, limit: IDENTIFIER_BYTES)
    end
  end

  # Host-owned validation feedback. Only return approved, schema-validated form
  # values; rejected requests do not change Surface or domain persistence.
  # A rejected form with field messages and explicitly safe retained values.
  class ValidationError < Error
    attr_reader :fields, :values
    # Creates field feedback with only the values the host approves for redisplay.
    def initialize(fields:, values: {}, message: nil)
      @fields, @values = Data.bounded(fields), Data.bounded(values)
      unless @fields.is_a?(Hash) && @values.is_a?(Hash) && @fields.all? { |key, text| key.match?(/\A[a-z][a-z0-9_]*\z/) && text.is_a?(String) && text.length <= 500 }
        raise Error.new("INVALID_VALIDATION_FEEDBACK")
      end
      Data.freeze_deep(@fields)
      Data.freeze_deep(@values)
      super("VALIDATION_FAILED", status: 422, message: message)
    end
    # Returns a bounded rejection payload for the caller.
    def to_h
      super.merge(fields: fields, values: values)
    end
  end

  # Validates a bounded, closed JSON contract.
  class Schema
    KEYWORDS = %w[type properties required additionalProperties items enum const minimum maximum minLength maxLength pattern minItems maxItems uniqueItems description title anyOf oneOf allOf].freeze
    TYPES = %w[object array string number integer boolean null].freeze
    COMBINATORS = %w[anyOf oneOf allOf].freeze
    attr_reader :json
    # Builds a closed schema; rejects unsupported or unbounded nested contracts.
    def initialize(schema)
      @json = Data.bounded(schema)
      inspect_schema!(@json)
      raise Error.new("INVALID_SCHEMA") unless @json["type"] == "object" && @json["additionalProperties"] == false
      @validator = JSONSchemer.schema(@json, ref_resolver: ->(_uri) { raise Error.new("INVALID_SCHEMA") })
      raise Error.new("INVALID_SCHEMA") unless @validator.valid_schema?
      Data.freeze_deep(@json)
    rescue JSONSchemer::UnknownRef, ArgumentError
      raise Error.new("INVALID_SCHEMA")
    end
    # Returns normalized validated data, or raises Error with the supplied code.
    def validate!(value, code: "INVALID_PROPS")
      data = Data.bounded(value)
      raise Error.new(code) unless @validator.valid?(data)
      data
    end
    private
    # Every subschema is walked, and every value position must say what it
    # accepts: an untyped or empty schema admits any JSON, which would reopen a
    # closed object from the inside. `bounded` is true only for a combinator
    # branch whose enclosing schema already constrains the same value.
    def inspect_schema!(schema, bounded: false) # :nodoc:
      raise Error.new("INVALID_SCHEMA") unless schema.is_a?(Hash) && (schema.keys - KEYWORDS).empty?
      types = Array(schema["type"])
      combinators = COMBINATORS.select { |key| schema.key?(key) }
      constrained = types.any? || schema.key?("enum") || schema.key?("const")
      valid = (types - TYPES).empty? && (constrained || bounded || combinators.any?) &&
        (!schema.key?("enum") || schema["enum"].is_a?(Array)) &&
        (!schema.key?("additionalProperties") || schema["additionalProperties"] == false) &&
        schema.fetch("properties", {}).is_a?(Hash) && schema.fetch("items", {}).is_a?(Hash) &&
        (!types.include?("object") || schema["additionalProperties"] == false) &&
        (!types.include?("array") || schema.key?("items")) &&
        combinators.all? { |key| schema[key].is_a?(Array) && schema[key].any? }
      raise Error.new("INVALID_SCHEMA") unless valid
      schema.fetch("properties", {}).each_value { |child| inspect_schema!(child) }
      inspect_schema!(schema["items"]) if schema.key?("items")
      combinators.each { |key| schema[key].each { |child| inspect_schema!(child, bounded: bounded || constrained) } }
    end
  end

  # Immutable actor and tenant references resolved by the host.
  class Scope
    attr_reader :actor, :tenant
    # Creates frozen, nonempty string references for an authenticated identity.
    def initialize(actor:, tenant:)
      @actor, @tenant = Data.identifier(actor), Data.identifier(tenant)
      freeze
    end
  end

  # Policy and handler context populated by the runtime.
  Access = Struct.new(:actor, :tenant, :operation, :props, :surface, :action, :arguments, :context_ref, keyword_init: true)
  # Handler result containing the next UI state and an optional agent flag.
  Transition = Struct.new(:state, :agent, keyword_init: true)
  Action = Struct.new(:key, :schema, :policy, :handler, keyword_init: true)

  # An immutable renderer, schema, version, and authorization contract.
  class Component
    # A ViewComponent opts into these by naming them as initializer keywords.
    CONTEXT = %i[surface state error].freeze
    attr_reader :key, :description, :schema, :partial, :component, :policy, :actions, :expose_to, :digest, :version, :context
    # Builds an immutable component with exactly one trusted renderer.
    def initialize(key, description:, schema:, partial: nil, component: nil, policy: nil, actions: {}, expose_to: [], version: "1")
      @key = key.to_s.freeze
      raise Error.new("INVALID_COMPONENT") unless @key.match?(/\A[a-z][a-z0-9_]{0,63}\z/)
      @description = Data.reference(description, code: "INVALID_COMPONENT")
      @version = Data.reference(version.to_s, code: "INVALID_COMPONENT")
      @schema = Schema.new(schema)
      if (!!partial == !!component) || (partial && (!partial.is_a?(String) || !partial.match?(/\A[a-zA-Z0-9_\/]+\z/))) || (component && (!component.is_a?(Class) || component.name.nil?))
        raise Error.new("INVALID_RENDERER")
      end
      @partial, @component, @policy = partial&.dup&.freeze, component, policy
      keywords = component ? component.instance_method(:initialize).parameters.filter_map { |kind, name| name if %i[key keyreq].include?(kind) } : []
      @context = (CONTEXT & keywords).freeze
      raise Error.new("INVALID_COMPONENT") if (@context.map(&:to_s) & @schema.json.fetch("properties", {}).keys).any?
      @expose_to = expose_to.map(&:to_sym).freeze
      @actions = actions.to_h do |name, definition|
        name = name.to_s.freeze
        raise Error.new("INVALID_ACTION") unless name.match?(/\A[a-z][a-z0-9_]{0,63}\z/) && (definition.keys - %i[schema policy handler]).empty? && definition[:handler].respond_to?(:call)
        [name, Action.new(key: name, schema: Schema.new(definition.fetch(:schema)), policy: definition[:policy], handler: definition[:handler]).freeze]
      end.freeze
      @digest = Data.digest(key: @key, version: @version, schema: @schema.json, renderer: @partial || @component.name,
        actions: @actions.transform_values { |action| action.schema.json }, contract_version: 1).freeze
      freeze
    end
    def authorize!(access) # :nodoc:
      raise Error.new("NOT_ALLOWED", status: 403) unless policy&.call(access) == true
    end
  end

  # Stores explicit component definitions and filters discoverable catalogs.
  class Registry
    # Creates an empty, process-local registry.
    def initialize
      @components = {}
      @mutex = Mutex.new
    end
    # Registers a component; duplicate keys raise DUPLICATE_COMPONENT.
    def register(key, **options)
      component = Component.new(key, **options)
      @mutex.synchronize do
        raise Error.new("DUPLICATE_COMPONENT") if @components.key?(component.key)
        @components[component.key] = component
      end
      component
    end
    # Returns the named component, or raises UNKNOWN_COMPONENT.
    def fetch(key)
      @components.fetch(key.to_s) { raise Error.new("UNKNOWN_COMPONENT", status: 404) }
    end
    # Returns explicitly exposed components allowed by discovery policy for scope.
    def catalog(keys:, scope:, exposure: :agent)
      raise Error.new("INVALID_SCOPE", status: 403) unless scope.is_a?(Scope)
      raise Error.new("CATALOG_TOO_LARGE") unless keys.is_a?(Array) && keys.length.between?(1, RailsToolViews.configuration.max_catalog_components) && keys.map(&:to_s).uniq.length == keys.length
      keys.map { |key| fetch(key) }.select do |component|
        component.expose_to.include?(exposure) && component.policy&.call(Access.new(actor: scope.actor, tenant: scope.tenant, operation: :discover, props: {}, context_ref: nil)) == true
      end.freeze
    end
  end

  # Process-local host hooks, request limits, and delivery settings.
  class Configuration
    attr_accessor :scope_resolver, :agent_adapter, :max_payload_bytes, :max_depth, :max_catalog_components, :max_actions_per_minute, :auto_deliver,
      :parent_controller, :delivery_lease
    # Initializes conservative request limits with no host identity or agent adapter.
    def initialize
      @max_payload_bytes, @max_depth, @max_catalog_components, @max_actions_per_minute = 32_768, 16, 20, 60
      @auto_deliver = true
      # Name the host controller that carries authentication; seconds before an unfinished delivery may be reclaimed.
      @parent_controller, @delivery_lease = "::ApplicationController", 300
    end
  end

  class << self
    # Returns the process-local component registry.
    def registry
      @registry ||= Registry.new
    end
    # Returns the process-local configuration.
    def configuration
      @configuration ||= Configuration.new
    end
    # Yields configuration to the host initializer.
    def configure
      yield configuration
    end
    # Registers a component; duplicate keys raise DUPLICATE_COMPONENT.
    def register(key, **options)
      registry.register(key, **options)
    end
    # Clears definitions while retaining configuration; use in Rails reload hooks.
    def reset_registry!
      @registry = Registry.new
    end
    # Clears definitions and configuration; intended for isolated tests.
    def reset!
      @registry, @configuration = Registry.new, Configuration.new
    end
  end
end
