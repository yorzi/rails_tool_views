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

v1 的业务权威在参考 host 的九张表：DemoStaff、DemoCustomer、DemoTicket、DemoReply、DemoOutboundReply、DemoArtifact、DemoArtifactVersion、DemoExport、DemoAgentReceipt。gem 包不带这些模型/迁移。TicketCard/ResultReview 的 props 只保存记录 ID；resolver 每次检查当前租户和关联，业务 lock_version/current_version 独立于 Surface revision。

```mermaid
erDiagram
  DEMO_CUSTOMER ||--o{ DEMO_TICKET : owns
  DEMO_STAFF ||--o{ DEMO_TICKET : assigned
  DEMO_TICKET ||--o| DEMO_REPLY : drafts
  DEMO_REPLY ||--o| DEMO_OUTBOUND_REPLY : queues_locally
  DEMO_ARTIFACT ||--o{ DEMO_ARTIFACT_VERSION : preserves
  DEMO_ARTIFACT ||--o{ DEMO_EXPORT : exports_accepted
```

SurfacesController 继承主应用 ApplicationController，因此挂载请求保留认证过滤器、scope 方法与视图 helper。主应用必须使用 HTML-capable controller 并审阅继承的过滤器。演示身份切换只选择固定测试角色，不能复用为生产认证。

日志脱敏只作用于引擎自身，不改主应用的 `filter_parameters`。SurfacesController 在 Rails 读取参数日志前追加一条过滤规则，只保留路由元数据；四个模型用各自的 `filter_attributes`；JSON 列使用 `RedactedJson`，它写入数据库的绑定值在 SQL 日志里显示为 `[FILTERED]`。主应用里同名的 `state`/`result` 参数和列不受影响。详见 ADR 003。

Schema 注册时遍历每一个子 schema：每个取值位置必须声明 type/enum/const 或由这样的分支组成，对象必须闭合，数组必须有 items。主应用的 renderer 或 Agent 适配器抛出的异常不再被吞掉：进入 `Rails.error`、Rails 日志和只含元数据的 `surface.render_failed` / `agent_failed` 事件；用户看到的仍是安全的兜底提示。错误文案和引擎界面文字可由主应用通过 `message:` 或 I18n（`tool_views.errors.*`、`tool_views.surface.*`）决定。

组件模板用 `tool_views_action_form` / `tool_views_action_button` 发起动作：字段名自动落在 `arguments[...]` 下，同页多个 Surface 的元素 id 不冲突，动作名、revision、幂等 key 和来源组件自动填入。ViewComponent 的构造函数如果声明了 `surface:`、`state:`、`error:` 关键字，就会收到对应的上下文，因此也能做成可交互组件；没有声明的组件行为不变。挂载控制器的父类由 `config.parent_controller` 指定（默认主应用的 ApplicationController）。数据库回滚整个动作事务时（死锁、序列化失败、锁超时）返回 CONFLICT，可用同一个 key 重试。SQLite 和 PostgreSQL 17 已在本地验证，MySQL 未验证。详见 ADR 004。

ValidationError 是受限的展示反馈，包含字段错误和批准的提交值；拒绝动作不持久化这些值，也不提交业务写入或回执。授权 HTML/Turbo 重绘当前组件，JSON 返回 422。业务续接在提交后执行；示例 Agent 将新业务版本/回复与 DemoAgentReceipt 放在一个事务，使用持久化 delivery_key 处理已写入但未确认的重试。外部 provider 仍需要自身 durable deduplication。
