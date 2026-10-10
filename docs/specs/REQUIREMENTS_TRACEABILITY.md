# Requirements and acceptance traceability
Canonical criteria and observable behavior: [04_FEATURE_MVP_SPECS.md](04_FEATURE_MVP_SPECS.md).

| Requirement | Acceptance IDs | Tests / evidence | Slice |
|---|---|---|---|
| FR-01 registry | FR-01-AC-01/02/03 | unit: valid, duplicate, unknown props, scoped exposure | S1 |
| FR-02 deterministic rendering | FR-02-AC-01/02 | Rails integration without RubyLLM | S1 |
| FR-03 optional agent tool | FR-03-AC-01/02/03/04 | mocked tool, correlation, retries, no mandatory gem | S2 |
| FR-04 Surface restore | FR-04-AC-01/02/03 | reload offline, missing renderer, cross-tenant | S1 |
| FR-05 authorized actions | FR-05-AC-01, FR-05-AC-02, FR-05-AC-03, FR-05-AC-04 | allowed vs invalid/stale/duplicate, forged component source and client rules, DB side effects | S1 |
| FR-06 continuation | FR-06-AC-01/02/03 | event payload, adapter history, agent absent | S3 |
| FR-07 Hotwire UX | FR-07-AC-01, FR-07-AC-02, FR-07-AC-03, FR-07-AC-04 | browser focus, mobile, loading/conflict/error; JSON/Turbo same state; bounded Turbo targets | S1/S3 |
| FR-08 OSS installation | FR-08-AC-01/02/03 | clean dummy Rails app, opt-in smoke, release gate | S4 |
| NFR-01 | NFR-01-AC-01 | SEC-01/02/03/10 | S1/S4 |
| NFR-02 | NFR-02-AC-01, NFR-02-AC-02 | SEC-04/06/07/08/13/14/15/16/17/18; restart/worker isolation | S1/S3 |
| NFR-03 | NFR-03-AC-01 | supported-version CI matrix | S4 |
| NFR-04 | NFR-04-AC-01 | Gemfile excludes RubyLLM | S1 |
| NFR-05 | NFR-05-AC-01 | sensitive-data/retention audit | S4 |
| NFR-06 | NFR-06-AC-01 | keyboard, accessible names, narrow viewport | S1/S4 |

## Use-case mapping (hypotheses, not new V0 features)
- **UC-01** Choice/agent roundtrip → FR-01/02/03/04/05/06/07; Demo A S1/S2/S3.
- **UC-10** AI-free StatefulWidget → FR-01/02/04/05/07 plus NFR-04; Demo A S1.
- **UC-02** prefilled forms → future V1 FR-01/02/04/05/07, mass-assignment and duplicate-create acceptance.
- **UC-03 / UC-05** Admin and support → future V1 object auth, server resolver, action-source binding and role/tenant negative tests; Demo B.
- **UC-04** generation-review → future V1 FR-04/05/06/07, revision consistency and deterministic-vs-agent action split; Demo C.
- **UC-06 / UC-07 / UC-08 / UC-09** research, shopping, analytics and multi-step forms → V1+/V2 exploratory; require independent scope/evidence before new FR or commitments.

Canonical list and scenario-specific evidence: [supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md). **No UC other than 01/10 is required for S1–S3.**

Upstream regression probes SP-09..12 in [supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md](supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md) supplement but do not replace FR/NFR and SEC verification.

Do not treat defined acceptance as executed tests. After handoff the implementation repo acceptance matrix tracks results and commit evidence.