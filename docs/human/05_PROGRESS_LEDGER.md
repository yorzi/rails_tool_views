# Progress Ledger

每个本仓库人工编写的 commit 都有一个新的 WORK 小节和匹配的 Work-ID trailer。此记录是审阅入口，不替代代码、测试或正式发布批准。

### WORK-20261010-01 — Build ToolViews local v0

**Date:** 2026-10-10
**Baseline refs:** FR-01..08 / NFR-01..06 / SEC-01..18 / UC-01/10
**Change type:** feature / security / test / docs / infra
**Human comprehension impact:** system-level

**What changed**

从空仓库实现 Rails Engine gem：严格组件 registry、可信 Partial/ViewComponent、持久化 Surface、授权动作、revision/幂等回执、JSON/Turbo 和独立的 agent continuation。RubyLLM 仅由可选适配器加载。提供离线 ChoiceCard demo、安装器、版本锁、测试与 CI 配置。

**Why**

验证已有 Rails 组件能作为可恢复的交互工具复用，同时保持 host 的业务权限、数据与 transcript 权威。采用 ADR 001 的最小独立方案；不扩展到其他场景或任意生成 UI。

**Human review points**

1. 阅读 README 的 scope/policy 与 handler 示例，确认模型提出的选项不能成为权限来源。
2. 执行 bin/demo：普通页面、chat、ViewComponent、空状态；保存后刷新，检查状态和日志。
3. 阅读 runtime 的同库事务、重放与续接边界；外部副作用/远端去重/队列属于 host。
4. 对照 acceptance matrix 和 VALIDATION.md 的本地证据与发布缺口。

**Validation performed**

核心 36 tests / 238 assertions 在 Ruby 3.3.5 + Rails 7.2.3/8.1.4、Ruby 4.0.2 + Rails 8.1.4 均通过，eager load 通过。可选真实 RubyLLM SDK 离线夹具 5 tests / 34 assertions 通过。独立进程恢复/并发、实际 SQL 日志过滤、打包 gem 安装到全新 Rails host 通过。浏览器键盘、360px、真实服务重启恢复与两标签冲突检查通过。详细命令和边界在 ../evidence/VALIDATION.md；本次 commit 执行 staged/range linkage 与 authored-file whitespace 检查。

**Architecture / data / security impact**

新增四张 namespaced 表，无旧数据迁移。默认拒绝；actor/tenant/资源和动作再次授权；CSRF、输入边界和固定 DOM target。动作事务包括 host 同库写入、Surface 与回执；续接在提交后，失败不丢失选项。请求/SQL 绑定中的 props/state/payload/result 被过滤；host 仍需负责数据投影和自身日志。

**Living docs updated**

README、SPEC_BASELINE、RE_ENTRY、ADR、agent 计划/验收/delta、human 状态/功能/架构/流程/术语/变更、operations、安全与发布记录。docs/specs 是未改动的外部规格快照。

**Spec alignment**

INTENTIONAL_DELTA DELTA-001：用户授权从 REVIEW 源规格完成本地 v0，未伪造正式 Gate V/H2/C/R 批准。运行时范围与 v0 一致；FR-08-AC-03 / NFR-03-AC-01 的发布级证据保持 PARTIAL。

**Follow-up / risk**

正式开源发布尚需 license/name、独立安全/无障碍审查、远程 CI、真实 provider、PostgreSQL 和外部安装/对比试验。没有推送或发布。两次临时 Puma 已停止，3100 无监听，测试标签页已关闭。

### WORK-20261010-02 — Build ToolViews v1 reference workflows

**Date:** 2026-10-10–11
**Baseline refs:** UC-02..05 / Demo B/C; FR-01..08 / SEC-01..18 reused as applicable; local V1-* acceptance
**Change type:** feature / security / test / docs
**Human comprehension impact:** system-level

**What changed / why**

按 Andy 明确要求，从已完成的 v0 继续到 v1，完工后才人工检查。新增三个 host 工作流：可修正与保留错误的客户表单；有角色/租户约束的客服查询、账户查看、分配、草拟、人工审阅和明确本地入队；不可变结果版本的编辑、接受、显式再生成、恢复和授权文本导出。核心新增受限 ValidationError、通用状态文案，并修正 Engine 控制器继承以保留 host 认证/helper。

**Human review points**

