# 项目状态

2026-10-26：**owner授权直接发布1.0.0（跳过rc1），1.0条件5与条件6中的独立安全审核/正式gate处置以例外豁免（DELTA-008），并非已满足。** 发布结果以交付证据为准；tag发布前最新公开版本仍为0.4.0。

本轮审计修复5类缺陷（刷新抢焦点、注册错误码、标识符编码/SafeBuffer/digest边界/竞争诊断、CSP nonce、RC会成为GitHub Latest），声明1.0公开契约，RubyLLM适配器标为experimental、MySQL排除出支持矩阵，升级覆盖0.1.0..0.4.0全部已发布版本。随后按owner要求解决D1..D3（ADR 010/DELTA-007）：purge_closed游标分页、host证明的reconcile_delivery、无adapter投递抛AGENT_NOT_CONFIGURED。本地全矩阵通过，详见[RC1准备记录](../evidence/RC1_READINESS.md)。

以下为0.4.0发布状态：

## 已交付

- [RubyGems 0.4.0](https://rubygems.org/gems/rails_tool_views/versions/0.4.0)、[GitHub Release](https://github.com/yorzi/rails_tool_views/releases/tag/v0.4.0)，annotated tag固定于`e93f8df`；MIT、MFA与既有OIDC发布。
- attempts确认fence与事务外投递，host job/进程中断恢复；action.executed增加replayed，临时notice保留旧message语义。无新schema/migration/runtime依赖。
- 精确tag三组SQLite各129/1129，PG132/1145、adapter7/45、Chrome8/77全绿；真实0.2/0.3升级、实际包/隔离安装/审计与3,102文档链接通过。
- registry/API/client/Release/SHA256SUMS一致；下载包重新空环境Rails接入通过。[稳定0.4与next文档](https://rails-tool-views.wangyaodi.com)18个HTTPS入口、安装指令/搜索/版本切换已验证。

详见[发布证据](../evidence/RELEASE_0_4_0.md)与[本地验收](../evidence/V0_4_VALIDATION.md)。旧版本/tag保持不可变。

## 当前工作与下一步

D4/D5已决定：发布1.0.0，条件5/6的外部试用、对照、非dummy使用、独立安全审核与正式gate豁免为owner例外。WORK-20261026-01推送1.0.0元数据并核验精确CI，WORK-02打tag、OIDC发布、核验registry与stable 1.0、/next/、/v0/站点。即时清单见[Current Work](../agent/02_CURRENT_WORK.md)。

升级从0.3无需迁移，必须drain旧web/worker，deliver移到host commit后；更旧版本先执行0.3迁移。fence不等于远端exactly-once，uncertain仍隔离，host负责durable dedup/outbox和reconcile。notice是显示寿命，回执仍保留，不能存秘密。

## 尚未解决

| 问题 | 当前事实 / 后续证据 |
| --- | --- |
| 不确定投递 | 仍不凭时间或状态清除；host核对去重记录与静默后用reconcile_delivery证明结果（ADR 010） |
| 实际采用 | 外部setup trials、实测定制实现对照和持续非dummy使用尚缺（1.0条件5） |
| 支持与review | MySQL、真实provider、独立安全/full a11y未验证；正式H2/C/R仍开放 |

历史与授权见[Progress Ledger](05_PROGRESS_LEDGER.md)、[Spec Delta](../agent/05_SPEC_DELTA_PROTOCOL.md)。
