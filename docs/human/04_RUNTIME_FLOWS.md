# 运行流程

```mermaid
sequenceDiagram
  participant H as Host/可选工具
  participant R as Registry
  participant D as Rails 数据库
  participant B as 浏览器
  H->>R: component + props + 可信 scope
  R->>D: 授权后创建/去重 Surface
  D-->>H: 独立展示引用
  H->>B: 可信组件 HTML
  B->>D: 动作 + revision + key + CSRF
  D->>D: 重新授权、事务 handler/状态/回执
  D-->>B: JSON 或 Surface 内 Turbo 更新
  D-->>H: 可选结构化 AgentInteraction
```

刷新只读取持久化数据，不调用模型。重复 key 返回已有回执；不同参数复用 key 被拒；过期 revision 返回冲突并显示当前状态。权限失败不泄漏 props。组件摘要变化显示兼容性错误而保留数据。

后续交互可同步投递，也可由 host 关闭 auto_deliver 后在 Active Job 调用 deliver。pending/failed/completed 与选项保存分开。失败可明确重试；重试前再次授权，使用同一 delivery key。RubyLLM continuation 使用新的 user turn，拒绝混入未完成 tool round。
