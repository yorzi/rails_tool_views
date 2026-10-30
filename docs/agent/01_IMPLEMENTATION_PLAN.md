# Completed implementation map

This file records completed implementation sequencing. Future version proposals live in [ROADMAP.md](../../ROADMAP.md); executable scope lives in [Current Work](02_CURRENT_WORK.md). Historical V1 below is a feature milestone, not public version 1.0.0.

Purpose: reuse a trusted host Partial/ViewComponent as a persistent interactive tool. Actors and tenants are host-resolved opaque references; permissions deny by default. No account model or AI provider is required.

1. Inspect pinned upstream implementations; choose a bounded independent registry or a safe reuse path through an ADR. Use JSONSchemer rather than a copied compiler.
2. Registry: immutable key/version/digest, strict closed schemas, explicit render target and policies; capped catalogs. FR-01/02.
3. ActiveRecord runtime: Surface, Presentation (correlation), ActionExecution (replay receipt), AgentInteraction (post-commit continuation). FR-04/05.
4. One transaction for validated/authorized actions; durable idempotency and revision checks; JSON and Turbo only negotiate output after commit. FR-05/07 and SEC-01..18.
5. Optional RubyLLM Tool subclass with explicit host scope/catalog/context, real ToolCall correlation and browser references separate from acknowledgment. FR-03.
6. Explicit structured agent interaction delivered by an opt-in host adapter; no transcript writes from core. FR-06.
7. Engine controller, helper, migration installer and ChoiceCard dummy app. Native labeled controls, mobile layout, empty/error/conflict/loading/continuation states; browser keyboard and restored state verification. FR-07/08.
8. Core-only and adapter tests, fresh packaged install, local Ruby/Rails matrix, CI configuration, human docs and progress ledger. Record live/provider/PostgreSQL/external/release gaps honestly.

No ActionCable in v0: JSON and Turbo are the supported transports. Introducing broadcasting requires separate scoped subscription tests. Host domain state stays outside Surface. External side effects require host idempotency/outbox.

## Completed local V1 extension — DELTA-002

Promoted by explicit owner authorization after V0, without changing the external baseline or release gates:

1. Generic bounded field feedback and authorized HTML/Turbo re-render; preserve host controller authentication/helpers.
2. UC-02: host-owned CustomerForm and transactional create-once service with protected attributes denied.
3. UC-03/05: independently scoped query/resolver/action policies, two roles/two tenants, account/assignment, explicit draft/review/confirmed local outbox.
4. UC-04: host-owned immutable artifact versions, deterministic edit/accept/export, explicit regeneration, current domain-version guards and crash-safe host receipts.
5. Full regression/SDK/matrix/package checks, separate-process durability, privacy and browser/mobile/restart/download evidence; update ADR/human/operations docs and local ledger-linked commit.

Feature-milestone acceptance is in 08_V1_ACCEPTANCE.md. Version 0.1.0 publication is recorded in ../evidence/RELEASE_0_1_0.md; remaining adoption/formal gaps and the next unit are tracked in the current status and Current Work.

## Public 0.2 local acceptance

WORK-20261018-06..09: browser/isolated-host foundation → deny-by-default Partial generator → complete authorized HTML correction → metadata/docs/matrix/package verification. No migration, retention, notification or adapter expansion. [Validation](../evidence/V0_2_VALIDATION.md) records local completion; push/remote CI/publication are separate next steps.

## Owner-authorized 0.3 local sequence

WORK-20261019-01 lifecycle/migration and Surface-first delivery coordination → WORK-02 opt-in payload cleanup and dummy E2E → WORK-03 genuine 0.2 data upgrade, PostgreSQL competing workers, compatibility/package/isolated/docs acceptance. ADR 008 fixes tombstone and quarantine boundaries. No new notification or recovery protocol; publication and provider calls remain separate. Evidence lives in V0_3_VALIDATION.

## Owner-authorized 0.4 local sequence

WORK-20261020-01 attempt-fenced recovery/host job and crash boundary → WORK-02 metadata-only ordinary diagnostics/browser feedback → explicit DELTA-006 owner choices → WORK-03 additive replayed/notice and upgrade/installed-host fixtures → WORK-04 supported matrix/PG/browser/isolated/audit/docs acceptance. No new schema/dependency/queue. Completed locally; V0_4_VALIDATION records outcomes and remaining1.0 evidence limits. Owner subsequently authorized release; WORK-05..06 verifies exact remote CI/OIDC/registry/Pages and records delivery in RELEASE_0_4_0.

## Owner-authorized 1.0.0 release

WORK-20261026-01 owner exception (DELTA-008), 1.0.0 metadata/docs and exact candidate CI → WORK-02 annotated v1.0.0, OIDC publication and hosted acceptance. Runtime unchanged from 8be445d. Evidence: ../evidence/RELEASE_1_0_0.md.

## Owner-authorized 1.0.1 release

WORK-20261028-01 review of the post-1.0 audit and RubyLLM 2.0.0 CI → WORK-02 1.0.1 metadata/docs and local release matrix → WORK-03 exact candidate CI, annotated v1.0.1, OIDC publication and hosted acceptance. Evidence: ../evidence/RELEASE_1_0_1.md.

## Owner-authorized 1.0.2 release

WORK-20261030-01 installer keeps an existing Engine mount and shared-runtime docs (rails_ai_admin DEP-006, DEP-001) → WORK-02 1.0.2 metadata/docs and local release matrix → WORK-03 exact candidate CI, annotated v1.0.2, OIDC publication and hosted acceptance.
