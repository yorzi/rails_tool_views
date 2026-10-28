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

## WORK-20261018-02 — first gem release and hosted docs

- Owner explicitly requests documentation on GitHub Pages, DNS setup, following ruby_llm-browser's release process, and publishing `rails_tool_views` 0.1.0. This supersedes the historical no-publication scope.
- Base `eb72232`, clean main. Read entrypoint, pinned baseline, current work, maintenance, release checklist, acceptance and ADR 006. All 59 `docs/specs` files match pinned OddlyNiche `0ea28b1`; its current checkout differs, so the pinned revision was used.
- Baseline: Ruby 3.3.5 / Rails 8.1.4, SQLite, 89 tests / 723 assertions and eager load PASS. Remote repository is already PUBLIC; Pages does not exist, private security reports are disabled.
- Scope: first public version metadata, existing guides, versioned Pages, narrowly scoped DNS record, OIDC release workflow, package/install validation. No runtime/API/schema change. License and disclosure decisions requested from owner before publication.
- Classification: INTENTIONAL_DELTA for first publication despite open formal/adoption/live-provider evidence; record DELTA-005 without editing external Specs or implying those checks passed.
- Reference: ruby_llm-browser `release.yml` and successful release run 39110148539 use environment `release`, RubyGems Trusted Publishing, matching tag/version checks and disabled optional experimental attestations.
- Security: inspect gem/site manifests; exclude internal Specs, databases, credentials and tests; no API key added to GitHub. Temporary previews bind loopback and stop before completion.

Release preflight update: owner confirms domain/public repository/MIT/private reports and completes RubyGems reauthentication. Explicit at-action confirmation authorizes creating the scoped OIDC publisher. Release audit found Rails 7.2.3 and Ruby 3.3 default-gem advisories; this work therefore also updates the 7.2 test target to 7.2.3.2 and requires patched CGI/ERB/Resolv/URI/Zlib. This is dependency hardening inside the existing runtime contract, not a feature or schema change. Audit activated isolated-install specs in addition to lockfiles.

## WORK-20261018-05 — concise docs and a proposed 1.0 roadmap

- Owner requests a shorter GitHub README, clear repo/site responsibilities and iterative planning from simple 0.2.0 features to 1.0.0. Documentation/planning only; no feature implementation or new gem publication. The request to update GitHub authorizes committing/pushing this documentation update.
- Base `9f0bbd3`, clean tree. Read entrypoint, baseline, human status, implementation/current work, delta/maintenance, release evidence, upstream pinned roadmap, current controller/runtime/models/generator and contribution/site docs.
- Current evidence: 0.1.0 already published; no component generator or retention API; HTML rejections render fragments; replay emits action.executed. These are observed code facts, not inferred missing features.
- Classification: implementation-aligned docs corrections plus a PROPOSED roadmap. Proposed lifecycle/notification changes require scoped owner decisions and deltas before implementation; publishing the plan does not approve them. No external Specs edits.
- Validate links, guide style/build and executable tutorial examples. No runtime suite needed for prose-only changes; do not change version, tag, dependencies, schema or published artifact. No temporary server required.

## WORK-20261018-06..09 — AI-assisted 0.2 development

Owner explicitly authorizes improving the local agent development/testing foundation, then implementing 0.2 steadily with incremental commits until acceptance. Base `c90fd8d`, clean main. Read entrypoint, pinned baseline/current docs, roadmap, delta/maintenance, runtime/controllers/views/generator and current tests/package checks. All 59 Specs copies match pinned 0ea28b1; the live Specs checkout differs, so pinned objects were read.

Scope: (06) repeatable browser/screenshot and fully isolated packaged-host verification; (07) deny-by-default Partial component generator; (08) full non-Turbo HTML error page with authorized correction and unchanged JSON/Turbo semantics; (09) final version/docs/matrix/browser/package acceptance. No retention, new adapter, notification catalog or schema change. 0.2 implementation and local commits are authorized; no future gem upload is inferred. Existing demo is the canonical browser/test host; no separate long-lived application is required.

Browser tests bind loopback, use disposable test data, preserve offline core tests, and close driver/server processes. Screenshots contain fixtures only. Generator must reject unsafe names and never overwrite host files. HTML errors retain status/validation values only after server authorization, never from Referrer or client targets. Run focused failing regressions before features, then core/adapter/matrix/package/docs/browser checks. New public behavior gets guides in the same commit.

## WORK-20261018-10..11 — authorized 0.2 publication

