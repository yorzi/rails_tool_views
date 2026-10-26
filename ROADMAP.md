# Roadmap

**1.0.0 is published, 2026-10-26, under an owner exception.** See [delivery evidence](docs/evidence/RELEASE_1_0_0.md). 1.0.0 declares the [public contract](docs/site/_reference/public-contract.md), carries the audit fixes and settles lifecycle semantics: paged cleanup, host-attested delivery reconciliation and loud failure without an adapter (ADR 010). The [readiness record](docs/evidence/RC1_READINESS.md) shows conditions 1, 2 (engineering host), 3 (local) and 4 met. The owner chose to publish 1.0.0 directly, skipping rc1, with conditions 5 and 6's independent review and formal disposition waived rather than met (DELTA-008). Versions 0.1.0 through 0.4.0 are published; see [0.4 delivery evidence](docs/evidence/RELEASE_0_4_0.md). Provider calls and later releases still need their own authorization. Dates are not promised.

The goal is a Rails component runtime that is easy to integrate, safe to operate and stable to upgrade. The core remains independent of AI providers; customer, ticket and content services stay in the host.

## After 1.0

1.0.0 is a Semantic Versioning promise for every name the [Public Contract](docs/site/_reference/public-contract.md) lists. Fixes ship as patches, compatible capabilities as minors, and a contract change waits for a major. Everything in this section is proposed. Each release needs the owner's authorization, and dates are not promised.

### On `main`, unreleased

The 2026-10-26 audit added these after 1.0.0. They are patch-sized, need no migration, and are candidates for 1.0.1:

- The RubyLLM adapter raises `Gem::LoadError` on RubyLLM 1.x, where its tool was never callable. It requires RubyLLM 2.0 or later.
- The demo adds an agent chat that runs RubyLLM's real tool loop offline, with integration tests.
- Guides show how to attach `PresentUI` to a chat and continue it safely, and how to register the Stimulus controller in an importmap host.

Before tagging, add CI coverage for RubyLLM 2.0.0 (the new floor) next to 2.1.x. Versions 2.0.0, 2.1.0 and 2.1.1 pass locally; CI only locks 2.1.0.

### 1.1: make the RubyLLM adapter stable

The adapter stays experimental until each gap below closes. The provider-free core does not depend on any of them.

| Gap | Why it is not ready | Done when |
| --- | --- | --- |
| Live provider evidence | Only offline transports have exercised the tool. Providers accept different JSON Schema keywords, such as `anyOf`, `maxLength` and `maxItems`, and a rejected schema fails every request. | An owner-authorized run against at least OpenAI and Anthropic presents, acts and continues, with request shapes, failures and cost recorded. The demo's live mode is one way to run it. |
| Component and props binding | `component` is an enum and `props` accepts any catalog schema, so a model can pair them wrongly. The server rejects the pair with `INVALID_PROPS`, which costs a model round trip. | Live evidence shows how often it happens. Then choose between one tool and one tool per component. |
| Ownership during continuation | `chat_resolver` receives only `context_ref`. Checking that the chat belongs to the Surface's owner needs a wrapping adapter, as the demo and guide show. | `chat_resolver` can receive the payload as an optional second argument, an additive change. |
| Persisted chats | Rails hosts usually persist chats with RubyLLM's `acts_as_chat`. The project has tested plain `RubyLLM::Chat` with its own transcript. | An installed host with RubyLLM's generated schema presents, reloads, continues and deduplicates. |

### Decisions for the owner

These trade-offs came up in the audit. Each is a documented 1.0 behavior, so changing a default is a breaking change.

- **Follow-up recorded as skipped.** When the process that commits an action has no adapter configured, its follow-up is recorded `skipped` for good (ADR 010 keeps FR-06-AC-03). A web tier without adapter configuration in front of a worker that has one drops follow-up work without an error. Options: keep it and document it more prominently, or add an opt-in setting that records `pending` regardless of configuration.
- **Synchronous delivery.** `auto_deliver` is on by default, so with a live model the action request waits for the model. Options: keep it, since fast host callbacks are unaffected, or have the install generator write `auto_deliver = false` together with a job example.
- **Automatic importmap pin.** The engine could pin `rails_tool_views_controller` itself, as turbo-rails pins its own module. That saves one line in the host but adds public behavior.

### Risks to watch

- The Selenium browser suite fails intermittently with Chrome 153 here ("Node with given id does not belong to the document"). It fails the same way on the 1.0.0 commit, so it predates the audit; the 1.0.0 release CI passed on its Chrome. Check the CI Chrome version before GitHub's runners move.
- Sprockets hosts are unverified. MySQL stays outside the supported matrix.
- 1.0 conditions 5 and 6 stay open under DELTA-008: external setup trials, the bespoke comparison, non-dummy use, an independent security review and the formal baseline disposition.

