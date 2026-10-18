# 人工变更记录

## 2026-10-18 — 只保留一个名字

gem 名不变，仍是 `rails_tool_views`。变化在于不再有第二套名字：`ToolViews` 常量、旧 require、旧安装命令和 `tool_views_*` helper 都删掉了，表、翻译 key、通知、页面 id 和续接 key 统一用 `rails_tool_views` 前缀。原因是 gem 还没发布，现在去掉没有外部成本；一旦发布，这些别名就要永久兼容，而且顶层 `ToolViews` 会占用一个不属于本 gem 的名字。已有的 0.2 主应用（目前只有 OddlyDock）跑一个改表迁移即可，保存的 Surface 和回放回执不受影响。详见 ADR 006。

2026-10-13：审计加固。需要更新的认知有四点。第一，安装这个 gem 不再改变主应用的日志：以前它会把所有叫 `state`、`result` 的参数和列都打码，现在只打码引擎自己的请求和四张表。第二，“严格闭合 schema”以前有漏洞，没写 type 的子 schema 可以放进任意 JSON，现在注册时就会被拒绝。第三，组件渲染失败或 Agent 适配器出错以前完全无声，现在会进日志和错误上报。第四，之前记录的“测试全绿”依赖执行顺序：单独运行 v1 控制器测试文件时 14 个 seed 中 5 个失败，完整套件前 12 个 seed 中 1 个失败，原因是一个 CSRF 测试污染了全局状态，已修复并用多个 seed 复验。已应 Andy 要求本地提交，未推送。

同日继续：写一个可交互组件不再需要手写隐藏字段，用 `tool_views_action_form` 即可；ViewComponent 不再是二等公民；用 Rails 自带的提交按钮不会再得到 400。PostgreSQL 从“未验证”变为“本地 17.11 通过”，这是之前最大的验证缺口。认证写在 ApplicationController 子类里的主应用现在可以用 `parent_controller` 接入。

2026-10-11：完成用户授权的本地 v1。三个真实数据库工作流验证组件可以承载表单、业务记录和创作审阅。新增通用表单反馈；修正挂载控制器继承，使 host 认证/helper 实际可用。业务版本和 Surface revision 分离，人工审阅/接受为确定性动作，再生成/草拟必须明确续接。示例 Agent 使用同事务的业务去重回执；客服只写本地 outbox，没有对外通信。人工检查现在待 Andy 执行，公共发布门槛继续保留。

2026-10-10：从空目录构建 ToolViews v0。核心新增三种独立权威：可信组件契约、持久化 UI 状态、主应用业务/Agent 状态。工具输出只是确认与引用；真实 UI 由 host 渲染，业务动作由可信服务决定。现有本地测试与浏览器证据支持技术可行性，不能代替正式开源批准、远程 provider 或实际接入试用。

## 2026-10-16 — RailsToolViews

按 Andy 要求将 gem/API 正式改为 `rails_tool_views` / `RailsToolViews`，旧 `ToolViews` 作为同一模块的兼容入口。数据库、组件契约、回放标识不改；已有 host 不必重新运行安装器。新安装采用新名字和路由，旧 helper/mount 继续可用。OddlyDock 仍是计划中的参考集成，不是 gem 依赖。详见 ADR 005。

## 2026-10-16 — Demo workbench and concise README

The reference app now organizes its existing examples into Component playground, Customer intake, Support workspace and Content review. Shared navigation, visible tenant/role context and suggested test flows make the same host-owned workflows easier to demonstrate. The support inbox retains the search query when opening a ticket. README is an entry point; detailed usage belongs to the guides, including the new Demo Workbench walkthrough. No core trust boundary or data model changes.

## 2026-10-17 — First real host integration (OddlyDock)

OddlyDock is the first real application to install the gem through the installer, and it found two issues the dummy app could not show. First, without JavaScript a committed action redirected through a hard-coded `tool_views` route name; hosts mounted under the installer's `rails_tool_views` name got a 500. The dummy app mounts under the old name, so the packaged-install smoke test now checks this path in a fresh host. Second, a Surface's accessible name could not be translated, because component registration runs before Rails applies its locale settings. The name is now looked up per render under `tool_views.components.<key>`. The guides also say plainly that partials and controller filters run inside the Engine's controller, so host links must go through `main_app`.

## 2026-10-17 — Audit hardening (identifiers and collation)

A full review of the gem found two real defects. The first is the biggest one because it would have blocked MySQL completely: the installer migration built the presentation's five-column unique index on plain `varchar(255)` columns, and MySQL measures that key as 5100 bytes against a 3072-byte ceiling, so creating the table fails. Identifier columns are now limited to 150 bytes, which brings the widest index to 3000 bytes. The second is subtler: identity lookups only asked the database for "equal" values, and on a database whose collation is not binary (MySQL's default, or a PostgreSQL locale) a value that merely compares equal could resolve another actor's or tenant's Surface, another correlation's presentation, or another action receipt. The runtime now bounds every stored identifier to 150 bytes and confirms a byte-exact match after each lookup. Your existing database needs no migration: the old columns remain and the bound is applied in code, so the only visible change is that an identifier longer than 150 bytes is now rejected instead of stored. Two smaller things: the documentation said the presentation index "needs review for utf8mb4 limits" and it is now fixed, and the "two migration copies have no consistency test" finding was stale because such a test already existed. MySQL itself is still not installed, so that fix rests on reading the schema and arithmetic, not a real MySQL run.

## 2026-10-18 — First public release path

首次公开版本从 0.1.0 开始；原来的 0.2/0.3 只是内部候选标记。代码能力不变，分发方式变为 MIT gem、公开 GitHub 仓库及自定义域名 Pages。发布由匹配标签触发，通过兼容性、依赖安全、实际独立安装与文档检查后使用 GitHub OIDC 上传，随后刷新稳定版与 next 文档。私密安全报告通过 GitHub 接收。当前上传状态及未完成证据见 RELEASE_0_1_0；没有把发布授权当作正式 H2 或外部采用证明。

发布结果：0.1.0 于 2026-10-18 发布，精确标签的全部 CI 与发布后 Pages 成功。稳定版/next、DNS/HTTPS、RubyGems/GitHub 校验和一致已核验。后续版本沿用此流程；开放证据边界不变。

## 2026-10-18 — Documentation roles and the proposed road to 1.0

README 只保留定位、安装、demo 和入口；使用细节由文档站统一维护，贡献/安全/变更/版本计划留在仓库 Markdown。修正 CONTRIBUTING 与 Production 中未发布/未选许可证的旧说法，压缩当前状态和任务清单，历史仍在 ledger/evidence 与 Git。

新增 ROADMAP 提案：0.2 接入便利与错误页面，0.3 生命周期，0.4 恢复/诊断，1.0 RC 冻结契约、审查、外部试用与升级验证。未来功能尚未实现，内部历史 V1 不等于公开 1.0。架构和业务流程无变化。

## 2026-10-18 — 0.2 开发与测试基础

同一份 dummy 同时承担 demo 与真实 Chrome 测试；每次使用临时数据库，保留 fixture 截图。实际打包 gem 在隔离依赖的临时 host 验证接入，避免工作区依赖掩盖缺包。两者分别证明浏览器行为和安装接入，不代表外部采用。后续按 ROADMAP 推进生成器和 HTML 纠错；发布未自动授权。
