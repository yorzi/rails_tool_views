# Formal Specs review / 立项审核

**Decision:** CHANGES_REQUIRED
**Reviewer and role:** AI-assisted initial desk review (not human approval)
**Reviewed at:** 2026-10-10
**Reviewed content:** Draft Specs; no fixed Q commit.
**Authority:** User requested an independent open-source, AI-framework-agnostic Rails component/tool framework.

| Dimension | Finding |
|---|---|
| Problem/value | Clear hypothesis, no external user evidence yet |
| Product/domain | Component/Tool/Surface/Action separated, FR/AC drafted |
| UX | Wireframe/flow, no real browser prototype or approved state board |
| Technology | Pinned upstream source review added (GenerativeUI vs A2UI Rails); SP-01..12 runnable reproduction outstanding |
| Safety | SEC-01..18 specified with added client-policy, source spoofing, stream/target and response-format tests; not executed |
| OSS/legal | Namespace, license, support and matrix pending |
| Agent delivery | Source map/slices specified; no Gate H2 |
| Cross-doc | Intent vs implementation authority separated |

## Findings
| ID | Severity | Gap | Gate / owner |
|---|---|---|---|
| R-01 | BLOCKER | No runnable RubyLLM-free core/adapter roundtrip evidence | Phase 0 / researcher |
| R-02 | MAJOR | generative_ui overlap and reuse not measured | Phase 0 / maintainer |
| R-03 | MAJOR | No browser state board/prototype | H1 / designer |
| R-04 | MAJOR | No external Rails integrator feedback/glue-code comparison | Gate R / maintainer |
| R-05 | MAJOR | Owner selected **ToolViews**; gem/repo namespace availability, trademark, license and public repo still unverified | H2/Release / human owner |
| R-06 | BLOCKER | Pinned source findings (Core eager RubyLLM loader; A2UI Rails memory store, request-sourced rules, stream boundaries, format-specific mutations) lack runnable reproduction and prevention tests | Phase 0 SP-09..12 + SEC-13..18 / researcher |
| R-07 | MAJOR | UC-01..10 ranked from architectural reasoning, not Rails adopter interviews; V1 Demo B/C needs measured incremental value | V1 adoption research / maintainer |

## Use cases and naming addendum (2026-10-10)
Owner selected **ToolViews** and the Specs path is now `toolviews/`; no third-party name/namespace clearance has been performed. Ten proposed adoption scenarios and three demo directions are documented under [supporting/06](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md). **V0 remains UC-01/10 only**, with V1/V2 cases explicitly non-binding. Review status stays **CHANGES_REQUIRED**.

## Source-review addendum (2026-10-10)
[Supporting audit](supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md) records immutable upstream SHAs and code paths. This **improves factual architecture evidence only**: no unit suite, gem build, two-tenant exploit simulation, browser replay or interview was run. Do not change lifecycle, grant human approval or mark Gate V/H passed.

## Negative review
A focused upstream contribution plus Rails adapter may be better than another gem. Avoid duplicate schema compiler, AI-specific core dependency and early component trees/progressive rendering/protocol compliance. No actual adoption or security validation has been performed.

## Conclusion
Continue REVIEW and Phase 0 only. Re-review after hard blockers have reproducible evidence. HUMAN_REVIEW requires H1; HANDOFF_READY requires independent human H2 with Q.