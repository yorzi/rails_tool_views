---
layout: default
title: "Agent Continuation"
nav_order: 2
description: "Continue an agent after a committed action and retry failures explicitly."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Request continuation after an action commits.
* Deduplicate delivery and retry failed attempts.

## Request a Follow-Up

Return a `Transition` with `agent: true` from the action handler. This persists an `AgentInteraction` along with the action receipt. A configured adapter runs after commit; without an adapter the interaction is marked skipped. Direct Ruby dispatch callers invoke delivery explicitly, while the mounted controller can deliver automatically.

The adapter receives a structured payload and `delivery_key:`. Authorize the referenced conversation in the host and deduplicate that delivery key durably. Never infer an assistant or tool transcript message from UI text.

## Deliver Explicitly

Call `RailsToolViews.deliver(interaction_id, scope: scope)` for the saved interaction. To retry a failed delivery, pass `retry_failed: true`. A failure preserves the committed Surface and stores `AGENT_UNAVAILABLE`. A completed or skipped interaction is not delivered again.

For slow work, set `auto_deliver = false` and have the host enqueue delivery. The gem does not provide a job queue or poll a provider. Re-resolve authorized scope in the job; do not serialize a browser-supplied identity as authority.

## Handle Uncertain Remote Outcomes

An unfinished claim has a `delivery_lease`. After expiry it can be reclaimed. The process may fail after a remote service accepted a request but before local completion, so the receiver must deduplicate by delivery key. Exactly-once remote delivery is not guaranteed.

`RailsToolViews::Adapters::RubyLLM::Continuation` accepts `chat_resolver:` and `delivery:` callables. The resolver returns an authorized chat; the delivery callable performs durable deduplication around the provided block. The adapter starts a supported user turn with `Chat#ask`. The host owns its conversation and pending-tool lifecycle.

A lease takeover now records durable uncertainty for [lifecycle protection]({% link _advanced/lifecycle.md %}#protect-uncertain-delivery). Do not close or clean up a view merely because a lease expired or a status became terminal.

## Next Steps

* [Production Boundaries]({% link _advanced/production.md %}) covers outbox and retention choices.
* [Configuration]({% link _getting_started/configuration.md %}) lists delivery settings.
