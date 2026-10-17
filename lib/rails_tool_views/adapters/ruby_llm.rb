# frozen_string_literal: true
# Only this explicitly required file loads RubyLLM.
require "rails_tool_views"
require "ruby_llm"

module RailsToolViews
  module Adapters
    module RubyLLM
      # Optional RubyLLM tool exposing a scoped, approved component catalog.
      class PresentUI < ::RubyLLM::Tool
        description "Present one trusted interactive Rails component to the user."
        # Returns the stable provider-facing tool name.
        def self.tool_name
          "present_ui"
        end
        attr_reader :references
        # Captures an authorized catalog and server-owned correlation context.
        def initialize(keys:, scope:, context:, adapter_key: "ruby_llm")
          @scope = scope
          @context = Data.identifier(context, code: "INVALID_CONTEXT")
          @adapter_key = Data.identifier(adapter_key, code: "INVALID_CORRELATION")
          @components = RailsToolViews.registry.catalog(keys: keys, scope: scope)
          raise Error.new("EMPTY_CATALOG") if @components.empty?
          @references = []
        end
        # Returns the bounded schema presented to the provider.
        def parameters_schema
          { "type" => "object", "additionalProperties" => false, "required" => %w[component props],
            "properties" => { "component" => { "type" => "string", "enum" => @components.map(&:key) },
              "props" => { "anyOf" => @components.map { |component| component.schema.json }.uniq } } }
        end
        # Presents a component using a real RubyLLM ToolCall; returns an acknowledgment or rejection.
        def execute(component:, props:, tool_call: nil)
          definition = @components.find { |item| item.key == component.to_s }
          raise Error.new("NOT_ALLOWED", status: 403) unless definition
          raise Error.new("INCOMPATIBLE_COMPONENT", status: 422) unless RailsToolViews.registry.fetch(definition.key).digest == definition.digest
          # A server-owned ToolCall is required for provider replay safety.
          raise Error.new("MISSING_TOOL_CALL") unless tool_call.is_a?(::RubyLLM::ToolCall)
          raise Error.new("INVALID_TOOL_CALL") unless tool_call.name == name
          surface = RailsToolViews.present(definition.key, props: props, scope: @scope, context: @context,
            correlation: { adapter: @adapter_key, call_id: tool_call.id, context: @context })
          reference = { surface_id: surface.id, context_ref: @context }
          @references << reference.freeze unless @references.include?(reference)
          RailsToolViews.notify("adapter.tool_called", surface_id: surface.id, revision: surface.revision)
          # The persisted presentation receipt preserves the original tool result.
          # Match the receipt byte for byte; a non-binary collation must not return
          # another call's acknowledgment.
          presentation = RailsToolViews::Presentation.find_by(surface_id: surface.id, adapter: @adapter_key, call_id: tool_call.id, context_ref: @context)
          unless presentation && presentation.adapter == @adapter_key && presentation.call_id == tool_call.id && presentation.context_ref == @context
            raise Error.new("INVALID_CORRELATION")
          end
          presentation.result.symbolize_keys
        rescue Error => error
          error.to_h
        end
      end

      # Host owns durable chat lookup and delivery deduplication. This adapter
      # only starts a supported user turn; RubyLLM prevents pending-tool mixing.
      class Continuation
        # Accepts authorized chat resolution and durable host delivery deduplication.
        def initialize(chat_resolver:, delivery:)
          @chat_resolver, @delivery = chat_resolver, delivery
        end
        # Starts a user turn within the host delivery deduplication block.
        def call(payload, delivery_key:)
          @delivery.call(delivery_key) do
            chat = @chat_resolver.call(payload.fetch("context_ref"))
            chat.ask(JSON.generate(payload))
          end
        end
      end
    end
  end
end
