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

### WORK-20261016-02 — 记录私有仓库交付证据

2026-10-16。实施提交 `7e73e4e` 已成功推送 `yorzi/rails_tool_views` 的 main；远端 SHA 完全匹配，GitHub 可见性 PRIVATE。按用户要求保持私有，开发完成前不公开。

本提交仅将 current work、post-flight、human status 和 RENAME_VALIDATION 更新为实际交付状态，修正推送前的待办表述；无运行时/数据/安全/可访问性变化，无需重复测试或流程图。实施验证沿用 WORK-20261016-01，提交关联检查通过；远程 CI 已触发但检查时仍排队，不冒充通过。人工可查看仓库 main、可见性与 Actions；下一步是等待 CI 结果及继续原有人工检查/未完成开发，不发布 gem。未启动长期进程。

### WORK-20261016-03 — 创建并提交 RailsToolViews 使用文档站

2026-10-16。用户明确调用 project-docs 创建项目文档。采用 Jekyll + jekyll-vitepress-theme，站点源码独立放在 docs/site，保留内部规格、架构、审计与历史。四组 14 篇页面和首页覆盖安装、组件、Surface、动作、验证、RubyLLM、续接、生产边界、升级与 API。补充公共源码注释、RDoc/Markdown API、llms、搜索、版本构建与 CI 检查。

对应 FR-02/03/05/07/08 的使用说明和维护需求，IMPLEMENTATION_ALIGNED，无新增产品意图。人工可按 docs/README.md 运行本地预览、教程检查并审阅升级指南。验证：样例 core/adapter 均执行通过，83 tests / 665 assertions、eager load、站点构建、样式与链接检查通过；浏览器搜索、API、窄屏与深浅色预览完成。详见 DOCS_VALIDATION。

无数据库迁移、provider 调用或权限变化；原 Specs 不改，内部文档不进入站点。Pages 需明确开启且仓库 public，目前保持关闭/private。Andy 随后明确要求提交/推送并重命名本地项目目录；本次提交使用本节 Work-ID，站点仍不部署。目录目标为 `/Users/andy/Workspace/OpenSource/rails_tool_views`，安装示例同步新路径。提交前补齐 API-only PR 的文档构建触发，并让缺失站点输出的检查失败。临时 127.0.0.1:4000 预览和 watcher 已停止，标签页已关闭。架构运行流程不变，无需修改图。下一步人工阅读指南，公开发布继续按既有开发完成条件处理。

### WORK-20261016-04 — README 精简与演示工作台

- 内容与原因：按用户要求把 README 收敛为安装、演示和文档入口；演示应用增加统一导航、清晰的租户/角色上下文、场景提示、工单双栏和空状态；保留查询条件。新增 Demo Workbench 指南。
- 映射：现有持久化视图、字段校验、授权动作与人工审核流程的演示可用性维护；无产品意图变化，不修改原始 Specs。
- 人工审阅：运行 bin/demo，依次试用四个工作区；保存选项后刷新，提交无效邮箱后修正，审核回复并确认本地队列，接受内容后查看导出入口；切换 South Agent 检查可见上下文。
- 验证：83 tests / 665 assertions、eager load 通过；15 篇指南 lint 无错误/警告，站点构建通过，1,075 个本地链接无断链。真实浏览器完成上述主要路径。物理手机和完整无障碍审计未执行，不能视为正式验收。
- 风险与数据：仅 dummy host 展示和文档；无迁移、核心 API、授权策略或依赖变更，无外部消息/模型调用。临时数据库与正常演示数据隔离。
- 文档：README、演示指南、验证证据、验收补充、human changelog、pre/post-flight 和当前任务已同步；架构/运行时权责未变，无需重画图。
- 清理与下一步：任务服务 PID 59386（127.0.0.1:3197）已停止，预览标签关闭；原有 3100 服务未动。按既有授权提交并推送，保持 private；等待人工体验反馈，不声明生产发布。

### WORK-20261017-01 — OddlyDock 首次真实接入发现的修复

- **内容与原因：** Andy 2026-10-17 指示 OddlyDock 以开发模式接入本 gem，发现问题可直接修 gem。OddlyDock 通过安装器挂载为 `rails_tool_views`，暴露两个 dummy 应用测不到的问题：(1) 无 Turbo 且无同源 Referer 时，HTML 动作回跳写死了 `tool_views` 路由代理，在安装器默认挂载名下抛 `NameError` 返回 500，改为 Engine 自己的 `surface_path`，任何挂载路径/名称都正确；(2) Surface 的无障碍名称直接用注册时的 description，而 `to_prepare` 在 Rails 应用 `config.i18n` 之前执行，注册时调用 `I18n.t` 会取到错误语言。新增 `rails_tool_views_component_name`（及旧前缀别名），每次渲染按 `tool_views.components.<key>` 查翻译，回退到 description。指南补充：渲染器和父控制器过滤器运行在 Engine 控制器内，主应用路由需经 `main_app`。
- **映射：** IMPLEMENTATION_BUG（安装器挂载名下的回跳）和公共 API 的向后兼容新增（翻译 scope、helper），无产品意图变化，无新 delta。
- **验证：** `bundle exec rake test zeitwerk:check` 84 tests / 669 assertions 通过、eager load 通过（Ruby 3.3.5 + Rails 8.1.4）；`rake test:adapter`（RubyLLM 2.1.0）6 tests / 44 assertions 通过；`scripts/package_smoke.rb` 新增无 Turbo HTML 回跳检查，修复前失败（500）、修复后通过；docs_examples、文档站构建、15 篇指南风格检查（0 错误 0 警告）、1,075 个本地链接无断链。曾尝试进程内 `with_routing` 测试，因 Rails 挂载 helper 和 Engine script name 是进程级全局状态而污染后续测试，已放弃，改用独立进程的安装烟测。Rails 7.2 矩阵、PostgreSQL 和浏览器本次未重跑：改动只涉及一个路由 helper 调用和一个翻译查找。
- **人工复查：** 阅读 `surfaces_controller.rb` 的回跳一行和 `surfaces_helper.rb` 的新 helper；运行 `bundle exec ruby scripts/package_smoke.rb`；在 components 指南中确认 `main_app` 和翻译说明的措辞。
- **风险与数据：** 无迁移、无依赖变化；授权、CSRF、回跳同源限制不变（`allow_other_host: false` 保留）。旧挂载名 `tool_views` 继续工作。
- **文档：** CHANGELOG、components/configuration/validation/production/whats-new 指南、human changelog、current work。运行流程未变，无需改图。
- **交付：** 在 main 提交并推送到 private `yorzi/rails_tool_views`，供 OddlyDock 的 Gemfile.lock 固定到该提交；不发布 gem。未启动长期进程。

### WORK-20261017-02 — 全面审阅与审计后的加固修复

- **内容与原因：** Andy 在本次会话要求对整个项目做 review/audit，验证正确性与最佳实践，并修复真实问题。基 `a1a9b26`。复现并修复两个真实缺陷：(1) 安装器迁移把 Presentation 的五列唯一索引建在无长度限制的 `varchar(255)` 上，utf8mb4 下 MySQL/InnoDB 按 5×255×4=5100 字节算，超过 3072 字节上限，建表直接失败；现在标识符列统一 `limit: 150`，最宽索引 5×150×4=3000 字节。(2) 身份匹配只做等值查询且上限 255 字节；在非二进制排序规则（MySQL 默认 utf8mb4、PostgreSQL 的 ICU/libc locale）下，仅"比较相等"的值可能解析到其它 scope 的 Surface、其它 correlation 的 presentation、其它动作回执或其它幂等 key。现在 `Data.identifier` 把被存储、被索引的标识符按字节限制到 150（description/version 仍用 255 的 `reference`），每次查找后再做字节级精确比对：`restore` 必须 actor/tenant/id 完全一致，`correlated_presentation` 与适配器回执在近似匹配时抛 `IDEMPOTENCY_CONFLICT`/`INVALID_CORRELATION`，`dispatch` 回放前必须幂等 key 完全相等。
- **映射：** IMPLEMENTATION_BUG（MySQL 建表失败、跨身份匹配）+ 安全面收紧；无产品意图变化，无新 delta。未改动原始 Specs。原“两份迁移无一致性测试”的发现已过时——`test/identity_test.rb` 早已断言两者逐字节相同。
- **验证：** `bundle exec rake test zeitwerk:check` 88 tests / 702 assertions 通过、eager load 通过（Ruby 3.3.5 + Rails 8.1.4，SQLite）；本地 PostgreSQL 17.11 同样 88/702（需先重建 probe schema）；`rake test:adapter`（RubyLLM 2.1.0）7/45 通过；`scripts/package_smoke.rb` 通过；docs_examples 通过；文档站构建后 1,075 个本地链接 0 断链、内部记录不外泄；15 篇指南风格检查 0 错误 0 警告。五个新测试逐一做了破坏验证：把守卫/长度限制改回旧实现后对应测试即失败（restore、correlation、幂等 key、适配器回执四个 collation 测试，以及迁移限制 5100 字节断言）。另外探测并推翻的疑似问题（顶层 JSON null/数组/字符串返回有界 400、props 内 NUL 在 PG `json` 上可往返、表单 helper 不产生多余 utf8/_method 字段）不记为缺陷。
- **人工复查：** 读 `lib/rails_tool_views/runtime.rb` 的 `exact_match?`/`correlated_presentation` 与 `restore` 的守卫；读迁移里 150 字节的注释与 `lib/rails_tool_views/core.rb` 的 `Data.identifier`；运行 `bundle exec rake test`。已有 host 无需数据迁移：旧列保留、限制在代码里执行；新 host 或 MySQL 才需要新的列定义。
- **风险与数据：** 无新表/新列/数据迁移，无依赖变化。行为变化：超过 150 字节的标识符现在被拒绝（`INVALID_SCOPE`/`INVALID_CONTEXT`/`INVALID_CORRELATION`/`INVALID_IDEMPOTENCY_KEY`），而不是截断或写入超长值——这对既有 host 是收紧，需在升级指南告知。授权、事务与幂等语义不变。MySQL 本身仍未运行；未重做真实 provider、浏览器/无障碍与远程 CI。
- **文档：** CHANGELOG、production/upgrading/whats-new 指南、agent current work 与验收表、human 状态/变更记录、本 ledger；新增 evidence/AUDIT_V2_VALIDATION.md。运行流程未变，无需改图。
- **交付：** 在 main 本地提交，未推送（用户未要求推送）。遗留一条需 owner 决定的建议：回放动作目前与首次执行同样发 `action.executed`，若要新增 `action.replayed` 会改变固定规格里列出的通知目录，故本次不改。未启动长期进程。

