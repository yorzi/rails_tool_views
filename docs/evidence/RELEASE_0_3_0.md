# 0.3.0 verified public delivery

Date: 2026-10-19. Owner explicitly authorizes publication, documentation and commits.
WORK-20261019-04 prepares the release; WORK-05 records the observed outcome.

## Immutable identity

- Gem: [rails_tool_views 0.3.0](https://rubygems.org/gems/rails_tool_views/versions/0.3.0).
- Annotated tag: [v0.3.0](https://github.com/yorzi/rails_tool_views/releases/tag/v0.3.0), commit `d12996ed2dc6a0dbf3d5041ac4d31da789789a9b`.
- GitHub Release published at `2026-10-19T09:26:18Z`; not a draft or prerelease.
- Published gem SHA-256: `01e004ba5deb2cba23d175a3d8110d1ed3cbbcc6c128cc9b735c0f380aed76a3`.
- RubyGems API SHA, direct registry gem download, standard `gem fetch`, GitHub gem asset and SHA256SUMS agree.
- All 35 package files are byte-identical to the tested release-preparation package. Normalized name/version/Ruby requirement/licenses/authors/metadata/runtime dependency contracts agree. Build timestamps/tool serialization differ; binary reproducibility across jobs is not claimed.

No published tag was moved or reused. Versions 0.1.0 and 0.2.0 remain unchanged.

## Exact remote runs

| Run | Result and scope |
| --- | --- |
| [Candidate CI 39229304949](https://github.com/yorzi/rails_tool_views/actions/runs/39229304949) | PASS on d12996e before tag |
| [Candidate Docs 39229304982](https://github.com/yorzi/rails_tool_views/actions/runs/39229304982) | PASS before tag, stable0.2/next |
| [Tag CI 39229612275](https://github.com/yorzi/rails_tool_views/actions/runs/39229612275) | PASS on v0.3.0 |
| [Release 39229612284](https://github.com/yorzi/rails_tool_views/actions/runs/39229612284) | All eight jobs PASS; exact-tag compatibility, package/audits/isolated host/docs, then OIDC and GitHub Release |
| [Post-release Pages 39230070227](https://github.com/yorzi/rails_tool_views/actions/runs/39230070227) | PASS; stable0.3/next deployed |

Release logs confirm three Ruby/Rails SQLite combinations each **114 tests / 988 assertions**, PostgreSQL **116 / 1000**, adapter **7 / 45**, Chrome **5 / 40**. All have zero failures/errors/skips. Each core combination passes the real v0.2 old-runtime/new-runtime migration fixture, package host and generated Minitest **1 / 2**. The upgrade verifies receipt/correlation preservation, conservative backfill, rollback guards, cleanup and host business preservation. PostgreSQL includes actual competing cleanup workers and action/closure serialization.

The package job passes the 35-file formal release gate, all seven dependency lock audits, empty GEM_HOME network resolution/full installed host/activated dependency audit, and stable0.3/next build with **2,692 links**, zero broken. Advisory snapshot `fa2295251efb3b0d1a300e5ce8ad700ff1f1b485`. See [local implementation evidence](V0_3_VALIDATION.md) for tests, prior failures and exact behavior boundaries.

## Registry and hosted verification

The public RubyGems version page shows MIT, required MFA, publication with MFA and `GitHub Actions yorzi/rails_tool_views @ .github/workflows/release.yml (release)`. Public metadata points to the repository, bug tracker, changelog and documentation. Existing publisher/environment were reused; no persistent token or additional grant was introduced.

After successful Pages deployment, 16 HTTPS entries return 200: root, Getting Started, lifecycle, upgrading, What's New0.3, release history, API index/class/Markdown, llms/llms-full, sitemap/search and next Getting Started/lifecycle/search. Stable installation specifies **0.3.0**; next uses the main branch. Stable and next search each index the correct lifecycle URL. API contains purge_closed, upgrading contains the standard migration task, canonical root is correct, HTTP redirects to HTTPS, and sitemap excludes agent/Specs records.

In real Chrome, the RubyGems version/publisher/MFA page is observed. Stable Getting Started displays 0.3.0; search opens Surface Lifecycle; the version menu switches to Next. No DNS or access policy was changed. The browser verification tab is closed after inspection.

Downloaded gems, public API/run metadata and hosted checks are retained in ignored `tmp/release-verification-0.3.0/`. Raw logs under `/tmp/rtv030-*.log` are ephemeral; authoritative run URLs above retain remote evidence. The final delivery-record commit gets its own CI/Docs run after pushing; those results are verified in the final handoff, without claiming a future result inside this record.

## Operating boundary

0.3 adds a lifecycle migration and JSON snapshot fields. Existing hosts stop old web/workers, take a complete backup and run `bin/rails railties:install:migrations FROM=rails_tool_views`, then `bin/rails db:migrate`. Do not mix old writers or downgrade after lifecycle use. The installer is for new hosts. Read the published [Upgrading guide](https://rails-tool-views.wangyaodi.com/upgrading/) and [Surface Lifecycle guide](https://rails-tool-views.wangyaodi.com/lifecycle/).

Cleanup stays opt-in and defaults to preview. Pending/failed work requires explicit abandonment; delivering and historically uncertain work remains protected. Surface/Presentation metadata preserves replay guards. This is payload cleanup, not full erasure, remote cancellation, disk compaction or exactly-once delivery recovery. Host business data, backups/logs and opaque metadata policy remain host-owned.

No new runtime dependency, notification, provider call, permission, DNS change or host production migration occurred during publication. Formal H2/C/R, independent security/full accessibility review, MySQL, live provider behavior and external adoption remain open. 0.4 is not automatically started. No local preview server or long-lived process was started; release/Docs watchers finish with their runs.
