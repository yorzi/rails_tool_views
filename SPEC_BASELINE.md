# ToolViews product-intent reference

Source: https://github.com/yorzi/oddlyniche/tree/main/toolviews

Pinned source commit: `0ea28b1a76990b8c1e6a0bbd236119fd5bc5d1cc` (2026-10-10).
The unchanged reference pack is in `docs/specs/`. Canonical acceptance: `04_FEATURE_MVP_SPECS.md` and `supporting/04_SECURITY_VERIFICATION.md`.

The source is REVIEW / 0.1.0-draft, with no formal H2/C/R approval. The owner explicitly authorized this local implementation through the current `/goal` instruction. That authorization does not fabricate formal baseline approval, a public repository, license clearance, external adoption or release approval. No remote push or publication is authorized.

Initial v0 scope: Demo A, UC-01 and UC-10; S1 offline runtime, S2 optional RubyLLM presentation, S3 explicit agent continuation, and local packaging/documentation. V1 promotion is recorded below; trees, external protocols and SaaS remain outside scope.

## V1 authorization

After v0, Andy explicitly requested continuing through v1 before human inspection. Local scope now includes the pinned P1 UC-02..05 contracts and Demo B/C. This authorizes reversible local implementation and its verification; the external reference remains unchanged, and release/maintainer contact/live communication remains outside this task.

## 2026-10-18 single identity

The owner kept `rails_tool_views` and chose to remove the legacy `ToolViews` compatibility layer and `tool_views_*` identifiers before the first release. See ADR 006 and DELTA-004. The pinned Specs remain unchanged.

## 2026-10-16 identity supplement and push authorization

The owner now explicitly requests adopting **RailsToolViews**, updating the gem and related surfaces, then commit and push. This supersedes the earlier no-push scope for this work unit; RubyGems publication is not requested. Original Specs remain pinned above and unchanged. Additional naming/compatibility intent is read from OddlyNiche commit `c100a73d80b92de2246901922caa2b7bd819d889`, `toolviews/supporting/07_RAILS_NAME_AND_ODDLYDOCK_CONTRACT.md`. See ADR 005 and DELTA-003 for the implementation decision. OddlyDock remains a planned reference host, not a core dependency or a completed integration claim.

## 2026-10-18 first public release authorization

Andy explicitly requests documentation on GitHub Pages, DNS and publishing the gem as `0.1.0`, following ruby_llm-browser. He selects `rails-tool-views.wangyaodi.com`, a public repository, MIT and GitHub private vulnerability reporting. This authorizes the necessary commit/push/tag/publication and supersedes older no-publication statements for this release. Internal `0.2`/`0.3` prerelease labels were never public versions. DELTA-005 records remaining formal, security, provider and adoption gaps; external Specs remain read-only and pinned.

## 2026-10-18 public 0.2 development authorization

Andy explicitly authorizes improving AI-agent local development/testing, implementing the bounded 0.2 generator and HTML correction scope, and incremental local commits until acceptance. Reuse the maintained dummy demo plus disposable installed-gem hosts, with real browser/E2E screenshots. This does not authorize future publication, provider calls or speculative lifecycle/notification changes. No baseline intent or external Specs changed; ADR 007 records implementation choices.

## 2026-10-18 public 0.2 release authorization

After reviewing local acceptance, Andy explicitly authorizes pushing the candidate, checking remote CI, then publishing 0.2.0. This supersedes the previous local-only limitation for this release, including necessary metadata commits, annotated tag, OIDC upload, GitHub Release and versioned Pages deployment/verification. MIT, disclosure and scope stay unchanged; formal/security/provider/adoption gaps remain open.

## 2026-10-19 public 0.3 development authorization

Andy requests continuing 0.3 development with high-quality tests, against the roadmap's lifecycle/opt-in retention scope. Reversible local implementation, verification and incremental commits are authorized. Host controls deadlines and authorization; no automatic deletion, guessed delivery quiescence, notification change or future publication is inferred. Original Specs remain pinned and unmodified.

## 2026-10-19 public 0.3 release authorization

After local candidate acceptance, Andy explicitly requests advancing and publishing 0.3.0, synchronizing documentation and committing. This authorizes candidate commit/push, exact remote CI, annotated v0.3.0, existing OIDC publication, GitHub Release and versioned Pages verification. It supersedes the earlier local-only limitation for this release. Runtime scope, MIT/disclosure and external pinned Specs stay unchanged; provider, adoption, formal and independent security gaps remain open.

## 2026-10-20 public 0.4 development authorization

Andy requests executing the planned 0.4 recovery/diagnostics/UI feedback scope with high-quality tests and simple solutions. Reversible local implementation and incremental commits are authorized. Keep host-owned queues, authorization and durable deduplication; no provider calls, push, tag or publication is inferred. Notification/feedback compatibility choices follow the roadmap's explicit decision requirement; external Specs stay pinned and unchanged.

## 2026-10-20 0.4 compatibility decisions

