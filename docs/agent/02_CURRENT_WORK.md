# Current work

## Owner-authorized 0.4 local development

Base: 3ed5e39, clean main; published version remains 0.3.0. Follow ROADMAP.md.

- [x] WORK-20261020-01: fence stale delivery acknowledgments using the existing attempt counter; enforce delivery outside transactions; exercise host jobs, crash and durable deduplication. Keep uncertainty protection.
- [x] WORK-20261020-02: metadata-only diagnostics and existing UI keyboard/focus/loading/mobile/retry coverage.
- [x] WORK-20261020-03: owner confirms additive replayed metadata and transient notice, keeping event name and persistent message semantics. Implement/test/document DELTA-006.
- [x] WORK-20261020-04: candidate metadata/docs, real old-data upgrade and installed-host verification, supported matrix, adapter, PostgreSQL concurrency, browser and local acceptance.

No built-in queue/dashboard, dependency or schema expansion is planned. 0.4 push/publication is now explicitly authorized in the latest owner request. Existing provider/MySQL/adoption/independent security/formal gaps remain open.

## Local acceptance and next step

0.4 implementation and local acceptance complete. See ../evidence/V0_4_VALIDATION.md. Three combinations129/1129, PG132/1145, adapter7/45, Chrome8/77; actual old-runtime/installed/isolated/audit/docs checks PASS. No remaining implementation decision. Owner now explicitly authorizes remote CI, release acceptance, documentation and publication. No automatic1.0/provider/MySQL/adjacent work.

## Authorized 0.4 publication

- [ ] WORK-20261020-05: release metadata/package/docs checks, commit/push, exact remote CI/Docs, annotated tag and existing OIDC publication, registry/assets/hosted acceptance.
- [ ] WORK-20261020-06: observed delivery evidence, living status/roadmap/acceptance, delivery-record commit/push and its own remote checks.

No future release or 1.0 feature work is authorized by this unit.
