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
