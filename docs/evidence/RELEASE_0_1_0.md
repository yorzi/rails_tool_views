# RailsToolViews 0.1.0 release evidence

Date: 2026-10-18 (Asia/Shanghai). Work: WORK-20261018-02. Base: `eb72232`. This is the first public version; earlier 0.2/0.3 labels were unpublished development candidates.

## Authorization and scope

Andy explicitly requests gem documentation on GitHub Pages, DNS and publishing `0.1.0` following ruby_llm-browser. He confirms the public repository, `rails-tool-views.wangyaodi.com`, MIT and GitHub private vulnerability reporting. After reviewing the filled form, he also confirms creating the RubyGems OIDC publisher scoped to `yorzi/rails_tool_views`, `release.yml`, environment `release`. No long-lived publish credential was added.

All 59 local `docs/specs` files were compared byte for byte with pinned OddlyNiche `0ea28b1a76990b8c1e6a0bbd236119fd5bc5d1cc`, with no difference. Its current checkout differs, so the pinned revision was read. External Specs are unchanged. DELTA-005 records publication separately from the unclosed formal/adoption gates.

## Local validation

| Check | Result |
| --- | --- |
| Ruby 3.3.5 / Rails 8.1.4 / SQLite | 89 tests, 723 assertions, zero failures/errors/skips; eager load PASS |
| Ruby 3.3.5 / Rails 7.2.3.2 / SQLite | 89 tests, 723 assertions, zero failures/errors/skips; eager load PASS |
| Ruby 4.0.2 / Rails 8.1.4 / SQLite | 89 tests, 723 assertions, zero failures/errors/skips; eager load PASS |
| Optional RubyLLM 2.1.0 adapter | 7 tests, 45 assertions, zero failures/errors/skips |
| Core and adapter documentation examples | PASS |
| Packaged fresh Rails host | PASS: install/generator/migration, escaped renderer, form, HTTP action, no-Turbo redirect, validation, durable restore and eager load |
| Clean network-resolved installation and activated-gem audit | PASS: fresh GEM_HOME, artifact/installer load, zero known advisories against `fa2295251efb3b0d1a300e5ce8ad700ff1f1b485` |
| Release metadata/package guard | PASS: version/tag/docs/changelog/license/MFA, 25 approved files, no private artifacts |
| Site style | 15 guides, zero errors/warnings |
| Unversioned custom-domain build | PASS: 1,042 local links, zero broken links, internal records excluded |
| Root, Rails 7.2, adapter, PostgreSQL, Ruby 4 and docs lockfile audits | PASS against ruby-advisory-db `fa2295251efb3b0d1a300e5ce8ad700ff1f1b485` |

Commands are in `docs/operations/02_RELEASE_CHECKLIST.md`. Tests sharing the dummy database run sequentially. An initial accidental concurrent core/adapter invocation deleted each other's fixtures and failed; the sequential runs above passed. The first clean-install probe installed 52 dependencies but its own path assertion failed on Ruby's built-in `enumerator.so` feature name; the assertion now filters the actual entrypoint before resolving its path.

## Dependency audit findings and repairs

The old Rails 7.2 test bundle pinned 7.2.3 and matched upstream Rails advisories. It now uses 7.2.3.2. The first isolated install activated vulnerable Ruby 3.3 defaults: CGI 0.4.1, ERB 4.0.3, Resolv 0.3.0, URI 0.13.1 and Zlib 3.1.1. These defaults were absent from the development lock's activated set. The gem now explicitly requires patched versions, and the release workflow audits actual activated isolated-install dependencies as well as all lockfiles. No runtime API or database schema changes.

## External configuration

- Repository observed PUBLIC before this work; no visibility mutation required.
- GitHub private vulnerability reporting enabled and confirmed by API.
- Pages configured with build type `workflow`, domain `rails-tool-views.wangyaodi.com`, `DOCS_PUBLISH=true`.
- Cloudflare DNS-only CNAME created for the exact subdomain, targeting `yorzi.github.io`; `dig` confirms it. No other DNS record changed.
- GitHub `release` environment and matching pending RubyGems Trusted Publisher created.
- Reference implementation: ruby_llm-browser's successful release run 39110148539; use OIDC with optional experimental attestations disabled.

## Delivery verification

