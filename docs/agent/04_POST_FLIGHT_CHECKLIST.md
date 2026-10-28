# Post-flight record — WORK-20261013-01

2026-10-13. Result: AUDIT_HARDENING_LOCAL_COMPLETE / COMMITTED_LOCAL / UNPUSHED / UNPUBLISHED / HUMAN_REVIEW_PENDING.

- [x] Six defects reproduced, fixed and covered: open nested schemas, host-wide log redaction, swallowed renderer and adapter failures, unwordable host codes with demo leakage in core, zero-argument form posts, and an order-dependent test that made earlier green runs depend on seed.
- [x] Each fix has tests that fail when that fix alone is reverted to 3635c54.
- [x] Adoption work added on the owner's second request: three form helpers, tolerated Rails submit names, ViewComponent context, two configuration options, redirect back without Turbo, rollback mapped to CONFLICT. Each has a test that fails when the change is broken.
- [x] PostgreSQL 17.11 on a task-owned loopback instance: full suite, five seeds, eager load, demo over HTTP. Instance stopped and its data directory removed.
- [x] No migration, new table or runtime dependency; `pg` is a development gemfile only. Authorization, transaction, replay and transport behavior unchanged; all 60 earlier tests still pass, two with assertions rewritten from the global filter list to observed log output and one CSRF test's setup narrowed to its own controller.
- [x] Privacy re-verified from real output: Engine request parameters, SQL binds and `#inspect` redacted; host parameters and columns named `state`/`result`/`arguments` visible; notifications metadata-only.
- [x] Full suite and eager load on the three local combinations, each also across fixed seeds; optional adapter suite; packaged install on all three. Details: ../evidence/AUDIT_VALIDATION.md.
- [x] Real demo driven over HTTP with cookies and CSRF, and once in a browser for the Stimulus change.
- [x] ADR 003 and 004, README, SECURITY, CHANGELOG, acceptance rows, runbook, release checklist and human docs updated; one ledger section added.
- [x] Task-owned demo server stopped twice; port 3100 has no listener; browser tab closed.
- [x] Commit: one local commit on main with `Work-ID: WORK-20261013-01`, requested by Andy on 2026-10-13 after both summaries. Staged ledger linkage and whitespace were checked first. No remote is configured; nothing was pushed. Both rounds are one commit because they change the same files and only the final tree was verified as a whole.

Alignment: IMPLEMENTATION_BUG repairs plus ADR-recorded technical choices. No baseline edit, formal gate, license, push, publication, provider call or external contact. MySQL, remote CI and a full accessibility audit remain NOT_RUN; PostgreSQL is LOCAL only. Open findings that were not implemented are listed in ../human/01_PROJECT_STATUS.md.

## WORK-20261016-01 — rename verification

- [x] Owner-authorized RailsToolViews identity implemented with old constant/requires/helpers/mount compatibility and stable persisted identifiers.
- [x] 83 tests / 665 assertions and eager load on three local Ruby/Rails combinations; six optional-adapter tests; built-gem fresh-host install; actual old-code/new-code database replay PASS. See RENAME_VALIDATION.
- [x] No migration, dependency coupling, provider call or authentication/policy change. Original Specs snapshot unchanged (59 exact matches).
- [x] README upgrade steps, ADR 005, Spec supplement/DELTA-003, acceptance, status, operations and ledger updated. Runtime flow is unchanged; no diagram rewrite needed.
- [x] No task-owned long-lived processes started; temporary package and upgrade probes cleaned up automatically.
- [x] Ledger-linked implementation commit 7e73e4e pushed to owner-approved private `yorzi/rails_tool_views`; remote SHA and PRIVATE visibility verified. No gem release or formal gate approval claimed. Remote CI was queued when checked.

## WORK-20261016-03 — documentation site

Local draft complete. Four collections and 14 pages plus homepage; generated Ruby API, Markdown and llms output. Style check: zero errors/warnings. Build, tutorial core/adapter examples, 83-test regression with 665 assertions, eager load and generated local link checks pass. Browser search, guide navigation, API entry, narrow layout and light/dark mode checked. No deployment, data migration or runtime behavior change. Source comments/CI doc checks added. Existing internal records and Specs excluded. Temporary Jekyll PID 53838 on 127.0.0.1:4000 stopped; browser tab closed. Exact evidence and limits: evidence/DOCS_VALIDATION.md.