- Owner explicitly authorizes pushing the candidate, checking remote CI, then publishing 0.2.0. Base aefc53d, clean main, four local commits; fetched origin is c90fd8d and v0.2.0 is unused. Existing MIT/OIDC/environment/domain remain authorized.
- Read entrypoint, baseline/current human/agent docs, delta/maintenance, release checklist/workflows and project-docs release routine. Source Specs unchanged; no new product/API/schema intent.
- WORK-10 prepares dates/released flag, focused upgrade/current What's New and historical guide, package/docs checks, ledger commit/push, exact remote CI then annotated tag/OIDC release and checksum/HTTPS verification. WORK-11 records observed delivery in its own commit. Runtime code is frozen unless remote evidence finds a real failure.
- Prior local 0.2 evidence is 97/837 across three Ruby/Rails combinations and PostgreSQL, adapter 7/45, Chrome 4/28, seven unique lock audits and isolated full host. Remote checks must cover the final commit; no historical evidence is relabeled remote PASS. No provider/contact/DNS mutation or 0.3 work. All temporary processes must end.

## WORK-20261019-01..03 — authorized 0.3 development

Owner requests continued 0.3 development and high-quality tests. Base 78d1333, clean main; read entrypoint, baseline, current human/agent/ADR/runtime/model/generator/test/roadmap/maintenance docs. All 59 Specs copies match pinned 0ea28b1; external checkout is only read through pinned git objects.

Scope: 01 explicit lifecycle/migration and delivery/closure coordination; 02 opt-in bounded payload cleanup with tombstones plus demo/browser/concurrency tests; 03 old-runtime upgrade, matrix/package/isolated installation/docs and local acceptance. Commit completed units locally under existing incremental-commit preference. No push/tag/upload/provider or 0.4 telemetry/transient-message work is inferred.

Implementation decisions: active→closed or abandoned, no automatic expiry; restore remains readable until explicit purge, new actions stop and exact receipts replay within the host retention window. Retain minimal Surface/Presentation guards after deleting payloads/receipts so old correlation cannot recreate work. No reopening. Retention deadline is host-set, nil means indefinite; retention policy denies by default, preview is default. Surface lock coordinates actions, closure and delivery claims; callbacks stay outside transactions. Reclaimed/legacy ambiguous delivery attempts are quarantined from lifecycle cleanup, even if their status later becomes terminal; do not infer quiescence from a lease timeout. ADR 008 records details and limitations. New additive migration requires stopping old 0.2 workers; downgrade after closure is refused.

Mapping: FR-04/05/06/07/08, NFR-02/05, SEC-04/06/07/11/12/18; aligned host-owned retention implementation, not new product intent. No notification catalog change or external Specs edit. Meaningful failing tests precede runtime; full matrix, PG, installed artifact, browser and process cleanup at acceptance.

## WORK-20261019-04..05 — authorized 0.3 publication

Base 18f5f73, clean main. Owner explicitly requests publishing 0.3 and synchronizing docs/commits. Read entrypoint, baseline/status/implementation/current work, delta/maintenance, ADR008 and release operations/workflows/project-docs routine. All 59 Specs match pinned 0ea28b1. Refetched origin; v0.3.0 unused, repo public, Pages HTTPS and existing release environment observed. Runtime frozen; 114/988 x three, PG116/1000, adapter7/45, Chrome5/40, genuine upgrade/installed/isolated/audit/docs local evidence remains V0_3_VALIDATION.

WORK-04 sets date/released flag, release notes/history/upgrade links and authorization, verifies actual package/docs, commits/pushes candidate, waits exact remote CI then tags/publishes via existing OIDC. WORK-05 records actual registry/Release/checksum/Pages outcome and pushes final documentation record. No DNS/new permission/provider/0.4 expansion. All task-created processes must end.

## WORK-20261020-01..03 — authorized 0.4 development

- Owner requests planned 0.4 development and best practices. Base 3ed5e39, clean main. Read entrypoint, baseline/status/implementation/current work, delta/maintenance, ADR008, runtime/model/controller/browser/continuation and host-durability tests. All 59 copied Specs match pinned 0ea28b1; external checkout is read via pinned objects.
- Baseline: Ruby3.3.5/Rails8.1.4 SQLite 114 tests/988 assertions and eager load PASS.
- Observed defect: callbacks acknowledge unconditionally after releasing claim locks, so a stale worker can overwrite the newer attempt. Reuse monotonic attempts as an acknowledgment fence; preserve stable delivery keys and conservative uncertainty. A host outer transaction must not allow pre-commit adapter effects. No new schema, dependency or queue.
- Classification: IMPLEMENTATION_BUG for recovery; notification and transient-feedback decisions requested explicitly under ROADMAP, not assumed. Metadata diagnostics must not log raw exception messages. Host owns durable deduplication/outbox and current authorization.
- Meaningful failure tests precede fixes. Validate host jobs/process death, fresh and expired leases, permission revocation, replay/committed state; then matrix/PG/browser/package/upgrade/docs. Stop task-owned services. Local commits authorized; no push or publication.

## WORK-20261020-03..04 — confirmed compatibility choices

