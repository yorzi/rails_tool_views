# Build sequence & acceptance
Contract source: [04 FR/AC](../04_FEATURE_MVP_SPECS.md), [traceability](../REQUIREMENTS_TRACEABILITY.md), [11 gates](../11_ROADMAP_EXECUTION_PLAN.md).
1. Phase 0 SP-01..12 environment/source verification + decision ADR (source audit: [05](../supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md)). STOP/PIVOT if missing differentiation.
2. S1 FR-01-AC-01..03, FR-02-AC-01..02, FR-04-AC-01..03, FR-05-AC-01..04, FR-07-AC-01..04, NFR-02-AC-01/02 and SEC-01..18 applicable offline negative cases first.
3. S2 FR-03-AC-01..04 Tool schema, correlation and inline Surface reference; RubyLLM optional.
4. S3 FR-06-AC-01..03 agent continuation; pending/failure UX.
5. Release hardening FR-08-AC-01..03 + NFR-01..06, external setup trials, legal and security gates.
For each behavior write failure fixture before implementation, test unauthorized/duplicate/replay/stale and compare against spec. No fake provider responses treated as real compatibility proof. Do not create public repo until Gate H2 authorization.
**Reference demo track:** A=ChoiceCard offline + optional agent (V0, UC-01/10), B=Support Ticket Assistant (V1, UC-03/05), C=Generated Result Review (V1, UC-04); the other UC-IDs are exploratory. See [06](../supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md). Never implement ten UC features inside S1–S3.