### WORK-20261018-01 — 发布前只保留一个名字（0.3.0.pre.v3）

- **内容与原因：** Andy 在 2026-10-18 的会话中问 gem 是否值得做、是否需要改名，并在两个选项中选了“Full single identity”。结论：gem 名 `rails_tool_views` 符合 RubyGems 下划线命名惯例，保留不改；需要去掉的是 0.1/0.2 遗留的第二套名字。删除 `ToolViews` 常量、`toolviews`/`tool_views` 入口、`tool_views:install`、`tool_views_*` helper 和 `:tool_views` 路由回退。表、索引、I18n、通知、`Rails.error` source、DOM/CSS/Stimulus 和续接 delivery key 统一改为 `rails_tool_views` 前缀。原因：gem 尚未发布，现在去掉没有外部成本；发布后这些别名都要永久兼容，而且顶层 `ToolViews` 会占用一个不属于本 gem 的名字。
- **映射：** PRODUCT_INTENT_CHANGE，经 owner 批准，记为 DELTA-004 / ADR 006。命名补充合同 TV-05 允许“读取旧记录或显式迁移”，本次选择显式迁移。组件契约、digest、Surface ID、revision 与回放语义不变。原始 Specs 未改。
- **人工复查：** 读 ADR 006 和 Upgrading 指南中的迁移片段；看 `app/helpers/rails_tool_views/surfaces_helper.rb`，确认已无别名循环和旧挂载回退；看 `test/identity_test.rb` 和新增的 Stimulus 标识测试；按 `bin/demo` 试一次保存后刷新。
- **验证：** Rails 8.1.4 与 7.2.3、Ruby 4.0.2 下均为 89 runs，0 failures，eager load 通过。adapter 7/45 通过；打包安装和文档示例通过；文档站构建通过，1,042 个链接无断链，样式检查 0 问题。PostgreSQL 和 MySQL 本次 NOT RUN（本机没有数据库服务）。改名中发现一个真实缺陷：`data-tool-views-*` 属性漏改，Stimulus 因此不绑定。OddlyDock 的浏览器测试暴露了这个问题，已修复并加回归测试，详见 IDENTITY_V3_VALIDATION。
- **风险与数据：** 对 0.2 主应用是破坏性变更，需要一个可回滚的改表迁移。在部署前要排空续接，并刷新已打开的页面。唯一的 0.2 主应用 OddlyDock 已在开发库上做过正向、回滚、再正向迁移，数据保留。授权、CSRF、幂等不变，没有新增依赖。
- **文档：** README、Upgrading/What's New/Release History/组件/Surface/校验/生产/入门指南、runbook、发布清单、ADR 005 标注被取代、ADR 006、DELTA-004、验收表、human 状态/架构/变更记录、SPEC_BASELINE、CHANGELOG、current work，以及本节。
- **交付：** 已在 main 本地提交，未推送。临时 demo（127.0.0.1:3111）已停止。下一步：Andy 审阅后推送本仓库，再推送 OddlyDock 的对应提交。

### WORK-20261018-02 — Prepare 0.1.0 gem and hosted documentation

**What / why:** Andy 要求完成 gem 文档、GitHub Pages、DNS，参考 ruby_llm-browser 发布 0.1.0；随后明确选定 MIT、公开仓库、私密安全报告与域名，并确认创建精确限定的 OIDC 发布权限。统一首次公开版本，补齐元数据和标签发布流程；主线与稳定版文档分别在 next 与根路径。FR-08/NFR-03，DELTA-005，外部 Specs 不改。

**Human review:** 阅读 README 和线上 Getting Started；核对安装命令、MIT、私密漏洞入口；查看 release.yml 的匹配元数据/完整兼容性/实际依赖审计/打包/文档检查与 OIDC 发布边界。发布状态以 RELEASE_0_1_0 为准。

**Validation:** 本地 Ruby 3.3/Rails 8.1.4、Ruby 3.3/Rails 7.2.3.2、Ruby 4.0.2/Rails 8.1.4 各 89 tests / 723 assertions，adapter 7/45；eager load、文档示例、打包主应用、15 页文档检查、站点构建与 1,042 链接均通过。六份 lockfile 安全审计通过。初次共享库并行测试失败及 probe 自身错误均已修正并顺序重跑；详细证据保留边界。独立网络解析安装与激活依赖审计通过；精确提交的远端/上传证据另行记录。

**Risk / data / security:** 无 API/schema/业务数据迁移。修复发布依赖隐患：Rails 7.2 测试补丁及 CGI/ERB/Resolv/URI/Zlib 下限；25 个 gem 文件排除内部记录、数据库与凭证。DNS 仅新增指定子域名，发布凭证由 OIDC 临时取得。无 provider 调用或临时服务。开放的独立安全审查、MySQL、真实 provider、外部采用与正式 H2/C/R 未被改为 PASS。

**Docs / alignment / next:** 更新 README、用户指南、release checklist、baseline 授权补充、delta、acceptance、status、human changelog 与 evidence；架构/运行序列不变。下一步：推送候选并验证其远端 CI，推送匹配标签、核验 RubyGems 与 stable/next Pages、HTTPS，然后记录实际交付结果。

### WORK-20261018-03 — Complete Ruby 4 registry checksum

**What / why:** 0.1.0 候选 4f2d6fc 的 Linux Ruby 4 在冻结安装阶段失败：macOS Ruby 4 的默认 CGI 0.5.2 留下空 CHECKSUMS，Linux 需要远端校验和。用 `bundle lock --add-checksums` 从 RubyGems 再生成唯一缺失的 SHA-256；没有更改依赖版本。FR-08/NFR-03 发布兼容性修复。

**Review / validation:** diff 仅增加 CGI 0.5.2 checksum；本地 Ruby 4 frozen `bundle check` 通过。前一候选其它四组 CI 和 Docs 部署成功；修补候选需重新通过远端 CI 后才打标签。详见 RELEASE_0_1_0。

**Impact / docs / alignment:** 无运行时代码、API/schema/数据变化，保持冻结与校验和检查。更新发布证据与本 ledger；架构和用户文档无需变化。下一步：验证本提交的完整 CI，随后发布并检查证书。

### WORK-20261018-04 — Record verified 0.1.0 publication

**What / why:** 完成 Andy 已授权的正式交付：`v0.1.0` / `f2d4303` 通过 OIDC 发布到 RubyGems，GitHub Release 带 gem 与 SHA256SUMS；Pages 稳定版与 next 上线，指定 DNS 与强制 HTTPS 生效。更新真实当前状态，FR-08/NFR-03，DELTA-005。

**Human review:** 打开 https://rails-tool-views.wangyaodi.com，检查版本菜单与安装命令，搜索 idempotency；打开 RubyGems 0.1.0 和 GitHub Release，比对 SHA256SUMS。后续发布操作见 operations/02_RELEASE_CHECKLIST。

**Validation:** 精确标签 release run 39117821018 全绿：三组 SQLite 与 PostgreSQL 各 89 tests / 723 assertions；adapter 7/45；metadata/package、六份 lockfile 与实际激活依赖安全审计、独立网络安装、稳定/next 构建及 2,152 链接通过。post-release Pages run 39118079958 全绿，10 个 HTTPS 入口返回 200；浏览器搜索/版本切换与首页已检验。RubyGems API、registry 下载、Release 附件与 SHA256SUMS 均为 `85e3a516cc20700969edbf474d90e9e20c322334d942735882eabc699d95b166`。与前置验证 artifact 的 25 个文件及 gemspec 一致，tar 时间戳不同，不声称跨 job 二进制可重现。

**Impact / alignment:** 本 commit 只记录交付，不改包或 tag；无 API/schema/数据变更。MIT、MFA、OIDC 与私密安全报告已观察；未使用长期发布 key。正式 H2/C/R、独立安全审查、MySQL/provider 与外部采用仍开放。未启动临时服务，所有临时安装进程已完成。

**Docs / next:** 更新 evidence、status、at-a-glance、feature map、human changelog、current work/post-flight、acceptance 和 operations。架构与运行序列无需改图。无剩余发布任务；后续按用户优先级处理。

### WORK-20261018-05 — Simplify project docs and propose the road to 1.0

**What / why:** Andy 要求精简 GitHub README、平衡仓库 Markdown 和 doc site，并安排简单的 0.2.0 功能与 1.0 前迭代。README 从 90 行缩为 34 行；使用说明归 doc site，贡献/安全/变更/计划归各自 Markdown。修正 CONTRIBUTING 与 next Production 中未发布/无许可证的陈旧说法；当前状态和任务不再堆积已完成历史。FR-08 文档维护，无运行时修改。

**Plan / human review:** ROADMAP 是唯一版本计划：0.2 组件生成器/完整 HTML 错误反馈，0.3 生命周期/保留，0.4 续接恢复/诊断，rc1 冻结契约和升级/外部验证，再满足条件发布 1.0。对照当前缺口审阅每版 scope、done/stop 条件与 1.0 兼容/安全/接入证据；不要把提案当作已实现或已批准的新契约。新增导航链接，不复制一套站内路线图。

**Validation:** 32 个仓库 Markdown 本地链接，零断链；15 篇指南检查零错误/警告；可执行文档示例通过；stable/next 构建成功，2,152 生成链接零断链，内部记录未进入站点。`git diff --check` 通过；提交前 staged linkage，提交后 range linkage。未本地重跑 runtime/adapter/数据库套件，原因是仅 prose/navigation 变化；现有 CI 会按提交运行。

**Impact / alignment:** gem 仍为 0.1.0，未改依赖/API/schema/数据或发布新 gem。原 Specs 的 pinned roadmap/launch 两文件已比对；没有改外部 Specs，也没有把生命周期/通知/新适配器决策视为批准。当前状态和计划的角色变化写入 human changelog 与 maintenance；架构/流程不变，无需改图。没有启动临时服务。

