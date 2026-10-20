---
layout: default
title: "What Is New in 0.4"
nav_order: 4
description: "Recover committed follow-up work without letting stale workers overwrite newer delivery attempts."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Recover pending and failed follow-up through a host job.
* Protect newer delivery attempts from stale acknowledgments.
* Distinguish receipt replay in existing notifications.
* Display a temporary notice without changing saved UI state.

## Recover Committed Work

```ruby
RailsToolViews.deliver(interaction_id, scope: scope, retry_failed: true)
```

Call delivery after the host transaction commits. An outer transaction now raises `DELIVERY_IN_TRANSACTION` before any adapter call. A stale worker can no longer mark a newer attempt completed or failed. Stable delivery keys still require durable host deduplication. See [Agent Continuation]({% link _advanced/continuation.md %}).

An expired lease does not prove that a previous callback stopped. The existing uncertainty flag continues to protect lifecycle cleanup. This release adds no queue, migration or runtime dependency. See [Upgrading]({% link _reference/upgrading.md %}) before changing workers.

## Inspect Failures Without Payloads

[Operational Diagnostics]({% link _advanced/diagnostics.md %}) lists the existing notification catalog and recovery metadata. Handled-error log lines omit raw exception messages and stack text. The original exception remains in the host's `Rails.error` reporting pipeline, where the host configures privacy controls.

## Distinguish Replay and Display Temporary Feedback

`action.executed` keeps its event name and adds the boolean `replayed`. Existing subscribers continue receiving successful dispatches. Count new executions with `replayed: false`. No private values are added to telemetry.

Return `Transition.new(state: { selected: "compare" }, notice: "Selection saved.")` to acknowledge an action without persisting the message in Surface state. Existing `state["message"]` keeps its behavior. Read [Status and Temporary Feedback]({% link _core_features/feedback.md %}) for all transports and durable receipt semantics.
