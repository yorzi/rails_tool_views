---
layout: default
title: "Surface Lifecycle"
nav_order: 4
description: "Close completed views or abandon unfinished follow-up while preserving authorized reads and action replay."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Close or abandon a view from trusted host code.
* Preserve replay receipts and choose a retention deadline.
* Protect unfinished and uncertain delivery.

## Close a Finished View

```ruby
closed = RailsToolViews.close(surface.id, scope: scope,
  retain_until: 30.days.from_now)
closed.lifecycle_status
# => "closed"
```

The host decides when work is finished. The component policy must allow `access.operation == :close`, as well as the normal read check. A different actor or tenant cannot close the view. There is no built-in HTTP endpoint or AI tool for lifecycle changes; authorize any host route you add and keep its CSRF protection.

Closure advances the revision once. `restore` still checks ownership, component compatibility and current read policy, then returns the saved data. A correlated presentation still returns the same closed view. Engine rendering shows a closed notice without action forms. Exact committed requests replay their old receipts under current action authorization; new requests return `SURFACE_CLOSED` with HTTP 410. Closing does not change a customer, ticket or other host business record.

The first successful termination wins. Repeating close does not reopen the view, change the deadline or advance revision again. An invalid deadline type is rejected. For an active view, a deadline must still be in the future when the lock is acquired.

## Keep Data Indefinitely

```ruby
RailsToolViews.close(surface.id, scope: scope)
```

Without `retain_until`, data stays indefinitely. A deadline defines the earliest time payload cleanup may become eligible; it does not schedule deletion, expire a view or disable replay by itself. Nothing runs automatically on installation. Choose a window long enough for your jobs, browser retries and operational recovery. The gem does not guess a duration.

Snapshots add a `lifecycle` object with status, closed_at, retain_until and purged_at. Times are ISO 8601 strings or null. Active views retain their existing action behavior. See [Upgrading]({% link _reference/upgrading.md %}) before updating strict JSON consumers.

## Abandon Unfinished Follow-up

```ruby
RailsToolViews.abandon(surface.id, scope: scope,
  retain_until: 30.days.from_now)
```

Normal closure refuses pending or failed continuation work with `LIFECYCLE_BUSY`. If the host intends to stop it, authorize `access.operation == :abandon`. Pending and failed interactions become `abandoned`; later delivery calls do not invoke the adapter. Already committed business actions and their replay receipts stay intact. This is not a remote cancellation API.

## Protect Uncertain Delivery

A delivering interaction blocks close and abandon, even after its lease expires. Lease expiry allows a retry; it does not prove that the old process or network call ended.

A takeover sets the durable `delivery_uncertain` flag. It remains set if a stale callback later writes a terminal status. Such a Surface stays protected from lifecycle cleanup. The migration also marks old delivering or multiple-attempt rows conservatively, since their history cannot prove which attempts overlapped. An ordinary explicit retry after a known failure does not introduce this flag in the new runtime.

There is no force option to clear uncertainty in this release. Stop automatic retention for these views and investigate the host delivery process and durable deduplication records. Do not rewrite the flag merely because enough time passed. The [continuation guide]({% link _advanced/continuation.md %}) explains the host's remote deduplication responsibility.
