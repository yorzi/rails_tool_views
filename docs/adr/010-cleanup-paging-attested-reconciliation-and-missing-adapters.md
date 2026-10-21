# ADR 010 — Cleanup paging, attested delivery reconciliation and missing adapters

Date: 2026-10-21. Status: accepted for the owner-authorized 1.0.0.rc1 candidate. FR-04/05/06/07, NFR-05, SEC-04/06/18. Supersedes the deferral in ADR 008 ("recovery/attested resolution is deferred") and ADR 009 ("no attested-recovery API without a concrete safe host contract") by defining that contract. External Specs unchanged; DELTA-007 records the contract supplement.

## Context

The rc1 audit found three lifecycle gaps that a frozen 1.0 contract would otherwise keep forever:

1. `purge_closed` orders candidates by `closed_at, id` and has no cursor. Protected candidates, such as views under a host legal hold, are the oldest rows, so they fill every batch and newer eligible views are never reached.
2. `delivery_uncertain` is permanent. A Surface with that flag can never be closed, abandoned or purged, and the host has no supported way to record what its own deduplication evidence shows.
3. `deliver` without an adapter marks pending or failed work `skipped`, a terminal status. A worker that boots without adapter configuration silently and irreversibly drops committed follow-up.

## Decision

**Cleanup paging.** `purge_closed` accepts `after:` and returns `next_after`. Candidates use keyset order `(closed_at, id)`. `next_after` is an opaque string for the last candidate of a full batch, otherwise nil. The cursor is only AND-ed with the existing scope, cutoff, deadline and purge conditions, so a forged value can skip rows but never widen access; it needs no signature. Every rule of the unpaged call is unchanged, and each sweep starts from nil, so views that become eligible later are found by the next sweep. An invalid cursor raises `INVALID_RETENTION_REQUEST`.

**Attested reconciliation.** `reconcile_delivery(id, scope:, outcome:)` records the host's attested outcome, `:completed` or `:failed`. The host contract is explicit: it has checked its durable deduplication record for the interaction's delivery key, and it knows that no attempt is still running. The Engine enforces what it can observe:

* Authorization uses a new host-level `reconciliation_policy`, default unset, which denies. It receives `operation: :reconcile`. Like `retention_policy`, it is independent of the registry, so an obsolete component's history can still be resolved. A new hook keeps existing retention policies from silently gaining reconciliation authority.
* Ownership is the exact actor and tenant of the Surface, matched byte for byte. Another scope receives 404.
* Locks are taken Surface first, then interaction, like delivery and lifecycle changes.
* A fresh delivering lease raises `DELIVERY_ACTIVE` (409). The Engine never overrides a running claim.
* Only an uncertain interaction or a delivering row whose lease expired is reconcilable. Its status becomes the outcome, `error_code` is `AGENT_UNAVAILABLE` for `:failed` and nil otherwise, `claimed_at` is cleared and `delivery_uncertain` becomes false. `attempts` is unchanged, so the existing compare-and-set fence still rejects any stale callback: it requires `delivering` and its own attempt.
* Repeating the same outcome on an already-resolved interaction returns it unchanged, so host jobs can retry. A different outcome for an interaction with nothing to reconcile raises `RECONCILIATION_CONFLICT` (409).
* An outcome other than `:completed` or `:failed` raises `INVALID_RECONCILIATION`.
* `agent_reconciled` reports `surface_id`, `interaction_id` and `outcome`, metadata only.

A `:failed` outcome makes the follow-up retryable with the same delivery key, or abandonable. Lifecycle rules do not change: uncertainty still blocks close, abandon and purge until it is reconciled.

**Missing adapters.** When `deliver` would claim work and no adapter is given or configured, it raises `AGENT_NOT_CONFIGURED` (503) and leaves the interaction unchanged. Terminal, freshly leased and unretried failed interactions keep returning without a claim. Dispatch without a configured adapter still records `skipped`, so FR-06-AC-03 holds: the deterministic action succeeds with no agent installed.

## Alternatives considered

* Page by offset or by skipping protected rows in SQL. Offsets shift under concurrent cleanup, and policy denials cannot be expressed in SQL.
* Clear uncertainty on age, on terminal status, or with a force flag. Neither proves quiescence or the remote outcome; ADR 008 rejects this.
* Authorize reconciliation through component policies or `retention_policy`. The first strands obsolete components; the second silently extends existing policies.
* Keep the missing-adapter skip, or add a skip API. The skip destroys committed work on a configuration mistake. Hosts that intend to stop follow-up already have `abandon`.

## Consequences

Hosts gain an additive keyword, a result key, one method, one configuration hook, four error codes (`AGENT_NOT_CONFIGURED`, `DELIVERY_ACTIVE`, `RECONCILIATION_CONFLICT`, `INVALID_RECONCILIATION`) and one event; cursor validation reuses `INVALID_RETENTION_REQUEST`, all declared in the public contract. Strict consumers comparing the whole cleanup summary must accept `next_after`. Reconciliation correctness depends on the host's attestation; the Engine cannot verify remote effects or process quiescence beyond lease freshness. A worker without an adapter now fails loudly instead of losing data.

## Human review trigger

Evidence that hosts misreport quiescence, need a third outcome, or need cleanup across scopes in one call.
