# ToolViews / Rails Components as Interactive AI Tools

> **Type:** Open-source Rails gem / library (not a SaaS). **Lifecycle:** REVIEW (not approved for implementation handoff). **Draft baseline:** 0.1.0-draft, 2026-10-10.
>
> **Promise:** Turn trusted Rails components into discoverable, callable and interactive presentation capabilities for Rails applications and AI agents—without requiring an AI framework.

## Read first
- Human review: [human/README.md](human/README.md) → [human/06_FINAL_HUMAN_APPROVAL.md](human/06_FINAL_HUMAN_APPROVAL.md).
- AI handoff: [ai/00_ENTRYPOINT.md](ai/00_ENTRYPOINT.md) → [ai/05_BUILD_SEQUENCE_AND_ACCEPTANCE.md](ai/05_BUILD_SEQUENCE_AND_ACCEPTANCE.md).
- Canonical contracts: [02_PRODUCT_VISION_PRD.md](02_PRODUCT_VISION_PRD.md), [03_CORE_MECHANIC_OR_METHODOLOGY_SPEC.md](03_CORE_MECHANIC_OR_METHODOLOGY_SPEC.md), [04_FEATURE_MVP_SPECS.md](04_FEATURE_MVP_SPECS.md), [05_TECHNICAL_ARCHITECTURE.md](05_TECHNICAL_ARCHITECTURE.md), [09_DEPLOYMENT_SECURITY_OPERATIONS.md](09_DEPLOYMENT_SECURITY_OPERATIONS.md), [REQUIREMENTS_TRACEABILITY.md](REQUIREMENTS_TRACEABILITY.md).
- Detailed technical hypotheses: [supporting/01_COMPONENT_TOOL_CONTRACT.md](supporting/01_COMPONENT_TOOL_CONTRACT.md), [supporting/02_SURFACE_ACTION_PROTOCOL.md](supporting/02_SURFACE_ACTION_PROTOCOL.md), [supporting/03_ECOSYSTEM_SPIKE.md](supporting/03_ECOSYSTEM_SPIKE.md), [supporting/04_SECURITY_VERIFICATION.md](supporting/04_SECURITY_VERIFICATION.md), [supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md](supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md), [supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md).

## Selected name and practical use cases
**ToolViews** is the selected project name (previous draft: ViewTools). Ruby module `ToolViews`, candidate gem `toolviews`, and `toolviews/` Specs directory; gem namespace, public repository availability, trademark and license clearance remain **release checks**, not verified ownership.

The ten reference use cases and three staged demos are defined in [supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md). **Only ChoiceCard plus AI-free direct Rails use are V0 proofs**; support-ticket and generated-result review are V1 examples, not an implementation commitment.

## Product thesis
A Rails developer registers an existing Partial or ViewComponent under a validated metadata contract. The same component can be presented from ordinary Rails code or through an opt-in tool adapter. A model request may create a durable Surface reference; Rails renders the approved component inside chat or a normal page. A user action is validated and authorized, then handled by a Rails service or sent through an explicit agent adapter. The model never supplies executable code or business authorization.

## Authority and gates
This folder owns **intended behavior**, not production reality. The independent open-source implementation repo will own code, tests, current architecture, ADRs, CI, release and day-to-day progress after a separately approved Gate H and Gate I. Current status REVIEW means the architecture is promising but runnable ecosystem spike (pinned source review completed, tests pending), license/name review, visual evidence and human Gate H2 are still open. No independent project repo or published Gem has been created by these Specs.

## V0 demonstration
One interactive selection form: existing Rails component → registry → AI-optional present_ui tool → persisted inline Surface → user selects option → authorized Rails action → structured agent continuation or deterministic UI refresh → reload restores state. No LLM required for local operation.

## Non-goals
No model orchestration framework; no generated HTML/JS/Ruby; no protocol-standard invention; no mandatory RubyLLM; no arbitrary component introspection; no multi-agent workflow DSL; no SaaS billing; no official OpenAI Intelligent UI clone.

## Sources and quality gates
Read [14_RESEARCH_SOURCES.md](14_RESEARCH_SOURCES.md), [SPEC_COVERAGE.md](SPEC_COVERAGE.md), [SPEC_REVIEW.md](SPEC_REVIEW.md) and [SPEC_READINESS_CHECKLIST.md](SPEC_READINESS_CHECKLIST.md). These are research-backed design hypotheses, not a proven market or shipped feature.