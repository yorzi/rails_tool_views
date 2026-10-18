# 项目状态

2026-10-18：**0.1.0 已发布；0.2.0 尚未开始；1.0 路线图为提案。**

## 已交付

- [RubyGems 0.1.0](https://rubygems.org/gems/rails_tool_views/versions/0.1.0)，tag `v0.1.0` 指向 `f2d4303`，MIT、MFA 和 GitHub OIDC 发布。
- [文档站](https://rails-tool-views.wangyaodi.com)：稳定版与 `/next/`，DNS、强制 HTTPS、搜索、API 和 llms 已验证。
- Registry/schema、Partial/ViewComponent、持久化 Surface、授权事务动作、revision/重放、表单反馈和可选 RubyLLM 续接已实现。客户/工单/内容是主应用示例，非 gem 内置业务。
- 正式标签的三个 SQLite 组合与 PostgreSQL 各 89 tests / 723 assertions，adapter 7/45；打包、依赖审计和 2,152 文档链接检查通过。完整边界见 [发布证据](../evidence/RELEASE_0_1_0.md)。

## 当前工作与下一步

本次只精简 README、划清文档分工并制定 [0.2 → 1.0 路线图](../../ROADMAP.md)，没有实现未来功能、升级版本或发布新 gem。README 做入口，文档站维护使用说明，仓库 Markdown 保留贡献/安全/路线图与内部证据。

建议下一步：先在独立 Rails host 按指南接入 0.1.0，记录重复劳动，再以组件生成器和无 Turbo 的完整错误反馈作为 0.2.0 候选。具体 API/设计在实施前确定；未来功能与版本发布需要相应授权。执行状态见 [Current Work](../agent/02_CURRENT_WORK.md)。

## 尚未解决

| 问题 | 当前事实 / 拟处理阶段 |
| --- | --- |
| 组件接入成本 | 只有安装生成器，没有组件生成器；拟在 0.2 解决 |
| 无 Turbo 的错误页面 | 拒绝动作仍显示片段；拟在 0.2 改善 |
| 数据生命周期 | 无内置 retention/cleanup API，重放回执与续接记录不可随意清理；拟在 0.3 先定契约 |
| 运行反馈与遥测 | `state["message"]` 会持久化，回放仍发 `action.executed`；拟在 0.4 处理，新通知契约需 owner 决定 |
| 实际采用 | 缺少外部开发者接入试验和实测定制实现对照；dummy 和本地 OddlyDock 接入不能替代外部证据 |
| 支持边界 | MySQL、真实 provider 与独立安全审核未验证；正式 H2/C/R 仍开放 |

1.0 的目标是稳定契约和可维护的实际接入，不是把所有构想都做完。具体版本退出条件只维护在 ROADMAP；此处不重复它的计划清单。

历史变更与授权见 [Progress Ledger](05_PROGRESS_LEDGER.md)、[Spec Delta](../agent/05_SPEC_DELTA_PROTOCOL.md) 和 [验证记录](../evidence/)。内部旧 `0.2/0.3` 标签是未发布候选，不是公共版本。
