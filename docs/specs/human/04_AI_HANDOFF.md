# AI Agent 交接说明

当前先按 [ai/00_ENTRYPOINT.md](../ai/00_ENTRYPOINT.md) 读取意图合同和 [11_ROADMAP_EXECUTION_PLAN.md](../11_ROADMAP_EXECUTION_PLAN.md) 的 Phase 0；第一条代码纵切是「不依赖 AI 的 Rails 组件注册→展示→操作→持久化→刷新」。

**注意：** 尚无人工 H2 批准，不能将独立仓库创建、发布 Gem、合并重大架构 PR 视为已授权。完成 Gate H2 与 C/R 后，使用 OddlyNiche implementation-repo-docs-template 建立新仓库并记录 R/C；以后日常代码/测试/文档在新仓库维护。
**场景交接：** [supporting/06](../supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md) 含 UC-01..10 与官方 Demo A/B/C；只有 UC-01/10 属于 V0，不得自动把候选 V1/V2 场景转化为实施任务。