Submission follow-up: owner explicitly requested commit/push and local folder rename. Keep Pages disabled and repository private. Prior remote CI passed. Source-only PR paths and missing-build detection tightened before this ledger-linked submission.

## WORK-20261016-04 — demo showcase

README shortened to adoption/demo/docs entry points. Shared responsive workbench shell, page-specific guidance, role-aware navigation, context panel, ticket inbox/detail and empty states added to the dummy host. Search query retained on ticket selection. No core API, schema, migration, policy or fixture changes. Regression: 83 tests / 665 assertions and eager load pass. Docs: 15 guides, zero lint warnings/errors, build and 1,075 local links pass. Browser checks cover saved selection, validation recovery, local reply queue, version acceptance/export availability and tenant switch; physical mobile/full accessibility audit not run. See evidence/DEMO_SHOWCASE_VALIDATION.md. Human changelog and acceptance updated; architecture/runtime diagrams unchanged because authority and transitions are unchanged. Loopback demo PID 59386 on port 3197 stopped; temporary browser tab closed. Existing app on 3100 untouched. Implementation-aligned presentation change, no Spec delta. Submission follows the owner's existing commit/push authorization; repository remains private, publication disabled.

## WORK-20261017-02 — review and audit hardening

Base `a1a9b26`. Owner asked in this session for a full review and audit and for real problems to be fixed.

- [x] Defect 1 reproduced from the migration: the presentation's five-column unique index on unbounded `varchar(255)` needs 5100 bytes under utf8mb4 and would not create on MySQL/InnoDB. Identifier columns now carry `limit: 150`; the widest index needs 3000 bytes.
- [x] Defect 2 fixed: identity lookups now confirm a byte-exact match, so a non-binary collation cannot resolve another actor's or tenant's Surface, another correlation's presentation, another action receipt or another idempotency key.
- [x] `Data.identifier` caps stored, indexed identifiers at 150 bytes; `Data.reference` keeps 255 for descriptions and versions.
- [x] Every fix has a test that fails when that fix alone is reverted: three collation tests, the adapter receipt guard and the 5100-byte index-width assertion. The `registry_test` cap assertions fail if the bound is widened.
- [x] Full suite 88 tests / 702 assertions and eager load pass on SQLite and on a fresh PostgreSQL 17.11 schema; adapter suite 7 tests / 45 assertions; packaged install, docs examples, docs build, 1,075 local links and 15-guide style check all pass.
- [x] No new table, column or dependency. No data migration; existing host columns stay and the bound is enforced in code. Behavior change recorded in the upgrade guide: identifiers longer than 150 bytes are now rejected.
- [x] Docs updated: CHANGELOG, production/upgrading/whats-new guides, runbook, acceptance addendum, current work, human status and changelog. New evidence file AUDIT_V2_VALIDATION.md. Architecture and flow unchanged; no diagram rewrite.
- [x] Uncommitted recommendation for the owner: a distinct `action.replayed` event would change the notification catalog the pinned specification lists, so it is not implemented here.
- [x] Committed on main with `Work-ID: WORK-20261017-02`; not pushed (owner did not ask). No long-lived process started.

Boundaries: MySQL NOT_RUN (proven by column introspection and arithmetic), no live provider, browser, remote CI or assistive-technology run. Local-only evidence. See ../evidence/AUDIT_V2_VALIDATION.md.

## WORK-20261018-02 — release preparation

