# 项目状态

2026-10-13：**AUDIT_HARDENING_LOCAL_COMPLETE / COMMITTED_LOCAL / UNPUSHED / HUMAN_REVIEW_PENDING**。应 Andy 要求对 v1 做了审阅与审计（WORK-20261013-01，ADR 003）。复现并修复六个问题：嵌套 schema 未闭合、日志过滤波及主应用、渲染/续接失败被吞掉、主应用无法为自己的错误码写文案、无参数表单被拒、测试结果依赖执行顺序。应 Andy 要求已在 main 本地提交，未推送（仓库没有 remote）。证据见 ../evidence/AUDIT_VALIDATION.md。

同一天应 Andy “继续”的要求，又做了降低接入成本的改动和 PostgreSQL 验证（ADR 004）：三个动作表单 helper；Rails 自带的 `form.submit`/`form.button` 不再被拒；ViewComponent 可以拿到 surface/state/error 并发起动作；`parent_controller` 与 `delivery_lease` 可配置；没有 Turbo 时提交后回到嵌入页面；数据库回滚（死锁等）返回可重试的 CONFLICT。完整套件 78 tests 在 SQLite 三个组合和本地 PostgreSQL 17.11 上通过，demo 在两种数据库上经 HTTP 验证。

仍然**没有实现**的发现，等待决定：

- ActionExecution/Presentation/AgentInteraction 只增不减，没有保留期或清理接口。
- MySQL 未验证；Presentation 的五列字符串唯一索引在 utf8mb4 下按计算会超过索引长度上限。
- 没有 Turbo 且动作被拒时，仍然渲染没有 layout 的片段页（成功路径已改为回到嵌入页面）。
- 状态文案存在 `state["message"]` 里，刷新后仍显示上一次动作的提示。
- 迁移文件在 `db/migrate` 和安装器模板各有一份，目前内容相同，但没有测试保证两者一致。
- 还没有组件生成器（`rails g tool_views:component`）；等有外部开发者试过 helper 之后再决定。

价值判断（审计结论，不是市场证据）：技术上有明确空位。RubyLLM 自带的工具 partial 和 generative_ui 都只做展示，不做持久化状态、授权动作、幂等和回传；RubyGems 上 `toolviews`/`tool_views` 目前都未被占用。最大的风险不在代码而在采用成本：注册一个组件仍要写 schema、两层 policy 和 handler（表单字段现在由 helper 生成），还没有外部开发者试过。HYP-01/02 仍未验证，下一步最有价值的是找一位外部 Rails 开发者按 README 接入一次并计时。

2026-10-11：**V1_LOCAL_COMPLETE / UNPUBLISHED / HUMAN_REVIEW_PENDING**。Demo A、UC-01/10 和新授权的 UC-02..05、Demo B/C 均完成本地实现与验证。Andy 明确要求 v1 完成后才人工检查；当前进入这个检查点。源规格仍为 REVIEW，DELTA-001/002 记录本地授权，不代表正式 H2/C/R 或公共发布批准。

客户表单可修正字段、保留校验错误并只创建一次；工单查询和动作分别校验身份、角色、租户与关联记录，回复需人工审阅及明确本地入队；结果可编辑、显式再生成、锁定接受版本和授权导出。主应用保留九张演示业务表，gem 核心仍是四张表。

本地证据：完整核心与可选 RubyLLM 离线测试；SQLite 独立进程恢复、并发/重放及业务回滚；打包后安装到全新 Rails host；三组本地版本；浏览器键盘、360px、失败续接重启/重试、接受和下载。具体命令/结果以 ../evidence/V1_VALIDATION.md 和 agent/08_V1_ACCEPTANCE.md 为准；v0 原始证据保留在 VALIDATION.md。

发布未完成：名称/namespace 与许可证、独立安全审核、私密披露渠道、远程 CI、PostgreSQL、真实 provider、外部安装试用、实测替代方案接入成本。没有创建公共仓库、推送或发布 gem。

下一步：人工检查三个工作流及 README 的 API/服务端权限示例，决定是否进入正式开源发布阶段。没有推送或发布；所有任务临时服务已停止。不要把本地技术验证当作用户需求、外部接入收益或市场验证。
