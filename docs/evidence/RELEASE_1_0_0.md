# 1.0.0 verified public delivery

Date: 2026-10-26. The owner asked to release the new version and update the docs and site, and chose 1.0.0 stable with an explicit exception over `1.0.0.rc1` (SPEC_BASELINE, DELTA-008). WORK-20261026-01 prepared the release; WORK-02 records the observed outcome.

## Immutable identity

- [RubyGems rails_tool_views 1.0.0](https://rubygems.org/gems/rails_tool_views/versions/1.0.0); the latest-version API reports `1.0.0`, MFA required, documentation and source URIs set.
- Annotated [v1.0.0](https://github.com/yorzi/rails_tool_views/releases/tag/v1.0.0) points to `5ded407d355f126f48b8327e85de64f83c47b8e8`.
- GitHub Release "RailsToolViews v1.0.0" published at `2026-10-26T01:46:22Z`; neither draft nor prerelease, and the repository's latest release is `v1.0.0`.
- Published SHA-256: `c71a31c88099cd851ffa4adbe3bbed811c137de72e987a3b0e0d11d916ec5df8`. The RubyGems API SHA, a direct registry download, the GitHub gem asset and SHA256SUMS agree.
- All 35 package files are byte-identical to the locally tested preparation build (`eea95020f4e2f61c1b921beca9df47f568bb33cdbb0871b29814af846ee79bca`); only build timestamps differ, so binary reproducibility is not claimed.

Previous tags stay immutable; no `v1.0.0.rc1` tag exists. No DNS, permission or credential change was needed; the existing OIDC publisher and `release` environment were reused.

## Exact remote runs

| Run | Observed result |
| --- | --- |
| [Base CI 40254474230](https://github.com/yorzi/rails_tool_views/actions/runs/40254474230) / [Docs 40254474364](https://github.com/yorzi/rails_tool_views/actions/runs/40254474364) | PASS on owner-pushed 8be445d |
| [Candidate CI 40255325539](https://github.com/yorzi/rails_tool_views/actions/runs/40255325539) | PASS on 5ded407 before tag: core Ruby 3.3/Rails 8.1, Ruby 3.3/Rails 7.2, Ruby 4.0, PostgreSQL, browser, adapter |
| [Candidate Docs 40255325572](https://github.com/yorzi/rails_tool_views/actions/runs/40255325572) | PASS before tag |
| [Tag CI 40255472016](https://github.com/yorzi/rails_tool_views/actions/runs/40255472016) | PASS on v1.0.0 |
| [Release 40255472062](https://github.com/yorzi/rails_tool_views/actions/runs/40255472062) | All eight jobs PASS: exact-tag compatibility, package/advisories/isolated install/docs, OIDC publication and GitHub Release |
| [Post-release Pages 40255852479](https://github.com/yorzi/rails_tool_views/actions/runs/40255852479) | build and deploy PASS |

Release logs show three SQLite combinations each **144 tests / 1254 assertions**, PostgreSQL **148 / 1274**, adapter **7 / 45**, Chrome **9 / 81**, with zero failures, errors or skips. Each core combination passes the installed-gem host with both renderers (1 / 2), executable guides, and separate-process upgrades from immutable 0.1.0, 0.2.0, 0.3.0 and 0.4.0 (five action graphs each; reconciliation, purge and business preservation). The package job passes the 35-file formal gate, seven clean lockfile audits and the activated-dependency audit at advisory commit `03da937a9e171e3fedebde6620e203559b7a60c0`, and builds v1.0.0 at `/`, the working tree at `/next/` and v0.4.0 at `/v0/` with **5,119 links**, zero broken.

## Published artifact and hosted acceptance

`gem install rails_tool_views -v 1.0.0` into an empty GEM_HOME outside Bundler resolves 57 gems from RubyGems and loads 1.0.0 with Rails 8.1.4 and without `ruby_llm`. The full installed-host workflow on the identical artifact is the release job's isolated install above.

After Pages deployed, 17 HTTPS entries return 200: root, Getting Started, What's New in 1.0, Upgrading, Public Contract, Release History, API, llms.txt, llms-full.txt, search, sitemap, `/next/`, `/next/getting-started/`, `/next/llms.txt`, `/v0/`, `/v0/getting-started/` and `/v0/api/`. Stable names 1.0.0 and installs `--version 1.0.0`; `/next/` installs from `main`; `/v0/` names 0.4.0 with its own canonical URL. Release History links v1.0.0. HTTP redirects to HTTPS, Pages enforces HTTPS on the custom domain, and internal record paths return 404.

## Exception and evidence boundaries

The owner waived, not met, ROADMAP condition 5 (three external setup trials, the measured bespoke-Rails comparison, two weeks of non-dummy use) and condition 6's independent security review and formal H2/C/R disposition (DELTA-008). rc1 and its observation window were skipped. MySQL stays excluded, the RubyLLM adapter stays experimental, and no live provider call or external contact took place. The public contract is now a Semantic Versioning promise; later adoption or review findings ship as 1.x fixes, or wait for a planned major if they need a contract change.

The dev-lockfile `crass` bump to 1.0.8 (GHSA-pq4g-8rxf-4g29) is not a runtime or gemspec dependency. Upgrading from 0.4 needs no migration; see [Upgrading](https://rails-tool-views.wangyaodi.com/upgrading/). No local server was started; scratch clones, downloads and the temporary GEM_HOME were removed.
