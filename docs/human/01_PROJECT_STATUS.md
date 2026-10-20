# 项目状态

2026-10-20：**0.4.0 已发布，远端CI与公开产物/文档验收通过。**

## 已交付

- [RubyGems 0.4.0](https://rubygems.org/gems/rails_tool_views/versions/0.4.0)、[GitHub Release](https://github.com/yorzi/rails_tool_views/releases/tag/v0.4.0)，annotated tag固定于`e93f8df`；MIT、MFA与既有OIDC发布。
- attempts确认fence与事务外投递，host job/进程中断恢复；action.executed增加replayed，临时notice保留旧message语义。无新schema/migration/runtime依赖。
- 精确tag三组SQLite各129/1129，PG132/1145、adapter7/45、Chrome8/77全绿；真实0.2/0.3升级、实际包/隔离安装/审计与3,102文档链接通过。
- registry/API/client/Release/SHA256SUMS一致；下载包重新空环境Rails接入通过。[稳定0.4与next文档](https://rails-tool-views.wangyaodi.com)18个HTTPS入口、安装指令/搜索/版本切换已验证。

详见[发布证据](../evidence/RELEASE_0_4_0.md)与[本地验收](../evidence/V0_4_VALIDATION.md)。旧版本/tag保持不可变。

## 当前工作与下一步

提交推送最终交付记录并检查该commit的CI/Docs。当前没有新的功能开发任务；1.0之前先按[路线图](../../ROADMAP.md)梳理契约冻结、非dummy接入/外部试用与独立review证据，不以增加功能或版本数代替验收。即时清单见[Current Work](../agent/02_CURRENT_WORK.md)。

升级从0.3无需迁移，必须drain旧web/worker，deliver移到host commit后；更旧版本先执行0.3迁移。fence不等于远端exactly-once，uncertain仍隔离，host负责durable dedup/outbox和reconcile。notice是显示寿命，回执仍保留，不能存秘密。

## 尚未解决

| 问题 | 当前事实 / 后续证据 |
| --- | --- |
| 不确定投递 | 保守保护已发布；不能凭时间清除，host负责reconcile/quiescence |
| 实际采用 | 外部setup trials、实测定制实现对照和持续非dummy使用尚缺 |
| 支持与review | MySQL、真实provider、独立安全/full a11y未验证；正式H2/C/R仍开放 |

历史与授权见[Progress Ledger](05_PROGRESS_LEDGER.md)、[Spec Delta](../agent/05_SPEC_DELTA_PROTOCOL.md)。
