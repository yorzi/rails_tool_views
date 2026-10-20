# ADR 009 — Bounded delivery recovery

Date: 2026-10-20. Status: accepted implementation design for owner-authorized 0.4 recovery. FR-05/06/07, SEC-04/06/11/18. External Specs unchanged.

Use the existing monotonic interaction attempts counter as a fencing token. Claims keep Surface-first locking. The adapter runs outside transactions. A single conditional update acknowledges only the still-delivering matching attempt, for both success and failure. Only the accepted acknowledgment emits the existing terminal notification. Observer failures do not become adapter failures. No new column, token service, queue or callback lock is needed.

Refuse delivery inside an outer transaction before making any claim or adapter call. Dispatch remains transactional with host writes. Host jobs must resolve current trusted identity and authorization, enqueue after commit and recover the commit/enqueue gap through their own durable outbox or pending scan. The dummy host owns the sample Active Job; process-death tests preserve a domain effect/receipt and recover with the stable delivery key.

Fencing does not stop an old callback or make a remote effect atomic. Retain the 0.3 uncertainty flag and lifecycle quarantine after takeover. Do not infer quiescence or clear uncertainty from age or terminal status. No force-cleanup or attested-recovery API is introduced without a concrete safe host contract.

Owner explicitly confirms both compatibility choices after the recovery unit; DELTA-006 records this before implementation. Keep action.executed and add replayed boolean. Add bounded plain-text Transition.notice without changing persistent state.message.

## Diagnostics and existing UI verification

The ordinary handled-error line exposes only event/class; the original exception remains in host-controlled Rails.error, with explicit privacy boundaries. Preserve event names, adding only the approved replayed boolean to action.executed. Browser checks exercise real keyboard activation, busy state/disabled submission, validation focus, mobile failure/retry/refresh and unchanged business receipt counts. No new UI state machine or client framework.

## Response notices

Notice is optional plain text at most500bytes, normalized to a plain String even for SafeBuffer input. Validate inside the action transaction so invalid feedback rolls back host and Surface writes. Store it in the action receipt to keep exact retries deterministic, never in Surface state/snapshot or notifications. JSON returns the optional field; Turbo renders it in the existing status region. HTML reuses Rails flash with exact Surface/actor/tenant matching, consumed once by the embedding helper. Restore without a response notice keeps the old persistent message or translated status. No extra session store, notice table or frontend framework.
