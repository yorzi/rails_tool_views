# 项目状态

2026-10-18：**0.1.0 已发布；0.2.0 开发中；1.0 路线图为提案。**

## 已交付

- [RubyGems 0.1.0](https://rubygems.org/gems/rails_tool_views/versions/0.1.0)，tag `v0.1.0` 指向 `f2d4303`，MIT、MFA 和 GitHub OIDC 发布。
- [文档站](https://rails-tool-views.wangyaodi.com)：稳定版与 `/next/`，DNS、强制 HTTPS、搜索、API 和 llms 已验证。
- Registry/schema、Partial/ViewComponent、持久化 Surface、授权事务动作、revision/重放、表单反馈和可选 RubyLLM 续接已实现。客户/工单/内容是主应用示例，非 gem 内置业务。
- 正式标签的三个 SQLite 组合与 PostgreSQL 各 89 tests / 723 assertions，adapter 7/45；打包、依赖审计和 2,152 文档链接检查通过。完整边界见 [发布证据](../evidence/RELEASE_0_1_0.md)。

## 当前工作与下一步

Andy 已授权 0.2.0 的开发和持续本地提交。复用 test/dummy 作为 demo 和浏览器测试 host，隔离依赖的临时 Rails 应用验证实际 gem；不另养一个应用仓库。

测试基础已完成：Chrome 三个场景 18 个断言通过，截图已检查；实际 gem 在空 GEM_HOME 的完整 host 流程和激活依赖审计通过。下一步：组件生成器和无 Turbo 完整纠错页面。新 gem 尚未发布；后续发布需相应授权。执行状态见 [Current Work](../agent/02_CURRENT_WORK.md)。

## 尚未解决

| 问题 | 当前事实 / 拟处理阶段 |
| --- | --- |
| 组件接入成本 | Partial 组件生成器已完成；closed schema、默认拒绝、三文件脚手架和实际打包验证通过 |
| 无 Turbo 的错误页面 | 拒绝动作仍显示片段；拟在 0.2 改善 |
| 数据生命周期 | 无内置 retention/cleanup API，重放回执与续接记录不可随意清理；拟在 0.3 先定契约 |
| 运行反馈与遥测 | `state["message"]` 会持久化，回放仍发 `action.executed`；拟在 0.4 处理，新通知契约需 owner 决定 |
| 实际采用 | 缺少外部开发者接入试验和实测定制实现对照；dummy 和本地 OddlyDock 接入不能替代外部证据 |
| 支持边界 | MySQL、真实 provider 与独立安全审核未验证；正式 H2/C/R 仍开放 |

1.0 的目标是稳定契约和可维护的实际接入，不是把所有构想都做完。具体版本退出条件只维护在 ROADMAP；此处不重复它的计划清单。

历史变更与授权见 [Progress Ledger](05_PROGRESS_LEDGER.md)、[Spec Delta](../agent/05_SPEC_DELTA_PROTOCOL.md) 和 [验证记录](../evidence/)。内部旧 `0.2/0.3` 标签是未发布候选，不是公共版本。
