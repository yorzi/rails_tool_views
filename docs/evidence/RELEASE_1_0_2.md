# 1.0.2 verified public delivery

Date: 2026-10-30. The owner asked to verify the rails_tool_views findings recorded by the rails_ai_admin consumer, address the real ones and release 1.0.2 (SPEC_BASELINE, 2026-10-30). WORK-20261030-01 fixed the installer and documented the shared runtime; WORK-02 prepared the candidate; WORK-03 records the observed outcome.

## Findings

| Consumer record | Verdict | 1.0.2 outcome |
| --- | --- | --- |
| DEP-006: installer duplicates an existing named mount | Reproduced on the source checkout. A host that keeps `:rails_tool_views` under its own path, as Getting Started recommends, gets a second mount with the same name and its routes fail to load. | `rails_tool_views:install` skips the route when `config/routes.rb` already mounts the Engine and says so. Four installer tests, each part checked by reverting it. |
| DEP-001: process-wide configuration, registry and route proxy | Not a defect. One configuration, registry and `:rails_tool_views` mount per process is the documented 1.0 design; the consumer's record also says a singleton alone is not an upstream bug. | Configuration's "Share One Runtime" explains the rule and what a gem should leave to the host. Separate runtimes are listed in ROADMAP as an owner decision; no contract change. |

## Immutable identity

- [RubyGems rails_tool_views 1.0.2](https://rubygems.org/gems/rails_tool_views/versions/1.0.2); the latest-version API reports `1.0.2`, MFA required, documentation and source URIs set.
- Annotated [v1.0.2](https://github.com/yorzi/rails_tool_views/releases/tag/v1.0.2) points to `1964ed5d5569ac3472fa47f430da0835c8ec8476`, the `main` commit whose CI passed before tagging.
- GitHub Release "RailsToolViews v1.0.2" published at `2026-10-30T00:10:35Z`; neither draft nor prerelease, and the repository's latest release is `v1.0.2`.
- Published SHA-256: `3d169601f62005fff6e510b604e377585edc308b31c92a4df6cc21b3a0789d50`. The RubyGems API SHA, a direct registry download, the GitHub gem asset and SHA256SUMS agree.
- All 35 package files are byte-identical to the local candidate build (`066babf2f80fd16a9d22b9601e01ac3d4f15173a0e41266578421d3c83d187f8`); only build timestamps differ, so binary reproducibility is not claimed.

Previous tags stay immutable. No DNS, permission or credential change was needed; the existing OIDC publisher and `release` environment were reused.

## Exact remote runs

| Run | Observed result |
| --- | --- |
| [Candidate CI 40977195850](https://github.com/yorzi/rails_tool_views/actions/runs/40977195850) | PASS on 1964ed5 before tag, all seven jobs: core Ruby 3.3/Rails 8.1, Ruby 3.3/Rails 7.2, Ruby 4.0, PostgreSQL, browser, adapter on RubyLLM 2.1.0 and on 2.0.0 |
| [Candidate Docs 40977195868](https://github.com/yorzi/rails_tool_views/actions/runs/40977195868) | PASS before tag |
| [Tag CI 40977410022](https://github.com/yorzi/rails_tool_views/actions/runs/40977410022) | PASS on v1.0.2 |
| [Release 40977410069](https://github.com/yorzi/rails_tool_views/actions/runs/40977410069) | All nine jobs PASS: exact-tag compatibility (seven jobs), package/advisories/isolated install/docs, OIDC publication and GitHub Release |
| [Post-release Pages 40978013823](https://github.com/yorzi/rails_tool_views/actions/runs/40978013823) | build and deploy PASS |

The local matrix on the candidate (Acceptance Matrix, WORK-20261030-02) passed the same suites, plus upgrades from immutable 0.1.0 through 1.0.1 and a versioned docs build with 5,137 links and none broken.

## Published artifact and hosted acceptance

`gem install rails_tool_views -v 1.0.2` into an empty GEM_HOME outside Bundler installs 57 gems from RubyGems and loads 1.0.2 and its installer with Rails 8.1.4 and without `ruby_llm`.

After Pages deployed, 20 HTTPS entries return 200: root, Getting Started, What's New in 1.0, Upgrading, Public Contract, Release History, Configuration, RubyLLM Integration, Demo Workbench, API, llms.txt, llms-full.txt, search.json, sitemap, `/next/`, `/next/getting-started/`, `/next/llms.txt`, `/v0/`, `/v0/getting-started/` and `/v0/api/`. Stable installs `--version 1.0.2`; Getting Started states that the installer leaves an existing mount alone; Configuration carries "Share One Runtime"; What's New carries "Rerun the Installer in 1.0.2"; Release History links v1.0.2. `/next/` installs from `main`; `/v0/` names 0.4.0 with its own canonical URL. HTTP redirects to HTTPS and internal record paths return 404.

## Evidence boundaries

DELTA-008's exception still stands: ROADMAP condition 5 and condition 6's independent security review and formal disposition are waived, not met. The RubyLLM adapter stays experimental; no live provider call or external contact took place, and nothing was posted to the consumer's repository. MySQL stays excluded. 1.0.2 needs no migration. Download directories and the temporary GEM_HOME were removed, and no local server was started for publication.
