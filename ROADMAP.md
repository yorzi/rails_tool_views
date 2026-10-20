# Road to 1.0

**0.4.0 published, 2026-10-20.** Versions 0.1.0 through0.4.0 are published. Owner-authorized0.4 candidate/tag CI, OIDC publication and registry/hosted verification are complete; see [delivery evidence](docs/evidence/RELEASE_0_4_0.md). Provider calls and later releases still need their own authorization. Reassess each version using feedback from the previous one; dates are not promised.

The goal is a Rails component runtime that is easy to integrate, safe to operate and stable to upgrade. The core remains independent of AI providers; customer, ticket and content services stay in the host.

## Starting point

0.1.0 already provides schemas, Partial/ViewComponent rendering, persistent Surfaces, authorized transactional actions, revision/replay protection, form validation and optional RubyLLM continuation. SQLite/PostgreSQL release CI, guides and gem publication are verified.

0.2 delivers the Partial generator and complete non-Turbo correction pages; exact-tag remote evidence is in [release validation](docs/evidence/RELEASE_0_2_0.md). 0.3 adds authorized lifecycle and opt-in payload cleanup, with completed [local acceptance](docs/evidence/V0_3_VALIDATION.md) and [exact-tag publication evidence](docs/evidence/RELEASE_0_3_0.md). 0.4 adds temporary response notices, replay metadata and fenced delivery recovery. Historically uncertain deliveries still require host reconciliation; the fence does not establish remote exactly-once effects. MySQL, live-provider behavior and external adoption remain unverified. See [current status](docs/human/01_PROJECT_STATUS.md) and [release evidence](docs/evidence/RELEASE_0_1_0.md).

## Version sequence

| Version | Outcome | Scope | Required evidence |
| --- | --- | --- | --- |
| 0.2.0 | Easier integration | Component generator; complete HTML error feedback | Fresh host: install, author, render, correct an error and restore |
| 0.3.0 | Controlled lifecycle | Explicit lifecycle rules; opt-in retention tooling | Safe cleanup, replay/continuation protection and upgrade coverage |
| 0.4.0 | Reliable operation | Continuation recovery, diagnostics and UI feedback | Real host recovers failures without duplicate effects or leaked data |
| 1.0.0.rc1 | Frozen contract | Upgrade, independent review and setup trials | All 1.0 conditions below are evidenced |
| 1.0.0 | Compatibility commitment | Fixes and final release verification | Owner reviews evidence and authorizes publication |

Use 0.x.y patches for compatible fixes. Put breaking changes in a planned minor with migration instructions. Add another 0.x iteration only for an unresolved gap, not to fill a version schedule. The public gem is0.4.0; future publication needs separate authorization.

## 0.2.0: two small improvements

Use the existing `test/dummy` as the maintained demo/test host. Verify installation with a disposable host consuming the built gem under isolated dependencies; a second long-lived Rails repository is not required. Agent browser checks and repeatable system tests complement each other. These are engineering checks, not external setup trials.

- **Partial generator (published).** Command: `bin/rails generate rails_tool_views:component choice_card`. Generate a Partial, closed-schema registration and test scaffold. Reuse registry reloads and form helpers. Keep policies deny-by-default and identity/business rules host-owned. Reject invalid names; never silently overwrite host files. Defer a ViewComponent option until needed.
- **Complete HTML errors (published).** Non-Turbo rejection shows a usable page, error and correction path. Preserve status, authorized validation values and host authentication; denied/not-found responses expose no component data. The Engine owns a complete layout that hosts can override. Keep payloads out of URLs.

**Delivered:** local [0.2 validation](docs/evidence/V0_2_VALIDATION.md) and exact-tag [publication evidence](docs/evidence/RELEASE_0_2_0.md).

**Done when:** a fresh packaged host exercises both transports, invalid input, stale revision, denial and refresh/restore; JSON/Turbo contracts still pass. Ship a generator guide, updated Getting Started and upgrade notes with the implementation.

**Stop if:** either change needs a new DSL, frontend or navigation framework. Reduce scope rather than widening this release. No retention system, new adapter or component kit in 0.2.

## 0.3.0: lifecycle before deletion

The published implementation follows ADR 008: explicit close/abandon, first-termination retention deadline, closed reads and authorized historical replay. No automatic expiry or reopening.

The published `purge_closed` implementation uses explicit scope/cutoff, dry-run counts and bounded batches. Never prune retryable receipts independently. Pending and retryable failed work requires explicit abandonment; delivering or historically uncertain interactions always remain protected. Surface/Presentation tombstones preserve correlation guards; this is payload cleanup rather than full erasure. No automatic deletion on installation or by default.

