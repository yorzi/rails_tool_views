# Pre-flight record — WORK-20261013-01

Base: 3635c54, local v1 complete and awaiting manual inspection. Owner explicitly requested a review and audit with improvements on 2026-10-13.

- [x] Read entrypoint, SPEC_BASELINE, system and status pages, implementation plan, current work, Spec Delta Protocol, ADR 001/002 and both acceptance records.
- [x] Read pinned FR/AC, component contract, Surface action protocol, SEC-01..18, ecosystem spike and upstream gap analysis. docs/specs is a tracked copy, not a symlink; it is not edited.
- [x] Baseline before change: 60 tests / 468 assertions pass on Ruby 3.3.5 / Rails 8.1.4.
- [x] Expected: closed nested schemas, host-neutral installation, visible failures, host-owned wording. Observed by probe: open nested schemas register; host `state`/`result` parameters and columns are redacted; renderer and adapter exceptions vanish; host codes cannot be worded.
- [x] Classification: IMPLEMENTATION_BUG for the schema walk and the zero-argument form; implementation-level technical choices for redaction scope, failure reporting and copy, recorded in ADR 003. No product-intent change and no new delta.
- [x] Scope limit: no new tables or migration, no new dependency, no change to authorization, transaction, idempotency or transport semantics.
- [x] Security plan: keep every existing privacy assertion true for Engine data while proving host data is untouched; keep notifications metadata-only.
- [x] Tests precede the completion claim; each fix is checked by reverting it.

Extended the same day when the owner asked to continue: adoption ergonomics and PostgreSQL verification, within FR-02/05/07/08 and NFR-03, recorded in ADR 004. Probes first confirmed that Rails submit helpers were rejected and that a ViewComponent could not reach Surface context or the mounted routes.

Human comprehension impact: module-level. Update README, SECURITY, CHANGELOG, ADR 003, acceptance rows, architecture, status, changelog and ledger.

## WORK-20261016-01 — identity update

- Owner explicitly requests RailsToolViews rename, related gem updates, commit and push. Remote destination requested because none is configured.
- Read entrypoint, current implementation/ADRs, baseline, acceptance, runbook and release checklist. Clean main at 26825cb. Baseline: 78 tests / 646 assertions and eager load PASS.
- Original Specs: OddlyNiche at 0ea28b1a76990b8c1e6a0bbd236119fd5bc5d1cc; current clean checkout c100a73d80b92de2246901922caa2b7bd819d889 adds naming contract. Original tracked docs/specs remains unchanged.
- PRODUCT_INTENT_CHANGE: owner-approved identity only; no host integration or new runtime features. Preserve tables, digests, receipts and optional-adapter isolation; verify old data across processes plus fresh packaged install.

## WORK-20261016-03 — user documentation site

Owner invoked project-docs to create project documentation. Read skill and its writing/site/theme/maintenance references, entrypoint, current scope, README, public runtime, adapter, helpers and examples. Baseline 873643d; clean before this task. Scope: user guides, generated API, executable examples and build workflow. Implementation-aligned documentation, no product-intent delta. Existing Specs remain untouched; internal records stay outside generated site. Private repository publication stays disabled.

## WORK-20261016-04 — README and demo

Owner requests a concise README and a polished testing/showcase demo. Base 67e13fb, clean tree. Read entrypoint, baseline/current reality and maintenance contract. Scope: documentation and host demo presentation, preserving existing forms, policies, fixtures and state. No schema, core API, external delivery or product intent change. Verify full regression, docs build and actual browser interactions; stop the temporary server.

## WORK-20261017-02 — review and audit hardening

Owner asked in this session for a full review and audit and for real problems to be fixed; that instruction is the authorization. Base `a1a9b26`, clean tree. Read entrypoint, SPEC_BASELINE, current work, Spec Delta Protocol, runtime/controller/adapter, migration and installer, tests, guides and evidence.

- [x] Baseline before change: 84 tests / 669 assertions pass on Ruby 3.3.5 / Rails 8.1.4 (SQLite); PostgreSQL 17.11 also passes on a fresh schema.
- [x] Probed suspected defects rather than assuming: top-level JSON null/array/string bodies return a bounded 400; NUL inside props round-trips on PostgreSQL `json`; the form helpers emit no stray `utf8`/`_method` fields; the tree holds no stray build output. None is a defect.
- [x] Confirmed defects: the unbounded presentation index exceeds utf8mb4's 3072-byte limit (5100 bytes, so MySQL `CREATE TABLE` fails), and identity lookups rely on database equality so a non-binary collation can resolve another scope, correlation or key.
- [x] Classification: IMPLEMENTATION_BUG. No product-intent change; no new delta. The `action.replayed` idea is recorded as a recommendation because it would change the pinned notification catalog.
- [x] Scope limit: no new table, column, dependency or data migration; authorization, transaction, idempotency and transport semantics preserved; descriptions and versions keep the 255-byte cap.
- [x] Tests precede the completion claim; each fix is verified by reverting it alone.
- [x] Owner decision recorded in current work; docs updated for the public behavior change (identifiers over 150 bytes now rejected).