Andy explicitly chooses to keep action.executed and add replayed:true/false metadata, and to add transient notice without changing persistent state["message"]. DELTA-006 records the notification supplement before implementation. This does not authorize an event rename, removal of old message behavior or publication.

## 2026-10-21 audit and 1.0 RC preparation authorization

Andy requests an audit of the gem's functions and handling logic, fixes for valid findings with incremental commits, a check of the plan and roadmap, and preparation for the 1.0 RC release. This authorizes reversible local fixes, tests, documentation, release-tooling changes and local commits. It does not authorize push, tag, RubyGems or GitHub publication, provider calls, external contact or adoption trials. Contract changes stay compatible; the external pinned Specs stay unchanged.

## 2026-10-21 rc1 lifecycle decisions

After reviewing the readiness record, Andy asks to resolve D1 (purge batch starvation), D2 (no path to resolve uncertain delivery) and D3 (missing adapter skips committed work) with the best design before rc1, accepting that the public contract becomes a compatibility promise at rc1. This authorizes the contract supplement in DELTA-007 and ADR 010, with tests and local commits. Push, tag, publication, provider calls and external contact remain unauthorized.

## 2026-10-20 public 0.4 release authorization

Andy explicitly requests completing remote CI, release acceptance, related documentation and publication. This authorizes the completed 0.4 candidate push, exact remote CI, annotated v0.4.0, existing OIDC publication, GitHub Release and versioned Pages verification, including preparation and delivery-record commits. It supersedes prior local-only statements for this release. DELTA-006, MIT/disclosure and the pinned external Specs remain unchanged; open provider/MySQL/adoption/independent review/formal gates remain evidence limits.

## 2026-10-26 public 1.0.0 release authorization and condition exception

After pushing the rc1 lifecycle work, Andy explicitly requests releasing the new gem version and updating the docs and site, and chooses **1.0.0 stable with an explicit exception** over publishing `1.0.0.rc1` first. This decides D4 and D5 of the readiness record. ROADMAP 1.0 conditions 5 (three external setup trials, the measured bespoke-Rails comparison, a non-dummy host in recurring use for two weeks) and 6's independent security review and formal H2/C/R disposition are waived for this release as an owner exception; they are not met and are not reported as met. The rc1 step and its two-week observation window are skipped. This authorizes the 1.0.0 metadata and docs commit, push, exact remote CI, annotated `v1.0.0`, existing OIDC publication, GitHub Release, versioned Pages verification (stable 1.0.0 at `/`, `/next/`, 0.4.0 at `/v0/`) and a delivery-record commit. DELTA-008 records the exception. The public contract becomes a Semantic Versioning promise at 1.0.0. Runtime, schema, dependencies, MIT/disclosure and the pinned external Specs stay unchanged.

## 2026-10-26 post-1.0 audit, demo and roadmap authorization

Andy requests a review and audit of the gem, a correct demo Rails application inside the gem for testing and demonstration, fixes that make the features correct and well designed for RubyLLM and Rails hosts, and a roadmap update for work that is not ready. This authorizes reversible fixes, tests, demo and documentation changes, incremental commits and pushing them to the development branch `claude/laughing-pasteur-p18ora`. It does not authorize a version bump, tag, RubyGems or GitHub publication, a pull request, provider calls by the agent or external contact. The demo may offer an owner-run live provider mode, but the agent does not run it. The public 1.0 contract stays compatible; the pinned external Specs stay unchanged.

## 2026-10-28 review and 1.0.1 release preparation

Andy requests a code review of the post-1.0 audit on `claude/laughing-pasteur-p18ora` and preparation of the 1.0.1 release. This authorizes review fixes, the RubyLLM 2.0.0 CI coverage that ROADMAP required before tagging, 1.0.1 version and documentation metadata, the local release checks and local commits. It does not authorize pushing, merging to `main`, the `v1.0.1` tag, RubyGems or GitHub publication or provider calls; those wait for Andy's explicit go-ahead. The public 1.0 contract and the pinned external Specs stay unchanged.

Later on 2026-10-28, after the review and local checks, Andy explicitly authorizes releasing v1.0.1 and updating the docs accordingly. This authorizes fast-forwarding and pushing `main`, exact remote CI, the annotated `v1.0.1` tag, the existing OIDC publication and GitHub Release, versioned Pages verification and a delivery-record commit.

## 2026-10-30 consumer dependency findings and 1.0.2 release

Andy asks to check the rails_tool_views findings recorded by the rails_ai_admin consumer (DEP-001 process-wide coexistence, DEP-006 installer duplicate mount), confirm which are real, address them and release 1.0.2. This authorizes reversible fixes, tests and documentation, the 1.0.2 version metadata and local release checks, local commits, pushing `main`, exact remote CI, the annotated `v1.0.2` tag, the existing OIDC publication and GitHub Release, versioned Pages verification and a delivery-record commit. It does not authorize provider calls, external contact or a public contract change. The pinned external Specs stay unchanged.
