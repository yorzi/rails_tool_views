# 产品与发布决策

**已依据用户明确方向确定：** Rails-native、现有 UI Components 复用；UI Component 可通过 Tool Adapter 供 AI 调用；RubyLLM 不是核心依赖；支持普通 Rails 渲染与交互；开源项目；先做一个完整 V0 闭环。

**技术建议，等待 Spike 验证：** 默认单个 present_ui tool + 有界 Registry；Core Registry/Surface/Action，RubyLLM 单独 Adapter；Partial/ViewComponent 首先支持；复用 generative_ui 能复用的协议/渲染；完整 Surface snapshot + Turbo 更新。

**已由用户选定的项目名称：** **ToolViews**（原 ViewTools）。Specs 目录已改为 `toolviews/`；Ruby 模块拟为 `ToolViews`，gem slug 拟为 `toolviews`，但并未声称 RubyGems/GitHub/商标可用。

**应用场景范围：** UC-01/10 为 V0 技术证明，UC-02..05 为 V1 候选，UC-06..09 为 V1+/V2 候选。Demo A/B/C 见 [supporting/06](../supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md)。场景表不是 MVP 功能列表。

**需要人工确认后方可发版：** 该名称和 Gem namespace 的实际可用性、MIT 或其他许可证、独立仓库地址、公开发布时间、首个维护者/安全联系渠道。

**不可自行扩大：** 将 RubyLLM 变成必需、生成可执行页面、全套 A2UI/MCP 实现、商业计费或未经批准的云服务。