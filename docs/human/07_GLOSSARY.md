# 术语

| 名称 | 含义 |
|---|---|
| Registry | 主应用显式注册的可信组件集合 |
| Surface | actor/tenant 范围内的持久化展示状态 |
| Scope | host 从身份系统解析的 actor/tenant 标识 |
| Revision | 已提交状态版本；过期写入拒绝 |
| Presentation | 工具调用与 Surface 的持久化关联 |
| ActionExecution | 一次动作的幂等回执与参数摘要 |
| AgentInteraction | 可选的结构化后续交互，不是 tool response |
| Delivery lease/key | 防止同时投递的短期 claim 与 host 远端去重键 |
| V0_LOCAL_COMPLETE | 本地实现验证完成；公共发布仍未批准 |
| V1_LOCAL_COMPLETE | 授权的 UC-02..05 本地实现验证完成；人工审阅与发布仍待进行 |
| ValidationError | 受限字段错误与批准提交值；422，不提交业务/Surface 状态 |
| Domain version | 主应用业务对象版本；独立于 Surface revision，防止跨 Surface 的过时写入 |
| Local outbox | 演示中持久化已审阅回复；不代表已发送给客户 |
| DemoAgentReceipt | 主应用同事务业务回执，按 delivery_key 防止重试重复写入 |