- [x] Owner authorizations, MIT/security reporting, public-repository observation and DELTA-005 recorded.
- [x] Version/gem/docs/changelog/package agree on 0.1.0; 25 packaged files reviewed; no API/schema or business-data migration.
- [x] Three core compatibility combinations each 89/723, adapter 7/45, packaged host and runnable docs pass; all checks with the shared test database run sequentially.
- [x] Docs style/build and 1,042 links pass; internal records excluded. No preview service started.
- [x] Six dependency lock audits and a clean network-resolved installation plus activated/default-gem audit pass. Security findings repaired by patched dependency floors and Rails 7.2.3.2 test target.
- [x] Pages/domain/DNS, private security reporting and the scoped OIDC publisher configured and observed. No long-lived secret added.
- [x] Operations, status, acceptance, delta, evidence and human changelog updated; architecture/runtime diagrams unchanged because behavior is unchanged.
- [x] Exact-tag compatibility/PostgreSQL/package/advisory checks, gem publication, release assets, versioned hosted docs and HTTPS verified. WORK-20261018-04 records actual delivery in RELEASE_0_1_0.

## WORK-20261018-05 — documentation and proposed roadmap

- [x] README shortened from 90 to 34 lines; API/tutorial detail stays in the site. CONTRIBUTING and docs/README own developer commands and documentation responsibilities.
- [x] ROADMAP is the single proposed version plan: bounded 0.2/0.3/0.4, rc1 and 1.0 conditions. Future commands/APIs are marked proposed; runtime and public gem stay 0.1.0.
- [x] Stale release/license statements corrected in CONTRIBUTING and next Production guide. Site navigation links to GitHub ROADMAP without duplicating it. Stable docs remain the immutable tagged snapshot.
- [x] 32 local Markdown links checked, zero broken; 15 guide pages with zero style errors/warnings; executable tutorial examples PASS; stable/next build and 2,152 generated links PASS.
- [x] Whitespace check and staged ledger linkage required before commit. Runtime/adapter/database suites not rerun locally: no code, schema, dependency or API change.
- [x] Current status/work shortened; completed history remains in ledger/evidence/Git. No external Specs edits or new approved product-intent delta. Architecture/runtime diagrams unchanged because behavior is unchanged.
- [x] No migration or data/privacy/accessibility impact; no temporary server or background process started. Proposed security/lifecycle/telemetry work is not labelled implemented or approved.

## WORK-20261018-06 — agent verification foundation

- [x] 复用 dummy；真实 Chrome 三场景 18 assertions，移动端错误截图检查通过。CSRF 开启，只有 loopback 允许 TCP；Selenium 端口探测也限制 loopback。
- [x] core 89/723、eager load、adapter 7/45、docs examples、打包 host 与隔离 GEM_HOME full host + activated audit 通过。CI 已配置，尚未推送/远程运行。
- [x] 无 runtime API/schema/迁移；浏览器依赖独立 bundle。59 个 Specs 文件与 pinned revision 完全一致，未编辑。FR-07/08 测试基础，implementation aligned。
- [x] 更新操作手册、贡献说明、当前工作、状态、验收与 ledger。无运行时架构变化，无需改图。浏览器子进程退出，临时 host/数据库自动清理，无保留服务。

## WORK-20261018-07 — safe Partial generator

- [x] FR-01/02/08：组件/动作默认拒绝，两个闭合 schema；三文件脚手架。所有输出预检，非法名称/冲突/越界 symlink 不产生部分写入。64 字符与 core key 上限一致。
- [x] 先失败（命令不存在），再通过 3/46 聚焦测试；全套 92/769 与 eager load；实际打包 host 的默认拒绝、授权后 escaped render/HTTP mutation 与生成的 Minitest 1/2 通过。
- [x] 16 篇指南 lint 零错误/警告；新功能独立指南、components、What's New、upgrading 与安装模板更新。最终 docs build/matrix 留 WORK-09，不称已通过。
- [x] 无 migration/dependency/新业务功能，Specs 不改，implementation aligned；共享 reload hook 不互相清空，无隐式 agent exposure。状态、验收、ledger 更新；下一步 HTML。无长期进程。

## WORK-20261018-08 — complete HTML correction pages

- [x] FR-07：完整 HTML 文档、main/title/viewport/lang/CSRF；授权后纠错和安全 reload。拒绝身份不显示组件数据。修复纠正后 Referer 为 POST-only 路由导致 GET 404 的缺陷；JSON/Turbo/auth/status 不变。
- [x] 新 4 测试先失败；5 个 HTTP 测试共 66 assertions + core 全套 97/835/eager load PASS。Chrome 4/28 PASS，关闭 JavaScript 的实际表单 invalid → correction → refresh，390px CDP 移动模拟截图检查。无辅助技术完整审核。
- [x] 新 layout 无 host 实例变量/资源依赖，可通过 Rails view override 定制；guide、upgrading、What's New、flow 与 ADR 007 更新。无 schema/migration/dependency，implementation aligned，Specs 不改。
- [x] 验收/状态/ledger 更新。Chrome/driver/Puma 随测试退出，无保留进程。最终兼容性和文档构建留 WORK-09。