**Next:** 提交推送本次 GitHub 文档更新并核验。开发下一单元前先走一次独立 host 接入，建议优先组件生成器；本次不开始 0.2 实现。稳定站点保留 v0.1.0 快照，main 文档更新在 next。

### WORK-20261018-06 — 建立 agent 浏览器与实际安装验证循环

**内容/映射：** 按 Andy 授权开始 0.2。独立浏览器 bundle、临时 SQLite、loopback Puma/Chrome、截图与 CI job；统一 developer/isolated 安装 host fixture，空 GEM_HOME 从仅加载升级为完整安装/渲染/表单/持久化/eager load。FR-07/08 测试基础，无产品意图 delta；59 个 Specs 文件比对 pinned revision 一致。

**复查/验证：** `bin/check-browser` 3 runs / 18 assertions PASS，检查移动端字段错误截图，值保留且无横向溢出。core 89/723、adapter 7/45、eager load、docs examples、package PASS。隔离 full host 与 activated-dependency audit PASS（fa2295251efb3b0d1a300e5ce8ad700ff1f1b485）。浏览器测试发现测试线程 SQL 缓存会掩盖服务端写入，改用 uncached 断言；Selenium 默认探测所有接口，改为 loopback。CI YAML 已解析；远程 CI 尚未运行。

**影响/文档/下一步：** 无 runtime API/schema/迁移，浏览器依赖仅开发使用。更新 CONTRIBUTING、操作手册、状态、验收与 checklists；架构/运行序列不变。临时 host/数据库清理，浏览器/driver 随测试退出，无保留服务。main 本地提交；下一步 WORK-07 安全组件生成器。

### WORK-20261018-07 — 安全的 Partial 组件脚手架

**内容/映射：** FR-01/02/08；`rails_tool_views:component review_card` 创建注册定义、Partial、Minitest。组件和动作 policy 默认 false，props/arguments 均闭合有界，无 agent exposure 和业务写入。遵循 core 的 64 字符 key。所有输出写前检查，已有文件（含 --force）、非法名称、越界符号链接拒绝；不重写 host initializer。统一共享 to_prepare 加载，避免多组件 reload 相互清除。实现层 ergonomics，无产品意图 delta。

**复查/验证：** 新测试先因命令不存在而失败；实现后 3 tests / 46 assertions PASS，覆盖默认拒绝、额外字段、多组件 reload、冲突与 symlink；全套 92/769 与 eager load PASS。实际打包 gem 的新 host 生成、默认拒绝、显式授权后 escaped render/HTTP 保存及生成 Minitest 1/2 PASS。16 篇指南 lint 零问题。最终跨版本/隔离安装/站点构建安排 WORK-09，远程 CI 未运行。

**影响/文档/下一步：** 无 schema/migration/dependency；既有手写定义不变。新 Generating a Component 指南、components/What's New/upgrading 与安装模板同步；状态、验收、checklist 更新。运行时架构不变，无需改图；测试 host 清理，无保留进程。main 本地提交。下一步完整 HTML 错误/纠错页面。

### WORK-20261018-08 — 完整 HTML 纠错与安全返回

**内容/映射：** FR-07：Engine HTML GET/错误使用自有完整 layout（lang/title/viewport/CSRF/main），授权后保留组件字段与 reload link。跨身份拒绝不呈现 props/表单。修正后 Referer 若为 POST-only Engine route，303 到可读 Surface，修复 GET /actions 404。嵌入 helper、JSON/Turbo/status/重新授权边界不变。实现层修复，无产品意图 delta。

**复查/验证：** 四个 HTTP 测试先失败，再增加 CSRF；合计 5/66，完整 core 97 tests / 835 assertions 与 eager load PASS。Chrome 4/28 PASS，包括真正禁用 JavaScript 的表单 error/correction/refresh，390px 设备模拟。检查移动错误截图，字段保留、标签/描述连接且可读；没有完整 screen-reader/物理设备审核。现有 Turbo/JSON suites 全绿。最终兼容矩阵、build、isolated host 由 WORK-09 完成。

**影响/文档/下一步：** 无 schema/migration/dependency；Engine layout 不加载 host 资产或依赖其 controller 实例变量，host 可覆盖，保留语义元素。更新 validation/upgrading/What's New、runtime flow、ADR 007、status/acceptance/checklists。浏览器/driver/Puma 随测试退出，无保留服务。main 本地提交，下一步版本元数据与最终验收，不自动发布。

### WORK-20261018-09 — 完成 0.2 本地候选验收

**内容/映射：** FR-01/02/07/08；版本/六份应用锁 path entries/站点对齐 0.2.0，changelog/history 与 docs 标记未发布。补强“只允许展示而未授权动作”公开 dispatch 拒绝测试；冻结安装输入副本并记录 SHA-256，避免构建覆盖正在验证的 artifact。实际 host 增补 JSON/Turbo replay、HTML stale/cross-scope denial、生成组件 HTML correction/restore。无产品意图 delta，Specs 不改。

**复查/验证：** Ruby3.3.5/Rails8.1.4、Ruby3.3.5/Rails7.2.3.2、Ruby4.0.2/Rails8.1.4 及 PostgreSQL17.11 各 97/837/eager load PASS；adapter 7/45、两种 docs examples PASS。冻结包三组实际 host 与生成 Minitest 1/2 PASS；空 GEM_HOME network resolve/full host/activated audit PASS。包 SHA256 e3c784de6f8527db6091b86b059945de2a0be112b9a2237fcf240904c4069a30，31 个打包文件；七份锁 audit clean，公告 fa2295251efb3b0d1a300e5ce8ad700ff1f1b485。Chrome 4/28，禁用 JS/390px；故意失败截图探针验证实际页面被捕获，恢复源码后全绿；人工 Tab→Enter invalid/correction/refresh PASS。16 guides zero errors、两条预期 unreleased/tag warnings；build/2,210 links/内部内容排除 PASS。candidate package gate PASS，正式 gate 对 unreleased 按预期拒绝。详细命令/范围见 V0_2_VALIDATION。

**影响/文档/下一步：** 无 migration/schema/runtime dependency，授权/CSRF/replay 不变。更新 Getting Started/What's New/upgrading、ROADMAP、操作/状态/feature map/实现图景、baseline 授权与验收；HTML flow/ADR 已在 WORK-08 更新。临时 demo 127.0.0.1:3198 PID51497 已停止，临时库删除；浏览器/driver/Puma 和临时 PG databases 清理，已有 PG 服务不动。main 本地第四次提交，无推送/tag/gem 上传/provider；下一步 owner 审阅后授权候选推送、remote CI，再准备发布标记和标签。不自动开始 0.3。

### WORK-20261018-10 — 准备并推进已授权的 0.2 发布

**内容/映射：** Andy 明确授权推送候选、检查远端 CI、再发布 0.2.0。FR-08/NFR-03；版本不再改动，补齐日期/released flag、聚焦 0.1→0.2 升级指南、新版 What's New 路径与导航；0.1 What's New 保留旧 URL，旧升级指南链接到 immutable v0.1.0。baseline/delta 只追加授权，Specs 不改；无 runtime/API/schema/依赖变化。

**复查/验证：** 实际新包 host 的安装/迁移、JSON/Turbo replay、stale/scoped denial、生成组件 HTML 纠错与持久化/eager load PASS，生成 Minitest 1/2；正式 release package gate PASS（31 files），docs examples PASS。17 guides zero errors，一条预期 pre-tag version warning；stable/next 构建与本地链接检查 PASS，内部内容排除。impact 提示 ApplicationController removed 是误报：core 默认仍为 ::ApplicationController，configuration 指南保留。完整本地运行矩阵见 V0_2_VALIDATION；精确候选的远程 CI 尚待推送运行，不提前声称通过。

**影响/下一步：** MIT/OIDC/release 环境、私密安全报告、Pages HTTPS 现状已复核；无权限/DNS 改动，无 provider 或外部客户通信。没有启动临时服务。先提交推送，等待本提交完整 CI，随后 annotated v0.2.0 触发 OIDC，核对 registry/Release SHA256 与 hosted docs，再由 WORK-11 单独记录实际交付。架构与运行序列不变，无需改图。

### WORK-20261018-11 — 记录已核验的 0.2.0 正式交付

**内容/映射：** 完成 Andy 明确授权的候选推送、远程 CI 后发布。v0.2.0 指向 3156fd38f9fde60c3d8d582853a84b3d9d71e3d5，经现有 OIDC 上传 RubyGems，GitHub Release 与稳定/next Pages 上线。FR-08/NFR-03；不移动已发布标签，不改 runtime/API/schema/依赖或外部 Specs。

**复查/验证：** main CI 39126752647、候选 Docs 39126752515、Release 39126933977、发布后 Pages 39127199725 全绿。标签三个 Ruby/Rails 与 PostgreSQL 各 97/837，adapter 7/45，Chrome 4/28；31-file package、生成测试、隔离安装/激活依赖审计、2,450 docs links PASS。registry API/实际 gem fetch/GitHub gem/SHA256SUMS 都是 5fd6a193dd9e69be3277ef34ff63802118031c51fee95ddcf4952af46d307367；31 个文件逐字节与本地一致、gemspec 契约相同（工具版本/文件排序不同，不声称跨 job 二进制复现）。版本页确认 MFA/精确 workflow publisher。稳定0.2/next 安装、搜索生成器指南、版本切换和 15 HTTPS 页面验证通过。详见 RELEASE_0_2_0；此记录自己的 post-push CI 需在提交后确认并在最终回复交接。

**影响/下一步：** 无迁移、新权限/DNS/长期 key/provider/客户联系；既有正式/安全/MySQL/adoption gaps 不变。更新 status/map/roadmap/operations/acceptance/checklist/evidence/current work；架构/运行序列无改动。没有启动本地服务；watchers 已结束，客户端临时目录删除，浏览器页关闭，下载包和截图保留 ignored tmp。提交推送本记录并核验最终 CI；本次无剩余发布操作，不自动开始 0.3。

### WORK-20261019-01 — 生命周期与安全关闭

**内容/映射：** owner 授权推进 0.3；FR-04/05/06/07/08。新增 close/abandon、四个 Surface 时间戳与 delivery_uncertain 加法迁移，installer 同步。read 和专用 policy 授权、关闭只读、新动作 410，历史回执和关联重放保持。Surface-first 认领/关闭锁；callback 事务外。旧投递 delivering 或 attempts>1 升级保守标记；后续回写不能清除。nil 保留无限期，首次终止决定不变。

