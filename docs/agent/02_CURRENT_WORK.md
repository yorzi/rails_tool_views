# Current work

## Owner-authorized 0.4 local development

Base: 3ed5e39, clean main; published version remains 0.3.0. Follow ROADMAP.md.

- [x] WORK-20261020-01: fence stale delivery acknowledgments using the existing attempt counter; enforce delivery outside transactions; exercise host jobs, crash and durable deduplication. Keep uncertainty protection.
- [x] WORK-20261020-02: metadata-only diagnostics and existing UI keyboard/focus/loading/mobile/retry coverage.
- [x] WORK-20261020-03: owner confirms additive replayed metadata and transient notice, keeping event name and persistent message semantics. Implement/test/document DELTA-006.
- [x] WORK-20261020-04: candidate metadata/docs, real old-data upgrade and installed-host verification, supported matrix, adapter, PostgreSQL concurrency, browser and local acceptance.

No built-in queue/dashboard, dependency or schema expansion is planned. No 0.4 push/publication authorization. Existing provider/MySQL/adoption/independent security/formal gaps remain open.

## Local acceptance and next step

0.4 implementation and local acceptance complete. See ../evidence/V0_4_VALIDATION.md. Three combinations129/1129, PG132/1145, adapter7/45, Chrome8/77; actual old-runtime/installed/isolated/audit/docs checks PASS. No remaining implementation decision. Owner review is next; only after separate explicit authorization push/check remote CI and publish. No automatic1.0/provider/MySQL/adjacent work.
