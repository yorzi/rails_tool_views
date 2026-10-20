# 0.4.0 verified public delivery

Date: 2026-10-20. Owner explicitly authorizes remote CI, release acceptance, documentation and publication. WORK-20261020-05 prepares the release; WORK-06 records the observed outcome.

## Immutable identity

- [RubyGems rails_tool_views 0.4.0](https://rubygems.org/gems/rails_tool_views/versions/0.4.0).
- Annotated [v0.4.0](https://github.com/yorzi/rails_tool_views/releases/tag/v0.4.0) points to `e93f8df20813335d66b34027a91637cb01d9d597`.
- GitHub Release published at `2026-10-20T02:48:40Z`; neither draft nor prerelease.
- Published SHA-256: `7efc0b470a60aec8526cb110066ae308aace2d9793c620a4c3e858b561d3f627`.
- RubyGems API SHA, direct registry download, standard `gem fetch`, GitHub gem asset/digest and SHA256SUMS agree.
- All 35 package files are byte-identical to the tested preparation artifact (`2231ea7a17f3ebd260302c12f4d80e9d7b6aa1386f37979c9cbd86462a35ed80`). Normalized identity/Ruby requirement/licenses/authors/metadata/runtime dependency contracts agree. Build timestamps and serialization differ; cross-job binary reproducibility is not claimed.

Previous public tags remain immutable. No DNS, permission or persistent credential change was required; existing scoped RubyGems OIDC publisher and release environment were reused.

## Exact remote runs

| Run | Observed result |
| --- | --- |
| [Candidate CI 39360489574](https://github.com/yorzi/rails_tool_views/actions/runs/39360489574) | PASS on e93f8df before tag |
| [Candidate Docs 39360489799](https://github.com/yorzi/rails_tool_views/actions/runs/39360489799) | PASS before tag; stable0.3/next |
| [Tag CI 39360617577](https://github.com/yorzi/rails_tool_views/actions/runs/39360617577) | PASS on v0.4.0 |
| [Release 39360617626](https://github.com/yorzi/rails_tool_views/actions/runs/39360617626) | All eight jobs PASS: exact-tag compatibility, package/advisories/isolated host/docs, OIDC and GitHub Release |
| [Post-release Pages 39360929392](https://github.com/yorzi/rails_tool_views/actions/runs/39360929392) | PASS; stable0.4/next deployed |

Release logs confirm three Ruby/Rails SQLite combinations each **129 tests / 1129 assertions**, PostgreSQL **132 / 1145**, optional adapter **7 / 45**, Chrome **8 / 77**; zero failures/errors/skips. Each core combination verifies the actual installed gem/generated Minitest **1 / 2**, executable guides, and separate-process upgrades from immutable v0.2.0 and v0.3.0. Five action graphs per old version preserve receipts/correlation/business records;0.3 adds closed/purged lifecycle guards. PostgreSQL exercises competing claims, stale acknowledgments, cleanup workers and action/closure serialization.

The package job passes the 35-file formal gate, seven lockfile audits, empty GEM_HOME network installation/full Rails host/activated dependency audit, and stable0.4/next build with **3,102 links**, zero broken. Advisory snapshot `fa2295251efb3b0d1a300e5ce8ad700ff1f1b485`,1266 advisories. Local post-tag22-guide lint has zero errors/warnings. Full implementation tests, initial failures and local matrix are in [V0_4_VALIDATION](V0_4_VALIDATION.md).

GitHub emits non-blocking action Node-runtime and ubuntu-latest image migration annotations; all jobs pass. No workflow expansion was made for those platform notices.

## Published artifact and hosted acceptance

The downloaded registry gem is installed again outside Bundler into an empty GEM_HOME with network-resolved dependencies. It passes actual Rails migration/rendering/HTTP JSON/Turbo/HTML/validation/replay/restore, transaction rejection and durable host retry, lifecycle/retention/business preservation, generated test1/2 and eager load. Activated dependencies audit clean. The frozen input hash is the published SHA above, not a rebuilt local gem.

RubyGems initially returned404 immediately after upload; a later API read, direct download and standard client fetch succeed. No artifact was accepted from that failed first read. The browser confirms0.4.0 latest, MIT, required MFA, published-with-MFA and `GitHub Actions yorzi/rails_tool_views @ .github/workflows/release.yml (release)`.

After Pages succeeds, **18 HTTPS entries** return200: root, Getting Started, feedback, diagnostics, continuation, upgrading, What's New0.4, history, API index/module, llms/llms-full, sitemap/search, and next Getting Started/feedback/diagnostics/search. Stable install names0.4.0; next uses main. Both search indexes include feedback/diagnostics; API exposes Transition, Upgrading includes DELIVERY_IN_TRANSACTION, root canonical is correct, HTTP redirects to HTTPS, and sitemap excludes internal records.

Real Chrome confirms the stable0.4 installation command, searches “temporary feedback”, opens the matching guide and switches through the version menu to Next with the main-branch command. The DevTools connection initially reported an occupied browser profile; the existing Chrome extension completed these checks. The task-created verification tab is closed; user tabs were not altered.

Downloads, API/run metadata and hosted checks are in ignored `tmp/release-verification-0.4.0/`; raw `/tmp/rtv040-*.log` files are ephemeral. The run URLs above retain remote evidence. The delivery-record commit has its own CI/Docs checked after push and reported in the final handoff, without inventing a future result here.

## Upgrade and evidence boundaries

From0.3 there is no new migration or runtime dependency. Stop and drain old web processes and delivery workers before switching; old callbacks lack the attempt acknowledgment fence. Call delivery after host commit. The fence protects Engine state; host durable deduplication/outbox and current authorization remain necessary, and historical uncertainty stays quarantined. Older hosts first follow the0.3 migration guide. See [Upgrading](https://rails-tool-views.wangyaodi.com/upgrading/).

`action.executed` retains its name and adds replayed:false/true. Optional notice leaves Surface state/snapshots unchanged, but receipts retain it for exact replay; existing persistent state.message remains compatible. Ordinary handled logs omit exception messages; host Rails.error still receives the original exception and needs host privacy controls.

No host production migration, provider call or external contact occurred. Formal H2/C/R, independent security/full accessibility review, MySQL, live providers, external setup trials and measured adoption remain open. Release success does not establish1.0 readiness. No local server was started; isolated/compare temporary directories were removed and task watchers ended. No next iteration starts automatically.