**复查/验证：** 聚焦测试先失败再实现；core 106 tests / 923 assertions + eager load PASS，覆盖重复关闭、跨 scope、专用 policy、pending/failed abandon、两个过期并行回调的保护。实际包新 Rails host 安装两个迁移、HTML 关闭与旧回执重放、标准 migration copy 去重、生成 Minitest 1/2 PASS；19 guides zero errors/two expected unreleased warnings。完整 matrix/upgrade/清理/browser/build 留后续，不称远端通过。

**影响/文档/下一步：** 升级需停旧 web/workers；已有 delivering 和历史多尝试可能永久受保护，没有强制清理或自动重开。旧 acknowledgement 的 exactly-once 不在本版修复范围。ADR 008、独立指南/升级/What’s New、human architecture/flow/map/status、acceptance/checklists 同步；59 Specs pinned 文件一致，无 intent delta、通知或依赖扩张。无长期进程，main 本地提交；下一单元显式保留策略和 payload 清理，不推送/发布。

### WORK-20261019-02 — 授权的 payload 清理与真实 demo

**内容/映射：** FR-04/05/06/07/08，purge_closed 默认 preview，config.retention_policy 默认 deny。限定 exact owner scope、past cutoff、已到期非 nil deadline、1..1000 Surfaces；锁内复查策略和终态，原子删除 interaction/receipt 并 scrub props/state/context。Surface/Presentation tombstone 保留，旧关联/动作 410，不重建业务动作；host 表不动。dummy 加 CSRF/session scope 控件，清理后 gallery 不 restore tombstone，日志仍读 host Effect。

**复查/验证：** 新 retention 测试先因缺少入口失败，再覆盖 preview no writes、strict policy、跨 scope、cutoff/deadline/batch、锁后 scope 变化、stale action、未知/未终止/uncertain 保护、注入 update failure 全图回滚与重试。完整 core 114/988 + eager load PASS；实际 installed host preview/apply/410 与 generated Minitest 1/2 PASS。Chrome 5/40 PASS，检查 closed-preview/cleaned-business-log 截图。初次 browser 期望文案错误，纠正为实际 View closed 后通过。19 guides zero errors/two expected unreleased warnings。PG 并发/旧 runtime 升级与完整 matrix 留 WORK-03。

**影响/文档/下一步：** 非完整删除/磁盘回收，opaque metadata 与 host backups 仍需保留政策；policy 必须无副作用，批次不保证 child 行数，protected rows 可占满一批。没有自动 job/force/恢复绕过。public lifecycle/config/API/What’s New/changelog、ADR/architecture/flow/acceptance/checklists 同步；implementation aligned，Specs 不改。browser/Puma/driver 随 runner 退出，无保留进程。main 本地第二提交，不推送/发布；继续升级与完整验收。

### WORK-20261019-03 — 真实升级与兼容性候选验收

**内容/映射：** FR-04/05/06/07/08；新增 immutable v0.2 runtime → working runtime 的独立进程升级 fixture，验证标准 migration copy、旧数据/receipt/correlation、保守 backfill、未使用时 down/up、关闭后拒绝 downgrade、清理后五条业务记录保留。接入三个 core CI 组合与 bin/check。真实 PG 双 cleaner/action-close 测试；guide close/preview/apply 可执行。修复 Rails7.2 无法识别 Rails8.1 SQLite boolean default 引发 nil 的兼容问题，用明确模型 default:false。

**复查/验证：** 三个 Ruby/Rails SQLite 组合各114/988/eager load；PG17.11独立临时 DB116/1000，adapter7/45；三组升级/实际包 host 与 generated Minitest1/2 PASS。空 GEM_HOME 网络解析/full host/activated audit PASS，SHA b82d0e09924d776e4f2e30de13c49cbed34299e9d80779f7ddb1072ea984fdcb，35 files。七份 locks 审计无已知漏洞（刷新公告 fa229525）。Chrome5/40、core/adapter 文档代码、19 guides零错误/两条预期版本警告、stable/next build/2,571 links PASS；candidate gate PASS，formal gate 按 unreleased 正确拒绝。V0_3_VALIDATION 记录具体范围/复现/失败修复；shared SQLite 并行干扰后全部串行重跑，browser inspector stale-document 错误后 lifecycle 使用原生 no-JS 流程，既有 Turbo 场景保留。

**影响/文档/人工复查：** 审阅 ADR008 与生命周期/升级指南，按 demo 保存→关闭→预览→到期 apply 检查业务日志，再查 evidence 三组 upgrade/PG 竞争边界。需要加法迁移、停旧 writers 与完整备份；元数据 tombstones/uncertain 隔离不声称完全抹除或 exactly-once。更新状态/功能图/一眼图景/路线图/操作手册/验收/checklist/ledger；architecture/flow 已在前两单元同步。无依赖版本、新通知或产品意图扩张，Specs 不改。临时包/DB/Chrome/driver/Puma 清理，已有 PostgreSQL 服务保留。

**下一步：** 0.3 本地候选完成，main 第三提交；owner 审阅后再授权推送、远端 CI 和发布。本地证据不等于远端/发布；MySQL/provider/adoption/独立安全/full a11y/正式 H2/C/R 仍开放，不自动开始0.4。

### WORK-20261019-04 — 推进已授权的 0.3 发布

**内容/映射：** Andy 明确要求发布0.3、同步文档与提交，授权 candidate push/remote CI/tag/OIDC/Release/Pages。FR-08/NFR-03；设置日期与 released:true，What's New/History/upgrading、release procedure、baseline/delta/current work/status/roadmap 同步。Runtime/API/schema/依赖与已验收候选不变，外部59 Specs仍与 pinned0ea28b1相同。

**复查/验证：** 实际35-file artifact 新Rails host install/migration/HTTP/actions/closed replay/preview/apply/410/标准迁移去重/eager load PASS，生成Minitest1/2；正式release package gate与可执行guide PASS。19 guides零错误，一条预期pre-tag warning；stable0.2/next build、2,571 links及内部内容排除 PASS。完整本地矩阵/PG/upgrade/isolated/browser见V0_3_VALIDATION，本单元不重标为remote。Refetch确认v0.3.0未占用，repo PUBLIC、release环境、DOCS_PUBLISH、Pages HTTPS和私密报告已观察。

**影响/下一步：** 0.3需迁移/停旧writers/备份，uncertain与tombstone边界不变；本commit只准备正式发布，不声明远端或上传成功。无新权限/DNS/provider/长期key/架构变化，无需重画图。无本地服务。提交推送后等精确CI，再annotated v0.3.0触发现有OIDC；实际交付由WORK-05记录，不移动已发布tag。

### WORK-20261019-05 — 记录已核验的 0.3.0 发布

**内容/映射：** 完成Andy明确授权的0.3候选推送、远端CI后发布。immutable v0.3.0→d12996ed2dc6a0dbf3d5041ac4d31da789789a9b，既有OIDC上传RubyGems，GitHub Release与stable0.3/next Pages上线。FR-08/NFR-03；此记录不改runtime/API/schema/依赖/通知/Specs，也不移动tag。

**复查/验证：** main CI39229304949/Docs39229304982，tag CI39229612275/Release39229612284，post-release Pages39230070227全绿。精确tag三组SQLite各114/988、PG116/1000（真实锁竞争）、adapter7/45、Chrome5/40；三个真实旧runtime升级/installed host与generated1/2、隔离network/full host/activated audit、七份locks审计与2,692links PASS。RubyGems API/direct/client fetch、GitHub gem/SHA256SUMS均为01e004ba5deb2cba23d175a3d8110d1ed3cbbcc6c128cc9b735c0f380aed76a3；35个文件逐字节与本地相同，normalized gemspec契约一致，工具/时间序列化不同不声称二进制复现。

**Hosted/复查入口：** RubyGems版本页显示MIT/MFA与限定release.yml/release publisher；Release非draft/prerelease。16 HTTPS入口返回200，stable安装0.3、next main、lifecycle search/API/upgrade/canonical/HTTP→HTTPS PASS；真实Chrome搜索进入Lifecycle，version菜单切Next。详见RELEASE_0_3_0，review前先读升级停旧writers/备份/不可危险downgrade与retention tombstone/uncertainty边界。

**影响/文档/下一步：** 更新status/map/at-a-glance/roadmap/operations/acceptance/checklists/evidence/current work；架构不变，无需改图。无新权限/DNS/长期key/provider/host生产迁移，正式H2/C/R、安全/MySQL/adoption gaps保持。未启动本地服务，workflow watchers完成，临时extract清理、Chrome核验页关闭；下载证据保留ignored tmp。提交推送本记录并检查它自己的CI/Docs，在最终回复交接实际结果；无剩余gem发布操作，不自动开始0.4。

### WORK-20261020-01 — 0.4 有界投递恢复

**内容/映射：** Andy 授权按路线图推进0.4并保持简单。FR-05/06/07、SEC-04/06/11/18；复用既有 attempts 为确认 fence，旧 success/failure 不能覆盖新 claim 或发误导终态通知；deliver 在 host 外层事务内明确拒绝。dummy 增加 host-owned Active Job，重新解析当前 staff/权限；独立 Rails 进程在 host effect/receipt 提交后退出，再以稳定 delivery_key 恢复。无新表、迁移、runtime依赖、内置队列或清理绕过。

**复查/验证：** 基线114/988/eager load；新增四个行为回归在旧实现真实失败，修复后4/30；job/restart/crash/retry/revocation4/39，完整core122/1057/eager load PASS。实际构建gem的临时Rails host/HTTP/lifecycle/replay/cleanup/生成Minitest1/2 PASS。20-guide lint零错误，两条预期unreleased警告；docs构建与后续完整matrix/PG/browser/upgrade不提前标PASS。59 Specs与pinned0ea28b1逐字节匹配。

