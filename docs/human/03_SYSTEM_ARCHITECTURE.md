# 当前架构

Registry 是 Ruby 定义：可信 renderer、严格 schema、版本摘要、权限和动作 allowlist。Core 入口不加载 RubyLLM；唯一 SDK require 在可选适配器文件。

```mermaid
erDiagram
  SURFACE ||--o{ PRESENTATION : correlates
  SURFACE ||--o{ ACTION_EXECUTION : records
  SURFACE ||--o{ AGENT_INTERACTION : emits
  ACTION_EXECUTION ||--o| AGENT_INTERACTION : triggers
```

Surface 保存 actor/tenant 不透明标识、context 引用、组件摘要、props/state、revision/lock_version。Presentation 的 actor+tenant+adapter+call+context 唯一键去重工具请求。ActionExecution 的 Surface+key 唯一键保存回执；参数摘要识别错误复用。AgentInteraction 的 execution 唯一键保存结构化输入、投递状态与 lease。

动作先校验/授权，再在同一数据库事务里执行 host handler、更新 revision 并写回执。JSON/Turbo 在提交后选择输出。Agent 投递在事务外；失败不会回滚已经保存的选项。跨数据库或外部服务副作用不在此原子性保证里。

默认拒绝读取/展示/动作；Surface 的 actor+tenant 必须匹配，并再次调用 host policy。source/target 绑定当前 Surface。模型 props 和客户端 policy 文本不能决定业务权限。host 自行解决数据库备份、保留期、敏感数据投影、远端去重与队列。
