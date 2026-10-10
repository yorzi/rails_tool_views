# Roadmap, verification and go/no-go gates

**Scenario scope:** Ten use cases and Demo A/B/C are documented in [supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md). UC-01+UC-10 and **Demo A only** belong to S1–S3. Demo B (support ticket, UC-03/05) and Demo C (review, UC-04) are post-V0 V1 validation candidates; UC-06..09 are exploratory and cannot change V0 acceptance implicitly.

## Phase 0 — discovery/spike (no product code commitment)
SP-01..08 in [supporting/03_ECOSYSTEM_SPIKE.md](supporting/03_ECOSYSTEM_SPIKE.md), extended by **SP-09..12** in [supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md](supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md). Compare bespoke Rails tool UI, GenerativeUI upstream contribution vs bridge vs minimal independent core, RubyLLM callbacks, and A2UI Rails patterns; verify pinned versions, require graph, actual gem package, licenses, authorization/stream regression probes and maintenance cost. Produce evidence bundles with commands, environment, fixtures, output and ADR decisions.

**Gate V:** PASS only with archived commands/test output for SP-01/03/04/05 **and SP-09..12**, plus a RubyLLM-free core that can register/render and a mocked optional adapter that presents tool-result/Surface reference without transcript corruption. SP-11 is a preventive two-actor/transport test: upstream failures are recorded as findings; ToolViews controls must actually PASS. Record ADR explicitly selecting upstream collaboration, safe bridge or minimal independent registry; otherwise PIVOT/STOP. Source inspection alone never passes Gate V.

## Phase 1 — S1 offline vertical slice
- Register existing Rails Partial and ViewComponent with explicit strict schema.
- Present one component from Rails Controller, create Surface in host app, render, reload.
- Add selected-option action with default deny policy, validated server handler, source-component/action authorization, revision + idempotency and durable transaction across restarts/workers.
- Ensure JSON/Turbo outputs (and optional ActionCable) read the same committed action result; reject UI targets outside the Surface and never accept browser-supplied business policy.
- Write unit, engine integration, browser and security tests tied to FR-01/02/04/05/07.

**Gate S1:** With ruby_llm absent and no network, same Surface renders/updates across reload and worker/restart boundaries; forgery/duplicate/conflict/target/format/state-scope cases SEC-01..18 covered by applicable tests.

## Phase 2 — S2 tool adapter
- RubyLLM adapter converts bounded Registry into present_ui Tool.
- Persist call correlation and return model acknowledgment separate from host inline rendering reference.
- Mock provider testing; real-provider smoke only when environment supports.
- Test tool duplicate, invalid props, tool result history and provider behavior.

**Gate S2:** FR-03 passes; one tool call creates exactly one displayed Surface, without monkeypatching chat internals.

## Phase 3 — S3 agent return
- Browser action can emit explicit structured AgentInteraction; adapter chooses new user turn vs continuing pending tool.
- Queue optional if host needs async; failures preserve Surface and show pending/retry safely.
- Test authorization, CSRF, idempotent forward and user-visible error paths.

**Gate S3:** FR-06/07 tests pass and agents do not confuse tool acknowledgment with user message.

## Phase 4 — OSS release candidate
- Installer, docs, sample Rails app, matrix CI, license/name clearance, security review, contributor policies.
- Conduct at least three external setup trials and a measured bespoke comparator per 08.
- Record independent repo baseline/adoption receipt; reviewers approve release, not just green CI.

**Gate R:** Continued standalone gem only if measurable advantage and maintainability are confirmed. Otherwise PIVOT to generative_ui contribution or focused adapter. Release is never automatic.

## Candidate V1 follow-up (separate approval)
- **Demo B Support Ticket Assistant (UC-03/05):** real host service, record resolver, role+tenant permissions and explicit human review; not autonomous sending or privileged mutations.
- **Demo C Generated Result Review (UC-04):** deterministic edit/accept/export vs explicit agent regeneration with artifact versioning.
- Prioritize based on developer setup trials and measured integration benefits; do not claim V1 delivery in PR #10.

## Stop list
No early tree composition, progressive streaming, A2UI/AG-UI/MCP Apps conformance, arbitrary generated code, multi-agent orchestration, paid SaaS or 20-component design kit.

## Task discipline
Each slice: verify existing API → failing spec/fixture → smallest code → unit + Rails/browser tests → security negative cases → docs/ADR → human review evidence. Do not auto-merge.