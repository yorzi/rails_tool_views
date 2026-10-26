# Current work

## Owner-authorized 1.0.0 release (2026-10-26)

- [x] WORK-20261026-01: owner exception (DELTA-008), 1.0.0 metadata (`released: true`), release history, What's New and Upgrading for stable, final local checks, push and exact main CI/Docs.
- [x] WORK-20261026-02: annotated `v1.0.0`, OIDC publication, registry/checksum/Release and stable 1.0, `/next/`, `/v0/` HTTPS acceptance, delivery evidence.

The owner chose 1.0.0 over rc1 and waived conditions 5 and 6's independent review and formal disposition. Published 1.0.0 at 5ded407; see ../evidence/RELEASE_1_0_0.md. No next iteration, provider call or future release is automatically authorized.

## Owner-requested audit and 1.0 RC preparation (2026-10-21)

- [x] WORK-20261021-01: pre-flight record; focus moves only after a Turbo replacement (browser regression first).
- [x] WORK-20261021-02: malformed registrations fail with stable codes.
- [x] WORK-20261021-03: identifier encoding, plain-String normalization, digest envelope, race-path rejection event, frozen discovery Access.
- [x] WORK-20261021-04: Engine page stylesheet carries the host CSP nonce.
- [x] WORK-20261021-05: prerelease-safe GitHub Release and verified stable-docs behavior for an rc tag.
- [x] WORK-20261021-06: declared public contract, experimental adapter, MySQL exclusion, 0.1-0.4 upgrade coverage.
- [x] WORK-20261021-07: `1.0.0.rc1` candidate metadata (`released: false`), What's New in 1.0, Upgrading from 0.4, full local matrix and [readiness record](../evidence/RC1_READINESS.md).

## rc1 lifecycle decisions (owner-approved, 2026-10-21)

- [x] WORK-20261021-08: ADR 010, DELTA-007 and pre-flight record before implementation.
- [x] WORK-20261021-09: D3, delivery without an adapter raises `AGENT_NOT_CONFIGURED`.
- [x] WORK-20261021-10: D1, keyset paging for `purge_closed`.
- [x] WORK-20261021-11: D2, attested `reconcile_delivery`.
- [x] WORK-20261021-12: installed-host and upgrade evidence, full matrix, readiness update.

D4/D5 were decided on 2026-10-26; see the 1.0.0 release section above.

## Owner-authorized 0.4 delivery

- [x] WORK-20261020-01: attempt-fenced recovery, transaction guard and host-job/process-death checks.
- [x] WORK-20261020-02: metadata-only diagnostics and browser keyboard/focus/loading/mobile/retry coverage.
- [x] WORK-20261020-03: owner-approved DELTA-006, compatible replayed metadata and optional transient notice.
- [x] WORK-20261020-04: full local compatibility/PG/browser/upgrade/installed/isolated/audit/docs acceptance.
- [x] WORK-20261020-05: release metadata, candidate push, exact main/tag CI, annotated v0.4.0 and OIDC publication, registry/assets/hosted acceptance.
- [x] WORK-20261020-06: observed delivery evidence and living docs complete. The record commit is pushed and its own CI/Docs checked as the final handoff gate; results are reported in the final response.

Published0.4.0 at e93f8df; see ../evidence/RELEASE_0_4_0.md and V0_4_VALIDATION.md. Existing provider/MySQL/adoption/independent review/formal gaps remain open. ROADMAP.md retains the1.0 conditions; no next feature iteration, provider call or future release is automatically authorized. No new schema/dependency/queue/dashboard.
