---
layout: default
title: "Upgrading"
nav_order: 2
description: "Upgrade from 0.3 while preserving saved state and using fenced delivery acknowledgments."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Restart delivery workers with the new acknowledgment behavior.
* Move adapter delivery outside host transactions.
* Preserve existing data and lifecycle protections.

## Replace Old Workers

Stop and drain old delivery workers before restarting with {{ site.version }}. An old worker does not enforce attempt fencing and can overwrite a newer claim. An expired lease alone does not prove that a worker stopped.

There is no new database migration or runtime dependency. Existing Surfaces, action receipts, component digests and delivery keys remain unchanged. Older hosts first follow the [0.3 upgrade guide](https://github.com/yorzi/rails_tool_views/blob/v0.3.0/docs/site/_reference/upgrading.md).

## Deliver After Commit

Move `RailsToolViews.deliver` out of any surrounding database transaction. It now raises `DELIVERY_IN_TRANSACTION` before calling the adapter if a transaction is open. Dispatch may still participate in the host transaction. Schedule the host job after commit, and recover committed pending rows if enqueueing fails.

A callback acknowledges only its own attempt. Stale success or failure cannot overwrite a newer claim or emit its terminal notification. The existing `delivery_uncertain` flag remains conservative after takeover. Never clear it based on elapsed time; host reconciliation and quiescence remain required before any manual data repair.

## Verify Recovery

Replay a saved action with the original arguments and key. Exercise pending delivery, explicit failed retry, a process exit after the host effect and an expired lease. Confirm that host deduplication produces one business effect with the same delivery key. Recheck authorization and cross-tenant rejection. See [Agent Continuation]({% link _advanced/continuation.md %}).

## Review Error Reporting

Handled-error log lines now contain the event and exception class, without raw messages or stack text. If an operator parsed the old line, use the notification metadata and the host-controlled `Rails.error` report instead. That report still receives the original exception; review privacy controls in its subscribers.

## Read Replay Metadata and Optional Notices

`action.executed.rails_tool_views` keeps its name and adds `replayed: false` for a new action and `true` for exact receipt replay. Update strict payload consumers to accept this boolean. Count new execution only when it is false; do not treat notification delivery as a business audit log.

`Transition` adds optional `notice:`. Existing `state["message"]` retains its persistence and meaning. A notice is bounded plain text, displayed for the action response and absent after refresh; the durable receipt retains it for exact replay. JSON responses add `notice` only when supplied. Standard HTML uses scoped Rails flash and the `rails_tool_views_surface` helper. See [Status and Temporary Feedback]({% link _core_features/feedback.md %}).