## WORK-20261018-09 — 0.2 local acceptance

- [x] VERSION、六份应用 lockfile path entries、docs 0.2.0 对齐；CHANGELOG/History 标明 unreleased，正式 release gate 拒绝该状态，candidate-only package check 通过。六份应用 lockfiles（含 root）加 docs/site 锁文件共七份被审计。
- [x] 三个 SQLite 兼容组合与 PostgreSQL 各 97 tests / 837 assertions、eager load；adapter 7/45、core/adapter docs examples PASS。实际 artifact host 在三个组合通过；生成 Minitest 各 1/2；空 GEM_HOME full host 和 activated audit PASS。
- [x] Chrome 4/28，真正禁用 JavaScript、390px 模拟、CSRF 和持久化；人工浏览器 Tab/Enter invalid → correction → refresh 复核，截图保留。无完整辅助技术/物理设备审核。
- [x] 七份 locks/advisory audit clean；16 guides zero errors，两条预期 unreleased/tag version warnings；stable+next 构建、2,210 links、内部内容排除 PASS。
- [x] 无 schema/migration/runtime dependency 新增。Specs 未编辑，implementation aligned。同步 baseline 授权、status/map/flow/roadmap、operations、evidence 与 ledger；current work 全部完成。
- [x] 临时 demo PID 51497 / 127.0.0.1:3198 停止并删除临时 SQLite；Chrome/driver/Puma 无遗留，临时 PG databases 已 drop；已有 PostgreSQL 服务未停止。无新推送/tag/上传/provider。

## WORK-20261018-10 — release candidate preparation

- [x] Owner explicitly authorizes 0.2 push/remote CI/publication. Refetched origin, v0.2.0 unused; existing release environment/private security reporting/Pages HTTPS confirmed.
- [x] Release dates/metadata, current/archived What's New, focused upgrading guide and navigation aligned. Public code/schema/dependencies unchanged; pinned Specs untouched.
- [x] Actual package host + generated Minitest, release package gate, docs examples, 17-guide lint (one expected pre-tag version warning), stable/next build/link/content checks PASS.
- [x] Exact candidate CI, tag/OIDC publication, registry/Release hash and hosted stable/next outcome now verified. Actual delivery is recorded in WORK-11; the preparation commit alone was not publication proof.
- [x] Ledger, status/authority/current work/release procedure updated; architecture unchanged. No temporary service.

## WORK-20261018-11 — verified 0.2 delivery

- [x] main/tag 3156fd3 remote CI/Docs/Release green; all tagged compatibility checks (97/837 × four, adapter 7/45, Chrome 4/28), isolated installation/audits/docs PASS.
- [x] RubyGems API/index/client actual download, GitHub gem/SHA256SUMS agree on 5fd6a193dd9e69be3277ef34ff63802118031c51fee95ddcf4952af46d307367; all 31 files and gemspec contract match local source. MFA and scoped OIDC publisher verified from the version page.
- [x] Release not draft/prerelease; post-release Pages successful; stable 0.2/next install commands, search/version menu, 15 HTTPS endpoints and redirect verified. Internal content remains excluded.
- [x] Status/map/roadmap/operations/acceptance/evidence/current work and ledger reflect delivery. No runtime/API/schema/migration/new dependency/DNS/security grant/provider/contact. Specs unchanged; architecture/runtime flow unchanged.
- [x] No temporary server; watchers finished, disposable client directory removed, browser tab closed. Downloaded evidence is retained in ignored tmp. This record's own post-push CI/Docs is checked after commit, without claiming future results inside it.

## WORK-20261019-01

