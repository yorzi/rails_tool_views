# 项目状态

2026-10-30：owner要求核实rails_ai_admin记录的rails_tool_views问题并发布1.0.2。DEP-006属实已修复：安装器发现已有Engine mount时不再追加同名默认mount（原先会让宿主路由无法加载）。DEP-001不是缺陷：配置、registry与mount按设计在进程内共享，Configuration新增说明，ROADMAP把“每进程一个运行时”列为owner决定。1.0.2候选通过完整本地发布检查，按发布清单推送、跑精确CI、打`v1.0.2`。

2026-10-28：owner要求审阅post-1.0审计并准备1.0.1。审阅无阻塞缺陷，修正demo两处小问题，CI的adapter job增加RubyLLM 2.0.0（新下限）。随后owner授权发布：**1.0.1已公开发布**（v1.0.1→7f50284，main已快进，精确CI/tag CI/Release九个job/Pages全部通过，RubyGems/GitHub Release/SHA256SUMS一致，稳定1.0.1、/next/、/v0/已上线），见[交付证据](../evidence/RELEASE_1_0_1.md)。下一步：owner决定路线图中“Decisions for the owner”三项，以及是否授权1.1适配器稳定化所需的live provider运行。

2026-10-26（1.0.0之后）：owner要求审计gem、补齐正确的demo并更新路线图。分支`claude/laughing-pasteur-p18ora`上已完成且未发布：RubyLLM适配器在1.x上拒绝加载（1.x上工具从来不可用）；demo修正已发布版本标签与可实际观察的清理期限，并新增运行RubyLLM真实工具循环的Agent chat（离线transport，含集成测试）；Getting Started补充importmap宿主的Stimulus接入（在生成的Rails 8.1宿主中验证）；ROADMAP新增“After 1.0”。未打tag、未发布、未调用provider。下一步由owner审阅并决定是否作为1.0.1发布，以及路线图中的三项默认行为决定。

2026-10-26：**owner授权直接发布1.0.0（跳过rc1），1.0条件5与条件6中的独立安全审核/正式gate处置以例外豁免（DELTA-008），并非已满足。** **1.0.0已发布**（v1.0.0→5ded407，RubyGems/GitHub Release/SHA256SUMS一致，稳定1.0、/next/、/v0/已上线），见[交付证据](../evidence/RELEASE_1_0_0.md)。

本轮审计修复5类缺陷（刷新抢焦点、注册错误码、标识符编码/SafeBuffer/digest边界/竞争诊断、CSP nonce、RC会成为GitHub Latest），声明1.0公开契约，RubyLLM适配器标为experimental、MySQL排除出支持矩阵，升级覆盖0.1.0..0.4.0全部已发布版本。随后按owner要求解决D1..D3（ADR 010/DELTA-007）：purge_closed游标分页、host证明的reconcile_delivery、无adapter投递抛AGENT_NOT_CONFIGURED。本地全矩阵通过，详见[RC1准备记录](../evidence/RC1_READINESS.md)。

以下为0.4.0发布状态：

## 已交付

- [RubyGems 0.4.0](https://rubygems.org/gems/rails_tool_views/versions/0.4.0)、[GitHub Release](https://github.com/yorzi/rails_tool_views/releases/tag/v0.4.0)，annotated tag固定于`e93f8df`；MIT、MFA与既有OIDC发布。
- attempts确认fence与事务外投递，host job/进程中断恢复；action.executed增加replayed，临时notice保留旧message语义。无新schema/migration/runtime依赖。
- 精确tag三组SQLite各129/1129，PG132/1145、adapter7/45、Chrome8/77全绿；真实0.2/0.3升级、实际包/隔离安装/审计与3,102文档链接通过。
- registry/API/client/Release/SHA256SUMS一致；下载包重新空环境Rails接入通过。[稳定0.4与next文档](https://rails-tool-views.wangyaodi.com)18个HTTPS入口、安装指令/搜索/版本切换已验证。

详见[发布证据](../evidence/RELEASE_0_4_0.md)与[本地验收](../evidence/V0_4_VALIDATION.md)。旧版本/tag保持不可变。

## 当前工作与下一步

D4/D5已决定：发布1.0.0，条件5/6的外部试用、对照、非dummy使用、独立安全审核与正式gate豁免为owner例外。WORK-20261026-01/02已完成。公共契约自1.0.0起按SemVer承诺；不自动开始下一迭代，外部试用/独立审核仍是1.x的开放证据。即时清单见[Current Work](../agent/02_CURRENT_WORK.md)。

升级从0.3无需迁移，必须drain旧web/worker，deliver移到host commit后；更旧版本先执行0.3迁移。fence不等于远端exactly-once，uncertain仍隔离，host负责durable dedup/outbox和reconcile。notice是显示寿命，回执仍保留，不能存秘密。

## 尚未解决

| 问题 | 当前事实 / 后续证据 |
| --- | --- |
| 不确定投递 | 仍不凭时间或状态清除；host核对去重记录与静默后用reconcile_delivery证明结果（ADR 010） |
| 实际采用 | 外部setup trials、实测定制实现对照和持续非dummy使用尚缺（1.0条件5） |
| 支持与review | MySQL、真实provider、独立安全/full a11y未验证；正式H2/C/R仍开放 |

历史与授权见[Progress Ledger](05_PROGRESS_LEDGER.md)、[Spec Delta](../agent/05_SPEC_DELTA_PROTOCOL.md)。
