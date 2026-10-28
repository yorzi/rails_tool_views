# 功能地图

| 契约 | 实现 | 入口 |
|---|---|---|
| FR-01 Registry/schema | IMPLEMENTED | lib/rails_tool_views/core.rb |
| FR-02 present/render | IMPLEMENTED | runtime.rb、SurfacesHelper |
| FR-03 可选工具 | IMPLEMENTED；仅离线 provider 夹具 | adapters/ruby_llm.rb |
| FR-04 持久化/恢复 | IMPLEMENTED；SQLite 与 PostgreSQL 通过本地/CI 验证 | Surface、Presentation |
| FR-05 授权动作 | IMPLEMENTED | dispatch、ActionExecution |
| FR-06 Agent 后续交互 | IMPLEMENTED；远端去重由 host 提供 | AgentInteraction、deliver、Continuation |
| FR-07 Rails UI | IMPLEMENTED；JSON/Turbo/完整 HTML 纠错，无 ActionCable | SurfacesController、Stimulus factory |
| FR-08 安装/文档 | 0.2.0 已发布；组件生成器、浏览器/隔离 host 验证与 hosted docs 已通过精确标签 CI | install/component generators、test/dummy、bin/check-browser、release.yml、docs/site |

v1 是主应用参考实现，未把客户/工单/创作业务加入 gem：

| 场景 | 本地能力 | 主应用入口 |
|---|---|---|
| UC-02 | 提议字段、人工修正、校验反馈、事务内创建一次 | DemoV1::Workflows.customer、v1/customer_form |
| UC-03/05 Demo B | 有界查询、记录 resolver、角色/租户、账户查看、分配、草拟/审阅/确认本地 outbox | DemoV1::TicketsQuery、Access、Workflows.ticket、Agent |
| UC-04 Demo C | 不可变版本、人工编辑、接受锁定、显式再生成、失败重试、授权下载 | DemoV1::Workflows.artifact、Exports、V1::ExportsController |
| 通用表单反馈 | 有界 ValidationError；422 JSON/HTML/Turbo 保留批准字段 | lib/rails_tool_views/core.rb、SurfacesController |
| 主应用控制器集成 | 继承认证方法、过滤器与 helper | SurfacesController < ::ApplicationController |
| 续接业务去重 | 同事务写业务结果与 delivery_key receipt | DemoAgentReceipt、DemoV1::Agent |
| Agent chat（post-1.0 demo） | 真实RubyLLM::Chat挂载PresentUI、离线Chat Completions transport、transcript重载渲染Surface、Continuation续接、所有权检查与receipt去重 | AgentController、DemoLLM（test/dummy/lib）、DemoConversation/DemoChatMessage、test/adapter/demo_agent_test.rb |

验收边界见 ../agent/08_V1_ACCEPTANCE.md。UC-06..09、真实 provider 与外部发送不在本次范围。

组件注册不等于权限；工具确认不等于界面；Surface 状态不等于业务记录；已保存选项不等于 Agent 成功。详见架构与运行流程。

## 0.3 已发布

`lib/rails_tool_views/lifecycle.rb` 提供授权的 close/abandon；Surface 新增生命周期时间戳和只读渲染。历史回执可重放，新的业务动作被拒绝。迁移/installer 同步，旧投递不确定性被保守标记；清理、真实旧数据升级、三个兼容组合与 PostgreSQL 并发/包/浏览器/独立安装已完成精确标签远端验收与发布；见 ../evidence/RELEASE_0_3_0.md。

## 0.4 已发布

投递使用已有 attempts 作为确认 fence，旧成功/失败不能覆盖新 claim；外层事务内 deliver 返回 DELIVERY_IN_TRANSACTION。dummy 的 DemoV1::ContinuationJob 重新解析当前 staff，独立进程中断/恢复验证主应用 receipt 去重。无新表、依赖或内置队列，已在0.4发布。

WORK-20261020-03：action.executed 增加 replayed 布尔；Transition.notice 是≤500bytes的响应反馈，JSON/Turbo直接返回，HTML由匹配Surface/actor/tenant的Rails flash显示一次。Surface state/snapshot无notice，回执保留同一响应以便精确重放，现有state.message不变。

0.4完整本地验收已完成，见 ../evidence/V0_4_VALIDATION.md；包含真实0.2/0.3升级（旧closed/purged guard）、三个installed host与空GEM_HOME、PG真实竞争和Chrome8场景。公共版本已是0.4；精确远端/registry/Pages证据见 ../evidence/RELEASE_0_4_0.md。

## 1.0 已发布

声明公共契约（Ruby API、错误码/状态、helper、HTTP字段、DOM/Stimulus、事件、delivery key、持久数据）；新增host证明的`reconcile_delivery`与默认拒绝的`reconciliation_policy`，`purge_closed`支持`after:`/`next_after`分页，无adapter的`deliver`抛`AGENT_NOT_CONFIGURED`。RubyLLM适配器为experimental，MySQL不在支持矩阵。无新schema/依赖。证据见 ../evidence/RC1_READINESS.md 与 ../evidence/RELEASE_1_0_0.md。

## 1.0.1 已发布

RubyLLM适配器在加载时要求RubyLLM 2.0+（`lib/rails_tool_views/adapters/ruby_llm.rb`），CI覆盖2.0.0与2.1.0。demo的Agent chat（`/agent`，`test/dummy/lib/demo_llm.rb`、`test/adapter/demo_agent_test.rb`）在离线transport上运行RubyLLM真实工具循环与Continuation。证据见 ../evidence/RELEASE_1_0_1.md。
