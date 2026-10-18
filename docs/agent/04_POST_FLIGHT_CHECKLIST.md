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

## WORK-20261016-01 — rename verification

- [x] Owner-authorized RailsToolViews identity implemented with old constant/requires/helpers/mount compatibility and stable persisted identifiers.
- [x] 83 tests / 665 assertions and eager load on three local Ruby/Rails combinations; six optional-adapter tests; built-gem fresh-host install; actual old-code/new-code database replay PASS. See RENAME_VALIDATION.
- [x] No migration, dependency coupling, provider call or authentication/policy change. Original Specs snapshot unchanged (59 exact matches).
- [x] README upgrade steps, ADR 005, Spec supplement/DELTA-003, acceptance, status, operations and ledger updated. Runtime flow is unchanged; no diagram rewrite needed.
- [x] No task-owned long-lived processes started; temporary package and upgrade probes cleaned up automatically.
- [x] Ledger-linked implementation commit 7e73e4e pushed to owner-approved private `yorzi/rails_tool_views`; remote SHA and PRIVATE visibility verified. No gem release or formal gate approval claimed. Remote CI was queued when checked.

## WORK-20261016-03 — documentation site

Local draft complete. Four collections and 14 pages plus homepage; generated Ruby API, Markdown and llms output. Style check: zero errors/warnings. Build, tutorial core/adapter examples, 83-test regression with 665 assertions, eager load and generated local link checks pass. Browser search, guide navigation, API entry, narrow layout and light/dark mode checked. No deployment, data migration or runtime behavior change. Source comments/CI doc checks added. Existing internal records and Specs excluded. Temporary Jekyll PID 53838 on 127.0.0.1:4000 stopped; browser tab closed. Exact evidence and limits: evidence/DOCS_VALIDATION.md.

Submission follow-up: owner explicitly requested commit/push and local folder rename. Keep Pages disabled and repository private. Prior remote CI passed. Source-only PR paths and missing-build detection tightened before this ledger-linked submission.

## WORK-20261016-04 — demo showcase

README shortened to adoption/demo/docs entry points. Shared responsive workbench shell, page-specific guidance, role-aware navigation, context panel, ticket inbox/detail and empty states added to the dummy host. Search query retained on ticket selection. No core API, schema, migration, policy or fixture changes. Regression: 83 tests / 665 assertions and eager load pass. Docs: 15 guides, zero lint warnings/errors, build and 1,075 local links pass. Browser checks cover saved selection, validation recovery, local reply queue, version acceptance/export availability and tenant switch; physical mobile/full accessibility audit not run. See evidence/DEMO_SHOWCASE_VALIDATION.md. Human changelog and acceptance updated; architecture/runtime diagrams unchanged because authority and transitions are unchanged. Loopback demo PID 59386 on port 3197 stopped; temporary browser tab closed. Existing app on 3100 untouched. Implementation-aligned presentation change, no Spec delta. Submission follows the owner's existing commit/push authorization; repository remains private, publication disabled.

## WORK-20261017-02 — review and audit hardening

Base `a1a9b26`. Owner asked in this session for a full review and audit and for real problems to be fixed.

- [x] Defect 1 reproduced from the migration: the presentation's five-column unique index on unbounded `varchar(255)` needs 5100 bytes under utf8mb4 and would not create on MySQL/InnoDB. Identifier columns now carry `limit: 150`; the widest index needs 3000 bytes.
- [x] Defect 2 fixed: identity lookups now confirm a byte-exact match, so a non-binary collation cannot resolve another actor's or tenant's Surface, another correlation's presentation, another action receipt or another idempotency key.
- [x] `Data.identifier` caps stored, indexed identifiers at 150 bytes; `Data.reference` keeps 255 for descriptions and versions.
- [x] Every fix has a test that fails when that fix alone is reverted: three collation tests, the adapter receipt guard and the 5100-byte index-width assertion. The `registry_test` cap assertions fail if the bound is widened.
- [x] Full suite 88 tests / 702 assertions and eager load pass on SQLite and on a fresh PostgreSQL 17.11 schema; adapter suite 7 tests / 45 assertions; packaged install, docs examples, docs build, 1,075 local links and 15-guide style check all pass.
- [x] No new table, column or dependency. No data migration; existing host columns stay and the bound is enforced in code. Behavior change recorded in the upgrade guide: identifiers longer than 150 bytes are now rejected.
- [x] Docs updated: CHANGELOG, production/upgrading/whats-new guides, runbook, acceptance addendum, current work, human status and changelog. New evidence file AUDIT_V2_VALIDATION.md. Architecture and flow unchanged; no diagram rewrite.
- [x] Uncommitted recommendation for the owner: a distinct `action.replayed` event would change the notification catalog the pinned specification lists, so it is not implemented here.
- [x] Committed on main with `Work-ID: WORK-20261017-02`; not pushed (owner did not ask). No long-lived process started.

Boundaries: MySQL NOT_RUN (proven by column introspection and arithmetic), no live provider, browser, remote CI or assistive-technology run. Local-only evidence. See ../evidence/AUDIT_V2_VALIDATION.md.

## WORK-20261018-02 — release preparation

- [x] Owner authorizations, MIT/security reporting, public-repository observation and DELTA-005 recorded.
- [x] Version/gem/docs/changelog/package agree on 0.1.0; 25 packaged files reviewed; no API/schema or business-data migration.
- [x] Three core compatibility combinations each 89/723, adapter 7/45, packaged host and runnable docs pass; all checks with the shared test database run sequentially.
- [x] Docs style/build and 1,042 links pass; internal records excluded. No preview service started.
- [x] Six dependency lock audits and a clean network-resolved installation plus activated/default-gem audit pass. Security findings repaired by patched dependency floors and Rails 7.2.3.2 test target.
- [x] Pages/domain/DNS, private security reporting and the scoped OIDC publisher configured and observed. No long-lived secret added.
- [x] Operations, status, acceptance, delta, evidence and human changelog updated; architecture/runtime diagrams unchanged because behavior is unchanged.
- [x] Exact-tag compatibility/PostgreSQL/package/advisory checks, gem publication, release assets, versioned hosted docs and HTTPS verified. WORK-20261018-04 records actual delivery in RELEASE_0_1_0.
