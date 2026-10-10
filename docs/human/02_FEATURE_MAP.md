# 功能地图

| 契约 | 实现 | 入口 |
|---|---|---|
| FR-01 Registry/schema | IMPLEMENTED | lib/tool_views/core.rb |
| FR-02 present/render | IMPLEMENTED | runtime.rb、SurfacesHelper |
| FR-03 可选工具 | IMPLEMENTED；仅离线 provider 夹具 | adapters/ruby_llm.rb |
| FR-04 持久化/恢复 | IMPLEMENTED；SQLite | Surface、Presentation |
| FR-05 授权动作 | IMPLEMENTED | dispatch、ActionExecution |
| FR-06 Agent 后续交互 | IMPLEMENTED；远端去重由 host 提供 | AgentInteraction、deliver、Continuation |
| FR-07 Rails UI | IMPLEMENTED；JSON/Turbo，无 ActionCable | SurfacesController、Stimulus factory |
| FR-08 安装/文档 | 本地实现完成；公共发布门槛待审 | installer、test/dummy、README |

组件注册不等于权限；工具确认不等于界面；Surface 状态不等于业务记录；已保存选项不等于 Agent 成功。详见架构与运行流程。
