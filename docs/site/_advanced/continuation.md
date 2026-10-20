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

## Run a Host Job After Commit

```ruby
class ContinueViewJob < ApplicationJob
  def perform(interaction_id, membership_id:, retry_failed: false)
    membership = Membership.active.find(membership_id)
    scope = RailsToolViews::Scope.new(
      actor: membership.actor_ref, tenant: membership.tenant_ref)
    RailsToolViews.deliver(interaction_id, scope: scope,
      retry_failed: retry_failed)
  end
end
```

`Membership` is a host model in this example. Re-resolve current identity and permissions from trusted host data. Deliver outside database transactions; an open transaction raises `DELIVERY_IN_TRANSACTION` before calling the adapter. Dispatch can join a host transaction, but enqueue the job only after commit.

A process can stop between commit and enqueue. Recover committed `pending` interactions from a host-owned scheduled scan or durable outbox. Resolve and authorize each owner again. Do not automatically retry `failed` work without an explicit host decision. A fresh `delivering` lease skips another call; an expired lease can be reclaimed.

The maintained demo includes `DemoV1::ContinuationJob`. Its tests boot another process, stop it after the host effect commits and restart delivery with the same key. The host receipt prevents a second reply. The gem provides no job scheduler.

## Handle Uncertain Remote Outcomes

An unfinished claim has a `delivery_lease`. After expiry it can be reclaimed. The process may fail after a remote service accepted a request but before local completion, so the receiver must deduplicate by delivery key. Exactly-once remote delivery is not guaranteed. Each claim increments the existing attempt counter. Only that attempt can acknowledge success or failure; a late callback cannot overwrite a newer claim or emit its terminal event. This fence protects Engine status, not remote effects.

`RailsToolViews::Adapters::RubyLLM::Continuation` accepts `chat_resolver:` and `delivery:` callables. The resolver returns an authorized chat; the delivery callable performs durable deduplication around the provided block. The adapter starts a supported user turn with `Chat#ask`. The host owns its conversation and pending-tool lifecycle.

A lease takeover now records durable uncertainty for [lifecycle protection]({% link _advanced/lifecycle.md %}#protect-uncertain-delivery). Do not close or clean up a view merely because a lease expired or a status became terminal.

## Next Steps

* [Production Boundaries]({% link _advanced/production.md %}) covers outbox and retention choices.
* [Configuration]({% link _getting_started/configuration.md %}) lists delivery settings.

* [Operational Diagnostics]({% link _advanced/diagnostics.md %}) explains metadata-only outcome events.