- [x] owner 0.3 本地开发授权与 pre-flight，59 Specs pinned 文件比对相同。
- [x] lifecycle API/schema、专用 policy、旧回执/关闭视图、Surface-first delivery 锁与持久 uncertainty 测试通过；106/923 eager load，package host + generated Minitest 1/2。
- [x] ADR 008、public guide/What’s New/upgrading、human architecture/flow/map/status、验收同步；未修改 Specs，无新增通知契约。
- [x] 无长期服务；只本地提交，不推送/发布。完整 matrix/upgrade/清理/E2E 未完成，不提前宣称候选通过。

## WORK-20261019-02

- [x] scoped/cutoff/deadline/batch/deny 默认明确，保留 tombstone；跨身份、锁后再检查、rollback、stale action 和旧 correlation 测试通过。
- [x] core 114/988、installed package host 与 Chrome 5/40 PASS；截图检查到清理后业务日志仍在。
- [x] public guide/config/API/What’s New/changelog、ADR/human flow/architecture/acceptance/ledger 更新。旧数据迁移与完整 matrix 留下一单元。
- [x] browser/driver 随 runner 退出；无手动常驻服务，不推送/发布。

## WORK-20261019-03 — local 0.3 candidate

- [x] 三组 114/988、PG116/1000 与 eager load；adapter7/45；真实旧 runtime 三组升级与标准迁移/安全回退/拒绝危险降级/保留业务检查。
- [x] 三个实际 artifact host、空 GEM_HOME network full host + activated audit、七份 locks audit PASS；35-file candidate gate，formal gate 对 unreleased 正确拒绝。
- [x] Chrome5/40、两种 guide snippets、19-guide lint/build/2,571 links PASS；实际截图复查，CI matrix 接入 upgrade smoke。
- [x] 修复 Rails7.2 SQLite bool default；共享 SQLite 测试干扰后串行重跑，browser inspector 问题与原生 lifecycle 覆盖边界记录。
- [x] status/map/at-a-glance/changelog/roadmap/architecture/flow/operations/acceptance/evidence/current work 与 ledger 同步；Specs 不改。
- [x] 无保留 server/driver/Puma，临时 PG DB 已删，既有 PG 服务不动；本地提交，不推送/tag/发布/provider。

## WORK-20261019-04 — release preparation

- [x] owner明确发布/提交授权；既有release环境、Pages HTTPS/开关、public repo/private reporting复核。
- [x] date/released/version/history/What's New/upgrading与授权/operations同步，runtime冻结，59 Specs不变。
- [x] actual package host/generated1/2、正式package gate、guide code、19-guide lint/build/2,571links PASS。
- [x] staging/commit linkage与whitespace检查；remote CI/tag/registry/Pages实际结果留WORK-05。无本地服务，架构不变。

## WORK-20261019-05 — verified 0.3 delivery

- [x] main/tag/Release成功，三组114/988、PG116/1000、adapter7/45、Chrome5/40；真实upgrade/installed/isolated与七份锁/activated audit及2,692links通过。
- [x] registry API/direct/client/Release/checksum同SHA，35files相同，gemspec契约一致；MFA/限定publisher公开页核验。
- [x] Release非draft/prerelease；post-release Pages成功，stable0.3/next安装/搜索/导航/16 HTTPS入口与canonical/重定向确认。
- [x] status/map/at-a-glance/roadmap/operations/acceptance/ledger/evidence/current work同步；无runtime/API/schema/依赖/通知/权限/DNS变化，Specs不改，架构不变无需重画图。
- [x] 临时浏览器页已关闭，无本地server；workflow watchers结束，临时extract目录清理。最终交付记录的CI/Docs在提交推送后核验。

## WORK-20261020-01 — 0.4 recovery

- [x] 四个行为回归先在旧实现失败（覆盖新 claim、降级终态、外层事务仍调用 adapter），修复后4/30；host job/process recovery4/39。完整 core122/1057和eager load PASS。
- [x] 实际包临时Rails host、generated Minitest1/2 PASS；20 guides零错误，两条预期候选版本警告。完整matrix/PG/upgrade/browser在最终验收执行。
- [x] 复用 attempts 条件确认，无 schema/runtime依赖/新队列；不放宽权限、不清 uncertainty、不改通知catalog。新增事务拒绝见升级指南。
- [x] baseline/ADR009/current work/status/map/flow/runbook/What's New/history/upgrading/acceptance与本commit ledger同步；外部Specs59文件未改。临时包进程已结束，无手工服务。