**影响/人工复查：** 阅读ADR009、Continuation和Upgrading；在host事务外运行job，验证业务effect后进程中断、租约到期同key恢复。需停止旧workers，避免其无fence确认；无新迁移。fence只保护Engine状态，远端仍需host durable dedup，uncertain仍隔离，不能凭时间强清。更新版本为本地0.4候选/released:false、What's New历史导航、状态/功能图/流程/runbook/验收。架构实体不变，无新图。归类IMPLEMENTATION_BUG和技术实现；通知/临时notice兼容性决定已提问，尚未实施。临时包清理，无新长驻服务。

**下一步：** 完成已确认的诊断/反馈范围与完整本地验收；不推送/发布0.4，不调用provider，不改外部Specs。

### WORK-20261020-02 — 元数据诊断与真实界面反馈验证

**内容/映射：** FR-07、SEC-11/18；以 sentinel 证实现有普通错误日志暴露 host 异常消息，改为event/class，不拷贝消息和栈；原异常仍由host Rails.error处理。新增Operational Diagnostics指南，列出现有event和metadata、观测非durable outbox、当前delivery排障方法与host日志隐私边界。

**复查/验证：** 隐私回归先失败后通过，privacy8/67，完整core123/1063/eager load。Chrome6/61：键盘提交/重试、aria-busy/按钮禁用、字段错误焦点、更新后status焦点、390px失败/恢复/刷新，并验证只创建一份reply/host receipt/action receipt。loading/failed/recovered三张截图已人工检查。首轮sandbox loopback EPERM不是产品缺陷，获得执行许可后真实重跑通过。21-guide lint零错误/两条预期候选警告，stable0.3/next build与2,822links通过。

**影响/人工复查：** 阅读diagnostics与upgrading；普通日志解析器改用event metadata或host Rails.error，原异常隐私仍需host控制。截图与browser操作只用合成数据；无provider/外部联系。无新schema/runtime依赖/客户端框架；兼容性决定尚未答复，故保留现有action.executed和持久state.message，未新增replayed字段或notice。Implementation bug/privacy hardening，无产品意图改动；ADR009/操作/验收/checklist/What's New同步，实体/流程不变无需新图。所有本轮Puma/Chrome/driver已结束。

**下一步：** 完成实施部分的matrix/PG/实际包/旧数据升级/隔离安装/审计；重放与notice待owner选择后才实现，不能将0.4标为完整或发布。

### WORK-20261020-03 — 已批准的重放元数据与临时提示

**内容/映射：** Andy 明确选择保留action.executed并增加replayed:false/true，新增显式notice并保留state.message；实现前记录DELTA-006。FR-05/07、SEC-04/06/11/18。Transition.notice限制500bytes纯文本，事务中校验，SafeBuffer也转为普通String后转义；不写Surface state/snapshot或通知。动作回执保存notice以保持精确重放；JSON/Turbo响应显示，HTML用既有Rails flash绑定Surface/actor/tenant一次消费，无URL载荷。demo增加临时反馈模式。

**复查/验证：** 六个feedback测试先在旧实现失败，修复后6/65；完整core129/1129/eager load PASS。Chrome8/77，Turbo/禁用JS保存notice→刷新消失而选择仍在；旧message场景仍通过，截图已检查。核对诊断目录发现数据库回滚映射CONFLICT却漏发已有event，三类rollback回归先失败后补齐code-only通知。22-guide lint零错误/两条预期候选警告；stable0.3/next build、2,897links与内部排除PASS，RDoc常量链接由检查定位后修正。

**恢复验证基础：** 实际包host增加事务拒绝、durable host receipt重试和notice核验；upgrade runner现在分别启动不可变0.2/0.3，再切当前runtime，覆盖0.3已closed/purged旧guard、旧state/receipt/correlation、uncertainty、rollback与业务保留；PG增加fresh双claim互斥。先前PG126/1079通过，首轮测试线程读query cache旧值后改uncached；最终增加feedback后的matrix/PG/包/隔离安装留WORK-04。

**影响/人工复查：** 阅读新feedback指南/升级与ADR009，试demo临时反馈并刷新，对比旧持久message。notice的临时性是显示寿命，回执仍存储，不能放秘密或当作擦除保证；host负责Rails.error/flash访问。无新migration/runtime依赖/队列/frontend框架；旧worker需停止后切新fence。同步路线图已确认选择、status/map/flow/human changelog、验收/checklist与API/What's New；结构无新实体无需新图。外部Specs未改，浏览器/driver/Puma已结束。

**下一步：** WORK-04对最终代码完成全部本地验收并提交证据；0.4不自动推送、tag或发布。

### WORK-20261020-04 — 0.4 完整本地验收与交接

**内容/映射：** FR-05/06/07/08、SEC-04/06/11/18；对最终runtime6d90216完成支持矩阵、真实旧runtime升级/包/隔离安装/审计/文档验收，记录V0_4_VALIDATION。升级提示明确drain旧web和worker回调，避免混用无fence确认。除文档/验收记录外，本commit不改runtime或包内容。

**复查/验证：** Ruby3.3.5/Rails8.1.4、3.3.5/7.2.3.2、4.0.2/8.1.4三组SQLite各129/1129/eager load；PG17.11独立临时DB132/1145（fresh双claim、overlap、cleaner/action-close）；adapter7/45、Chrome8/77。三个组合actual包host/generated1/2、不可变0.2/0.3独立进程升级PASS，旧closed/purged guard/回执/关联与业务记录保留。空GEM_HOME network/full host/activated audit PASS，最终artifact SHA58fd80ccd37505015fada90c10b561e24167e30b391ada153eaef60a162ce86a，35 files，前后相同。七份锁审计无已知漏洞（刷新fa229525/1266），22-guide lint零错误/两条预期候选警告、stable0.3/next build/2,897links/internal exclusion PASS，candidate gate PASS；formal gate按released:false正确拒绝。

**证据/影响：** V0_4_VALIDATION说明每个失败优先回归、PG query-cache测试修正、sandbox bind与RDoc link修正、fixture截图与可复现命令；不隐藏失败或把本地证明改写成remote。无新schema/migration/runtime依赖/queue/仪表盘/frontend framework。notice是响应显示寿命，回执仍留存；旧message兼容，fence不等于远端exactly-once，uncertain仍隔离。59 pinned Specs未改，DELTA-006已由owner明确批准。

**文档/人工复查：** 更新Current Work、status/map/at-a-glance、implementation、roadmap、runbook/upgrade、acceptance/postflight与evidence；review先读反馈/续接/升级三指南，再试临时提示刷新和失败重试。结构/实体不变，无新diagram。Chrome/driver/Puma已结束，独立PG临时DB核验已删除，包/升级/隔离tempdirs清理；既有PG服务不动，无预览/watcher/tunnel遗留。

**下一步：** 0.4本地候选完成，等待owner审阅后另行授权推送/精确远端CI及发布；本轮未推送、tag或上传，公共稳定0.3不变。provider/MySQL/外部采用/独立安全/full a11y/正式H2/C/R仍开放，不自动开展无关迭代。

### WORK-20261020-05 — 0.4 授权发布准备

**内容/映射：** Andy明确要求远端CI、发布验收、文档及发布，授权本候选push/tag/OIDC/Release/Pages及交付记录提交。FR-08/NFR-03；更新0.4日期/released/history/What's New、baseline授权/currentwork/status/发布流程。运行时代码冻结于6d90216，DELTA-006和59份pinned Specs不变。

**验证：** 最终元数据core129/1129/eager load，35-file正式包gate、实际Rails安装host/生成测试1/2、空GEM_HOME网络安装/full host/activated audit、可执行core文档通过。七锁审计fa229525干净；22-guide lint零错误/一条预期打tag前版本warning，stable0.3/next build2897links和internal exclusion通过。impact唯一新名称raise_action_conflict!已private/:nodoc，相关helper/render/notice/recovery/升级示例已复查。准备包SHA2231ea7a17f3ebd260302c12f4d80e9d7b6aa1386f37979c9cbd86462a35ed80；不是发布校验和。完整本地matrix/PG/browser/旧runtime升级见V0_4_VALIDATION，不重标为远端结果。

**影响/人工复查：** 阅读What's New/Upgrading/Feedback/Continuation，升级时drain旧web/worker，deliver置于host commit后；notice回执仍保留，旧message兼容。无新schema/runtime依赖/权限/DNS/provider调用；formal/MySQL/adoption/独立review缺口仍保留。文档版本与运行手册变化，不改结构图。未启动本地服务，isolated host临时目录已清理。

**下一步：** 本commit推送后等待精确main CI/Docs；通过再annotated v0.4.0与既有OIDC发布，核验registry/Release/HTTPS。WORK-06另记真实交付结果并提交推送；当前不提前宣称远端或发布成功。

### WORK-20261020-06 — 0.4 远端发布与公开验收

**内容/映射：** 完成owner授权的0.4公开交付，FR-05/06/07/08、NFR-03；annotated v0.4.0固定e93f8df。新增RELEASE_0_4_0证据，更新Current Work/status/at-a-glance/feature map/implementation/roadmap/runbook/checklist/acceptance/human changelog；站点release日期/What's New/Upgrading已随候选提交。无新运行时代码或架构实体，无需新图。

**验证：** mainCI39360489574/Docs39360489799，tagCI39360617577/Release39360617626全绿。精确tag三组SQLite129/1129、PG132/1145、adapter7/45、Chrome8/77；真实0.2/0.3升级/实际包host/生成测试1/2、七锁审计/isolated activated audit/3102links通过。registry/API/client/GitHub asset/digest/SHA256SUMS均7efc0b470a60aec8526cb110066ae308aace2d9793c620a4c3e858b561d3f627；35个包文件和规范化gemspec与准备包一致，不宣称跨job二进制可重现。下载的发布包再空GEM_HOME full Rails host/生成1/2/activated audit通过。Pages39360929392、18HTTPS入口、稳定安装0.4、next/main、搜索反馈指南与版本菜单真实Chrome通过；lint22guides零错误警告。首次registry404稍后成功，DevTools profile占用改用既有Chrome extension，两项不隐藏也不当作产品失败。

**影响/人工复查：** 从0.3无新migration/runtime依赖；升级drain旧web/worker，deliver移到host commit之后；fence只保护Engine确认，host负责durable dedup/outbox/reconcile，uncertain仍隔离。notice不进入Surface state但回执保留，旧message兼容；host Rails.error仍需隐私控制。Specs/DELTA-006不变，既有OIDC/MIT/MFA/DNS复用，无新权限/凭证/provider或host生产数据变动。1.0仍缺外部试用/独立review/MySQL/provider/正式gates证据。

