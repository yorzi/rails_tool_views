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
