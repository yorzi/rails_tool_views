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