**清理/下一步：** 未启动本地服务；临时isolated/compare目录自动删除，Chrome验收页关闭，任务watchers结束；ignored tmp保存下载证据。提交推送本记录并检查其自身CI/Docs，在最终回复报告实际状态；不预写未来SHA/成功，不自动开发下一版。

### WORK-20261021-01 — 审计启动与刷新焦点修复

**内容/映射：** Andy要求审计功能与处理逻辑、修复有效问题并分步提交、核对计划与路线图并准备1.0 RC；SPEC_BASELINE记录本轮仅授权本地修复/提交，不含push/tag/发布/provider/外部联系。FR-07/08（键盘与反馈）。Stimulus controller原先在任何revision>1的Surface连接时聚焦status，页面加载/刷新也会抢走焦点，与反馈指南“替换后聚焦”不符；现在`turbo:before-stream-render`给传入元素打标记，只有实际替换或error才移动焦点。

**复查/验证：** 新浏览器回归先失败（"A saved Surface took focus on page load"），修复后通过；替换后仍聚焦status。完整Chrome套件9个中一次出现禁用JS生命周期测试的stale-node错误；该测试中页面JS经探测确实不执行，交替运行原版/修复版各6次全部通过，记录为既有时序flake而非本修复。core 129/1129未受影响（仅JS/测试/文档）。

**影响/人工复查：** 在demo保存一次选择后刷新，确认焦点不跳到状态行；用Turbo提交时仍由status朗读结果。无schema/依赖/服务端行为变化。更新feedback指南、CHANGELOG Unreleased、Current Work和pre-flight记录；结构不变无需图。

**下一步：** 继续审计修复（注册错误码、标识符编码、digest边界、CSP nonce），每个commit独立Work-ID；随后RC准备。

### WORK-20261021-02 — 注册输入的稳定错误码

**内容/映射：** FR-01/02注册契约。探针发现三类畸形注册直接抛Ruby异常：schema的`pattern`不是合法正则抛RegexpError，action定义不是Hash或缺`schema:`抛NoMethodError/KeyError，`expose_to: :agent`（非数组）抛NoMethodError。现在分别为`INVALID_SCHEMA`、`INVALID_ACTION`、`INVALID_COMPONENT`，与其余注册错误一致，便于1.0冻结错误码。合法注册与digest不变。

**复查/验证：** 新registry测试先失败（RegexpError），修复后registry 7/81通过；完整core套件130/1138通过。

**影响/人工复查：** 只影响启动期注册失败的异常类型；原先已能注册的组件行为不变。components指南新增“注册失败”段落列出各错误码，CHANGELOG Unreleased已记录。无schema/依赖/数据影响。

**下一步：** 标识符编码、SafeBuffer归一化、digest边界、并发呈现的rejected通知与发现策略的不可变Access。

### WORK-20261021-03 — 值归一化、digest边界与诊断补齐

**内容/映射：** FR-01/04/05、SEC-04/06/18。五个探针确认的实现缺陷：(1) 非法UTF-8的actor/tenant等标识符抛ArgumentError，现返回该标识符自身错误码，合法值统一为UTF-8 String，二进制编码输入仍能逐字节匹配存储行；(2) `Data.normalize`保留SafeBuffer等String子类，内存值与重新读取的值不一致，现统一为普通String；(3) request digest对外层信封再次施加payload大小/深度限制，接近上限但已通过校验的props/arguments会被误报PAYLOAD_TOO_LARGE/DEEP，现digest只对已bounded值计算，不重复限制；(4) 关联呈现在并发插入竞争失败路径抛IDEMPOTENCY_CONFLICT却不发`presentation.rejected`，现由`present`统一包裹，主体移到private `present_surface`；(5) 发现策略收到可变Access，现与其他策略一样冻结。

**复查/验证：** 三个新测试先失败（ArgumentError、frozen断言、空事件列表），修复后core 133/1156、eager load、adapter 7/45、实际包安装host、0.2.0/0.3.0真实旧runtime升级（回执/关联/digest重放）、文档示例全部PASS。测试固定一个规范化digest字节值，证明已存组件digest与回执不变。

**影响/人工复查：** 不改schema/依赖/错误码集合/事件名；`presentation.rejected`在竞争路径新增一次与普通路径相同的code-only事件。阅读production指南的标识符段与CHANGELOG。私有方法标记:nodoc:。无结构变化无需图。

**下一步：** Engine页面内联style的CSP nonce；随后RC准备。

### WORK-20261021-04 — Engine完整页面的CSP nonce

**内容/映射：** FR-07/08、SEC（host安全头兼容）。Engine自有layout的内联`<style>`没有nonce，host若使用带nonce的`style-src`（不允许'unsafe-inline'），完整错误/读取页面会失去样式（仍可用但移动端布局和焦点外框丢失）。现在用`tag.style nonce: content_security_policy_nonce`；未配置CSP nonce时不输出属性。

**复查/验证：** 新HTML页面测试通过host真实CSP中间件路径（stub `env_config`）先失败：header含'nonce-page-nonce'而style无nonce；修复后html_page 7/83通过，并断言未配置时不渲染nonce属性。

**影响/人工复查：** 若host覆盖了layout，需要自行保留nonce；validation指南已说明。无JS/schema/依赖变化，不放宽任何CSP。CHANGELOG Unreleased已记录。

**下一步：** 汇总审计中“设计取舍”类发现交给owner决定，然后进行1.0 RC准备（契约声明、prerelease安全的发布流程、条件证据）。

### WORK-20261021-05 — RC发布流程：prerelease不取代稳定版

**内容/映射：** ROADMAP的rc1前置项“首个RC前把GitHub Release标为prerelease并确认不替换稳定文档/最新稳定版”。原`release.yml`对任何tag都直接`gh release create`，`v1.0.0.rc1`会成为GitHub Latest。现在用RubyGems自身的`Gem::Version#prerelease?`判断，prerelease加`--prerelease --latest=false`；稳定版保持GitHub自动Latest选择，不强制`--latest`（否则1.0之后的0.x补丁会被错误标为Latest）。release checklist新增“Release candidates”一节。

**复查/验证：** 本地验证判定：0.4.0/1.0.0为stable，1.0.0.rc1/1.0.0.pre为prerelease；`gh release create --help`确认`--prerelease`与`--latest=false`存在；workflow YAML可解析。在scratch本地clone中创建本地tag `v1.0.0.rc1`并运行`docs/site/bin/build.sh`：输出“Built v0.4.0 at / and the working tree at /next/”，首页与Getting Started显示“0.4.0 (stable)”且无rc1；clone与站点已删除，真实仓库未建tag。远端workflow未运行（无发布授权），属NOT_RUN。

**影响/人工复查：** 阅读release.yml的“Create GitHub Release”步骤与checklist新节。无运行时代码/包内容变化；不新增权限或密钥。

**下一步：** 声明1.0公开契约（含experimental适配器、MySQL排除），然后准备1.0.0.rc1候选元数据与证据。

### WORK-20261021-06 — 声明1.0公开契约

**内容/映射：** ROADMAP 1.0条件1（声明契约）、3（升级）、4（适配器边界）。新增`_reference/public-contract.md`：SemVer与rc1冻结规则；Ruby API签名与返回形状、稳定类成员、Access operation/interaction status/lifecycle枚举；全部错误码分组与非400状态；helper/模板覆盖点/generator；三个HTTP路由的请求/响应字段、202/303语义与snapshot字段（此前无任何指南记录线协议）；DOM/Stimulus标识；事件、delivery key与持久化数据。按路线图默认：未授权真实provider，RubyLLM适配器标为experimental（核心不受影响）；MySQL无真实迁移/并发运行，明确排除出支持矩阵。production指南的保留段原先仍说“手动删除”，已改为close+purge_closed；`rails_tool_views_text`补doc comment。upgrade smoke从v0.2/v0.3扩到v0.1.0..v0.4.0全部已发布版本。

**复查/验证：** 每条契约陈述逐一对照源码（错误码清单由grep生成，状态码逐个核对）。upgrade smoke四个真实旧runtime各5个action graph的回执/关联/隔离/回滚/purge/业务保留PASS；docs build stable0.4/next、3183链接零断链、内部记录排除PASS；project-docs lint 23篇0错误0警告，impact无公开名称变化。

**影响/人工复查：** 请重点审阅public-contract页面——rc1起这就是冻结清单，列入即承诺。experimental与MySQL排除是路线图规定的默认处理，若要改为支持需另行授权的provider/MySQL证据。无运行时行为变化。

**下一步：** 1.0.0.rc1候选元数据（released:false）、What's New in 1.0、RC准备证据与全矩阵本地验收。

### WORK-20261021-07 — 1.0.0.rc1 本地候选与准备证据

**内容/映射：** ROADMAP 1.0条件1..6、NFR-03。版本改为`1.0.0.rc1`，七个lockfile路径条目同步；docs `version: 1.0.0.rc1`、`released: false`（候选，正式gate应拒绝）；CHANGELOG Unreleased改为`## [1.0.0.rc1] - Unreleased candidate`。新增What's New in 1.0；0.4页面转入Release History（URL不变，/:name/）；Upgrading改为“从0.4升级”，更早版本指向v0.4.0的指南；导航与release history同步。新增`docs/evidence/RC1_READINESS.md`逐条记录1.0条件：1、3（本地）、4满足；2部分、5未开始、6部分。

**复查/验证：** 候选上顺序运行：三组SQLite各134/1162+eager load；PG17.11独立临时库137/1178（已删除并核实）；adapter 7/45及adapter文档示例；Chrome 9/81；实际包host/生成测试；真实0.1.0..0.4.0升级；空GEM_HOME安装/activated audit；七份lock bundle-audit无漏洞；35文件candidate gate PASS，本地SHA9bba50bd…802ed8（非发布校验和）；正式gate按released:false正确拒绝；docs stable0.4/next、3254链接、24篇0错误/2条预期打tag前警告。Ruby4首次因脚本`rvm use 4.0.2`写错失败，改用`rvm ruby-4.0.2 do`重跑并确认RUBY_VERSION 4.0.2后通过，如实记录。