Owner explicitly accepts preserving action.executed with replayed boolean and adding transient notice while retaining persistent state.message. Record DELTA-006 before behavior changes; external Specs remain unchanged. Notice belongs to an action response, never Surface state/snapshot; its durable receipt retains exact replay. Bound plain text to500bytes, escape it, omit from diagnostic metadata. For HTML use existing Rails flash scoped by Surface/actor/tenant, one GET; no payloads in URLs. Current behavior123/1063 across three combinations, PG126/1079, Chrome6/61, adapter7/45. Failing API/transport/privacy tests first, then repeat affected final acceptance after the compatibility change. No newschema/dependency or publication.

## WORK-20261020-05..06 — authorized 0.4 publication

Base e62dd20, clean main, four completed local commits. Andy explicitly requests remote CI, release acceptance, related docs and publication. Read entrypoint, baseline/system/status/implementation/current work, delta/maintenance, acceptance, release checklist/workflows, 0.3 delivery evidence, 0.4 validation and project-docs release routine. All 59 Specs match pinned0ea28b1; external checkout read through pinned objects. Fresh origin remains3ed5e39; v0.4.0 unused, registry0.4 API404, repo public, Pages existing HTTPS/domain, release environment present.

WORK-05 prepares release dates/flag/history/authorization, verifies final package/docs/installed host, commits and pushes; exact main CI/Docs must pass before annotated tag and OIDC release. WORK-06 records actual checksums/runs/hosted acceptance and pushes its own verified delivery record. Existing full local matrix remains V0_4_VALIDATION; remote PASS requires new exact evidence. Runtime frozen unless a real release failure warrants repair. No new permission/DNS/provider/schema/dependency/adjacent feature work. Stop all task-created processes.

## WORK-20261021 — audit and 1.0 RC preparation

Base 8d98688, clean main, 0.4.0 published. Andy requests an audit of functions and handling logic, fixes for valid findings with incremental commits, a plan/roadmap check and 1.0 RC preparation; the scope is recorded in SPEC_BASELINE. Read entrypoint, baseline, status, implementation plan, current work, roadmap, documentation maintenance, release checklist and workflows, and every runtime file (core, runtime, lifecycle, controller, helper, models, views, Stimulus controller, migrations, generators, RubyLLM adapter). docs/specs is the tracked pinned copy, last changed at 57edc3e, and is not edited.

- Baseline: Ruby 3.3.5/Rails 8.1.4 SQLite 129/1129 and eager load; adapter 7/45; package, upgrade and docs-example smokes PASS (`bin/check`).
- Probed defects: status focus on page load; invalid regex patterns, malformed action definitions and a non-array `expose_to` raise raw Ruby errors instead of stable codes; identifiers with invalid encoding raise ArgumentError; String subclasses survive normalization; request digests re-apply payload limits to already-validated values; the race path of correlated presentation skips `presentation.rejected`; discovery policies receive a mutable Access; the Engine page's inline style has no CSP nonce.
- Classification: IMPLEMENTATION_BUG for each. Digests of accepted inputs must stay byte-identical, so stored component digests and replay receipts remain valid. Documented limits (uncertain delivery has no force clear; protected rows can fill a purge batch; the mount must stay named `:rails_tool_views`) are recorded as rc decisions, not silently changed.
- Every fix lands with a test that fails first. No schema, dependency, queue or new public feature. Stop task-owned browsers and servers.

## WORK-20261021-08..12 — rc1 lifecycle decisions D1..D3

Base 9887701, clean main, local 1.0.0.rc1 candidate. Owner asks to resolve D1..D3 with the best design. Re-read ADR 008/009 (both defer attested resolution until a concrete safe host contract exists), the Spec Delta protocol, pinned FR-06 and NFR-05, lifecycle/retention/continuation tests and guides.

- Baseline: core 134/1162, adapter 7/45, PG 137/1178, Chrome 9/81, upgrades 0.1..0.4 PASS (RC1_READINESS).
- Classification: implementation designs inside FR-04/05/06 and NFR-05, recorded in ADR 010; the added public names are an owner-approved contract supplement, DELTA-007, recorded before implementation.
- Invariants to keep: dispatch without an agent still succeeds (FR-06-AC-03); Surface-then-interaction lock order; callbacks outside transactions; the attempt fence rejects stale acknowledgments; uncertainty never clears on age or status; cursor narrows but never widens a scoped query; default-deny for the new hook; no schema, dependency or queue.
- Order: decisions (08), D3 (09), D1 (10), D2 (11), real-host and upgrade evidence plus full matrix (12). Failing tests first; stop task-owned processes.

## WORK-20261026-01..02 — owner-authorized 1.0.0 release

