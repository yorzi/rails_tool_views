# 功能地图

| 契约 | 实现 | 入口 |
|---|---|---|
| FR-01 Registry/schema | IMPLEMENTED | lib/rails_tool_views/core.rb |
| FR-02 present/render | IMPLEMENTED | runtime.rb、SurfacesHelper |
| FR-03 可选工具 | IMPLEMENTED；仅离线 provider 夹具 | adapters/ruby_llm.rb |
| FR-04 持久化/恢复 | IMPLEMENTED；SQLite | Surface、Presentation |
| FR-05 授权动作 | IMPLEMENTED | dispatch、ActionExecution |
| FR-06 Agent 后续交互 | IMPLEMENTED；远端去重由 host 提供 | AgentInteraction、deliver、Continuation |
| FR-07 Rails UI | IMPLEMENTED；JSON/Turbo，无 ActionCable | SurfacesController、Stimulus factory |
| FR-08 安装/文档 | 本地实现完成；公共发布门槛待审 | installer、test/dummy、README |

v1 是主应用参考实现，未把客户/工单/创作业务加入 gem：

| 场景 | 本地能力 | 主应用入口 |
|---|---|---|
| UC-02 | 提议字段、人工修正、校验反馈、事务内创建一次 | DemoV1::Workflows.customer、v1/customer_form |
| UC-03/05 Demo B | 有界查询、记录 resolver、角色/租户、账户查看、分配、草拟/审阅/确认本地 outbox | DemoV1::TicketsQuery、Access、Workflows.ticket、Agent |
| UC-04 Demo C | 不可变版本、人工编辑、接受锁定、显式再生成、失败重试、授权下载 | DemoV1::Workflows.artifact、Exports、V1::ExportsController |
| 通用表单反馈 | 有界 ValidationError；422 JSON/HTML/Turbo 保留批准字段 | lib/rails_tool_views/core.rb、SurfacesController |
| 主应用控制器集成 | 继承认证方法、过滤器与 helper | SurfacesController < ::ApplicationController |
| 续接业务去重 | 同事务写业务结果与 delivery_key receipt | DemoAgentReceipt、DemoV1::Agent |

验收边界见 ../agent/08_V1_ACCEPTANCE.md。UC-06..09、真实 provider 与外部发送不在本次范围。

组件注册不等于权限；工具确认不等于界面；Surface 状态不等于业务记录；已保存选项不等于 Agent 成功。详见架构与运行流程。