**Done when:** dry run makes no writes; cross-tenant, concurrent action/delivery, crash/retry and upgrade checks pass; host business records survive. Document recovery/backup limits. If a safe retention boundary is unresolved, leave cleanup disabled and resolve it before 1.0.

## 0.4.0: recovery and diagnostics

- Exercise host-owned jobs through commit, pending delivery, crash, expired lease and explicit retry. Preserve delivery keys and host outbox/deduplication; do not promise exactly-once network delivery.
- Owner chose additive `replayed` metadata on `action.executed`; DELTA-006 records the approval. Keep event names and metadata-only payloads.
- Owner chose explicit `Transition#notice` while preserving persistent `state["message"]`. Verify JSON/Turbo/scoped HTML flash, refresh and exact receipt replay, plus keyboard, focus, loading, mobile and retry feedback.

**Done when:** recovery preserves committed results and produces no duplicate host effect; metadata-only diagnostics explain failures without exposing props/secrets. A dashboard or built-in queue is not required.

**Delivered:** [0.4 validation](docs/evidence/V0_4_VALIDATION.md) and [exact-tag publication evidence](docs/evidence/RELEASE_0_4_0.md) cover recovery, compatibility, host jobs, actual packages, browser feedback and stable0.4/next. The next planned milestone is contract/evidence preparation for rc1; unresolved1.0 conditions below remain open, and no next iteration is automatically authorized.

## 1.0 release conditions

1. **Declared public contract.** Freeze registration, scope, present/restore/render/dispatch, helpers, validation/errors, adapter hooks and configuration. Include wire/snapshot fields, DOM/Stimulus identifiers, events, delivery keys and persisted-data expectations. Mark internals and document deprecations using [Semantic Versioning](https://semver.org/).
2. **Complete host workflows.** In a separate host, exercise both renderers, reload, invalid/conflicting/repeated actions and continuation recovery. Preserve authorization, CSRF and tenant isolation. Settle lifecycle/retention semantics.
3. **Supported matrix and upgrades.** Run advertised Ruby/Rails/SQLite/PostgreSQL versions, concurrency/restart and packaged-install checks on the exact candidate. Upgrade saved 0.1 and intervening-minor data through documented migrations. Support MySQL only after real migration/collation/concurrency tests; otherwise explicitly exclude it from the supported matrix.
4. **Bounded adapter claims.** Keep real SDK contract/recovery tests. A supported provider integration needs a controlled end-to-end exercise with separately authorized credentials, data and budget. Otherwise label the affected adapter experimental before freezing the API; the provider-free core can be stable.
5. **External usability evidence.** Complete the pinned baseline's three external setup trials and measured bespoke-Rails comparison. Record setup time, blockers and practical differences without invented improvement targets. At least one non-dummy host must use a recurring workflow. No benefit is a reason to narrow/reconsider scope, not add features. Do not contact anyone without authorization.
6. **Review and distribution.** Resolve independent security-review findings; check licenses, advisories, diagnostics and private reporting. Record the owner's disposition of open formal baseline gates in the owning Specs workflow or as an explicit exception. Candidate CI, registry/release checksums, upgrade docs and stable/next HTTPS must pass. No unresolved authorization, data-loss or duplicate-effect defect ships as 1.0.

At rc1, freeze features and prefer fixes. Observe the non-dummy host for at least two weeks, including normal use, restart and recovery; elapsed time alone is not acceptance. A contract change needs another candidate and affected checks.

Use RubyGems version `1.0.0.rc1` and matching tag `v1.0.0.rc1`. Before the first RC, mark its GitHub Release as a prerelease in the workflow and verify it does not replace stable docs or the latest stable release. Publish 1.0 only after the conditions and owner authorization; permission to publish0.4.0 does not authorize future releases.

## Outside 1.0

Generated executable UI, arbitrary trees, progressive streaming, ActionCable, A2UI/AG-UI/MCP Apps conformance, multi-agent orchestration, SaaS and a large component kit. Each needs a demonstrated host use case and separate design; none is a 1.0 prerequisite.

This is the single maintained version plan. [Current Work](docs/agent/02_CURRENT_WORK.md) tracks the active unit, [Contributing](CONTRIBUTING.md) covers development and [the release procedure](docs/operations/02_RELEASE_CHECKLIST.md) covers publication. User guides describe delivered behavior.
