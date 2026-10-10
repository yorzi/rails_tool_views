# Decision log — product intent

| ID | Date | Decision | Status |
|---|---|---|---|
| D-001 | 2026-10-10 | Independent open-source Rails components as interactive tools | USER_DIRECTION |
| D-002 | 2026-10-10 | RubyLLM is optional adapter, not mandatory Core dependency | LOCKED |
| D-003 | 2026-10-10 | Reuse existing Partial/ViewComponent and trusted business actions | LOCKED |
| D-004 | 2026-10-10 | Separate Component, ToolDescriptor, Surface, Action and AgentContinuation | PROPOSED |
| D-005 | 2026-10-10 | Default bounded present_ui, single component V0 | VERIFY_IN_SPIKE |
| D-006 | 2026-10-10 | generative_ui integration upstream-first, never blindly duplicate | VERIFY_IN_SPIKE |
| D-007 | 2026-10-10 | **ToolViews** selected as the project name by owner (formerly ViewTools); RubyGem/repo namespace and MIT license still require clearance | NAME_SELECTED_RELEASE_GATES_PENDING |
| D-008 | 2026-10-10 | OddlyNiche H1/H2/Q/C/R/I approval gates | LOCKED |
| D-009 | 2026-10-10 | Source audit favors GenerativeUI Catalog/Validation reuse, A2UI Rails interaction patterns only; choose upstream/bridge/independent via runnable SP-09..12 | VERIFY_IN_SPIKE |
| D-010 | 2026-10-10 | One authoritative Rails state transition across JSON/Turbo/ActionCable; host domain data and Agent transcript remain separate | PROPOSED |
| D-011 | 2026-10-10 | Preserve ten reference use cases UC-01..10 as *research hypotheses*; UC-01/10 only in V0, P1/P2 separate V1/V2 | LOCKED_SCOPE_GUARDRAIL |
| D-012 | 2026-10-10 | Official demo order: A ChoiceCard V0, B Support Ticket V1, C Result Review V1 | PROPOSED |

Implementation ADRs are owned by independent repo after handoff. Do not silently promote proposals to settled product authority.