# Risk register — priority and mitigation

| Risk | Severity | Treatment / gate |
|---|---|---|
| Duplicate generative_ui catalog/compiler | HIGH | Verified source already offers Catalog/schema/tree/renderer; reproduce reusable neutral core and choose upstream/bridge/independent via SP-09/12; PIVOT if overlap dominates |
| Core unintentionally requires RubyLLM | HIGH | Gemfile without ruby_llm + CI independent boot |
| Untrusted model controls renderer/handler/code | CRITICAL | Registry whitelist, strict props schema, no eval/constantize or generated scripts |
| Cross-tenant Surface access | CRITICAL | default-deny object-scoped policy and negative tests |
| Tool-result and browser reference diverge | HIGH | scope correlation key by adapter+context; same persisted Surface |
| Agent continuation corrupts transcript | HIGH | adapter owns provider-specific history; mocked+live tests |
| Stale/duplicate browser actions | HIGH | optimistic revision check, idempotency record, shared JSON/Turbo/Cable state transition, post-commit updates |
| Client-controlled business rules / forged action source | CRITICAL | reject client policy, server authorization and action-source allowlist; SEC-13/14 |
| Cross-user ActionCable subscription / unsafe DOM target | CRITICAL | authenticate+authorize stream per Surface/actor and validate target scope; SEC-15/16 |
| In-process state or response-format-dependent mutation | HIGH | ActiveRecord Surface, transactional unified mutation across JSON/Turbo/Cable; SEC-17/18 |
| A2UI Rails packaging and component dispatch inconsistencies | MEDIUM | verify GemSpec/clean install and declared Tabs/Modal renderer behavior before reuse; SP-10 |
| Component schema changes break persisted UI | MEDIUM | digest + explicit incompatible state, migration ADR |
| Rails/Ruby/Hotwire compatibility | MEDIUM | tested version matrix and release notes |
| No external adopter demand | HIGH | 3 Rails developer trials and glue-code comparator; KILL/PIVOT gate |
| OSS name/license conflicts | MEDIUM | registry/trademark/dependency license review before release |
| Scope creep into universal UI system | HIGH | ten UC contracts are ranked **hypotheses**; V0 includes UC-01/10 only, defer others to V1/V2 |
| Weak understanding of ToolViews name or naming collision | MEDIUM | explanatory subtitle; RubyGems, GitHub, trademark and domain clearance pending, do not claim registration |
| Ten demo ideas mistaken for ten mandatory product features | HIGH | scenario/FR separation; UC-ID traceability and human product-intent gate |

Pinned-source technical evidence: [supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md](supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md). Upstream design concerns are not verified security exploits. No risk is resolved simply because a written design exists. See 09, 11 and supporting/04 for verification cases.
