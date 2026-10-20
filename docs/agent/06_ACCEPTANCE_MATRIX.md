# Acceptance matrix — v0 local evidence

Source: pinned 04_FEATURE_MVP_SPECS and SEC-01..18. LOCAL is not CI, PROVIDER, USER or BUSINESS proof. Read ../evidence/VALIDATION.md for exact commands and limits.

V0 evidence is retained as the original milestone record. The full suite now includes V1 regression coverage; see [V1 acceptance](08_V1_ACCEPTANCE.md) and [current validation](../evidence/V1_VALIDATION.md). No V1 evidence closes the external gates below.

| AC | Evidence | Local result / boundary |
|---|---|---|
| FR-01-AC-01 | registry_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-01-AC-02 | registry_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-01-AC-03 | registry_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-02-AC-01 | rendering_test.rb; registry_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. A ViewComponent can also receive Surface context and post actions (ADR 004). |
| FR-02-AC-02 | rendering_test.rb; registry_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-03-AC-01 | adapter/ruby_llm_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-03-AC-02 | adapter/ruby_llm_test.rb; privacy_test.rb | LOCAL_PASS; Real Chat acknowledgment and authorized HTML share an explicit reference; no model-text renderer. |
| FR-03-AC-03 | adapter/ruby_llm_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-03-AC-04 | adapter/ruby_llm_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-04-AC-01 | runtime_test.rb; durability_test.rb; rendering_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-04-AC-02 | runtime_test.rb; durability_test.rb; rendering_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-04-AC-03 | runtime_test.rb; durability_test.rb; rendering_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-05-AC-01 | runtime_test.rb; controller_test.rb; durability_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-05-AC-02 | runtime_test.rb; controller_test.rb; durability_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-05-AC-03 | runtime_test.rb; controller_test.rb; durability_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-05-AC-04 | runtime_test.rb; controller_test.rb; durability_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-06-AC-01 | continuation_test.rb; adapter/ruby_llm_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-06-AC-02 | continuation_test.rb; adapter/ruby_llm_test.rb | LOCAL_PASS; Actual RubyLLM ask/new-user-turn API; pending tool calls reject. No live provider. |
| FR-06-AC-03 | continuation_test.rb; adapter/ruby_llm_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-07-AC-01 | controller_test.rb; rendering_test.rb; manual browser evidence | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-07-AC-02 | controller_test.rb; rendering_test.rb; manual browser evidence | LOCAL_PASS; Ready/loading/empty/invalid/denied/conflict/pending/failed/completed tested by browser or integration fixtures. |
| FR-07-AC-03 | controller_test.rb; rendering_test.rb; manual browser evidence | LOCAL_PASS; 360px Space/Tab/Enter, native labels/legend, error-describedby and focus observed; no full screen-reader audit. |
| FR-07-AC-04 | controller_test.rb; rendering_test.rb; manual browser evidence | LOCAL_PASS; JSON/Turbo parity and bounded targets pass; ActionCable N/A, disabled. |
| FR-08-AC-01 | scripts/package_smoke.rb; README; release checklist | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-08-AC-02 | scripts/package_smoke.rb; README; release checklist | LOCAL_PASS; Mocked real Chat loop passes; live-provider script documented but NOT_RUN. |
| FR-08-AC-03 | scripts/package_smoke.rb; README; release checklist | LOCAL_PARTIAL / RELEASE_OPEN; Contribution/security/release documentation exists; license/disclosure/release approval remain pending. |
| NFR-01-AC-01 | registry_test.rb; rendering_test.rb; controller_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| NFR-02-AC-01 | durability_test.rb; runtime_test.rb; controller_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| NFR-02-AC-02 | durability_test.rb; runtime_test.rb; controller_test.rb | LOCAL_PASS; Fresh process and concurrent workers pass. Channels N/A while absent. |
| NFR-03-AC-01 | local Ruby/Rails matrix; .github/workflows/ci.yml | LOCAL_PARTIAL / RELEASE_OPEN; Three exact local combinations pass on SQLite and one on PostgreSQL 17.11 (../evidence/AUDIT_VALIDATION.md); MySQL NOT_RUN, but every index key is now asserted inside utf8mb4's 3072-byte limit (WORK-20261017-02); remote Linux CI is configured but NOT_RUN. |
| NFR-04-AC-01 | privacy_test.rb; offline network guard; package smoke | LOCAL_PASS; Offline positive/negative behavior covered. |
| NFR-05-AC-01 | privacy_test.rb; SECURITY.md; host projection/retention contract | LOCAL_PASS; No transcript/credentials/raw domain dump is persisted by core; accepted display fields require host projection. |
| NFR-06-AC-01 | manual browser evidence; rendering_test.rb | LOCAL_PASS; Desktop/360px no-overflow, restored choice and focus; assistive-technology audit still a release review. |

