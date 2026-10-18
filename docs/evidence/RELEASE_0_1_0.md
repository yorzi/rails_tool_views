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

Exact-commit remote CI, RubyGems upload, GitHub Release assets, stable/next Pages deployment and HTTPS enforcement are verified separately below when completed. No publication success is inferred from local checks.

## Remaining evidence gaps

No live AI provider call or external customer contact. No real MySQL migration, independent security review, external setup/adoption trial or formal H2/C/R was completed by this work. The published package and documentation must retain those limits. No temporary preview service was started.

### Candidate 4f2d6fc: remote feedback

[CI 39117565282](https://github.com/yorzi/rails_tool_views/actions/runs/39117565282) passed Ruby 3.3 / Rails 8.1 and 7.2, optional adapter and PostgreSQL. Ruby 4 failed **before tests**: its local default CGI 0.5.2 had left an empty CHECKSUMS entry; Linux's frozen bundle install requires the registry checksum. WORK-20261018-03 regenerates it with `bundle lock --add-checksums`; no version or runtime code changes. Frozen Ruby 4 local dependency verification passes.

[Docs 39117565347](https://github.com/yorzi/rails_tool_views/actions/runs/39117565347) built and deployed successfully. The custom domain serves HTTP 200. HTTPS certificate issuance is still pending, so HTTPS is not claimed yet and no certificate-validation bypass is used.