**影响/人工复查：** 先读public-contract（rc1起冻结），再读RC1_READINESS的D1..D5：purge批次饥饿、uncertain无解除路径、无adapter时pending被标skipped、条件2/5/6的证据或例外、发布授权。无schema/runtime依赖变化；main现为未发布候选，稳定文档仍由v0.4.0构建。浏览器/driver/Puma/临时PG已结束，既有PG服务保留。

**下一步：** owner审阅并决定；未授权前不push/tag/发布，不开展外部试用或provider调用。

### WORK-20261021-08 — D1..D3设计决定（ADR 010 / DELTA-007）

**内容/映射：** Andy要求在rc1冻结契约前以最佳设计解决D1..D3。实现前先记录决定：D1 `purge_closed`增加keyset游标（`after:`/`next_after`），游标只与既有scope/cutoff/期限条件AND，不能扩大访问；D2 新增host证明的`reconcile_delivery(id, scope:, outcome: :completed|:failed)`，由默认拒绝的`reconciliation_policy`授权（独立于registry，也不让既有retention_policy静默获得权限），新鲜lease拒绝（DELIVERY_ACTIVE），不改attempts以保留fence，同结果幂等、不同结果冲突（RECONCILIATION_CONFLICT），发metadata-only `agent_reconciled`；D3 deliver将要claim却无adapter时抛`AGENT_NOT_CONFIGURED`(503)且不改记录，dispatch无adapter仍记skipped（FR-06-AC-03）。这正是ADR 008/009推迟、要求“具体安全host契约”的部分。

**复查/验证：** 仅决策文档；无代码变化，未运行测试。DELTA-007按DELTA-006先例记录为owner批准的契约补充；外部Specs不变。

**影响/人工复查：** 阅读ADR 010的Decision与Alternatives。新增公开名称将在各实现commit写入public-contract。无schema/依赖。

**下一步：** WORK-09实现D3（先写失败测试）。

### WORK-20261021-09 — D3：无adapter的投递不再丢弃已提交工作

**内容/映射：** FR-06、ADR 010、DELTA-007。`deliver`在将要claim时若无adapter（未传且未配置），原先把pending/failed/过期delivering改成终态`skipped`，未配置adapter启动的worker会静默永久丢弃follow-up。现在抛`AGENT_NOT_CONFIGURED`（503，默认文案说明已保存并保留），记录不变；终态、新鲜lease和未授权重试的failed仍按原样直接返回。dispatch时无adapter仍记`skipped`，保证FR-06-AC-03。

**复查/验证：** 两个新测试先失败（未抛错；continuation重试HTTP返回200），修复后通过：pending/重试failed/过期delivering三种都不变（attempts与uncertain不变），随后配置好的adapter用同一delivery key完成；JSON重试端点返回503且failed保留。core 136/1178通过。

**影响/人工复查：** 行为变化写入Upgrading（确保每个投递进程加载adapter；需要停止follow-up改用abandon）、continuation指南、public-contract（新错误码与503）、What's New与CHANGELOG。无schema/依赖。

**下一步：** WORK-10实现D1游标分页。

### WORK-20261021-10 — D1：purge_closed游标分页

**内容/映射：** FR-04、NFR-05、ADR 010、DELTA-007。候选按`closed_at, id`排序且无游标，最旧的受保护视图（如policy保留的法律保全）会占满每个批次，较新的可清理视图永远轮不到。新增`after:`与返回的`next_after`：keyset条件`closed_at > t OR (closed_at = t AND id > i)`只与既有scope/cutoff/期限条件AND，伪造游标只能跳过行、不能扩大到其他scope；满批返回最后候选的不透明游标，否则nil；preview同样分页；格式非法抛`INVALID_RETENTION_REQUEST`。其他清理规则不变。

**复查/验证：** 新测试先失败（unknown keyword :after），修复后：无游标时两次满批都停在受保护行（缺陷重现），带游标第二页清理2个、第三页nil；相同closed_at按id分页1/1/1/0；他scope位置的游标只缩小本scope；七种非法游标被拒。retention 10/90在SQLite与独立临时PG17库均通过（库已删除）；core 138/1203；文档示例新增可执行sweep循环通过；lint 24篇0错误。

**影响/人工复查：** 摘要新增`next_after`键：比较整个hash的严格消费者需接受（Upgrading已写明）。lifecycle指南新增“Sweep Every Batch”，public-contract/What's New/CHANGELOG同步。无schema/依赖。

**下一步：** WORK-11实现D2 attested reconciliation。

### WORK-20261021-11 — D2：host证明的投递对账（reconcile_delivery）

**内容/映射：** FR-05/06、NFR-05、SEC-04/06/18、ADR 010、DELTA-007。`delivery_uncertain`原为永久标记，带该标记的视图永远无法close/abandon/purge，也没有受支持的方式记录host去重证据。新增`reconcile_delivery(id, scope:, outcome: :completed|:failed)`：host契约为“已核对该delivery key的持久去重记录，且确认无仍在运行的attempt”。Engine可观测部分全部强制：默认拒绝的独立`reconciliation_policy`（operation :reconcile，不经registry，过时组件也能处理，不让既有retention_policy静默获权）；精确actor/tenant字节匹配，他scope 404；Surface→interaction锁序；新鲜lease抛`DELIVERY_ACTIVE`；仅uncertain或lease过期的delivering可对账，状态设为结果、清除uncertain、failed记AGENT_UNAVAILABLE；attempts不变以保留fence；同结果幂等、无可对账内容且结果不同抛`RECONCILIATION_CONFLICT`、非法结果抛`INVALID_RECONCILIATION`；对账成功发metadata-only `agent_reconciled`。对账后close/abandon/purge按原规则。

**复查/验证：** 新测试文件6个测试先失败（无配置项），实现后6/51通过：默认拒绝且policy收到冻结的:reconcile请求；接管→uncertain→close被拒→对账→close→到期purge成功；新鲜lease拒绝，回调运行中lease过期后对账failed，旧回调成功确认被fence拒绝且无事件，之后同key重试完成；幂等/冲突/非法结果；他scope、大小写不同tenant、缺失id、purge后均404；过时组件仍可对账。四个变异（去lease检查/去policy/去幂等/不清标记）都使测试失败。core 144/1254、eager load、文档示例、站点build 3261链接零断链、锚点存在、lint 24篇0错误。

**影响/人工复查：** 正确性依赖host证明，Engine无法验证远端效果或进程静默（仅能看lease新鲜度），已在lifecycle指南写明。更新lifecycle（新节）、continuation、diagnostics事件表、configuration、public-contract、Upgrading（含0.3迁移标记的旧行）、What's New、CHANGELOG、ADR/DELTA措辞。无schema/依赖。

**下一步：** WORK-12：实际安装host与真实旧版本升级数据上的对账/分页证据、全矩阵、准备记录更新。

### WORK-20261021-12 — D1..D3的实际host/旧数据证据与全矩阵

**内容/映射：** 1.0条件2/3、ADR 010。实际安装gem的host新增：无adapter投递保留pending、接管后uncertain阻止close、以host自己的receipt表证明结果并对账、close后batch_size 1分页清理两个视图；并在开发bundle下增加ViewComponent渲染/Turbo动作/恢复（空GEM_HOME安装没有ViewComponent，如实标为Partial路径）。升级host对每个旧版本受保护的历史（各版本都有的delivering行，以及0.1/0.2迁移回填的uncertain行）先确认close被拒，再对账、close、purge。新增PG真实竞争测试：对账在锁内暂停时，回收过期lease的worker必须等待并遵守证明的failed，不调用adapter。public-contract补充可读查询的Surface/AgentInteraction成员（host需要查找uncertain记录与其owner），Continuation错误码表述更清楚，配置表补两个policy；修正lifecycle示例：policy收到的是视图owner的scope，而不是operator，原例`Operator.exists?(ref: access.actor)`会误导，改为按tenant授权的作业示例，并说明“缺少receipt只有在receipt与效果同事务写入时才能证明未发生”。

**复查/验证：** 最终矩阵：三组SQLite各144/1254+eager load；PG17.11临时库148/1274（含新竞争测试，库已删除）；adapter 7/45；Chrome 9/81；真实0.1.0/0.2.0/0.3.0/0.4.0升级各自对账2/2/1/1条历史后清理PASS；docs示例含sweep；正式gate按released:false拒绝；docs 3261链接、锚点存在、lint 24篇0错误。ViewComponent扩展在矩阵之后加入，随后单独重跑实际包host（两种渲染器PASS）与空GEM_HOME安装/审计（Partial路径PASS）。去掉对账行锁的变异使PG竞争测试失败；lifecycle指南的对账作业示例逐字执行通过。首次编写升级host时假设0.3/0.4数据的retried行也被隔离，结果“Quarantined history closed”失败——那是脚本假设错误（0.3+数据未回填该标记），改为按版本选择受保护行，如实记录。

**影响/人工复查：** 重点读public-contract新增成员与lifecycle“Reconcile an Uncertain Delivery”。条件2按工程host满足，外部adopter属条件5。RC1_READINESS现只剩D4（条件5/6证据或例外）与D5（发布授权）。所有浏览器/driver/Puma/临时PG库已结束并核实为0，既有PG服务保留。

**下一步：** owner审阅并决定D4/D5；未授权前不push/tag/发布。

### WORK-20261026-01 — 1.0.0 授权发布准备（owner例外）

**内容/映射：** Andy要求发布新版本gem并更新文档与站点，并在“rc1+例外 / 1.0.0+例外 / 暂缓”中明确选择直接发布1.0.0。记录D4/D5决定：SPEC_BASELINE授权、DELTA-008（条件5的外部试用/对照/≥2周非dummy使用，与条件6的独立安全审核/正式H2/C/R处置以例外豁免，未满足，不标为满足）、ROADMAP（rc1标为跳过）、发布流程、RC1准备记录、Current Work与状态。版本、六个路径lockfile、`released: true`、CHANGELOG日期、Release History（加1.0.0行，0.4.0归档于`/v0/`）、What's New、Upgrading（`~> 1.0`）和Public Contract改为1.0.0，删除候选措辞。运行时代码冻结于8be445d。

