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
* Protect unfinished and uncertain delivery, and reconcile it.
* Preview and apply scoped payload cleanup.
* Page through every batch past protected views.

## Close a Finished View

```ruby
# docs-example: close-surface
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

Use `surface.closed?` or `surface.purged?` to inspect a persisted record. `surface.lifecycle_status` returns `active`, `closed`, `abandoned` or `purged`. Snapshots add a `lifecycle` object with status, closed_at, retain_until and purged_at. Times are ISO 8601 strings or null. Active views retain their existing action behavior. See [Upgrading]({% link _reference/upgrading.md %}) before updating strict JSON consumers.

## Abandon Unfinished Follow-up

```ruby
RailsToolViews.abandon(surface.id, scope: scope,
  retain_until: 30.days.from_now)
```

Normal closure refuses pending or failed continuation work with `LIFECYCLE_BUSY`. If the host intends to stop it, authorize `access.operation == :abandon`. Pending and failed interactions become `abandoned`; later delivery calls do not invoke the adapter. Already committed business actions and their replay receipts stay intact. This is not a remote cancellation API.

## Protect Uncertain Delivery

A delivering interaction blocks close and abandon, even after its lease expires. Lease expiry allows a retry; it does not prove that the old process or network call ended.

A takeover sets the durable `delivery_uncertain` flag. It remains set if a stale callback later writes a terminal status. Such a Surface stays protected from lifecycle cleanup. The migration also marks old delivering or multiple-attempt rows conservatively, since their history cannot prove which attempts overlapped. An ordinary explicit retry after a known failure does not introduce this flag in the new runtime.

Nothing clears uncertainty because time passed or a status became terminal. Only your attested reconciliation does.

## Reconcile an Uncertain Delivery

```ruby
RailsToolViews.configure do |config|
  config.reconciliation_policy = ->(access) {
    access.operation == :reconcile && Operator.exists?(ref: access.actor)
  }
end

receipt = DeliveryReceipt.find_by(key: interaction.delivery_key)
RailsToolViews.reconcile_delivery(interaction.id, scope: scope,
  outcome: receipt ? :completed : :failed)
```

`Operator` and `DeliveryReceipt` are host models in this example. Before you reconcile, check your durable deduplication record for the interaction's `delivery_key`, and make sure no worker still runs an attempt. Pass `:completed` when the record shows the follow-up happened and `:failed` when it shows it did not. The Engine records your attestation; it cannot see remote effects.

The default `reconciliation_policy` is unset and rejects the call with `NOT_ALLOWED`. It receives `:reconcile`, the Surface and the interaction's action name, and it must return exactly `true`. It is independent of `retention_policy` and of the registry, so you can resolve an obsolete component's history. The view must belong to the exact actor and tenant; another scope receives 404.

A fresh delivering lease raises `DELIVERY_ACTIVE` and changes nothing. An uncertain interaction, or a delivering one whose lease expired, takes the outcome as its status, and its uncertainty flag clears. `:failed` stores `AGENT_UNAVAILABLE`, so you can retry it with the same delivery key or abandon the view. A callback that outlived its lease still cannot overwrite the result, because its attempt no longer matches. Repeating the same outcome returns the interaction unchanged. A different outcome for an interaction with nothing to resolve raises `RECONCILIATION_CONFLICT`. `agent_reconciled` reports the outcome without payloads. After reconciliation, close, abandon and cleanup follow the normal rules.

## Preview Eligible Payloads

The example uses the Getting Started fixture identity; replace it with your host authorization. Enable a host policy first. It receives `:purge` and the scoped Surface. Return exactly `true` to authorize cleanup. Keep this policy free of writes, including during preview. It owns retention authority independently of the component registry, so you can clean an obsolete component without registering its renderer again.

```ruby
# docs-example: retention-preview
RailsToolViews.configure do |config|
  config.retention_policy = ->(access) {
    access.operation == :purge &&
      access.actor == "alice" && access.tenant == "demo"
  }
end

summary = RailsToolViews.purge_closed(scope: scope,
  closed_before: 7.days.ago, batch_size: 100)
# => { examined: 1, eligible: 1, purged: 0, protected: 0, dry_run: true,
#      next_after: nil }
```

The default policy is unset and rejects the call with `NOT_ALLOWED`. Pass a real `Scope`, an explicit past cutoff and a batch size from 1 to 1000. Candidates must belong to that exact actor and tenant, have closed strictly before the cutoff, and have reached their non-null retention deadline. Active views and indefinite retention are excluded. Pending, failed, delivering, unknown or historically uncertain interactions remain protected even if a host edited lifecycle columns directly.

## Apply a Bounded Batch

```ruby
# docs-example: retention-apply
summary = RailsToolViews.purge_closed(scope: scope,
  closed_before: 7.days.ago, batch_size: 100, dry_run: false)
```

Each Surface is locked and eligibility is checked again. The batch bounds the number of Surfaces examined, not their child receipt count. Cleanup removes terminal interactions and action receipts, clears props, state and the Surface context reference, and sets `purged_at` in the same transaction. A database error rolls back that Surface. Earlier completed Surfaces in the batch stay committed; rerun the same request after resolving the error. Policy-denied or unsafe candidates count as protected and stay untouched.

Preview makes no Engine writes and reserves nothing. Apply may see different eligibility after concurrent work. Coordinate host policy changes and maintenance jobs accordingly. There is no automatic scheduler or tenant discovery. Choose a conservative batch size for large graphs and iterate known scopes in your own job.

## Sweep Every Batch

```ruby
# docs-example: retention-sweep
after = nil
loop do
  summary = RailsToolViews.purge_closed(scope: scope, closed_before: 7.days.ago,
    batch_size: 100, dry_run: false, after: after)
  after = summary[:next_after] or break
end
```

Protected views sort first when they are the oldest, such as views your policy keeps on hold, so a single batch can fill with them. Each summary therefore includes `next_after`. It is an opaque cursor for the last view the batch examined, or `nil` when the batch came back short. Pass it back as `after:` to continue past those views; they stay untouched. A preview pages the same way.

Start each sweep with `after: nil` and keep the same scope and cutoff while it runs. Views that reach their deadline later are found by the next sweep. The cursor only narrows the scoped query, so it cannot reach another actor or tenant. Store it only between calls of one sweep; an invalid value raises `INVALID_RETENTION_REQUEST`.

## Understand the Tombstone

Cleanup keeps the Surface identity, owner, component digest and lifecycle timestamps, plus Presentation correlation identifiers and request digests. These are durable replay guards, not a complete data-erasure mechanism. Host backups and retained opaque identifiers require their own policy. Cleanup does not shrink database files or remove host business records, logs or remote provider data.

After cleanup, authorized-owner `restore`, dispatch and matching correlated presentation return `SURFACE_PURGED` with HTTP 410. Another scope still receives 404. A deleted interaction returns 404 on delivery. A repeated cleanup skips the already-purged view. Keep correlation guards; deleting them could allow an old tool request to recreate the view and execute business work again.
