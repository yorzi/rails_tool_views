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

## Recover Committed Work

```ruby
RailsToolViews.deliver(interaction_id, scope: scope, retry_failed: true)
```

Call delivery after the host transaction commits. An outer transaction now raises `DELIVERY_IN_TRANSACTION` before any adapter call. A stale worker can no longer mark a newer attempt completed or failed. Stable delivery keys still require durable host deduplication. See [Agent Continuation]({% link _advanced/continuation.md %}).

An expired lease does not prove that a previous callback stopped. The existing uncertainty flag continues to protect lifecycle cleanup. This development version adds no queue, migration or runtime dependency. See [Upgrading]({% link _reference/upgrading.md %}) before changing workers.
