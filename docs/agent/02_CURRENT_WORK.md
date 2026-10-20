# Current work

## Owner-authorized 0.4 local development

Base: 3ed5e39, clean main; published version remains 0.3.0. Follow ROADMAP.md.

- [x] WORK-20261020-01: fence stale delivery acknowledgments using the existing attempt counter; enforce delivery outside transactions; exercise host jobs, crash and durable deduplication. Keep uncertainty protection.
- [x] WORK-20261020-02: metadata-only diagnostics and existing UI keyboard/focus/loading/mobile/retry coverage.
- [ ] Pending owner decisions: replay event/metadata and additive transient notice vs unchanged feedback. Preserve current behavior until replies arrive.
- [ ] WORK-20261020-03: candidate metadata/docs, real old-data upgrade and installed-host verification, supported matrix, adapter, PostgreSQL concurrency, browser and local acceptance.

No built-in queue/dashboard, dependency or schema expansion is planned. No 0.4 push/publication authorization. Existing provider/MySQL/adoption/independent security/formal gaps remain open.