## WORK-20261020-02 — diagnostics and browser feedback

- [x] Sentinel regression first exposes raw adapter secret in ordinary log, then passes with event/class only; Rails.error still receives the original exception. privacy8/67, core123/1063/eager load PASS.
- [x] Chrome6/61 on disposable loopback host: native keyboard submit/retry, aria-busy, disabled loading button, error/status focus,390px failure/recovery/refresh and one host reply/receipt; screenshots checked. Initial sandbox bind EPERM was rerun with approved execution. Browser/driver/Puma ended.
- [x] Diagnostic guide inventories actual existing events and limits, docs/upgrading/runbook/What's New updated.21 guides zero errors/two expected candidate warnings, stable0.3/next build and2,822links PASS.
- [x] No new event name/payload field/notice behavior/schema/dependency. Owner compatibility questions remain pending; this commit does not claim those parts of0.4 complete.

## WORK-20261020-03 — confirmed replay and notice compatibility

- [x] Owner choices recorded before implementation in DELTA-006/baseline/preflight. action.executed keeps its name and adds replayed; Transition.notice adds bounded plain-text feedback, preserving persistent message semantics.
- [x] Six feedback tests first fail on the old behavior, then6/65 PASS: deterministic receipt, no snapshot notice, metadata privacy, rollback on invalid/oversized notice, SafeBuffer escaping, JSON/Turbo/HTML-once/scope boundaries. Core129/1129/eager load PASS, Chrome8/77 PASS, screenshots checked.
- [x] Database rollback diagnostic omission reproduced then fixed using existing action.conflict code-only event; three rollback classes covered.
- [x] Built package host adds transaction guard/host receipt retry/notice check. Upgrade runner covers immutable0.2 and0.3, including old closed/purged guards. PostgreSQL competing fresh claims test added, prior126/1079 PASS after uncached reader correction; final expanded matrix belongs to WORK-04.
- [x]22-guide lint zero errors/two expected candidate warnings; stable0.3/next build/2,897links/internal exclusion PASS. New feedback guide, What's New/upgrading/API/diagnostics/runbook and human mental model sync. RDoc constant link corrected to generated anchor. No schema/dependency/queue; task-created browser processes ended.

## WORK-20261020-04 — 0.4 local acceptance

- [x] Final runtime6d90216: threeSQLite combinations129/1129/eager load, PG132/1145, adapter7/45, Chrome8/77 PASS; failure-first/visual evidence retained in V0_4_VALIDATION.
- [x] Actual0.2/0.3 separate-process upgrades and installed artifacts in allthree combinations PASS, including old lifecycle guards; final emptyGEM_HOME network/full host/activated audit PASS, SHA58fd80cc… unchanged afterward.
- [x] Seven lock audits clean at refreshedfa229525, candidate35-file gate PASS; formal gate refuses unreleased.22guides/build/2,897links/internal exclusions PASS; private helper heuristic reviewed rather than documented as public.
- [x] No schema/runtime dependency/queue or external Specs change. Upgrade docs clarify draining old web and worker callbacks. Current work/status/map/at-a-glance/implementation/roadmap/operations/acceptance/evidence/ledger updated. No new entity/flow requiring another diagram.
- [x] Browser/driver/Puma ended, temporary PG databases verified absent, isolated/upgrade/package tempdirs cleaned; pre-existing PG service retained. No credentials/provider/contact/push/tag/publication.
- [x] Local candidate complete and owner review next. Ledger linkage/clean tree verified with final commit; remote/hosted evidence remains NOT_RUN.

## WORK-20261020-05 — 0.4 release preparation

