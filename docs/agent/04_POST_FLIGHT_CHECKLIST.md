# Post-flight record — WORK-20261013-01

2026-10-13. Result: AUDIT_HARDENING_LOCAL_COMPLETE / COMMITTED_LOCAL / UNPUSHED / UNPUBLISHED / HUMAN_REVIEW_PENDING.

- [x] Six defects reproduced, fixed and covered: open nested schemas, host-wide log redaction, swallowed renderer and adapter failures, unwordable host codes with demo leakage in core, zero-argument form posts, and an order-dependent test that made earlier green runs depend on seed.
- [x] Each fix has tests that fail when that fix alone is reverted to 3635c54.
- [x] Adoption work added on the owner's second request: three form helpers, tolerated Rails submit names, ViewComponent context, two configuration options, redirect back without Turbo, rollback mapped to CONFLICT. Each has a test that fails when the change is broken.
- [x] PostgreSQL 17.11 on a task-owned loopback instance: full suite, five seeds, eager load, demo over HTTP. Instance stopped and its data directory removed.
- [x] No migration, new table or runtime dependency; `pg` is a development gemfile only. Authorization, transaction, replay and transport behavior unchanged; all 60 earlier tests still pass, two with assertions rewritten from the global filter list to observed log output and one CSRF test's setup narrowed to its own controller.
- [x] Privacy re-verified from real output: Engine request parameters, SQL binds and `#inspect` redacted; host parameters and columns named `state`/`result`/`arguments` visible; notifications metadata-only.
- [x] Full suite and eager load on the three local combinations, each also across fixed seeds; optional adapter suite; packaged install on all three. Details: ../evidence/AUDIT_VALIDATION.md.
- [x] Real demo driven over HTTP with cookies and CSRF, and once in a browser for the Stimulus change.
- [x] ADR 003 and 004, README, SECURITY, CHANGELOG, acceptance rows, runbook, release checklist and human docs updated; one ledger section added.
- [x] Task-owned demo server stopped twice; port 3100 has no listener; browser tab closed.
- [x] Commit: one local commit on main with `Work-ID: WORK-20261013-01`, requested by Andy on 2026-10-13 after both summaries. Staged ledger linkage and whitespace were checked first. No remote is configured; nothing was pushed. Both rounds are one commit because they change the same files and only the final tree was verified as a whole.

Alignment: IMPLEMENTATION_BUG repairs plus ADR-recorded technical choices. No baseline edit, formal gate, license, push, publication, provider call or external contact. MySQL, remote CI and a full accessibility audit remain NOT_RUN; PostgreSQL is LOCAL only. Open findings that were not implemented are listed in ../human/01_PROJECT_STATUS.md.
