# Research sources and evidence register

**Source inspection performed:** 2026-10-10. [Pinned source-level audit](supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md) identifies upstream commits and code paths; Phase 0 runnable reproduction NOT YET DONE. General documentation links below are living URLs and must not be mistaken for frozen implementation evidence.

| ID | Source | Why relevant | Evidence caveat |
|---|---|---|---|
| SRC-01 | https://github.com/crmne/ruby_llm/blob/main/docs/_core_features/tool-execution.md | Tool controls, approvals, callback/execution constraints | APIs version-sensitive |
| SRC-02 | https://github.com/crmne/ruby_llm/blob/main/docs/_advanced/rails-streaming.md | Hotwire streaming and persisted chat pattern | Does not directly implement UI Surfaces |
| SRC-03 | https://github.com/crmne/ruby_llm/blob/main/CONTRIBUTING.md | Core contribution boundary; app-layer integrations preferred | Maintainer policy may change |
| SRC-04 | https://github.com/kryzhovnik/generative_ui/blob/main/README.md | Catalog, Rails renderers, component tree | Experimental APIs, no production guarantee |
| SRC-05 | https://github.com/kryzhovnik/generative_ui/blob/main/lib/generative_ui/tool.rb | RubyLLM::Tool subclass and direct require | Only Tool class linkage observed, not proof entire catalog requires RubyLLM |
| SRC-06 | https://github.com/a2ui-project/a2ui | A2UI declarative agent UI standard | Confirm spec version / ownership |
| SRC-07 | https://github.com/ag-ui-protocol/ag-ui | Agent ↔ UI events | Distinct role from component rendering |
| SRC-08 | https://modelcontextprotocol.io/extensions/apps/overview | MCP Apps UI resource protocol | iframe/sandbox host contract separate |
| SRC-09 | https://turbo.hotwired.dev/ | Turbo Streams + morph | Browser/browser-version caveats |
| SRC-10 | https://guides.rubyonrails.org/ | Rails Engine, Active Record, jobs and security | Verify versions |
| SRC-11 | https://viewcomponent.org/ | Rails component contract | Optional dependency |
| SRC-12 | https://www.phlex.fun/ | Alternative Rails renderer | Deferred adapter |
| SRC-13 | https://github.com/kryzhovnik/generative_ui/tree/994410c95042b9c8da660fbf425cee99fb3e2066 | Pinned Catalog/Tool require graph, validation limits, Rails rendering and existing tests | Static source verified; not executed |
| SRC-14 | https://github.com/vicentereig/a2ui-rails/tree/d409b71670febabc46d64694461ec1adddd5996f | Pinned SurfaceManager, DSPy modules, Controller, Cable, renderer, GemSpec and tests | Static source verified; host exploitability/package install not tested |

## Differentiation hypothesis
generative_ui already provides RubyLLM-backed declarative tree/schema + Rails rendering. Proposed gap is independent **persistent Surface, trusted Rails Action, auth, idempotency, and agent-return lifecycle** with RubyLLM optional. This is an opportunity hypothesis, not a claim that other frameworks cannot implement it.

## Architectural interpretation
[Upstream code matrix, links and failure probes](supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md) supersede earlier informal comparisons. GenerativeUI's validated Catalog/Tree rendering is real and its main loader eagerly requires a RubyLLM Tool; A2UI Rails implements Stimulus/Turbo interaction but its state is per-process, its handler invokes an LLM rather than registered Rails business services, and its type Union limits extensibility. These observations inform a **conditional** reuse decision rather than a blanket fork recommendation.

## Use-case evidence status
UC-01..UC-10 and three reference demo proposals come from the maintainer discussion, **not** an external competitor, user interview or quantified market study. They are product hypotheses captured in [supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md). Verify actual Rails integrations and opportunity-size/maintenance assumptions before promoting V1; do not cite the scenario list as evidence of adoption.

## Missing evidence
No user interviews, comparative install benchmarks, completed repo tests, legal name search, licenses matrix or production security evaluation. The Phase 0 plan must explicitly gather these before Gate V and adoption claims.