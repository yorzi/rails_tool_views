---
layout: default
title: "Operational Diagnostics"
nav_order: 5
description: "Inspect action and delivery outcomes through metadata without copying component or provider payloads."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Subscribe to Engine notifications without collecting private payloads.
* Distinguish committed actions from continuation outcomes.
* Investigate failed and uncertain delivery safely.

## Subscribe to an Outcome

```ruby
ActiveSupport::Notifications.subscribe("agent_failed.rails_tool_views") do |event|
  metadata = event.payload.slice(:surface_id, :interaction_id, :error_class)
  Rails.logger.warn(metadata.to_json)
end
```

Identifiers are opaque operational references. Protect access and retention for logs that contain them. Never add props, state, arguments, context references, exception messages or provider responses to notification payloads. A notification is an observation after work, not a durable outbox or authorization decision. Subscribers run synchronously; keep them small and prevent subscriber failures from escaping.

## Read the Event Catalog

All names below have the suffix `.rails_tool_views`. An action commits independently from its follow-up. `agent_failed` means the current delivery attempt failed after that commit. A stale attempt emits no terminal event. A process exit may emit none, so use durable records for recovery.

| Event | Metadata fields | Meaning |
| --- | --- | --- |
| `presentation.accepted` | `surface_id`, `component`, `revision` | A new presentation commits. Correlated replay emits no new acceptance. |
| `presentation.rejected` | `code` | Presentation is rejected. |
| `surface.rendered` | `surface_id`, `component`, `revision` | An authorized renderer succeeds. |
| `surface.render_failed` | `surface_id`, `component`, `error_class` | A host renderer raises a handled exception. |
| `action.executed` | `surface_id`, `revision`, `action`, `replayed` | Dispatch succeeds. `false` means new execution; `true` means an exact authorized receipt replay. |
| `action.conflict` | `code` | The revision or transaction conflicts. |
| `action.rejected` | `code` | Dispatch is rejected for another reason. |
| `agent_returned` | `surface_id`, `interaction_id` | The current attempt acknowledges success. |
| `agent_failed` | `surface_id`, `interaction_id`, `error_class` | The current attempt acknowledges a handled adapter failure. |
| `adapter.tool_called` | `surface_id`, `revision` | The optional RubyLLM presentation tool returns a view. |

Fresh leases, skipped work, terminal delivery replay and lifecycle maintenance add no events to this catalog. It is not a complete audit trail. Measure external effects from the host's durable business receipts.

## Investigate Delivery

Use the interaction ID to inspect only `status`, `attempts`, `claimed_at`, `error_code` and `delivery_uncertain` in an authorized host operation. A pending row needs delivery; a failed row needs an explicit retry decision. A fresh delivering lease is active. An expired lease allows takeover with the same delivery key, while uncertainty continues to block lifecycle cleanup.

The Engine's handled-error log line includes the event and exception class. It omits raw messages and stack text. `Rails.error` still receives the original exception for host debugging. Configure filtering, access and retention in that reporting pipeline; the gem cannot sanitize arbitrary exception objects or SDK logs. Do not return those reports to a browser.

## Next Steps

* [Agent Continuation]({% link _advanced/continuation.md %}) covers host jobs and crash recovery.
* [Production Boundaries]({% link _advanced/production.md %}) covers privacy and ownership.
* [Surface Lifecycle]({% link _advanced/lifecycle.md %}) explains uncertainty protection.