1. 执行 bin/demo，打开 /v1/customer，输入错误邮箱再修正；确认只有批准字段进入创建服务，成功后可另开新 draft。
2. /v1/support 切换 North/South、lead/agent；检查有界查询和动作权限。请求草拟、编辑/批准、勾选本地 queue；确认 UI 没有把入队说成外部发送。
3. /v1/review 编辑、显式再生成、接受、下载；已接受版本锁定，继续创作使用新 draft。按 README 的失败夹具步骤检查重启和重试。
4. 对照 ADR 002、V1 acceptance/evidence，审阅业务版本、Surface revision 和续接回执三个边界。

**Validation performed**

核心/V1 60 tests / 468 assertions、eager load 在 Ruby 3.3.5 + Rails 7.2.3/8.1.4、Ruby 4.0.2 + Rails 8.1.4 全通过；真实 RubyLLM 2.1 SDK 离线夹具 6 tests / 44 assertions 通过。三个组合的安装后 fresh-host probe 通过，覆盖 host scope/helper 和字段反馈。独立进程并发/恢复、业务回滚、延迟续接冲突、已写入未确认的 receipt 重试、导出失败重试、SQL/参数过滤与 XSS 逃逸通过。浏览器实际表单修正、审阅/确认、角色/租户拒绝、360px、失败服务重启、续接重试、接受和下载检查通过。详见 ../evidence/V1_VALIDATION.md；本次 commit 检查 staged/range linkage 与 authored whitespace。

**Architecture / data / security impact**

新增九张 demo-only 主应用表；gem 仍只安装四张表，无核心 schema 迁移。组件 refs 不复制整条业务记录；查询/resolver/dispatch/下载分别重新授权。业务版本独立防止跨 Surface 过时写入；接受锁定不可变版本。业务续接和持久化 delivery receipt 同事务，外部去重仍由 host 负责。真实 provider 未调用、客服没有外部发送。参数/SQL 过滤补充 CSRF/表单值，host 示例补充 email/body/feedback；原生产隐私责任不被替代。

**Living docs / alignment**

README、CHANGELOG、SPEC_BASELINE、RE_ENTRY、SECURITY/CONTRIBUTING、ADR 002、V1 验收/证据、agent/human/operations 文档和实际架构图更新。docs/specs 未修改。INTENTIONAL_DELTA DELTA-002 记录本地 V1 授权，未伪造源规格 H2/C/R 或 release viability/外部采用证明。

**Follow-up / risk**

下一步是 Andy 人工检查。本地 V1_COMPLETE 不等于正式发布、生产认证、真实模型质量、PostgreSQL 或商业收益。发布缺口继续保留；没有推送。四次临时 Puma 已停止，3100 无监听，测试标签页关闭、viewport reset。

### WORK-20261013-01 — Audit hardening and adoption ergonomics after v1 review

**Date:** 2026-10-13
**Baseline refs:** SEC-10 / SEC-11 / SEC-12 / SEC-13 / SEC-18; FR-01-AC-02; FR-02-AC-01; FR-04-AC-02; FR-05-AC-01; FR-07-AC-02; FR-08; NFR-03-AC-01; ADR 003 / ADR 004
**Change type:** fix / security / feature / test / docs / infra
**Human comprehension impact:** module-level

**What changed / why**

Andy 要求审阅并审计这个 gem、判断价值、并在有更好设计时直接改进。先用可执行探针复现问题，再修复，共六项：

1. Schema 遍历不完整：没有 `type` 的子 schema、空 schema、没有 `items` 的数组都能注册，并接受任意 JSON。现在每个取值位置都必须声明 type/enum/const，对象闭合，数组有 items。
2. 引擎把 `props state payload result arguments values` 加进主应用全局过滤列表，主应用所有同名参数和列在日志与 `inspect` 中被打码。现在脱敏只作用于引擎的控制器、四个模型和它们的 SQL 绑定值。
3. renderer 和 Agent 适配器的异常被 `rescue StandardError` 吞掉。现在进入 `Rails.error`、日志和只含元数据的事件；`surface.rendered` 只在成功时发出。
4. 错误文案写死且核心里混有参考应用的三个错误码；引擎界面文字是固定英文，并特殊处理了 demo 的 `selected` 状态键。现在支持 `message:` 与 I18n，demo 文案移到参考应用自己的 locale。
5. 没有参数的动作用原生表单提交时返回 400，因为表单不会发送空的 `arguments`。demo 的“View authorized account”按钮在真实 HTTP 下一直是坏的。
6. 测试结果依赖顺序：一个 CSRF 测试在最先运行时会让之后所有 POST 被拒。未改动的 3635c54 单独运行 v1 控制器测试文件时，14 个 seed 中有 5 个失败。

