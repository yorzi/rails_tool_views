# ADR 009 — Bounded delivery recovery

Date: 2026-10-20. Status: accepted implementation design for owner-authorized 0.4 recovery. FR-05/06/07, SEC-04/06/11/18. External Specs unchanged.

Use the existing monotonic interaction attempts counter as a fencing token. Claims keep Surface-first locking. The adapter runs outside transactions. A single conditional update acknowledges only the still-delivering matching attempt, for both success and failure. Only the accepted acknowledgment emits the existing terminal notification. Observer failures do not become adapter failures. No new column, token service, queue or callback lock is needed.

Refuse delivery inside an outer transaction before making any claim or adapter call. Dispatch remains transactional with host writes. Host jobs must resolve current trusted identity and authorization, enqueue after commit and recover the commit/enqueue gap through their own durable outbox or pending scan. The dummy host owns the sample Active Job; process-death tests preserve a domain effect/receipt and recover with the stable delivery key.

Fencing does not stop an old callback or make a remote effect atomic. Retain the 0.3 uncertainty flag and lifecycle quarantine after takeover. Do not infer quiescence or clear uncertainty from age or terminal status. No force-cleanup or attested-recovery API is introduced without a concrete safe host contract.

Notification replay metadata and transient feedback are pending owner compatibility decisions, requested under the roadmap. No catalog or message behavior change is inferred by this recovery work.