Actual delivery is verified below. Publication success comes from RubyGems, the release workflow and downloaded artifacts, not from local checks.

## Remaining evidence gaps

No live AI provider call or external customer contact. No real MySQL migration, independent security review, external setup/adoption trial or formal H2/C/R was completed by this work. The published package and documentation must retain those limits. No temporary preview service was started.

### Candidate 4f2d6fc: remote feedback

[CI 39117565282](https://github.com/yorzi/rails_tool_views/actions/runs/39117565282) passed Ruby 3.3 / Rails 8.1 and 7.2, optional adapter and PostgreSQL. Ruby 4 failed **before tests**: its local default CGI 0.5.2 had left an empty CHECKSUMS entry; Linux's frozen bundle install requires the registry checksum. WORK-20261018-03 regenerates it with `bundle lock --add-checksums`; no version or runtime code changes. Frozen Ruby 4 local dependency verification passes.

[Docs 39117565347](https://github.com/yorzi/rails_tool_views/actions/runs/39117565347) built and deployed successfully. The custom domain serves HTTP 200. HTTPS certificate issuance is still pending, so HTTPS is not claimed yet and no certificate-validation bypass is used.

### Successful publication — WORK-20261018-04

- Candidate/tag commit: `f2d4303224f7a1bb07e793d930c67a6d0712358a`; annotated tag `v0.1.0`. No published tag was moved.
- [Main CI 39117732144](https://github.com/yorzi/rails_tool_views/actions/runs/39117732144) and [Docs 39117732147](https://github.com/yorzi/rails_tool_views/actions/runs/39117732147): SUCCESS.
- [Release 39117821018](https://github.com/yorzi/rails_tool_views/actions/runs/39117821018): SUCCESS. Three SQLite combinations and PostgreSQL each ran 89 tests / 723 assertions; optional adapter ran 7 / 45. Exact-tag package inspection, six lockfile audits, isolated install/activated dependency audit and versioned docs all passed. The double build checked 2,152 links, zero broken.
- [RubyGems 0.1.0](https://rubygems.org/gems/rails_tool_views/versions/0.1.0): version, MIT, source/docs URLs, MFA-required and MFA-published confirmed. Its UI identifies GitHub Actions `yorzi/rails_tool_views @ .github/workflows/release.yml (release)` as publisher. No long-lived key used.
- [GitHub Release](https://github.com/yorzi/rails_tool_views/releases/tag/v0.1.0): published 2026-10-18 18:08:25 Asia/Shanghai, with gem and SHA256SUMS.
- RubyGems API checksum, downloaded registry gem, downloaded GitHub gem and SHA256SUMS all agree:

```text
85e3a516cc20700969edbf474d90e9e20c322334d942735882eabc699d95b166
```

The separate CI verification artifact has SHA-256 `33fab2b131e43baf55d736f7b67854eb29d6a56a39f6fee6b05b9bfb2d1b5a22`. Its tar timestamps are `1792317933`; the publication rebuild's are `1792318061`. All 25 extracted files match byte for byte, and gemspec YAML, dependency requirements, author/license/version/URL contracts match. The release asset and registry artifact are byte-identical; no cross-job reproducible-binary claim is made.

- [Post-release Docs 39118079958](https://github.com/yorzi/rails_tool_views/actions/runs/39118079958): SUCCESS, triggered by successful Release Gem completion.
- HTTPS 200 confirmed for `/`, `/getting-started/`, `/next/`, `/next/getting-started/`, `/api/`, `/api/RailsToolViews.md`, `/llms.txt`, `/llms-full.txt`, `/next/llms.txt` and `/sitemap.xml`. Stable shows `0.1.0 (stable)` and the version install command; next uses `--git ... --branch main`.
- Browser confirmed search results for `idempotency` and navigation from the version menu to Next and back. The homepage renders without an error.
- Pages API: `cname=rails-tool-views.wangyaodi.com`, `build_type=workflow`, `https_enforced=true`. HTTP returns 301 to HTTPS; certificate verification succeeds. Private vulnerability reporting API returns `enabled=true`.
- No temporary server, watcher, tunnel or background service was started. Isolated installer processes finished and their temporary directories were removed.

Open formal/security/provider/MySQL/adoption gaps above remain open after release.