Base 8be445d, clean main, already pushed by the owner; its RailsToolViews CI and Docs runs (40254474230, 40254474364) succeeded. Andy requests releasing the new gem version and updating the docs and site, then chooses 1.0.0 stable with an explicit exception over rc1 or holding. Read entrypoint, baseline, status, current work, ROADMAP 1.0 conditions, RC1_READINESS, release checklist, release/docs workflows, build.sh and prepare_versions.rb. `docs/specs` is the tracked pinned copy, unchanged since 57edc3e, and is not edited. Tags end at v0.4.0; v1.0.0 is unused.

- Classification: RELEASE_GATE_EXCEPTION (DELTA-008) for conditions 5 and 6's independent review and formal disposition; no runtime, API, schema or dependency change. Runtime frozen at 8be445d.
- First major tag: build.sh will build v1.0.0 at `/`, the working tree at `/next/` and v0.4.0 at `/v0/`. Verify in a scratch clone with a local tag before pushing the real tag.
- WORK-01 sets version, lockfiles, `released: true`, changelog date, history, What's New and Upgrading, runs the release checklist locally, commits and pushes; exact main CI/Docs must pass before the tag. WORK-02 records actual runs, checksums and hosted results. Stop every task-created process.

## WORK-20261026-03..07 — post-1.0 audit, RubyLLM demo and roadmap

Owner request in this session: audit the gem, add a correct demo Rails app for testing and demonstration, make features correct for RubyLLM and Rails integrations and update the roadmap. Authorization recorded in SPEC_BASELINE (2026-10-26 post-1.0 audit). Base `f741646` on branch `claude/laughing-pasteur-p18ora`, clean tree.

- [x] Read AGENTS, entrypoint, SPEC_BASELINE, ROADMAP, Current Work, maintenance contract, ADR 010, runtime/lifecycle/adapter/controller/helper/views/JS, generators, demo host and RubyLLM/continuation/getting-started guides.
- [x] Baseline before change on local Ruby 3.3.6 / Rails 8.1.4 SQLite: core 144/1254 with eager load, adapter 7/45 (RubyLLM 2.1.0). The demo boots and its playground, customer, support and review pages render without console errors in Chromium.
- [x] Probed instead of assumed. RubyLLM 2.1 forwards `tool_call:` to `execute`, honors `Tool.tool_name` and sends the instance `parameters_schema` verbatim (non-strict) on every protocol. RubyLLM 1.0..1.16 call `execute(**args)` without a ToolCall and ignore `tool_name`: a real 1.16.0 chat loop refused `present_ui` and the adapter loaded without complaint. The adapter suite passes on RubyLLM 2.0.0, 2.1.0 and 2.1.1.
- [x] Confirmed findings: (1) adapter silently unusable on RubyLLM 1.x; (2) demo never runs RubyLLM, so `PresentUI` and `Continuation` are not exercised in a live Rails host; (3) demo labels the published 1.0.0 an "Unpublished development preview"; (4) demo cleanup can never purge interactively because closing keeps a one-day deadline; (5) the default Rails 8 importmap host has no documented controller setup.
- [x] Considered and kept: dispatch records `skipped` when no adapter is configured (ADR 010, FR-06-AC-03); the action handler runs inside the Surface lock; synchronous `auto_deliver`. These are documented contract choices; trade-offs go to the roadmap.
- [x] Classification: IMPLEMENTATION_BUG for (1), (3), (4); implementation-aligned demo and documentation for (2), (5). No product-intent change, no new delta, no core schema or runtime dependency. Demo-only tables live in `test/dummy`.
- [x] Security: the demo's model output is untrusted props; the existing closed schema and action policies still decide. No credential is added; the optional live mode reads the owner's own environment and is never run by the agent. Tests stay offline.

## WORK-20261028-01..02 — review of the post-1.0 audit and 1.0.1 preparation

Owner request in this session: review the changes on `claude/laughing-pasteur-p18ora`, then prepare the 1.0.1 release. Authorization recorded in SPEC_BASELINE (2026-10-28). Base `d71b63b` (branch head, remote CI 40326211289 green), clean tree, fast-forward of `main` at `f741646`.

- [x] Read AGENTS, entrypoint, Current Work, release checklist, maintenance contract, the six commits' diff (code, tests, docs, governance) and the runtime delivery path the demo adapter relies on.
- [x] Branch baseline on Ruby 3.3.5 / Rails 8.1 SQLite: core 144/1254 with eager load, adapter 12/83, adapter-bundle eager load, package smoke, upgrades from 0.1.0..0.4.0, docs examples core/adapter, Rails 7.2 144/1254. Ledger linkage for main..HEAD passes.
- [x] Classification: implementation-aligned review fixes and release metadata; no product-intent change, no new delta, no schema or runtime dependency. The 1.0.1 change visible to hosts is the RubyLLM 2.0 load-time requirement already recorded in WORK-20261026-03.
- [x] Pushing, tagging and publication are out of scope until the owner confirms.
