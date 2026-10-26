# frozen_string_literal: true
# The agent demo: a real RubyLLM chat that presents a component through the
# PresentUI tool and continues through the Continuation adapter. Loaded only
# when the bundle has RubyLLM 2.0 or later; bin/demo uses gemfiles/adapter.gemfile.
module DemoLLM
  MODEL = "gpt-4.1-mini"
  INSTRUCTIONS = "You help a Rails user choose a workflow. When a choice helps, call present_ui with the " \
    "choice_card component and the options compare and continue. A later JSON user message of type " \
    "agent_interaction is the user's choice from that card; answer it in one or two sentences."
  REPLIES = {
    "compare" => "You chose to compare options. A live model would now lay out the trade-offs side by side.",
    "continue" => "You chose to continue the analysis. A live model would now pick up from your question."
  }.freeze

  # An offline stand-in for the OpenAI Chat Completions endpoint. RubyLLM still
  # renders the request, parses the response and runs its tool loop; only the
  # network is replaced, so nothing leaves the process.
  class ScriptedTransport < Faraday::Adapter
    def call(env)
      super
      reply = Script.reply(JSON.parse(env.body))
      save_response(env, 200, JSON.generate(reply), { "content-type" => "application/json" })
      @app.call(env)
    end
  end
  Faraday::Adapter.register_middleware(rails_tool_views_demo: ScriptedTransport)

  # Deterministic model behavior, keyed on the last message RubyLLM sent.
  module Script
    module_function

    def reply(request)
      messages = request.fetch("messages")
      last = messages.last
      message = case last["role"]
      when "tool" then text(tool_result(last["content"]))
      when "user" then user_turn(request, text_of(last["content"]), messages.length)
      else text("I am the demo's scripted model.")
      end
      { id: "chatcmpl-demo-#{messages.length}", object: "chat.completion", created: 0, model: request["model"],
        choices: [{ index: 0, message: message, finish_reason: message[:tool_calls] ? "tool_calls" : "stop" }],
        usage: { prompt_tokens: 0, completion_tokens: 0, total_tokens: 0 } }
    end

    def user_turn(request, content, position)
      choice = continuation_key(content)
      return text(REPLIES.fetch(choice, "I received your choice: #{choice}.")) if choice
      # Read the catalog from the tool schema RubyLLM sent, as a provider would.
      tool = Array(request["tools"]).map { |entry| entry["function"] }.find { |function| function["name"] == "present_ui" }
      component = tool&.dig("parameters", "properties", "component", "enum")&.first
      return text("No interactive view is available in this chat.") unless component
      arguments = { component: component, props: { title: "Next step: #{content.squish.truncate(80)}",
        options: [{ key: "compare", label: "Compare options" }, { key: "continue", label: "Continue analysis" }] } }
      { role: "assistant", content: nil, tool_calls: [{ id: "call_demo_#{position}", type: "function",
        function: { name: "present_ui", arguments: JSON.generate(arguments) } }] }
    end

    def tool_result(content)
      result = JSON.parse(content.to_s)
      return "I added a choice card above. Pick a workflow and I will continue from your choice." if result["status"] == "presented"
      "The application refused that view (#{result['code'] || 'unknown'}), so nothing was shown."
    rescue JSON::ParserError
      "The tool returned something I could not read."
    end

    def continuation_key(content)
      payload = JSON.parse(content)
      payload.dig("values", "key").to_s if payload.is_a?(Hash) && payload["type"] == "agent_interaction"
    rescue JSON::ParserError
      nil
    end

    def text_of(content)
      content.is_a?(Array) ? content.filter_map { |part| part["text"] }.join("\n") : content.to_s
    end

    def text(content)
      { role: "assistant", content: content }
    end
  end

  # Persists the messages one turn adds after the turn completes. A failed turn
  # stores nothing, so it can be retried from the same transcript.
  Turn = Struct.new(:conversation, :chat) do
    def ask(content)
      known = chat.messages.length
      reply = chat.ask(content)
      DemoChatMessage.transaction do
        chat.messages.drop(known).each do |message|
          conversation.messages.create!(role: message.role.to_s, content: message.content&.to_s, tool_call_id: message.tool_call_id,
            tool_calls: message.tool_calls&.to_h { |id, call| [id, { "name" => call.name, "arguments" => call.arguments }] })
        end
      end
      reply
    end
  end

  module_function

  # Live mode is for the owner's own key. The project only runs the scripted transport.
  def live?
    ENV["RAILS_TOOL_VIEWS_DEMO_LLM"] == "openai"
  end

  def model
    live? ? ENV.fetch("RAILS_TOOL_VIEWS_DEMO_MODEL", MODEL) : MODEL
  end

  def context
    @context ||= RubyLLM.context do |config|
      if live?
        config.openai_api_key = ENV.fetch("OPENAI_API_KEY")
      else
        config.openai_api_key = "offline-demo"
        config.faraday_adapter = :rails_tool_views_demo
      end
    end
  end

  # Rebuilds the chat from the stored transcript and attaches a tool scoped to
  # the conversation's owner. Continuation turns get the same tool, so the
  # model can present another view while it answers.
  def chat_for(conversation)
    chat = context.chat(model: model, provider: :openai, protocol: :chat_completions, assume_model_exists: true)
    chat.with_instructions(INSTRUCTIONS)
    conversation.messages.each do |message|
      calls = message.tool_calls&.to_h do |id, call|
        [id, RubyLLM::ToolCall.new(id: id, name: call.fetch("name"), arguments: call.fetch("arguments"))]
      end
      chat.add_message(role: message.role.to_sym, content: message.content, tool_call_id: message.tool_call_id, tool_calls: calls)
    end
    chat.with_tools(RailsToolViews::Adapters::RubyLLM::PresentUI.new(keys: [:choice_card], scope: conversation.scope,
      context: conversation.context_ref))
    Turn.new(conversation, chat)
  end

  # The host adapter for agent conversations. The Engine has authorized the
  # action; the host still confirms that the chat belongs to the Surface's owner.
  def deliver(payload, delivery_key:)
    conversation = DemoConversation.for_context(payload.fetch("context_ref"))
    surface = conversation && RailsToolViews::Surface.find_by(id: payload.fetch("surface_id"))
    unless surface && [surface.actor_ref, surface.tenant_ref] == [conversation.actor_ref, conversation.tenant_ref]
      raise RailsToolViews::Error.new("NOT_ALLOWED", status: 403)
    end
    RailsToolViews::Adapters::RubyLLM::Continuation.new(chat_resolver: ->(_context_ref) { chat_for(conversation) },
      delivery: method(:deduplicate)).call(payload, delivery_key: delivery_key)
  end

  # The receipt and the transcript commit together, so a retried delivery cannot
  # add the reply twice. The model may be asked again after a crash.
  def deduplicate(delivery_key)
    DemoAgentReceipt.transaction(requires_new: true) do
      next if DemoAgentReceipt.exists?(delivery_key: delivery_key)
      yield
      DemoAgentReceipt.create!(delivery_key: delivery_key)
    end
  end
end