## Security coverage

| SEC | Executable evidence / applicability |
|---|---|
| SEC-01 | Registry unknown component/untrusted renderer/unknown props; no eval/constantize. |
| SEC-02 | Escaped script title in native Partial; ViewComponent safe render. |
| SEC-03 | Unknown action and missing policy reject before handler. |
| SEC-04 | Runtime/HTTP different actor or tenant returns unavailable with no props. |
| SEC-05 | Trusted host option allowlist rejects values even when model props offer them. |
| SEC-06 | Stale revision and independent concurrent workers produce conflict without overwrite. |
| SEC-07 | Action replay receipt, tool correlation and provider retry create once; concurrent same key effects once. |
| SEC-08 | Presentation keys isolate actor/tenant/adapter/context; chat scopes differ. |
| SEC-09 | Digest/missing component fails recoverably without deleting state. |
| SEC-10 | Size/depth/unknown-field/ref/schema tests; every nested value position must be typed, closed and item-bounded (registry_test, WORK-20261013-01); TCP blocked in tests. |
| SEC-11 | Provider callback failure, unchanged committed selection, explicit retry and active lease; failure reported to Rails.error with a metadata-only event. |
| SEC-12 | Metadata-only notifications, Engine-scoped request/SQL/inspect redaction with host parameters and columns left visible (privacy_test, ADR 003), snapshot projection and retention deletion. |
| SEC-13 | HTTP business_rules/tenant/policy-like extra fields rejected; host policy recomputed. Only Rails' inert `commit`/`button` submit names are tolerated (controller_test, ADR 004). |
| SEC-14 | Forged source and action not declared on registered component reject. |
| SEC-15 | Actor/tenant HTTP read/write denial. ActionCable subscription/broadcast N/A; no channel shipped. |
| SEC-16 | Client target body rejects; replacement target is authorized Surface only; browser ignores older revision. |
| SEC-17 | Identical JSON/Turbo committed state and replay; format does not branch mutation. |
| SEC-18 | SQLite and PostgreSQL 17.11 restored in new Ruby process; two separate concurrent workers; durable receipts; database rollback returned as retryable CONFLICT. |

## Evidence gates outside local v0

Gate V remains PARTIAL: actual upstream loader/catalog and package probes ran, and RailsToolViews controls pass, but no complete DSPy/A2UI runtime security comparison, neutral-core upstream extraction or measured extension comparator exists. SP-06 schema byte sizes are local measurements, not live model reliability/token benchmarks. SP-07 maintainer contact and external developer trials were not authorized/performed. Gate H2/R remains OPEN. No acceptance row turns those limits into a PASS.

## Identity upgrade — WORK-20261016-01

Supplemental TV-01/04/05, existing FR-01/02/05/07 and SEC-06/07/09/15: canonical namespace, compatibility requires/helpers, real pre-rename database replay, independent packaged-host install and original authorization/digest rejection checks. See ADR 005 and `docs/evidence/RENAME_VALIDATION.md`. This is local evidence; OddlyDock TV-02/03, remote CI and gem release remain unverified.

## Single identity — WORK-20261018-01

Supplemental TV-05 now takes its explicit-migration branch: a 0.2 host renames indexes and tables with one reversible migration, and saved Surfaces restore and replay under the new names (OddlyDock development database). `test/identity_test.rb` asserts the legacy constant, entrypoints, generator and helpers are absent and that every index name fits PostgreSQL's 63 bytes. Core suite on Rails 8.1 and 7.2, optional adapter, packaged install and docs examples pass. Ruby 4 and PostgreSQL were NOT RUN locally (see IDENTITY_V3_VALIDATION). ADR 006, DELTA-004.