## Road to 1.0

The sections below record how 1.0 was reached. They are kept as history.

### Starting point

0.1.0 already provides schemas, Partial/ViewComponent rendering, persistent Surfaces, authorized transactional actions, revision/replay protection, form validation and optional RubyLLM continuation. SQLite/PostgreSQL release CI, guides and gem publication are verified.

0.2 delivers the Partial generator and complete non-Turbo correction pages; exact-tag remote evidence is in [release validation](docs/evidence/RELEASE_0_2_0.md). 0.3 adds authorized lifecycle and opt-in payload cleanup, with completed [local acceptance](docs/evidence/V0_3_VALIDATION.md) and [exact-tag publication evidence](docs/evidence/RELEASE_0_3_0.md). 0.4 adds temporary response notices, replay metadata and fenced delivery recovery. Historically uncertain deliveries still require host reconciliation; the fence does not establish remote exactly-once effects. MySQL, live-provider behavior and external adoption remain unverified. See [current status](docs/human/01_PROJECT_STATUS.md) and [release evidence](docs/evidence/RELEASE_0_1_0.md).

### Version sequence

| Version | Outcome | Scope | Required evidence |
| --- | --- | --- | --- |
| 0.2.0 | Easier integration | Component generator; complete HTML error feedback | Fresh host: install, author, render, correct an error and restore |
| 0.3.0 | Controlled lifecycle | Explicit lifecycle rules; opt-in retention tooling | Safe cleanup, replay/continuation protection and upgrade coverage |
| 0.4.0 | Reliable operation | Continuation recovery, diagnostics and UI feedback | Real host recovers failures without duplicate effects or leaked data |
| 1.0.0.rc1 | Frozen contract | Skipped by owner decision, 2026-10-26 | Conditions 5 and 6 waived for 1.0.0 (DELTA-008) |
| 1.0.0 | Compatibility commitment | Fixes and final release verification | Owner reviews evidence and authorizes publication |

Use 0.x.y patches for compatible fixes. Put breaking changes in a planned minor with migration instructions. Add another 0.x iteration only for an unresolved gap, not to fill a version schedule. The public gem is 1.0.0; future publication needs separate authorization.

### 0.2.0: two small improvements

Use the existing `test/dummy` as the maintained demo/test host. Verify installation with a disposable host consuming the built gem under isolated dependencies; a second long-lived Rails repository is not required. Agent browser checks and repeatable system tests complement each other. These are engineering checks, not external setup trials.

- **Partial generator (published).** Command: `bin/rails generate rails_tool_views:component choice_card`. Generate a Partial, closed-schema registration and test scaffold. Reuse registry reloads and form helpers. Keep policies deny-by-default and identity/business rules host-owned. Reject invalid names; never silently overwrite host files. Defer a ViewComponent option until needed.
- **Complete HTML errors (published).** Non-Turbo rejection shows a usable page, error and correction path. Preserve status, authorized validation values and host authentication; denied/not-found responses expose no component data. The Engine owns a complete layout that hosts can override. Keep payloads out of URLs.

**Delivered:** local [0.2 validation](docs/evidence/V0_2_VALIDATION.md) and exact-tag [publication evidence](docs/evidence/RELEASE_0_2_0.md).

**Done when:** a fresh packaged host exercises both transports, invalid input, stale revision, denial and refresh/restore; JSON/Turbo contracts still pass. Ship a generator guide, updated Getting Started and upgrade notes with the implementation.

**Stop if:** either change needs a new DSL, frontend or navigation framework. Reduce scope rather than widening this release. No retention system, new adapter or component kit in 0.2.

### 0.3.0: lifecycle before deletion

The published implementation follows ADR 008: explicit close/abandon, first-termination retention deadline, closed reads and authorized historical replay. No automatic expiry or reopening.

The published `purge_closed` implementation uses explicit scope/cutoff, dry-run counts and bounded batches. Never prune retryable receipts independently. Pending and retryable failed work requires explicit abandonment; delivering or historically uncertain interactions always remain protected. Surface/Presentation tombstones preserve correlation guards; this is payload cleanup rather than full erasure. No automatic deletion on installation or by default.

**Done when:** dry run makes no writes; cross-tenant, concurrent action/delivery, crash/retry and upgrade checks pass; host business records survive. Document recovery/backup limits. If a safe retention boundary is unresolved, leave cleanup disabled and resolve it before 1.0.