Owner-authorized publication scope recorded before changes. Date/released/history/What's New/upgrading and operations are aligned at0.4.0. Runtime unchanged from accepted6d90216; 59 Specs byte-identical to pinned0ea28b1. Final release metadata core129/1129/eager load, 35-file formal package gate, actual installed host/generated test1/2, executable core docs and empty GEM_HOME network/full host/activated audit PASS. Seven locks clean at fa229525; docs22guides zero errors/one expected pre-tag version warning, stable0.3/next build2897links/internal exclusion PASS. Impact helper warning reviewed: raise_action_conflict! is private/:nodoc; helper/render examples and upgrade/recovery/privacy/notice guides reviewed.

Local preparation artifact SHA2231ea7a17f3ebd260302c12f4d80e9d7b6aa1386f37979c9cbd86462a35ed80; this is not yet a published checksum. No new schema/dependency/permission/DNS/provider effect. No local server started; isolated temp host removed. Next: push candidate and require exact CI/Docs before tag; actual publication/hosted results belong in WORK-06, not a preemptive PASS here.

## WORK-20261020-06 — verified 0.4 public delivery

Exact immutable tag e93f8df main/tag compatibility, package/isolated/audits/docs and OIDC Release PASS; published registry/direct/client/Release checksums agree. Downloaded package's35 files and normalized contract equal tested preparation; empty GEM_HOME actual Rails host/generated1/2/activated audit passes again on the published hash. Pages39360929392 stable0.4/next,18HTTPS entries, real Chrome stable install/search/new guide/version menu PASS;22guides lint zero errors/warnings,3102 local links clean. See RELEASE_0_4_0 for exact run URLs/hash/first registry404/platform warnings/browser connection fallback and limits.

No new schema/dependency/provider/permission/DNS or host production migration. DELTA-006 and59 pinned Specs unchanged. Status/currentwork/roadmap/feature map/implementation/runbook/acceptance/evidence synchronized; no entity/architecture change needing new diagrams. Real user review: read upgrade/feedback/continuation guides and verify own host recovery. Independent review/adoption/provider/MySQL/formal evidence remains open. No local server started; isolated/extract directories removed, task-created browser tab closed and watchers complete. Next: commit/push record, verify its own CI/Docs and clean tree in final handoff; no new version work.

## WORK-20261021-01..07 — audit and 1.0 RC preparation

- [x] Each fix had a failing test first; affected guides, CHANGELOG and Upgrading changed with it. Stored digests are pinned and unchanged; real 0.1..0.4 data upgrades.
- [x] Full local matrix on the candidate recorded in RC1_READINESS with the Ruby 4 harness error and the pre-existing no-JS flake stated, not hidden.
- [x] Public contract declared; RubyLLM adapter experimental and MySQL excluded per ROADMAP defaults. No schema, dependency, queue or new public feature.
- [x] Browsers, drivers, Puma and the temporary PG database stopped/removed and verified; pre-existing PG service retained; scratch clones deleted. No push, tag, publication, provider call or contact.
- [x] Open: conditions 2/5/6 and owner decisions D1..D5. External pinned Specs unchanged.

## WORK-20261021-08..12 — rc1 lifecycle decisions

- [x] Decisions recorded before code (ADR 010, DELTA-007, authorization); each behavior change had a failing test first; key guards mutation-checked.
- [x] FR-06-AC-03 preserved (dispatch without an agent succeeds); lock order, callback isolation, attempt fence and default-deny kept; no schema, dependency or queue.
- [x] Public contract, lifecycle, continuation, diagnostics, configuration, Upgrading, What's New, CHANGELOG and readiness record updated; corrected a lifecycle example whose policy wrongly treated the owner scope as an operator.
- [x] Browsers, drivers, Puma and all temporary PostgreSQL databases stopped/removed and verified (0 remaining); pre-existing PG service retained. No push, tag, publication, provider call or contact.

## WORK-20261026-01 — 1.0.0 release preparation

