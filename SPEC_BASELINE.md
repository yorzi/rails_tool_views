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