### 0.4.0: recovery and diagnostics

- Exercise host-owned jobs through commit, pending delivery, crash, expired lease and explicit retry. Preserve delivery keys and host outbox/deduplication; do not promise exactly-once network delivery.
- Owner chose additive `replayed` metadata on `action.executed`; DELTA-006 records the approval. Keep event names and metadata-only payloads.
- Owner chose explicit `Transition#notice` while preserving persistent `state["message"]`. Verify JSON/Turbo/scoped HTML flash, refresh and exact receipt replay, plus keyboard, focus, loading, mobile and retry feedback.

**Done when:** recovery preserves committed results and produces no duplicate host effect; metadata-only diagnostics explain failures without exposing props/secrets. A dashboard or built-in queue is not required.

**Delivered:** [0.4 validation](docs/evidence/V0_4_VALIDATION.md) and [exact-tag publication evidence](docs/evidence/RELEASE_0_4_0.md) cover recovery, compatibility, host jobs, actual packages, browser feedback and stable0.4/next. Contract and evidence preparation for rc1 is done locally; see the [readiness record](docs/evidence/RC1_READINESS.md) for the open conditions and the two remaining owner decisions. No push, tag or publication is authorized.

### 1.0 release conditions

1. **Declared public contract.** Freeze registration, scope, present/restore/render/dispatch, helpers, validation/errors, adapter hooks and configuration. Include wire/snapshot fields, DOM/Stimulus identifiers, events, delivery keys and persisted-data expectations. Mark internals and document deprecations using [Semantic Versioning](https://semver.org/).
2. **Complete host workflows.** In a separate host, exercise both renderers, reload, invalid/conflicting/repeated actions and continuation recovery. Preserve authorization, CSRF and tenant isolation. Settle lifecycle/retention semantics.
3. **Supported matrix and upgrades.** Run advertised Ruby/Rails/SQLite/PostgreSQL versions, concurrency/restart and packaged-install checks on the exact candidate. Upgrade saved 0.1 and intervening-minor data through documented migrations. Support MySQL only after real migration/collation/concurrency tests; otherwise explicitly exclude it from the supported matrix.
4. **Bounded adapter claims.** Keep real SDK contract/recovery tests. A supported provider integration needs a controlled end-to-end exercise with separately authorized credentials, data and budget. Otherwise label the affected adapter experimental before freezing the API; the provider-free core can be stable.
5. **External usability evidence.** Complete the pinned baseline's three external setup trials and measured bespoke-Rails comparison. Record setup time, blockers and practical differences without invented improvement targets. At least one non-dummy host must use a recurring workflow. No benefit is a reason to narrow/reconsider scope, not add features. Do not contact anyone without authorization.
6. **Review and distribution.** Resolve independent security-review findings; check licenses, advisories, diagnostics and private reporting. Record the owner's disposition of open formal baseline gates in the owning Specs workflow or as an explicit exception. Candidate CI, registry/release checksums, upgrade docs and stable/next HTTPS must pass. No unresolved authorization, data-loss or duplicate-effect defect ships as 1.0.

At rc1, freeze features and prefer fixes. Observe the non-dummy host for at least two weeks, including normal use, restart and recovery; elapsed time alone is not acceptance. A contract change needs another candidate and affected checks.

Use RubyGems version `1.0.0.rc1` and matching tag `v1.0.0.rc1`. Before the first RC, mark its GitHub Release as a prerelease in the workflow and verify it does not replace stable docs or the latest stable release. Publish 1.0 only after the conditions and owner authorization; permission to publish 0.4.0 does not authorize future releases.

**Owner exception, 2026-10-26.** The owner authorized 1.0.0 directly, without rc1. Conditions 5 and 6's independent security review and formal baseline disposition are waived for 1.0.0, not met (DELTA-008). They remain the open evidence for 1.x: setup trials, a bespoke comparison and non-dummy use may still narrow scope, and review findings ship as fixes. A finding that needs a contract change waits for a planned major.

## Outside 1.0

Generated executable UI, arbitrary trees, progressive streaming, ActionCable, A2UI/AG-UI/MCP Apps conformance, multi-agent orchestration, SaaS and a large component kit. Each needs a demonstrated host use case and separate design; none is a 1.0 prerequisite.

This is the single maintained version plan. [Current Work](docs/agent/02_CURRENT_WORK.md) tracks the active unit, [Contributing](CONTRIBUTING.md) covers development and [the release procedure](docs/operations/02_RELEASE_CHECKLIST.md) covers publication. User guides describe delivered behavior.