## Documentation usability — WORK-20261016-03

FR-02/03/05/07/08 documentation now has executable tutorial blocks, core/optional-adapter checks, a generated API reference and linked guides. Local build/link/preview evidence in DOCS_VALIDATION; no external onboarding or hosted-access evidence is inferred.

## Demo presentation follow-up — WORK-20261016-04

README and reference host presentation refreshed. Existing action/persistence/validation/tenant boundaries remain covered by 83 tests / 665 assertions. Browser checks exercised all four workspaces with an isolated fixture database. This is local showcase evidence, not a new production or human-approval gate. See [validation](../evidence/DEMO_SHOWCASE_VALIDATION.md).

## Audit hardening — WORK-20261017-02

SEC-04, SEC-07, SEC-08, SEC-18 and NFR-02/03 gain executable coverage: the suite now asserts that every index key stays inside utf8mb4's 3072-byte limit (closing the MySQL `CREATE TABLE` failure recorded under NFR-03), that stored identifiers are byte-capped, and that a lookup only a non-binary collation could match is refused for a Surface, a correlation and an idempotency key. 88 tests / 702 assertions pass on SQLite and PostgreSQL 17.11. MySQL stays NOT_RUN: the fix is proven by column introspection and arithmetic, not a real MySQL migration. See [AUDIT_V2_VALIDATION.md](../evidence/AUDIT_V2_VALIDATION.md).

## First public release — WORK-20261018-02

FR-08/NFR-03 分发与文档：首次公开版本 0.1.0，MIT、自定义域名 GitHub Pages、私密安全报告及 GitHub OIDC 标签发布流程。三组本地核心套件各 89/723、适配器 7/45、打包主应用、文档与六份 lockfile 安全审计通过。Rails 7.2 样例更新到 7.2.3.2，并显式约束五个易被旧 Ruby 默认版本满足的运行时依赖。精确提交的远端验证、实际发布和 HTTPS 见 `../evidence/RELEASE_0_1_0.md`；先前 NOT_RUN 的历史行不替代本次证据，开放的 MySQL/provider/adoption/H2 等边界不变。

### Verified release delivery — WORK-20261018-04

