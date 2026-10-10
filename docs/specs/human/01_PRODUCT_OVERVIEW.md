# 产品概览 / ToolViews

**一句话：** 一个独立于 AI 框架的 Rails UI 工具层，让已有的 Partial / ViewComponent 成为可注册、可由 AI 调用、可交互和可持久化的 UI。

**用户：** 已有 Rails 应用、想给聊天或工作流嵌入交互组件的 Rails 开发者。

**价值：** AI 负责选择已允许的展示方式；Rails 负责组件渲染、权限、状态和 Action；RubyLLM 仅为可选适配器。没有 AI 仍可使用相同的注册与展示能力。

**名称：** 已选定 **ToolViews**（原代号 ViewTools）；`toolviews` Gem/仓库 slug、商标和许可证仍需发布前验证。

**典型应用：** Human-in-the-loop 选择/确认、AI 辅助表单、Rails Admin Copilot、内容生成结果审核、客服工单，以及研究、电商、数据分析、多步骤表单和纯 Rails 组件（完整十项见 [supporting/06](../supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md)）。十项是候选场景，不代表十项 MVP 功能。

**V0 演示：** 一个选项卡片，先在普通 Rails 页面展示，再通过可选 Tool Call 嵌入 Chat；点击选项后由 Rails 处理或将结构化结果交回 Agent；刷新后状态保留。

**不做：** React 基础设施、任意 HTML/JS/Ruby 生成、新 Agent 框架、完整 A2UI/AG-UI/MCP 标准和商业 SaaS。

**最大风险：** 与 generative_ui 重复；真实价值必须在「状态 + Action + 交互回合」上得到验证。