**验证：** core与Rails 7.2各144/1254+eager load，adapter 7/45，实际安装包host（两种渲染器）、0.1.0..0.4.0真实升级、core/adapter文档示例、正式`RELEASE_PACKAGE_PASS`（35文件）、空GEM_HOME安装+activated audit、docs build 3262链接零断链与internal排除均通过。bundle-audit发现开发lockfile中crass 1.0.7（GHSA-pq4g-8rxf-4g29），保守升级到1.0.8后七个lockfile在advisory 03da937a均无漏洞，升级后core/7.2/adapter/包host重跑通过。Ruby 4与PostgreSQL本地未重跑，由tag前精确远端CI覆盖。本地包SHA eea95020f4e2f61c1b921beca9df47f568bb33cdbb0871b29814af846ee79bca，不是发布校验和。

**影响/人工复查：** 读DELTA-008与ROADMAP例外段，确认豁免范围；读Upgrading与What's New的安装指令。crass仅是开发bundle的传递依赖，不进gemspec，不影响host解析，故不写CHANGELOG。无schema/运行时依赖/provider调用。未启动服务。

**下一步：** 推送后等待精确main CI/Docs；通过再打annotated v1.0.0并由OIDC发布。WORK-02记录真实运行、校验和与stable 1.0、/next/、/v0/的HTTPS核验。

### WORK-20261026-02 — 1.0.0 公开交付记录

**内容/映射：** 记录WORK-01之后实际观察到的发布结果。FR-04..08、NFR-03/05。新增RELEASE_1_0_0证据；更新ROADMAP、状态、at-a-glance、feature map（1.0节）、human changelog、实施计划、验收矩阵、Current Work、发布流程与postflight。

**验证：** 候选5ded407的main CI 40255325539/Docs 40255325572通过后打annotated v1.0.0；tag CI 40255472016、Release 40255472062全部8个job、Pages 40255852479通过。精确tag三组SQLite各144/1254、PG 148/1274、adapter 7/45、Chrome 9/81；真实0.1.0..0.4.0升级、安装包host、七锁与activated audit（03da937a）干净、docs 5119链接零断链。发布SHA c71a31c88099cd851ffa4adbe3bbed811c137de72e987a3b0e0d11d916ec5df8在RubyGems API/下载/GitHub资产/SHA256SUMS一致；35个文件与本地测试构建逐字节相同；空GEM_HOME从RubyGems安装并加载1.0.0（无ruby_llm）。17个HTTPS入口200，稳定1.0/next(main)/v0(0.4.0)安装指令与canonical正确，HTTP→HTTPS，内部路径404。

**影响/人工复查：** 打开 https://rails-tool-views.wangyaodi.com 、/v0/ 与Release页面核对。条件5与条件6的独立审核/正式处置仍是NOT_MET，由DELTA-008豁免，已在证据与ROADMAP写明。无schema/运行时依赖/provider/外部联系；未启动服务，临时clone/下载/GEM_HOME已删除。

**下一步：** 推送本记录并核对其CI/Docs。不自动开始下一迭代；外部试用、独立安全审核等仍是1.x的开放证据。

### WORK-20261026-03 — RubyLLM适配器拒绝在RubyLLM 1.x上加载

**内容/映射：** FR-03、1.0条件4（适配器声明有界）。owner要求审计gem并确保RubyLLM集成正确。核查RubyLLM真实源码：2.0起`Tool#call(tool_call:, **args)`把ToolCall传给`execute`并使用`Tool.tool_name`；1.0..1.16均为`call(args)`→`execute(**args)`，不传ToolCall，也不认`tool_name`。gemspec不约束可选的ruby_llm，所以1.x host能正常`require`适配器，但工具以类名派生名`rails_tool_views--adapters--ruby_llm--present_ui`暴露，模型调用`present_ui`被RubyLLM拒绝；即使调用长名，也只会得到`MISSING_TOOL_CALL`。适配器在`require "ruby_llm"`前加`gem "ruby_llm", ">= 2.0"`（与Active Record数据库适配器相同的激活检查），不满足时`Gem::LoadError`。文档新增`site.requirements.ruby_llm`，RubyLLM指南、Public Contract、Upgrading与CHANGELOG（Unreleased）同步。同时记录本轮pre-flight、SPEC_BASELINE授权与Current Work。

**复查/验证：** 用真实gem复现：RubyLLM 1.16.0上同一聊天循环，修复前适配器加载成功、工具结果为“unavailable tool `present_ui`”、0个Surface；修复后`require`即抛`Gem::LoadError: can't activate ruby_llm (>= 2.0), already activated ruby_llm-1.16.0`。同一脚本在2.0.0/2.1.0/2.1.1上均创建Surface。适配器测试在2.0.0、2.1.0、2.1.1各7/45通过（2.0.0与2.1.1为本地一次性bundle，CI只锁2.1.0）。无RubyLLM的core bundle改为`Gem::LoadError: ruby_llm is not part of the bundle`，仍是LoadError子类。core 144/1254+eager load、文档示例（core与adapter）通过；docs build（本clone无tag，只构建工作树）1611链接零断链、internal排除PASS（本机需`LANG=C.UTF-8`，否则postprocess脚本按US-ASCII读文件报错，CI不受影响）。1.x回归没有放进CI：需要第二套锁文件安装旧RubyLLM，代价不成比例，以本记录的实测为证据。

**影响/人工复查：** 读`lib/rails_tool_views/adapters/ruby_llm.rb`开头三行与RubyLLM指南“Load Only When Needed”。对1.x host不是功能回退（工具本来不可用），只是从静默失败变为加载期报错；已写入Upgrading。无schema/运行时依赖变化。

**下一步：** WORK-04：demo正确性与可复用的demo配置。

### WORK-20261026-04 — demo：已发布版本标签与可实际观察的清理

**内容/映射：** FR-07（生命周期/保留）、1.0条件2（完整host工作流）。审计发现两处demo与事实不符：(1) 侧栏把已发布的1.0.0标为“Unpublished development preview”，改为与发布状态无关的“Local reference host”；(2) “Close view”以`retain_until: 1.day.from_now`关闭，交互用户在一个会话里永远看不到“Clean eligible views”生效，只有浏览器测试用`travel_to`才能走到清理。改为1分钟期限（代码注释说明这是demo选择，真实host自定），页面文案与Demo指南新增“Close and clean up a view”一节，说明期限、只读、清理移除props/state/receipt而保留身份与业务日志。核心API与默认值不变。

**复查/验证：** Chromium按真实时钟走完：保存选择→关闭→预览“0 eligible”→等待62秒→预览“1 eligible”→应用“1 purged”、“1 cleaned views”。Selenium浏览器套件9/81通过（含原`travel_to`清理测试；本机PATH里的chromedriver 147与Chrome 153不匹配，移出PATH后由Selenium Manager解析驱动）。core 144/1254；docs build 1611链接零断链。

**影响/人工复查：** `bin/demo`后在Component playground关闭一个视图，一分钟后点“Preview cleanup”。仅demo host与指南变化；无schema/依赖/安全影响。

**下一步：** WORK-05：运行真实RubyLLM循环的agent chat demo。

### WORK-20261026-05 — demo新增运行真实RubyLLM循环的Agent chat

**内容/映射：** FR-03/06、1.0条件2/4。owner要求demo能正确测试和演示RubyLLM与Rails集成；审计发现demo的“Present in chat”只调用普通lambda，`PresentUI`与`Continuation`从未在运行中的Rails host里执行。新增“05 Agent chat”：真实`RubyLLM::Chat`（OpenAI provider，Chat Completions协议）挂载`PresentUI`；只替换网络——注册为Faraday adapter的离线transport按OpenAI格式应答，所以请求渲染、工具schema序列化、tool call解析、ToolCall传入`execute`、工具结果与`Continuation`的新user turn全部走RubyLLM真实代码。transcript存于demo专用表`demo_conversations/demo_chat_messages`（不依赖acts_as_chat的schema），一轮成功后才持久化；工具结果中的surface_id在重载后以当前scope渲染Surface。续接adapter先按host数据核对会话属于Surface的actor/tenant，再以`DemoAgentReceipt`与transcript同事务去重。playground配置抽到`DemoSetup`（行为不变），供测试复用；`bin/demo`改用`gemfiles/adapter.gemfile`并自动安装；核心Gemfile下demo其余部分照常运行（RubyLLM代码只在`test/dummy/lib/demo_llm.rb`，按需require）。可选live模式只读owner自己的环境变量，本项目未运行。RubyLLM指南新增挂载工具、渲染已呈现视图、带所有权检查和去重的续接示例；Demo指南、README、CONTRIBUTING、CHANGELOG同步。

**复查/验证：** 新增`test/adapter/demo_agent_test.rb` 5个集成测试：完整循环（provider收到的工具名/enum、PresentUI schema未加strict、presentation关联call_demo_2、transcript角色序列、HTML动作后interaction completed、receipt、回复内容与重载渲染）；重复投递不增消息；模型编造的选项可显示但选择被403拒绝且无interaction；他人会话不能接收续接（failed/AGENT_UNAVAILABLE、对方transcript为空）；模型请求失败不存任何消息并提示。三个变异（去所有权检查/去receipt检查/不挂工具）均使测试失败。adapter 12/83（原7/45）、core 144/1254+eager load（两套bundle的zeitwerk均通过）、文档示例core/adapter、package smoke、真实0.1.0..0.4.0升级smoke均通过；拉取tag并装rsync后版本化docs build（v1.0.0在/、工作树在/next/、v0.4.0在/v0/）5123链接零断链，新节只出现在/next/。Chromium实测：发送→present_ui→选择→续接回复→重载6条消息，无console错误，390px宽无横向滚动。Selenium套件4次全量运行2次9/81、2次各1个“Node with given id does not belong to the document”错误；改动前基线`f741646`全量3次均同样出错（不同测试），单测各5/5通过，属本机Chrome 153与Selenium驱动的既有不稳定，非本改动引入，未改测试。

**影响/人工复查：** `bin/demo`后打开Agent chat，发送消息、选择并保存、刷新；读`test/dummy/lib/demo_llm.rb`与RubyLLM指南“Continue the Chat”。demo不进gem包（gemspec只含app/config/db/lib）。无core schema/运行时依赖变化；demo表只在dummy迁移中。

**下一步：** WORK-06：importmap宿主的Stimulus控制器接入，在生成的Rails host中验证。
