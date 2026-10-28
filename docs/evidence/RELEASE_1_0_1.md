# 1.0.1 verified public delivery

Date: 2026-10-28. The owner asked for a review of the post-1.0 audit and preparation of 1.0.1, then authorized the release and the matching documentation updates (SPEC_BASELINE, 2026-10-28). WORK-20261028-01 reviewed the audit and added RubyLLM 2.0.0 CI; WORK-02 prepared the candidate; WORK-03 records the observed outcome.

## Immutable identity

- [RubyGems rails_tool_views 1.0.1](https://rubygems.org/gems/rails_tool_views/versions/1.0.1); the latest-version API reports `1.0.1`, MFA required, documentation and source URIs set.
- Annotated [v1.0.1](https://github.com/yorzi/rails_tool_views/releases/tag/v1.0.1) points to `7f502842a06a5a13afe63d24b834fc874a7d76bd`, the commit `main` was fast-forwarded to before tagging.
- GitHub Release "RailsToolViews v1.0.1" published at `2026-10-28T01:35:39Z`; neither draft nor prerelease, and the repository's latest release is `v1.0.1`.
- Published SHA-256: `b35d792611e46e55b1be1b79898fab39445bebc7583d7e1e67ae7229468ada1e`. The RubyGems API SHA, a direct registry download, the GitHub gem asset and SHA256SUMS agree.
- All 35 package files are byte-identical to a local build of the same commit (`4846fbbbd63820de8abdf21999a1164a0e0e05dff0bd007810c602f30af6b98a`); only build timestamps differ, so binary reproducibility is not claimed.

Previous tags stay immutable. No DNS, permission or credential change was needed; the existing OIDC publisher and `release` environment were reused.

## Exact remote runs

| Run | Observed result |
| --- | --- |
| [Candidate CI 40615340900](https://github.com/yorzi/rails_tool_views/actions/runs/40615340900) | PASS on 7f50284 before tag, all seven jobs: core Ruby 3.3/Rails 8.1, Ruby 3.3/Rails 7.2, Ruby 4.0, PostgreSQL, browser, adapter on RubyLLM 2.1.0 and on 2.0.0 |
| [Candidate Docs 40615340842](https://github.com/yorzi/rails_tool_views/actions/runs/40615340842) | PASS before tag |
| [Tag CI 40615530643](https://github.com/yorzi/rails_tool_views/actions/runs/40615530643) | PASS on v1.0.1 |
| [Release 40615530715](https://github.com/yorzi/rails_tool_views/actions/runs/40615530715) | All nine jobs PASS: exact-tag compatibility (seven jobs), package/advisories/isolated install/docs, OIDC publication and GitHub Release |
| [Post-release Pages 40615978017](https://github.com/yorzi/rails_tool_views/actions/runs/40615978017) | build and deploy PASS |

The local matrix on the candidate (Acceptance Matrix, WORK-20261028-01..02) passed the same suites, plus upgrades from immutable 0.1.0, 0.2.0, 0.3.0, 0.4.0 and 1.0.0, and a versioned docs build with 5,127 links and none broken. The 1.0.1 change visible to hosts is the RubyLLM adapter's load-time floor, RubyLLM 2.0, which CI now exercises at 2.0.0 and 2.1.0.

## Published artifact and hosted acceptance

`gem install rails_tool_views -v 1.0.1` into an empty GEM_HOME outside Bundler installs 57 gems from RubyGems and loads 1.0.1 with Rails 8.1.4 and without `ruby_llm`.

After Pages deployed, 19 HTTPS entries return 200: root, Getting Started, What's New in 1.0, Upgrading, Public Contract, Release History, RubyLLM Integration, Demo Workbench, API, llms.txt, llms-full.txt, search.json, sitemap, `/next/`, `/next/getting-started/`, `/next/llms.txt`, `/v0/`, `/v0/getting-started/` and `/v0/api/`. Stable names 1.0.1 and installs `--version 1.0.1`; Upgrading carries "Update RubyLLM for 1.0.1"; the RubyLLM guide states the 2.0 floor and the tested 2.0.0 and 2.1.0. `/next/` installs from `main`; `/v0/` names 0.4.0 with its own canonical URL. Release History links v1.0.1. HTTP redirects to HTTPS, Pages enforces HTTPS on the custom domain, and internal record paths return 404.

## Evidence boundaries

DELTA-008's exception still stands: ROADMAP condition 5 and condition 6's independent security review and formal disposition are waived, not met. The RubyLLM adapter stays experimental; no live provider call or external contact took place. MySQL stays excluded. 1.0.1 needs no migration. Download directories and the temporary GEM_HOME were removed, and no local server was started for publication.