FR-08/NFR-03 的精确发布证据：`v0.1.0` / `f2d4303` 的 [release run 39117821018](https://github.com/yorzi/rails_tool_views/actions/runs/39117821018) 全绿，三组 SQLite 与 PostgreSQL 各 89/723，adapter 7/45；包检查、lockfile/实际激活依赖审计、独立网络安装和 2,152 文档链接均通过。RubyGems 0.1.0 与 GitHub Release 附件/SHA256SUMS 一致。发布后的 Pages run 39118079958 全绿；稳定/next、API、llms、搜索、DNS 与强制 HTTPS 已验证。MIT、MFA/OIDC、私密安全报告属于已观察的配置/发布事实，不替代独立安全审核或正式产品门槛。完整证据见 RELEASE_0_1_0。

## Documentation ownership and proposed roadmap — WORK-20261018-05

FR-08 documentation: README now routes to canonical hosted tutorials/API; contribution/maintenance/roadmap material stays in the repository. Markdown links, 15-guide style check, executable examples and the stable/next build with 2,152 generated links pass. No runtime acceptance changes. ROADMAP's 0.2..1.0 exit conditions are proposals and cannot be counted as delivered functionality or completed baseline gates.

## 0.2 development foundation — WORK-20261018-06

FR-07/08 LOCAL_PASS: `bin/check-browser` Chrome 3/18，Partial/ViewComponent 保存刷新、移动端字段错误及纠正；截图保存在 ignored tmp/browser，CI 配置上传。`clean_install_smoke.rb --audit` 在空 GEM_HOME 外部 Bundler 完成完整 Rails host 行为与激活依赖审计；不再只加载入口。core 89/723、adapter 7/45、eager load、package/docs examples 通过。远程 CI、外部采用、provider 和完整辅助技术审核未运行。

## Partial generator — WORK-20261018-07

FR-01/02/08 LOCAL_PASS: 三文件生成器，64 字符 key，closed schema、双 policy deny、无 agent exposure，reload 多定义保留。非法名/越界 symlink/冲突（含 --force）先拒绝无部分写入。3/46 聚焦、全套 92/769 + eager load；实际 package host 默认拒绝、显式授权渲染/保存与生成 Minitest 1/2 PASS。docs lint 16 guides clean；最终构建/matrix 由 WORK-09 执行。

## Complete HTML correction — WORK-20261018-08

FR-07 LOCAL_PASS: HTML page/403 CSRF/404 scoped denial/409 conflict/422 escaped retained fields、safe reload、correction redirect 均有 HTTP assertions。JSON/Turbo 回归保留。core 97/835/eager load；Chrome 4/28，真实禁用 JS 的 390px 表单纠正和刷新 PASS。截图人工检查，screen-reader/物理设备/完整 a11y 未运行。最终 matrix/package/docs 留 WORK-09。

## Public 0.2 local acceptance — WORK-20261018-09

FR-01/02/07/08 LOCAL_PASS: generator 默认展示/动作拒绝（公开 dispatch 验证）、closed schemas、路径/冲突守卫、多文件 reload；完整 HTML 403/404/409/422、字段保留/escaping、纠正后安全跳转；嵌入/JSON/Turbo 回归保留。三个 Ruby/Rails SQLite 组合与 PostgreSQL 各 97/837/eager load；adapter 7/45；Chrome 4/28，禁用 JS/390px/实际键盘复查。冻结 artifact 的实际 host 在三个组合通过，独立 GEM_HOME full host + generated Minitest + activated audit PASS。七份锁审计、16-guide lint（两条预期版本警告）、build/2,210 links 通过。详见 ../evidence/V0_2_VALIDATION.md。

仅本地候选，未推送/未发布，remote CI NOT_RUN。无新 schema/migration/runtime dependency；不关闭 MySQL/provider/外部采用/独立安全/正式 H2/C/R。

## Public 0.2 delivery — WORK-20261018-11

FR-08/NFR-03 RELEASE_PASS: exact tag 3156fd3 CI and OIDC publication complete, RubyGems/Release/client checksum agreement, full isolated installed host and dependency audits PASS. FR-01/02/07 remote regressions: three Ruby/Rails and PostgreSQL each 97/837; adapter 7/45; Chrome 4/28. Hosted stable0.2/next Pages, new feature search/version navigation, 15 HTTPS entries, 17-guide lint and 2,450 generated links PASS. No migration/runtime dependency change. Exact run/hash details in ../evidence/RELEASE_0_2_0.md. Formal H2/C/R, MySQL/provider/adoption/independent security/full a11y remain open.

## WORK-20261019-01 — 生命周期本地验证

FR-04/05/06/07/08 LOCAL_PASS：close/abandon 专用授权、跨租户拒绝、关闭后旧回执/关联重放、新动作拒绝；pending/failed 显式放弃，delivering/持久 uncertain 保护。两个并行回调的过期租约测试证明旧回写不能移除保护，callback 在事务外。core 106/923 + eager load、实际 package host + generated Minitest 1/2 PASS；19 guides zero errors/two expected unreleased warnings。完整矩阵、迁移旧数据、清理、browser 留后续单元；未推送或运行远端 CI。

## WORK-20261019-02 — 保留清理本地验证

FR-04/05/06/07/08 LOCAL_PASS：默认 deny、严格 true policy、preview 零写入、cutoff/deadline/batches、跨 scope/锁后变更、stale restore 后 dispatch、未知/unfinished/uncertain 保护、删除故障事务回滚。core 114/988 + eager load、实际 package host 生命周期/preview/apply/410 + generated Minitest 1/2 PASS。Chrome 5/40，closed-preview 和 cleaned-business-log 截图检查；host Effect 保留。19 guides zero errors/two expected unreleased warnings。旧版本升级/完整 matrix 与 PG 并发由下一单元完成。

## WORK-20261019-03 — 0.3 本地候选验收

FR-04/05/06/07/08 LOCAL_PASS：三个 Ruby/Rails SQLite 组合各 114/988/eager load；PostgreSQL 116/1000（真实双 cleaner 和 action/close 锁竞争）；adapter 7/45。真实 v0.2 runtime 的五组持久数据在三个组合迁移/replay/correlation/backfill/rollback/purge 保留业务验证通过；三个 installed host 与 generated Minitest 1/2，空 GEM_HOME network/full host/activated audit PASS。Chrome 5/40（生命周期原生无 JS），core/adapter guide snippets PASS；19 guides zero errors、两条预期 unreleased warning，stable/next build/2,571 links PASS。七份 locks audit clean。35-file candidate package gate PASS；formal gate 因 released:false 正确拒绝。详见 ../evidence/V0_3_VALIDATION.md，原始失败/修复与证据边界不隐藏。远端 CI/发布、provider/MySQL/adoption/独立审核/正式 gates 未完成。

## WORK-20261019-05 — 0.3 verified public delivery

FR-08/NFR-03 RELEASE_PASS：immutable v0.3.0→d12996e，main CI39229304949/Docs39229304982，tag CI39229612275/Release39229612284全绿。精确tag三组114/988、PG116/1000、adapter7/45、Chrome5/40，真实0.2升级/包/isolated安装/审计、2,692文档链接通过。registry API/direct/client/Release/SHA256SUMS均为01e004ba5deb2cba23d175a3d8110d1ed3cbbcc6c128cc9b735c0f380aed76a3；35files与本地一致，normalized gemspec契约相同。Pages39230070227全绿，stable0.3/next、16 HTTPS/搜索/版本切换/API/migration docs/MFA/OIDC observed PASS。详见../evidence/RELEASE_0_3_0.md。此记录自己的post-push CI在提交后检查，不提前声称。formal/security/MySQL/provider/adoption/full a11y gaps保持。

## WORK-20261020-01 — 0.4 recovery local unit

FR-05/06/07、SEC-04/06/11/18 LOCAL_PASS：stale success/failure 不覆盖新 attempt，late failure 不降级 completed 或发 false event；外层事务拒绝 delivery。host Active Job 重新解析 active staff/scope，独立 boot 恢复 pending，真实 process exit(73) 在 host effect/receipt commit 后恢复同一 key、无第二次 reply。原保护仍阻止 uncertain lifecycle。core122/1057/eager load、实际 installed-gem host/generated1/2 PASS；20-guide lint零错误/两条预期候选警告。PG/matrix/完整browser与最终包/upgrade由后续单元覆盖；无远端 CI/发布。

## WORK-20261020-02 — diagnostics and browser feedback

SEC-11/18、FR-07 LOCAL_PASS：ordinary handled-error log does not copy host exception sentinel; Rails.error retains exception behind host controls. privacy8/67, core123/1063/eager load。Chrome6/61 covers keyboard activation, busy/disabled loading, validation error focus, post-replacement status focus, mobile failed delivery/explicit retry/refresh, exactly one local reply/receipt. Three screenshots manually checked. Existing catalog documented with no payload/catalog change; replay/notice decisions pending.21-guide lint/build/2,822links PASS(two expected unreleased warnings)。Full a11y/screen reader/device testing NOT_RUN.

## WORK-20261020-03 — approved compatibility implementation

FR-05/07、SEC-04/06/11/18 LOCAL_PASS：action.executed adds replayed boolean under DELTA-006; exact receipt stays deterministic and metadata excludes notice. notice≤500bytes escaped/plain even SafeBuffer, invalid feedback rolls back host effects, state/snapshot independent, JSON/Turbo and exact scope-bound HTML flash once. feedback6/65; core129/1129/eager load, Chrome8/77(Turbo and JS-disabled refresh, existing message compatibility) PASS. Database rollback sends existing code-only action.conflict, failing regression reproduced/fixed.22 guides/build/2,897links PASS. Final matrix/package/upgrade/PG/isolated audit acceptance is WORK-04, not yet claimed.
