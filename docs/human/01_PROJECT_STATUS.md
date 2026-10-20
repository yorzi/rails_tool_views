# 项目状态

2026-10-20：**0.3.0 已发布；0.4 本地候选验收完成，未推送或发布。**

## 已交付

- [RubyGems 0.3.0](https://rubygems.org/gems/rails_tool_views/versions/0.3.0)、[GitHub Release](https://github.com/yorzi/rails_tool_views/releases/tag/v0.3.0)，tag 指向 `d12996e`。MIT、MFA 与既有 OIDC 发布。
- close/abandon、scoped retention preview/apply、关联 tombstone 与不确定投递保护。需要加法迁移、停止旧 writers 与备份；业务表不删，nil 保留无限期。
- 精确标签三组 SQLite 各114/988，PG116/1000，adapter7/45，Chrome5/40；真实0.2数据升级、实际包/隔离安装/审计与2,692文档链接通过。
- [文档站](https://rails-tool-views.wangyaodi.com)稳定0.3/next，16个HTTPS入口、安装指令/搜索/版本切换已验证；registry/API/client/Release四方SHA一致。

详见[发布证据](../evidence/RELEASE_0_3_0.md)与[本地候选验证](../evidence/V0_3_VALIDATION.md)。旧标签和发布保持不可变。

## 当前工作与下一步

0.4按路线图完成恢复/诊断/临时反馈，owner批准DELTA-006。三个Ruby/Rails组合各129/1129，PG132/1145，adapter7/45，Chrome8/77；真实0.2/0.3升级、实际包/隔离安装/审计与2,897文档链接通过。详见[0.4本地验收](../evidence/V0_4_VALIDATION.md)。owner现已明确授权推送/远端CI、发布验收和发布；正在执行0.4发布，尚未取得远端或公开交付结果。即时清单见[Current Work](../agent/02_CURRENT_WORK.md)。

## 尚未解决

| 问题 | 当前事实 / 拟处理阶段 |
| --- | --- |
| 数据生命周期 | close/abandon 与清理已发布。旧租约不确定投递受持久保护，不能据时间强删；0.4支持有fence的恢复，uncertain仍保守隔离；host负责reconcile/quiescence |
| 运行反馈与遥测 | owner 已批准 DELTA-006：action.executed + replayed；新增 transient notice，保留 state.message。本地矩阵/包/Chrome验收通过，尚未发布 |
| 实际采用 | 缺少外部开发者试验和实测定制实现对照；dummy/本地接入不是外部采用 |
| 支持边界 | MySQL、真实 provider、独立安全审核未验证；正式 H2/C/R 仍开放 |

历史与授权见 [Progress Ledger](05_PROGRESS_LEDGER.md)、[Spec Delta](../agent/05_SPEC_DELTA_PROTOCOL.md)。