- [x] Owner decision recorded before metadata changes: SPEC_BASELINE, DELTA-008, ROADMAP, release checklist, readiness record, Current Work and status. Conditions 5 and 6's review and formal disposition are waived, not reported as met.
- [x] Version, six path lockfiles, `released: true`, CHANGELOG 2026-10-26, release history, What's New, Upgrading and Public Contract name 1.0.0; candidate wording removed.
- [x] Local checks: core and Rails 7.2 each 144/1254 with eager load, adapter 7/45, package smoke (both renderers), upgrade smoke from 0.1.0..0.4.0, core and adapter docs examples, formal `RELEASE_PACKAGE_PASS` (35 files), empty GEM_HOME install and activated audit, docs build 3262 links with internal records excluded. Ruby 4 and PostgreSQL were not rerun locally; exact remote CI covers them before the tag.
- [x] `bundle-audit` found GHSA-pq4g-8rxf-4g29 in dev-lockfile `crass` 1.0.7; conservative bump to 1.0.8 in six lockfiles, then all seven clean at advisory 03da937a. Not a runtime or gemspec dependency, so no CHANGELOG entry.
- [x] Local build SHA-256 eea95020f4e2f61c1b921beca9df47f568bb33cdbb0871b29814af846ee79bca; not the published checksum. No server left running. Next: scratch-clone `v1.0.0` docs layout, push, exact main CI/Docs, then tag (WORK-02).

## WORK-20261026-02 — 1.0.0 delivery record

- [x] Exact candidate CI/Docs passed before the annotated tag; tag CI, all eight Release jobs and post-release Pages passed. Run URLs in RELEASE_1_0_0.
- [x] Published SHA-256 agrees across RubyGems API, download, GitHub asset and SHA256SUMS; 35 files identical to the tested build; empty GEM_HOME registry install loads without `ruby_llm`. GitHub Release is not a prerelease and is Latest.
- [x] Stable 1.0, `/next/` and `/v0/` serve over enforced HTTPS with the right install commands and canonicals; internal paths 404.
- [x] Exception boundaries stated in evidence, ROADMAP, status and acceptance. No server, provider call or external contact; scratch clones, downloads and temporary GEM_HOME removed.

## WORK-20261026-03..07 — post-1.0 audit, RubyLLM demo and roadmap

- [x] Every finding was reproduced before it was fixed: real RubyLLM 1.16.0 chat loop, real-clock demo cleanup, a generated Rails 8.1 importmap host with a no-pin control. New demo tests were mutation-checked (owner check, receipt check, tool attachment).
- [x] Public 1.0 contract unchanged except the adapter's load-time requirement, which affects only RubyLLM 1.x hosts, where the tool never worked; recorded in CHANGELOG (Unreleased), Upgrading, the RubyLLM guide and the Public Contract's experimental section.
- [x] No core schema, runtime dependency, migration or lockfile change. Demo tables and RubyLLM-dependent demo code stay in `test/dummy`; the gem package is unchanged in scope (app, config, db, lib).
- [x] Guides updated in the same commits as the behavior they describe: RubyLLM Integration, Demo Workbench, Getting Started, Upgrading, Public Contract, README, CONTRIBUTING. ROADMAP gains "After 1.0"; status, at-a-glance, feature map, architecture, human changelog, acceptance matrix, RE_ENTRY and Current Work reflect the result.
- [x] Not run for this work: Ruby 4, Rails 7.2, PostgreSQL, remote CI, live provider. The Selenium flake under Chrome 153 predates the work (base f741646 fails 3/3 full runs) and is recorded as a risk, not fixed.
- [x] Demo (3100) and verification host (3101) servers, browsers and drivers stopped and verified; scratch hosts and RubyLLM version bundles deleted. Pushed only to `claude/laughing-pasteur-p18ora`; no tag, publication, pull request, provider call or contact.

## WORK-20261028-01..02 — review and 1.0.1 candidate

- [x] Review findings reproduced before change: the Turn comment claim was checked with a temporary probe test (one saved Surface, zero messages), then the probe was deleted.
- [x] Public contract unchanged beyond the RubyLLM 2.0 load-time floor from WORK-20261026-03, now explained in its own Upgrading section, What's New in 1.0 and CHANGELOG 1.0.1. No schema, migration or runtime dependency change; lockfile changes are the path version only, plus the new RubyLLM 2.0.0 lock.
- [x] Full local release matrix passed (see Acceptance Matrix). Not run: PostgreSQL (not installed locally), remote CI, tag workflow, hosted docs.
- [x] The browser and package checks started their own servers and temporary hosts and removed them. No process from this task remains running. No push, tag, publication, provider call or external contact.