Andy 看过第一轮后要求继续。第二轮针对接入成本和最大的验证缺口（ADR 004）：

7. 新增 `tool_views_action_form`、`tool_views_action_button`、`tool_views_action_fields`。字段名、唯一 id、动作名、revision、幂等 key、来源组件由 helper 负责；动作名写错在渲染时就报错。参考应用的 ChoiceCard 和五个单按钮表单已改用它们。
8. Rails 自带的 `form.submit`/`form.button` 会提交 `commit`/`button`，以前被当作未知字段拒绝（400）。现在这两个名字被接受并忽略，其他未知字段照旧拒绝。
9. ViewComponent 的构造函数声明 `surface:`/`state:`/`error:` 就会收到它们，可以做成可交互组件；未声明的组件行为不变。demo 的 ViewComponent 卡片现在可以选择并保存。
10. `config.parent_controller`（认证写在子类里的主应用）和 `config.delivery_lease`。
11. 没有 Turbo 时，动作成功后回到嵌入 Surface 的同源页面，而不是引擎的无 layout 片段页。
12. 数据库回滚整个动作（死锁、序列化失败、锁超时）返回可重试的 CONFLICT，而不是未处理异常。
13. PostgreSQL：新增 `gemfiles/postgres.gemfile` 和 CI job，用 `DATABASE_URL` 选择数据库。

**Human review points**

1. 读 ADR 003，重点是 `RedactedJson` 的做法：数据库绑定值是一个 `inspect` 为 `[FILTERED]` 的 String 子类。它避免了改主应用日志，但依赖 Rails 用 `inspect` 打印 binds；确认是否接受这个取舍。
2. 读 `lib/tool_views/core.rb` 的 `inspect_schema!`，确认新规则没有拒绝你实际要用的 schema 写法。
3. 运行 `bin/demo`：`/` 选择后状态显示 “Selection saved: …”；`/v1/support` 打开工单后点 “View authorized account” 现在应成功。
4. 读 ../human/01_PROJECT_STATUS.md 里六条未实现的发现，决定哪些要做。
5. 注意之前两次记录的“全部通过”依赖执行顺序，见 ../evidence/AUDIT_VALIDATION.md 第 6 项。
6. 读 README 里新的表单示例和 ADR 004。确认两点取舍：`commit`/`button` 成为被忽略的保留字段名；无 Turbo 的跳转依赖同源 `Referer`。
7. `bin/demo` 首页点 “Render ViewComponent”，这张卡片现在由 ViewComponent 渲染并可保存选择。

**Validation performed**

最终状态：核心与参考应用 78 tests / 646 assertions，在 Ruby 3.3.5 + Rails 7.2.3/8.1.4、Ruby 4.0.2 + Rails 8.1.4（SQLite）以及 Ruby 3.3.5 + Rails 8.1.4 + PostgreSQL 17.11 通过，eager load 通过；四个组合各跑 4 到 12 个固定 seed 全过。可选 RubyLLM 适配器 6 tests / 44 assertions 通过。三个 SQLite 组合的安装后 fresh-host probe 通过，并新增对表单 helper 的检查。每项修复和每个新行为都做了破坏验证：改回旧实现后对应测试失败。真实 demo 经 HTTP（cookie + CSRF）22 项检查在 SQLite 和 PostgreSQL 上都通过；第一轮在浏览器里验证了 Stimulus/Turbo 的保存提示、替换和焦点，第二轮没有再做浏览器检查。未运行：MySQL、远程 CI、真实 provider、真实死锁、360px 与读屏审计。提交前执行了 staged ledger 关联检查和空白检查。

**Architecture / data / security impact**

