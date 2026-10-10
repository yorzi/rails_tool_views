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
