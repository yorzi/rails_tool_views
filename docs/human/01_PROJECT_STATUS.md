# 项目状态

2026-10-19：**0.2.0 保持已发布；owner 已授权推进 0.3.0 推送、远端验证与发布。**

## 已交付

- [RubyGems 0.2.0](https://rubygems.org/gems/rails_tool_views/versions/0.2.0)，[GitHub Release](https://github.com/yorzi/rails_tool_views/releases/tag/v0.2.0)；tag 指向 `3156fd3`，MIT、MFA、现有 GitHub OIDC。
- 新增安全 Partial 生成器、完整无 Turbo HTML 纠错与安全返回。已有 schema/Surface/授权事务/回放/可选 RubyLLM 能力保持；无 migration 或新 runtime dependency。
- 精确标签远端：三个 Ruby/Rails 与 PostgreSQL 各 97/837、adapter 7/45、Chrome 4/28；实际安装、生成测试、依赖审计与 2,450 文档链接通过。
- [文档站](https://rails-tool-views.wangyaodi.com) 稳定版 0.2.0，next 跟随 main；搜索、版本切换、15 个 HTTPS 入口与实际客户端 gem 下载验证通过。

完整记录：[发布证据](../evidence/RELEASE_0_2_0.md)；[本地实现验收](../evidence/V0_2_VALIDATION.md)。历史版本保持不可变，不把旧内部 V1 名称当成公共 1.0。

## 当前工作与下一步

0.3 本地候选已完成：close/abandon、加法迁移、scoped retention preview/apply、correlation tombstone 和不确定投递保护。三个 SQLite 组合各 114/988，PostgreSQL 116/1000（含真实锁竞争），adapter 7/45，Chrome 5/40、三个旧数据升级/实际包 host、隔离网络安装/审计和文档通过。详见 [0.3 验证](../evidence/V0_3_VALIDATION.md)。正准备发布标记与文档，随后推送并等待精确候选 CI，再经既有 OIDC 发布并核验；未提前声明发布完成。执行状态见 [Current Work](../agent/02_CURRENT_WORK.md)。

## 尚未解决

| 问题 | 当前事实 / 拟处理阶段 |
| --- | --- |
| 数据生命周期 | close/abandon 与清理本地候选通过。旧租约不确定投递受持久保护，不能据时间强删；恢复方案留 0.4 |
| 运行反馈与遥测 | state message 会持久化，回放仍发 action.executed；拟在 0.4 处理，新通知契约需 owner 决定 |
| 实际采用 | 缺少外部开发者试验和实测定制实现对照；dummy/本地接入不是外部采用 |
| 支持边界 | MySQL、真实 provider、独立安全审核未验证；正式 H2/C/R 仍开放 |

历史与授权见 [Progress Ledger](05_PROGRESS_LEDGER.md)、[Spec Delta](../agent/05_SPEC_DELTA_PROTOCOL.md)。
