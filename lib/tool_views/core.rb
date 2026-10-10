# frozen_string_literal: true
require "json"
require "digest"
require "securerandom"
require "json_schemer"
require_relative "version"

module ToolViews
  class Error < StandardError
    attr_reader :code, :status
    MESSAGES = {
      "NOT_FOUND" => "This view is unavailable.", "NOT_ALLOWED" => "You do not have permission to use this view.",
      "CONFLICT" => "This view changed. Refresh to continue.", "INVALID_ARGUMENTS" => "Choose an allowed option and try again.",
      "INCOMPATIBLE_COMPONENT" => "This view's contract changed. Ask the application owner to migrate or recreate it.",
      "RENDER_FAILED" => "This view cannot be rendered. Your saved state is preserved.",
      "AGENT_UNAVAILABLE" => "Your choice was saved, but the AI follow-up could not complete.",
      "IDEMPOTENCY_CONFLICT" => "This request identifier was already used for a different request."
    }.freeze
    def initialize(code, status: 400)
      @code, @status = code, status
      super(MESSAGES.fetch(code, "The request was rejected (#{code})."))
    end
    def to_h
      { status: "rejected", code: code, message: message }
    end
  end

  module Data
    module_function
    def normalize(value, depth = 0)
      raise Error.new("PAYLOAD_TOO_DEEP") if depth > ToolViews.configuration.max_depth
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
      raise Error.new("PAYLOAD_TOO_LARGE", status: 413) if JSON.generate(normalized).bytesize > ToolViews.configuration.max_payload_bytes
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
    def reference(value, code: "INVALID_SCOPE")
      raise Error.new(code) unless value.is_a?(String) && !value.strip.empty? && value.bytesize <= 255
      value.dup.freeze
    end
  end

  class Schema
    KEYWORDS = %w[type properties required additionalProperties items enum const minimum maximum minLength maxLength pattern minItems maxItems uniqueItems description title anyOf oneOf allOf].freeze
    attr_reader :json
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
    def validate!(value, code: "INVALID_PROPS")
      data = Data.bounded(value)
      raise Error.new(code) unless @validator.valid?(data)
      data
    end
    private
    def inspect_schema!(schema)
      raise Error.new("INVALID_SCHEMA") unless schema.is_a?(Hash) && (schema.keys - KEYWORDS).empty?
      if schema["type"] == "object" || Array(schema["type"]).include?("object")
        raise Error.new("INVALID_SCHEMA") unless schema["additionalProperties"] == false && schema.fetch("properties", {}).is_a?(Hash)
        schema.fetch("properties", {}).each_value { |child| inspect_schema!(child) }
      end
      inspect_schema!(schema["items"]) if schema.key?("items")
      %w[anyOf oneOf allOf].each { |key| schema.fetch(key, []).each { |child| inspect_schema!(child) } }
    end
  end

  class Scope
    attr_reader :actor, :tenant
    def initialize(actor:, tenant:)
      @actor, @tenant = Data.reference(actor), Data.reference(tenant)
      freeze
    end
  end

  Access = Struct.new(:actor, :tenant, :operation, :props, :surface, :action, :arguments, :context_ref, keyword_init: true)
  Transition = Struct.new(:state, :agent, keyword_init: true)
  Action = Struct.new(:key, :schema, :policy, :handler, keyword_init: true)

  class Component
    attr_reader :key, :description, :schema, :partial, :component, :policy, :actions, :expose_to, :digest, :version
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
    def authorize!(access)
      raise Error.new("NOT_ALLOWED", status: 403) unless policy&.call(access) == true
    end
  end

  class Registry
    def initialize
      @components = {}
      @mutex = Mutex.new
    end
    def register(key, **options)
      component = Component.new(key, **options)
      @mutex.synchronize do
        raise Error.new("DUPLICATE_COMPONENT") if @components.key?(component.key)
        @components[component.key] = component
      end
      component
    end
    def fetch(key)
      @components.fetch(key.to_s) { raise Error.new("UNKNOWN_COMPONENT", status: 404) }
    end
    def catalog(keys:, scope:, exposure: :agent)
      raise Error.new("INVALID_SCOPE", status: 403) unless scope.is_a?(Scope)
      raise Error.new("CATALOG_TOO_LARGE") unless keys.is_a?(Array) && keys.length.between?(1, ToolViews.configuration.max_catalog_components) && keys.map(&:to_s).uniq.length == keys.length
      keys.map { |key| fetch(key) }.select do |component|
        component.expose_to.include?(exposure) && component.policy&.call(Access.new(actor: scope.actor, tenant: scope.tenant, operation: :discover, props: {}, context_ref: nil)) == true
      end.freeze
    end
  end

  class Configuration
    attr_accessor :scope_resolver, :agent_adapter, :max_payload_bytes, :max_depth, :max_catalog_components, :max_actions_per_minute, :auto_deliver
    def initialize
      @max_payload_bytes, @max_depth, @max_catalog_components, @max_actions_per_minute = 32_768, 16, 20, 60
      @auto_deliver = true
    end
  end

  class << self
    def registry
      @registry ||= Registry.new
    end
    def configuration
      @configuration ||= Configuration.new
    end
    def configure
      yield configuration
    end
    def register(key, **options)
      registry.register(key, **options)
    end
    def reset_registry!
      @registry = Registry.new
    end
    def reset!
      @registry, @configuration = Registry.new, Configuration.new
    end
  end
end
