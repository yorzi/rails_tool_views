# Product vision & PRD

## Problem and observed context
Rails applications already own view components, business services, auth and persisted data. An LLM can call tools but a tool result does not inherently become a persistent, authorized, user-interactive Rails view. Developers currently hand-code presentation routing, state lifetime, tool-result references and return trips to the agent. Existing generative_ui handles catalogs and tree rendering; it does not eliminate the need for an application-owned interaction runtime. These are technical observations/hypotheses; no end-user interviews or independently measured demand have been performed.

## JTBD
When adding an agent-assisted workflow to an existing Rails app, I want to expose selected existing view components as safe presentation capabilities, display the output in a chat or ordinary page, capture user decisions and continue the workflow, **without** making RubyLLM mandatory or introducing React.

## Personas and current alternatives
1. Rails full-stack maintainer with Hotwire and server-rendered components; alternative: bespoke Turbo partials and tool handlers.
2. RubyLLM integrator; alternative: own RubyLLM::Tool + generated partial and state handling.
3. Rails engine/gem author seeking shared interoperability; alternative: generative_ui, A2UI implementation, MCP Apps UI resources.
Early adopters are **hypothesized**; recruit maintainers before release.

## Falsifiable bets
- HYP-01: Three independent Rails developers can embed a registered component in <60 minutes using docs and no framework-specific frontend build.
- HYP-02: The framework removes at least 30% of glue-code steps versus a documented bespoke Rails baseline; measured on an equivalent task.
- HYP-03: Existing Rails code can present and update a Surface with **no RubyLLM gem loaded**.
- HYP-04: At least one agent adapter can roundtrip an AI-generated view and a user action while preserving correct transcript/tool state.

## Validated use-case hypotheses (not delivered features)
See [ten scenario contracts and demos](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md). Priorities: **P0:** UC-01 human-in-the-loop ChoiceCard and UC-10 AI-free Rails widget; **P1/V1:** UC-02 assisted data entry, UC-03 Admin Copilot, UC-04 generated-result review, UC-05 customer support; **P2/V1+/V2:** UC-06 interactive research, UC-07 shopping, UC-08 analytics, UC-09 multi-step forms. These are ranked engineering/adoption hypotheses, not measured market demand. Do not interpret ten use cases as a ten-feature MVP.

Reference demos: **A ChoiceCard** in S1–S3; **B Support Ticket Assistant** and **C Result Review Workflow** are candidate V1 application proofs after the core gates. These establish reusable runtime capability, not a built-in ticketing/creative-commerce framework.

## Must (V0)
Registry with explicit properties/action metadata; existing Rails Partial + ViewComponent rendering; single-component presentation; optional RubyLLM tool adapter; presentation/tool-result dual channel; persisted Surface and replay; validated and authorized server Action; explicit agent-return bridge; Turbo/Stimulus browser interaction; idempotency and revision conflict handling; open-source install/demo/test/documentation.

## Should (after V0)
Multiple components/composition; partial state bindings; Phlex adapter (after API compatibility spike); progressive rendering; package extraction of RubyLLM adapter; A2UI/MCP Apps import/export.

## Won't (V0)
Execute model HTML/Ruby/JS; automatically infer tool schemas from arbitrary view constructors; complex layout generator; arbitrary remote tools; protocol compliance claims; complex CRDT/event sourcing; agents modifying unrelated business models without developer-provided handler; automatic billing/monetization.

## Primary journey
Maintainer registers an existing component and permitted interaction. App or optional agent calls present_ui with validated props. Runtime returns durable Surface ID, renders server-side UI in chat or page and sends a structured tool acknowledgment. User chooses an option; Rails validates actor/surface/action/params, updates state or dispatches explicit agent-continuation event. Refresh restores the exact current revision.

## Exit criteria
Complete FR-01..FR-08 and NFR acceptance map; validate first slice without network provider; adapter integration demo with fixture tests and one real provider check; negative test suite for unauthorized/duplicate/invalid/stale calls; independent developer reproduction and maintainer/OSS feedback. If novelty vs existing generative_ui is not material, prefer an upstream contribution or refocus; see roadmap gates.