# 0.2.0 release evidence

2026-10-18. Andy explicitly authorizes pushing the local candidate, checking remote CI, then publishing 0.2.0. Preparation WORK-20261018-10, actual delivery WORK-11. The 0.1.0 tag stays immutable.

## Local preparation

Implementation base aefc53d contains the four accepted development commits. Full local evidence is in [V0_2_VALIDATION](V0_2_VALIDATION.md): three Ruby/Rails combinations and PostgreSQL 97/837, adapter 7/45, Chrome 4/28, isolated installed host, seven unique dependency locks and activated-gem audits. These are local results, not candidate remote CI.

Release-only edits date CHANGELOG and history, set released true, archive What's New 0.1 at its existing URL, expose What's New 0.2, and replace Upgrading with the 0.1→0.2 instructions. Older identity migration instructions remain at immutable v0.1.0. No runtime/schema/dependency change.

New package/full host/actual generated Minitest 1/2, official release metadata gate (31 files) and documentation examples pass. Docs impact's ApplicationController removal warning is a false positive: core still defaults to ::ApplicationController, documented in Configuration. Docs lint: 17 guides, zero errors, one expected pre-tag version warning. Stable v0.1.0 + working next build: 2,301 local links, zero broken; internal records excluded.

Local preparation package SHA-256: `2c395bd4d41cfe3bd01c5e2654b1d25e7f84c5b512a2899ac875ba40460faef2`. Publication rebuilds separately; verify actual registry/Release assets instead of assuming binary identity across jobs.

Repository is PUBLIC, private vulnerability reporting enabled, release environment exists, Pages domain/HTTPS enforced. Existing scoped OIDC publisher remains in use; no security permission or DNS change is needed.

## Remote verification and delivery

Observed delivery, recorded by WORK-20261018-11:

- Exact candidate/tag commit: `3156fd38f9fde60c3d8d582853a84b3d9d71e3d5`; annotated `v0.2.0` tag object `4fc1de4d32d61b65af355ffb62e89a6e021dc9c6`. Neither published tag moved.
- [Main CI 39126752647](https://github.com/yorzi/rails_tool_views/actions/runs/39126752647): SUCCESS. Three core combinations and PostgreSQL each 97 tests / 837 assertions; adapter 7/45; real Chrome 4/28. Packaged hosts and generated tests pass; fixture screenshots uploaded. [Candidate Docs 39126752515](https://github.com/yorzi/rails_tool_views/actions/runs/39126752515): SUCCESS.
- [Release 39126933977](https://github.com/yorzi/rails_tool_views/actions/runs/39126933977): SUCCESS for that exact tag. All compatibility jobs reran and passed, including browser. Metadata/package, lockfile/activated dependency audits, isolated installed-host workflow and versioned docs passed before OIDC upload. Advisory snapshot `fa2295251efb3b0d1a300e5ce8ad700ff1f1b485`; 2,450 docs links pass.
- Upload log: `Successfully registered gem: rails_tool_views (0.2.0)`, `2026-10-18T12:24:27Z`. No long-lived RubyGems key.
- [GitHub Release](https://github.com/yorzi/rails_tool_views/releases/tag/v0.2.0) published `2026-10-18T12:25:10Z` (20:25:10 Asia/Shanghai), not draft/prerelease, with gem and SHA256SUMS.
- [RubyGems 0.2.0](https://rubygems.org/gems/rails_tool_views/versions/0.2.0): version/MIT/source/docs/MFA metadata verified. Its page reports new versions require MFA and this version was published with MFA, both true; publisher is `GitHub Actions yorzi/rails_tool_views @ .github/workflows/release.yml (release)`. V2 JSON does not expose a top-level mfa_published field, so MFA-published evidence comes from the version page, not an invented API field.
- RubyGems initially returned 404 for the newly published version API. Subsequent version API with a cache-busting parameter, standard versions index, direct artifact download, and real `gem fetch rails_tool_views --version 0.2.0` all succeed. Actual fetched bytes and API checksum match the GitHub Release gem and SHA256SUMS:

```text
5fd6a193dd9e69be3277ef34ff63802118031c51fee95ddcf4952af46d307367
```

All 31 extracted files match the locally verified source package byte for byte. Name/version/platform/authors/license/URLs/metadata/dependency requirements and remaining gemspec contract match. Raw gemspec YAML differs in file ordering and RubyGems builder version (local 3.5.16, publication 3.5.22). Separate release verification artifact hash is `b60ec2c26aa31fe49984e0d07b5eb0a4f7bfa6147d43c49bb85f086c6c3f094c`; publication rebuilds separately. Do not claim cross-job binary reproducibility.

- [Post-release Pages 39127199725](https://github.com/yorzi/rails_tool_views/actions/runs/39127199725): SUCCESS, triggered by Release Gem completion. Stable shows `0.2.0 (stable)` and versioned install command; next uses `--git ... --branch main`.
- Fifteen HTTPS paths return 200: root, Getting Started, generator, validation, upgrading, both What's New pages, next root/Getting Started, API root/Markdown, llms/llms-full/next-llms and sitemap. HTTP redirects to HTTPS; standard certificate verification succeeds. Candidate and tag builds exclude internal records.
- Actual browser: search “component generator” returns the new guide and What's New 0.2; opening the result works; version menu switches stable→next→stable with correct installation commands. Native screenshot retained at ignored `tmp/release-verification-0.2.0/docs-stable.png`. Browser tab closed.

The delivery-record commit changes internal status/roadmap/evidence only. Its post-push CI/Docs outcome is checked after committing and reported in the final handoff; it cannot be embedded into its own immutable commit in advance.

## Limits and cleanup

No live provider or external customer contact, MySQL qualification, independent security review, external setup/adoption trials or formal H2/C/R closure. No temporary local server started. Previous development services were cleaned up; release/CI/Pages watcher processes completed. Browser tab closed; the disposable client-fetch directory removed itself. Downloaded artifacts remain ignored under tmp for inspection. No runtime repair was needed.