无迁移、无新表、无新的运行时依赖（`pg` 只在开发用 gemfile 里）。授权、事务、幂等语义不变。新增公开接口：三个 view helper、`Component#context`、两个配置项。`commit`/`button` 成为被忽略的保留字段名。无 Turbo 的跳转只跟随同源 `Referer`，否则回退到原来的引擎页面。安全面收紧：schema 更严格；引擎请求日志从“按名称打码若干字段”改为“除路由元数据外全部打码”。行为变化：注册时可能拒绝以前能加载的 schema；renderer/适配器的异常信息现在会出现在主应用日志和错误上报里，主应用不应把机密写进异常信息；订阅 `surface.rendered` 的代码在渲染失败时不再收到事件。URL 查询串由 Rails 在路由前记录，不在引擎过滤范围内，引擎也不读取它。

**Living docs updated**

README、SECURITY、CHANGELOG、ADR 003/004、RE_ENTRY、安装器模板、CI 配置、agent 的 current work/pre-flight/post-flight/delta 说明/两份验收表、runbook、release checklist、human 的状态/架构/变更记录、evidence/AUDIT_VALIDATION.md。docs/specs 未修改。

**Spec alignment**

IMPLEMENTATION_BUG 修复（schema 闭合、无参数表单、Rails 提交按钮被拒）加上 ADR 003/004 记录的实现层技术选择；ADR 004 修订了 ADR 001 的 ViewComponent 取舍和 ADR 002 的父控制器取舍。没有产品意图变更，没有新的 delta；DELTA-001/002 不变。

**Follow-up / risk**

应 Andy 要求在 main 上本地提交为一个 commit；仓库没有配置 remote，未推送、未发布。两轮改动合为一个 commit，因为它们改的是同一批文件，而完整验证只针对最终状态。下一步是 Andy 按自己的节奏检查 v1 工作流和 ADR 003/004。`RedactedJson` 在 MySQL 上未验证，PostgreSQL 只验证了本地 17.11。六条未实现的发现列在项目状态页。四次临时 demo 服务和一次临时 PostgreSQL 已停止，数据目录已删除，3100 与 54329 无监听，浏览器标签页已关闭。

### WORK-20261016-01 — RailsToolViews 改名与兼容更新

2026-10-16。Andy 明确要求查找原始 Specs，更新 gem，改名 RailsToolViews，完成后 commit/push。基于 26825cb；原始 Specs 59 个文件逐字节匹配固定版本 0ea28b1；新增命名/兼容合同取自 OddlyNiche c100a73，外部来源只读。

- **改变与原因：** gem 更新为 `rails_tool_views` 0.2.0.pre.v2，canonical namespace 为 `RailsToolViews`；同步 require、安装器、helper、新 host mount、示例和文档。旧 `ToolViews` 及 require/helper/mount 仍兼容；数据库/组件摘要/DOM/交互 delivery key 不改，避免改名破坏持久化与重放。依赖约束和第三方版本保留。
- **映射：** 命名合同 TV-01/04/05；原 FR-01/02/05/07、SEC-06/07/09/15；DELTA-003 是用户明确批准的名称变更，非 H2 或 gem 发布批准。
- **验证：** Ruby 3.3.5 + Rails 8.1.4/7.2.3、Ruby 4.0.2 + Rails 8.1.4 均 83 tests / 665 assertions，eager load 通过；可选 RubyLLM 6 tests / 44 assertions 通过。打包后独立 host 安装和旧提交写入→新代码读取/重放的跨进程验证通过。具体边界见 RENAME_VALIDATION。
- **人工复查：** 阅读 README 的安装/升级节和 ADR 005；运行 `bundle exec ruby scripts/package_smoke.rb` 与 `bundle exec ruby scripts/rename_smoke.rb`；已有 host 不重新运行 installer，检查 Engine partial overrides 和自定义序列化类名。
- **风险与数据：** 无表/数据迁移、无新 runtime 依赖；授权/CSRF/日志脱敏/原生可访问控件行为不变。未重新做浏览器/a11y、PostgreSQL、live provider、OddlyDock 和远程 CI；未声明市场/发布/商标清理完成。
- **文档：** 更新 README、CHANGELOG、baseline supplement、current/pre/post-flight、delta、acceptance、ADR 005、human status/changelog 和 operations。系统运行流程未变，无须修改流程图。历史 evidence 和原 Specs 不改。
- **交付：** main 本地提交已授权；Andy 已指定创建 `yorzi/rails_tool_views` private，私有仓库已创建并配置 origin；本次提交后推送 main，最终结果以远端 SHA 核验为准。保持 private，后续开发完成后才讨论公开。未发布 gem。未启动任何长期服务；临时 host/数据库进程已结束并自动清理。
