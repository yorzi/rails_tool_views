---
layout: default
title: "RubyLLM Integration"
nav_order: 1
description: "Expose an approved component catalog through an optional RubyLLM tool."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Load the adapter explicitly.
* Bound the catalog and correlate real tool calls.
* Attach the tool to a chat and render the views it presents.
* Continue the same chat after the user acts.

## Load Only When Needed

Add `ruby_llm` {{ site.requirements.ruby_llm }} to the host Gemfile, then load the adapter explicitly:

```ruby
require "rails_tool_views/adapters/ruby_llm"
```

The require raises `Gem::LoadError` when the bundle has no RubyLLM or only RubyLLM 1.x. The tool depends on RubyLLM 2.0 passing the real `ToolCall` to it, so on 1.x every call would be refused.

The core does not require RubyLLM or a provider. The adapter is [experimental]({% link _reference/public-contract.md %}#experimental-parts): it has offline coverage against RubyLLM {{ site.requirements.ruby_llm_tested }}, including a real chat loop, but no live provider has been exercised end to end, and it may change in a minor release. Configure provider credentials through the host's RubyLLM setup, not through RailsToolViews.

## Build the Approved Tool

After registering the tutorial component with `expose_to: [:agent]` and creating its authorized `scope`:

```ruby
# docs-example: tool
present_ui = RailsToolViews::Adapters::RubyLLM::PresentUI.new(
  keys: [:choice_card], scope: scope, context: "conversation:demo")
```

Pass this instance to the host chat's RubyLLM tool registration. Keep `keys`, scope, and context server-owned. The catalog applies discovery policy and exposes bounded schemas. Execution validates the exact selected component and current digest again.

The adapter requires a real `RubyLLM::ToolCall` with the correct tool name. Do not invent correlation IDs in model output. Durable presentation receipts deduplicate tool retries. `references` is request-local browser reference collection, separate from the acknowledgment returned to the model.

## Attach the Tool to a Chat

Register the tool on the chat that answers the user. RubyLLM runs it when the model calls `present_ui`:

```ruby
chat = RubyLLM.chat(model: "gpt-4.1-mini")
chat.with_tools(RailsToolViews::Adapters::RubyLLM::PresentUI.new(
  keys: [:choice_card], scope: scope, context: "conversation:#{conversation.id}"))
chat.ask("Help me choose the next step")
```

The model sees one tool. Its `component` argument is an enum of the catalog, and its `props` argument accepts any catalog schema. The schema goes to the provider as declared, without strict mode. A model can still pair a component with another component's props, so the server validates the selected component again and returns `INVALID_PROPS` to the model instead of saving.

Treat props from a model as untrusted input. The closed schema bounds their shape, and your action policies decide which values a user can submit. If a model invents an option, the view can display it, but your policy rejects choosing it.

## Render What the Model Presented

The tool returns `{ status: "presented", surface_id:, revision: }` to the model. RubyLLM stores that acknowledgment as the tool result message. Read the Surface ID from that message when you render the transcript, and render it with the viewer's scope:

```erb
<%= rails_tool_views_surface(surface, scope: current_scope) %>
```

`references` lists the Surfaces presented during the current request. Use it to render immediately; use the stored tool result after a reload.

## Continue the Chat

Return `agent: true` from the action handler. Then make the agent adapter a callable that finds the chat from the payload, checks its owner, and hands the turn to `Continuation`:

```ruby
RailsToolViews.configuration.agent_adapter = ->(payload, delivery_key:) {
  conversation = Conversation.find_by!(context_ref: payload.fetch("context_ref"))
  surface = RailsToolViews::Surface.find(payload.fetch("surface_id"))
  unless conversation.owned_by?(actor: surface.actor_ref, tenant: surface.tenant_ref)
    raise RailsToolViews::Error.new("NOT_ALLOWED", status: 403)
  end
  RailsToolViews::Adapters::RubyLLM::Continuation.new(
    chat_resolver: ->(context_ref) {
      conversation.chat.with_tools(RailsToolViews::Adapters::RubyLLM::PresentUI.new(
        keys: [:choice_card], scope: conversation.owner_scope, context: context_ref))
    },
    delivery: ->(key, &deliver) {
      DeliveryReceipt.transaction do
        next if DeliveryReceipt.exists?(delivery_key: key)
        deliver.call
        DeliveryReceipt.create!(delivery_key: key)
      end
    }
  ).call(payload, delivery_key: delivery_key)
}
```

`Conversation` and `DeliveryReceipt` are host models. Resolve the chat's owner from your own records, never from the payload. The resolver attaches `PresentUI` again, scoped to that owner, so the model can present another view while it answers. `Continuation` sends the payload as a new user turn with `Chat#ask`. A chat with unanswered tool calls raises `RubyLLM::PendingToolCallsError`, and the delivery fails until that round finishes.

The delivery callable owns deduplication. When the transcript and the receipt commit together, a retried delivery cannot add a second reply, although the model may be asked again after a crash. With `auto_deliver`, the follow-up runs inside the action request; for a live model, set `auto_deliver = false` and deliver from a job as [Agent Continuation]({% link _advanced/continuation.md %}) shows.

## See It Run

The [demo]({% link _getting_started/demo.md %}#talk-to-an-agent) runs this integration with RubyLLM's real chat loop. Only the network is scripted. See `test/dummy/lib/demo_llm.rb` for the tool, transcript and continuation wiring, and `test/adapter/demo_agent_test.rb` for the checks.

## Next Steps

* [Agent Continuation]({% link _advanced/continuation.md %}) covers delivery, retries and recovery.
* [Registering Components]({% link _core_features/components.md %}) explains discovery policies.
