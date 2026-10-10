# ToolViews — MASTER PRODUCT / TECHNICAL SPEC

> **本文件由脚本生成，请勿手工编辑。**
> 源文件是 `project-manifest.json` 中 `documents` 列出的各分册。
> 重新生成：`node scripts/build-master-spec.mjs`
>
> 版本 0.1.0-draft — 2026-10-10
> 主体：Independent OSS initiative (ownership pending)（Not selected）

---

## 目录

1. 00_README.md
2. 01_BRAND_DOMAIN_POSITIONING.md
3. 02_PRODUCT_VISION_PRD.md
4. 03_CORE_MECHANIC_OR_METHODOLOGY_SPEC.md
5. 04_FEATURE_MVP_SPECS.md
6. 05_TECHNICAL_ARCHITECTURE.md
7. 06_DESIGN_SYSTEM_AND_COPY.md
8. 06A_VISUAL_SPEC_AND_PROTOTYPES.md
9. 07_SEO_CONTENT_ARCHITECTURE.md
10. 08_ANALYTICS_AND_EXPERIMENTATION.md
11. 09_DEPLOYMENT_SECURITY_OPERATIONS.md
12. 10_GROWTH_DISTRIBUTION_MONETIZATION.md
13. 11_ROADMAP_EXECUTION_PLAN.md
14. 12_AI_DEVELOPMENT_WORKFLOW.md
15. 13_PRIVACY_ACCESSIBILITY_LEGAL.md
16. 14_RESEARCH_SOURCES.md
17. 15_BUSINESS_MODEL_AND_OPERATIONS.md
18. 16_COLD_START_LAUNCH_PLAN.md
19. 17_RISK_REGISTER.md
20. 18_LONGEVITY_AND_CONTINUITY.md
21. 19_PROJECT_HANDOFF_AND_IMPLEMENTATION_GOVERNANCE.md

---


<!-- ==== SOURCE: 00_README.md ==== -->

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

---


<!-- ==== SOURCE: 01_BRAND_DOMAIN_POSITIONING.md ==== -->

# Identity and positioning — selected project name

- **Selected name (owner decision):** **ToolViews**. Prior Specs codename: `ViewTools`. Preferred Ruby module: `ToolViews`; candidate gem/repo slug: `toolviews` (unverified availability; naming/clearance gate still open).
- **Name rationale:** Rails View + agent-callable Tool. External tagline must also explain authorized Actions, persisted Surface and optional AI, so `ToolViews` is not mistaken for a collection of view helpers.
- **Category:** Rails-native open-source developer infrastructure; AI-framework-agnostic.
- **Tagline:** Existing Rails views, available as interactive tools.
- **Primary user:** Rails developers embedding AI-backed or deterministic workflows into existing applications.
- **Not:** a React generative UI platform, a hosted AI SDK, a universal design system, or a RubyLLM-owned submodule.
- **Voice:** precise Ruby/Rails terminology; README in English, compact Chinese human approval in OddlyNiche.
- **Public repository:** separate future OSS repo; chosen naming intent is `ToolViews` / `toolviews`, exact package/repository namespace conditional on RubyGems/GitHub/trademark checks. Do not claim registration.
- **License direction:** MIT candidate, pending dependency/license and contributor-policy checks before public release; not a claim that approval already happened.
- **Domain and trademark:** No domain purchase required for V0. Recheck name availability at RELEASE gate.
- **Success signal:** Rails maintainers can reuse existing Partial/ViewComponent and implement a real agent→UI→user→action roundtrip without a parallel frontend stack.

---


<!-- ==== SOURCE: 02_PRODUCT_VISION_PRD.md ==== -->

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

---


<!-- ==== SOURCE: 03_CORE_MECHANIC_OR_METHODOLOGY_SPEC.md ==== -->

# Domain / methodology contract

## Core distinctions
- **ComponentDefinition:** trusted application-owned registry item with ID, description, property JSON Schema, renderer reference, allowed action names, explicit exposure policy. Does not contain user data or model instructions from untrusted input.
- **ToolDescriptor:** adapter-generated function schema describing a capability. It is *not* HTML, a renderer, or authorization. Default candidate: bounded catalog exposed as one present_ui tool.
- **PresentationRequest:** untrusted proposal from Rails code or AI tool-call arguments. Must be validated before it becomes a Surface.
- **Surface:** durable, app-owned presentation instance (one registered component in V0) with props, state, revision, actor scope and optional context reference. Not a Chat or agent transcript.
- **Action:** a named, allowlisted browser intent. Server validates arguments and permission before execution.
- **AgentContinuation:** explicit structured handoff to host app/adapter. Not a synthetic provider tool-result unless the provider's lifecycle calls for one.

## Invariants
INV-01: Registry and component implementation exist before tool discovery; model output never registers new component code.
INV-02: Core boots, presents, actions and restores with RubyLLM absent.
INV-03: Every external presentation is schema-validated and passes component policy; unknown keys/components/actions reject.
INV-04: Tool execution has **two** outputs: structured model acknowledgment and browser-targeted Surface reference. The application explicitly mounts the UI; neither a tool call nor tool result automatically renders in chat.
INV-05: Surface state is server-authoritative and tenant/actor scoped. Context association is not equivalent to permission.
INV-06: All stateful server actions require explicit app authorization. Default deny. No class constantization/eval from model-controlled strings.
INV-07: Duplicate tool-calls/action submissions do not duplicate side effects; revision conflicts cannot silently overwrite.
INV-08: Adapter owns provider-specific transcript/resume rules. Core never constructs provider wire messages directly.
INV-09: Stored presentation can be rendered offline after reload, independent of LLM.
INV-10: Never serialize secrets, raw private objects, internal auth tokens, or arbitrary ActiveRecord attributes into browser state.
INV-11: UI Surface state, host business records and agent transcript are distinct authorities. Model-returned UI data cannot assert completed business operations.
INV-12: JSON, Turbo and ActionCable responses observe the same authorized, persisted Action transition; response format cannot change side effects or revision.
INV-13: Browser/agent-provided source IDs, policy text, tenant scope, event targets and channel names do not grant permissions; verify registered component/action/source and Surface ownership server-side.

## Trust boundaries
AI-generated parameters and browser inputs are untrusted; registry metadata, renderers and service handlers are trusted code but still scoped to actor/tenant. A tool request may be valid JSON and still be forbidden. Persist accepted metadata and canonical props only; raw prompts/tool payloads follow host application's retention policy.

## Concrete example vector
Registered select_card component properties: title:string; options: array<{key:string,label:string}>; selected:string|null. Allowed action select_option(params: {key:string}). Input keys are compared against trusted options server-side. One call present_ui({component:"select_card",props:{title:"Choose", options:[...]}}) yields surface ID + revision=1. User selects B -> authorized action -> revision=2, state.selected="B"; optional app callback forwards {surface_id,action:"select_option",selection:"B"} to an agent. Bad key, forged action or wrong account is rejected before mutation.

## Scope consequence from upstream source audit
GenerativeUI already supplies Catalog/schema/tree validation/Partial+ViewComponent rendering; A2UI Rails supplies sample Surface/Stimulus/Turbo event mechanics, not a safe general business Action executor. ToolViews differentiates on the **authorized action + durable state + framework-neutral handoff**; no reimplementation of tree composition is justified without Phase 0 proof. Source evidence and untested probes: [supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md](supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md).

## Conflict policy
Component identity stable across page refresh. Schema/version fingerprint stored to detect incompatible renderer upgrades; migrations deferred but behavior must fail explicitly. Version mismatch yields recoverable state, not untrusted fallback HTML.

---


<!-- ==== SOURCE: 04_FEATURE_MVP_SPECS.md ==== -->

# V0 feature contract — canonical FR/AC definitions

**Status:** Product-intent contract; implementation NOT_STARTED. AC IDs are unique and stable.

## FR-01 Registry and explicit schema
Register trusted Rails Partial / ViewComponent with immutable key, description, strict props schema, renderer binding and exposure policy.
- FR-01-AC-01: valid registration discovers the same key/schema independently of LLM.
- FR-01-AC-02: duplicate key, unknown field and schema mismatch are rejected; no runtime eval of model-supplied constants.
- FR-01-AC-03: registry can be scoped so a caller sees only an explicitly permitted component subset.

## FR-02 Deterministic present and render
Application code can present one registered component and render as server HTML.
- FR-02-AC-01: with RubyLLM uninstalled, a Partial and a ViewComponent render from validated props.
- FR-02-AC-02: unknown component or invalid props yields structured error and no Surface write.

## FR-03 Optional RubyLLM Tool export
Adapter compiles bounded catalog into present_ui-compatible schema and executes a presentation request.
- FR-03-AC-01: tool-call arguments create exactly one authorized Surface and return {status,surface_id,revision} to model.
- FR-03-AC-02: chat-side UI is linked through an explicit presentation reference independent of model text.
- FR-03-AC-03: core gem load and tests pass without ruby_llm installed; provider-specific classes isolated in adapter.
- FR-03-AC-04: repeated upstream call ID returns same Surface/result; provider continuation remains valid.

## FR-04 Persistent Surface
A Surface stores component ID, version fingerprint, props, presentation state, owner scope, optional context link, revision.
- FR-04-AC-01: reload produces the same UI/state without any AI/network call.
- FR-04-AC-02: missing/incompatible component renderer fails visibly and safely rather than rendering arbitrary fallback.
- FR-04-AC-03: surface cannot be accessed via another tenant's identifier.

## FR-05 Authorized server actions
A component declares an allowlist of named actions; host app supplies handler, parameter schema and policy.
- FR-05-AC-01: valid option selection executes one registered handler, changes state and returns a new revision.
- FR-05-AC-02: unknown action, invalid params, unauthorized actor/tenant and stale revision reject without mutation.
- FR-05-AC-03: repeated action idempotency_key cannot repeat side effects.
- FR-05-AC-04: forged source component/action combination, client-supplied rules and unauthorized domain-resource IDs are rejected; trusted policy is recomputed server-side.

## FR-06 Agent continuation
An action may emit a structured, app-owned agent interaction through an optional adapter.
- FR-06-AC-01: interaction contains authorized action name, validated values, surface/context references and no raw HTML.
- FR-06-AC-02: host adapter re-enters its agent using a supported history/continuation method; core does not fabricate tool responses.
- FR-06-AC-03: no agent installed → deterministic action still succeeds.

## FR-07 Rails-native updates and UX
Turbo and Stimulus integrate within chat or an ordinary Rails page; no required React/node service.
- FR-07-AC-01: browser action produces updated HTML with matching current revision and preserves usable focus/state.
- FR-07-AC-02: loading, empty, invalid, denied, conflict, agent-pending and completed states are visibly distinct.
- FR-07-AC-03: keyboard and assistive tech can operate the first selection form.
- FR-07-AC-04: JSON and Turbo (and ActionCable when enabled) report the same committed revision/side effect; no update may address a DOM target outside the authorized Surface.

## FR-08 Installation and reference example
Document install, registry, rendering, tool integration, actions, auth and failure handling.
- FR-08-AC-01: fresh Rails test/dummy app exercises present→render→act→restore without external API keys.
- FR-08-AC-02: optional adapter scenario with mocked LLM tool-call; one configured real-provider smoke test documented separately.
- FR-08-AC-03: OSS contribution, security disclosure, license choice and release readiness documented before public release.

## Nonfunctional contract
- NFR-01-AC-01: no untrusted executable HTML/JS/Ruby path; XSS and unknown-component security tests pass.
- NFR-02-AC-01: server-authoritative revision, idempotency and cross-tenant denial proven by integration tests.
- NFR-02-AC-02: state survives restart/worker boundaries; channel subscriptions and broadcast IDs are tenant/actor scoped, with unauthorized access denied.
- NFR-03-AC-01: Ruby/Rails version matrix explicitly supported and CI-tested; unsupported combinations documented.
- NFR-04-AC-01: no RubyLLM/provider/network required for core tests, install and deterministic roundtrip.
- NFR-05-AC-01: no stored sensitive prompts, secrets or customer raw data by default; host controls retention/export/deletion.
- NFR-06-AC-01: clean Rails demo on mobile and desktop for keyboard, labels, errors and focus; accessible names validated.

All new FR-05/07 and NFR-02 criteria map to SEC-13..18 in [supporting/04_SECURITY_VERIFICATION.md](supporting/04_SECURITY_VERIFICATION.md). Upstream examples are threat inspiration, not a substitute for executable tests.

## Scenario boundary
[UC-01 and UC-10](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md) exercise the existing V0 contract. UC-02..09 are **not** added to FR-01..08, do not imply new core adapters or a general-purpose wizard, and require separate future approvals/acceptance if promoted to V1.

## First vertical slice (S1)
Register a single pre-existing SelectCard partial, present in ordinary Rails, persist, submit select_option, update revision and restore after refresh—all offline. S2 adds RubyLLM tool export and chat embedding; S3 agent continuation; S4 hardens publication and OSS docs.

---


<!-- ==== SOURCE: 05_TECHNICAL_ARCHITECTURE.md ==== -->

# Technical architecture & reversibility

## Dependency direction
~~~text
Host Rails app: Partials / ViewComponent / policies / services
   ├─ ToolViews Core: Registry, schemas, PresentationRequest, Surface/State/Actions
   ├─ Rails Runtime: Engine, ActiveRecord, Controller, Turbo/Stimulus
   └─ Optional adapters
        ├─ RubyLLM adapter (depends on RubyLLM, core never loads it)
        ├─ generative_ui bridge (investigate existing catalog reuse)
        ├─ Phlex renderer (later)
        └─ A2UI / MCP Apps / other LLMs (future)
~~~

## Code boundaries
**Registry (Ruby-only abstractions within a Rails-oriented gem):** explicit component descriptions, property schema, trusted render targets, allowed actions, exposure policy. No database, no adapter imports, no instance state.

**Presentation Service:** validates key/props/caller policy, resolves app-scope owner, writes Surface atomically, returns typed reference. It does not render provider-specific payloads.

**Rendering:** adapters for Partial (V0) and ViewComponent (V0), using view_context and Rails autoescaping. Renderer never constantizes model-controlled class names.

**Runtime:** ActiveRecord Surface with ownership context, component_key, component/schema digest, catalog/contract version, props, state, revision, lock_version and timestamps. Optional context association to message/project/report; owner/tenant independent. Route and controller can be mounted/configured by host. Only UI presentation state belongs in Surface; host business records and agent transcript remain separate authorities. Do **not** copy A2UI Rails' in-process Hash store.

**Action Dispatcher:** trusted registry-based **deterministic** host handlers, parameter validation, actor+tenant+resource+source-component/action authorization, transaction/update with optimistic locking, idempotency key uniqueness and consistent commit-before-broadcast. Never treat LLM-provided business rules as executable authorization; TypeCoercion/schema checks are not authorization. Side effects must support retry-safety; outbox may be added later for cross-system effects. Agent continuation is a separate *post-action* option.

**Adapter:** converts registry subset into tool schema, maps tool call to PresentationRequest, stores tool-call correlation key, produces minimal model acknowledgment and chat UI reference, exposes optional structured agent callback. Adapter owns the agent transcript: never append arbitrary tool-result messages to a pending call.

## Data contract (proposed; verify in S1)
~~~text
surfaces: id, owner_type/id, tenant_key or application policy scope,
  context_type/id (nullable), component_key, component_digest,
  props_json, state_json, revision, lock_version, timestamps

presentations/tool_call_links: surface_id, adapter_key, external_call_id,
  context_ref, unique(adapter_key, external_call_id, context_ref)

action_executions: id, surface_id, action_key, arguments_json, actor_ref,
  base_revision, idempotency_key, status, timestamps,
  unique(surface_id, idempotency_key)
~~~
Do not persist rich transcript inside core; do not assume all apps have User/Account models. Provide actor and authorization hooks; decide whether explicit tenant ID is an adapter-supplied scope. SQLite test baseline; PostgreSQL matrix before release.

## Single transition and transport boundary
A shared host-side TransitionService validates, authorizes, runs the handler, commits Surface state + action idempotency record and returns a canonical result. Controller response negotiation (Turbo vs JSON) and optional ActionCable broadcasts occur **after** the same commit. This prevents the response-format-specific Surface mutation observed in A2UI Rails. Broadcast subscriptions must confirm authorized actor/tenant ownership and use non-colliding scoped stream identifiers. Agent- or client-provided Turbo targets must be validated against the currently authorized Surface; never pass arbitrary target strings to Turbo operations.

The Rails component registry is explicitly authored and bounded. Upstream options are conditional: (A) contribute neutral Catalog/Renderer extraction to GenerativeUI, (B) bridge a stable upstream core, or (C) implement a minimal single-component registry if reuse proves costly. **No default fork, no copied tree compiler, and no unverified A2UI Rails runtime dependency.** Pinned sources and acceptance probes: [supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md](supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md).

## Flow contracts
1. Ordinary Rails: register → present → validation → Surface → render in view.
2. AI: agent receives bounded schema → present_ui tool call → validate/authorize → create once → model result {status,id,revision} + app presentation reference → host displays Surface within chat.
3. Browser: Stimulus POST action with CSRF, revision, idempotency → authorize actor/object → validate action → transactional state update → Turbo response/broadcast.
4. Agent return: registered action explicitly emits structured interaction; optional adapter uses provider's supported conversation continuation; errors do not corrupt Surface.
5. Refresh: authorization → load stored component key/props/state → schema compatibility check → trusted server renderer. No model call.

## Decisions with reversal strategy
- **Core mandatory RubyLLM?** NO: optional adapter; tested with gem omitted.
- **Component definition:** prefer existing Rails view code, not generated templates.
- **One tool vs many:** bounded present_ui default; individual per-component export optional later.
- **One component or tree:** single component S1/V0; composition only after real need. Existing generative_ui tree support via bridge is a hypothesis, not a duplicated compiler.
- **UI update:** full trusted Partial/ViewComponent rerender + Turbo replace/morph V0; component diff/progressive output postponed.
- **Persistence:** ActiveRecord/transactions; no event sourcing/CRDT/Redis requirement.
- **Schema:** explicit JSON Schema-compatible contract, no reflection of arbitrary initializer methods; selection of Schematist vs another validator is Phase 0 ADR. GenerativeUI's Schematist/JSONSchemer compiler is an upstream reuse candidate, not permission to copy its implementation.
- **Ruby/Rails version support:** verify supported matrix in actual dependencies; do not promise a version without CI.
- **Name:** ToolViews is working name pending legal/name search; package API can be renamed before first published tag.

## Compatibility and lifecycle
Persist component key, registry/schema fingerprint and schema format version. On changed render contract fail with explicit upgrade/migration guidance; never silently interpret old props as new permission. Rendering failures are recoverable, not destructive.

## Observability
Instrument presentation.accepted/rejected, surface.rendered, action.executed/rejected/conflict, adapter.tool_called and agent_returned through ActiveSupport::Notifications. Never log raw secrets or large untrusted payloads.

## Scenario-driven architecture test
The same independent Registry + Surface + authorized ActionDispatcher + optional Adapter must handle UC-01 (choice with agent return) and UC-10 (no AI) in S1–S3. Future UC-02/03/04/05 demonstrate **existing Rails business service reuse**—they must not require a new AI-specific domain model, generated executable UI, or weakening authorization. See [use-case contracts](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md).

## Anti-scope creep
No built-in LLM choice, prompts, RAG, speech/video, orchestration, arbitrary HTML generation, authorization engine or business CRUD DSL. Use host services.

---


<!-- ==== SOURCE: 06_DESIGN_SYSTEM_AND_COPY.md ==== -->

# UX / design contract for an OSS Rails component runtime

This is a developer SDK, not a consumer UI brand. Do not impose a default product aesthetic on host Rails apps. Components inherit host styling; optional example CSS must be namespaced and removable.

## Surfaces
- SCR-01: Developer demo page (registered component, props, preview, present action, action log).
- SCR-02: Inline chat bubble containing one interactive component; host renders Surface, never tool JSON.
- SCR-03: Surface recovery/error state for denied access, stale revision, malformed component, missing renderer and agent unavailable.

## Interaction principles
- One visible choice with explicit label/legend; Submit/Continue button clarifies whether it updates locally, saves to server or requests AI follow-up.
- Accessible HTML form control before custom widget. Keyboard tab order natural. Visible focus, disabled and pending indicators; errors connected to fields using aria-describedby and announced via role=status/alert appropriately.
- States: initial, loading, empty options, ready, submitted, agent_pending, validation_error, forbidden, conflict/reload, provider_failure, incompatible_schema. No blank error swallowing.
- Narrow viewports: inline Surface width 100%, no mandatory horizontally scrolling cards, touch targets sized for common mobile devices.
- Developer-facing copy: precise, no anthropomorphism. Example: "Selection saved"; "This view changed. Refresh to continue"; "Your choice was saved, but the AI follow-up could not complete."

## Demo visual specification
Wireflow is maintained in 06A and assets/design; a low-fidelity ASCII/Mermaid flow is authoritative for sequence only. No canonical colors, logo or marketing screenshots; this is intentional because the host owns design. A functional narrow-width browser prototype is required before Gate H1, and system tests before release.

## No unsafe "magic"
UI output must only include registered components; no invisible controls or auto-submitted destructive user choices. Avoid assuming every component is safe to expose as agent-callable.

---


<!-- ==== SOURCE: 06A_VISUAL_SPEC_AND_PROTOTYPES.md ==== -->

# Visual and prototype applicability

**Classification:** Open-source developer integration with one end-user demo. Product visual identity is NOT_APPLICABLE for V0 because the gem reuses host components; functional interaction visuals are INCLUDED.

## Required design evidence
- VIS-01: [data/control flow](assets/design/flow.mmd) — reference-only architecture, not exact UI geometry.
- SCR-01: inline chat select-card and selection submission; low-fidelity concept below, no high-fidelity concept required before this code-first feasibility spike.
- SCR-02: same component in ordinary Rails page; same props/action behavior.
- SCR-03: visible invalid/stale/denied/agent unavailable fallbacks.

~~~text
┌ Chat message ─────────────────────────────┐
│ AI: Please select an option.             │
│ ┌── trusted Rails SelectCard ──────────┐ │
│ │ Choose a workflow                   │ │
│ │ ( ) Compare options                 │ │
│ │ ( ) Continue analysis               │ │
│ │ [Continue]                           │ │
│ └──────────────────────────────────────┘ │
│ Submitted ✓ / AI follow-up pending…      │
└───────────────────────────────────────────┘
~~~

## Visual authority
Flow diagram and ASCII wireframe are EXPLORATION/REFERENCE; neither overrides feature/security contracts. Before Gate H1 capture human-reviewed lightweight UI state board for mobile/desktop and a working interactive prototype or document a signed rationale for its absence. No actual visual prototype exists in this Specs-stage commit.

## Verification
Tab/Enter/Space keyboard operation, error focus/announcements, 360px width, reload restored values, no model call on deterministic interaction. The app repo maintains screenshots and browser test reality after Gate I.

---


<!-- ==== SOURCE: 07_SEO_CONTENT_ARCHITECTURE.md ==== -->

# SEO / content applicability

**N/A for traffic-site SEO:** This is an open-source gem, not a public consumer content site or keyword-driven SaaS. SEO route hierarchy, multilingual landing pages and programmatic SEO are outside V0. Reassess at RELEASE if an independent documentation website is established.

Documentation discoverability still matters: installation, 5-minute first example, component registry, tool presentation, action handling, security, compatibility, migration and troubleshooting are required in the implementation repository. Preserve accurate metadata for GitHub/RubyGems, no speculative benchmark or provider-compatibility claims.

---


<!-- ==== SOURCE: 08_ANALYTICS_AND_EXPERIMENTATION.md ==== -->

# Adoption metrics, evidence and experiments

## Hypothesis measurement
- EV-01 (developer completion): >=3 independent Rails developers attempt the setup; >=2 complete register→present→interact→restore in <=60 min from clean app without guidance beyond docs. Record versions, elapsed time, blockers.
- EV-02 (glue-code reduction): compare a documented bespoke Rails implementation with gem demo, same features and auth requirements; target >=30% fewer custom integration statements/steps without extra runtime dependencies. Note that LOC alone can be gamed.
- EV-03 (tech independence): CI Gemfile matrix excludes RubyLLM yet core demo and tests pass.
- EV-04 (model loop): one supported RubyLLM model tool call yields validated Surface and later action uses correct chat continuation; fixture tests plus opted-in live smoke.
- EV-05 (safety): all SEC-01..18 applicable tests pass; no forbidden action/tenant write.
- EV-06 (latency): measure Rails present/action/render timings under fixture workloads, record machine and P50/P95, avoid invented performance guarantees.

## Scenario adoption evidence
For every study, record `UC-ID` from [the ten use-case contracts](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md), Rails app baseline, existing component/action reused, independent developer, authorization expectations, equivalent bespoke alternative, time and maintenance burden. UC-01/10 must establish **technical feasibility**; UC-05/04 (V1) should establish **business workflow differentiation** only after prior gates. A useful demo does not by itself confirm adoption or product-market fit.

## Instrumentation
Events: registry.registered; presentation.accepted/rejected; surface.rendered; action.accepted/rejected/conflict; adapter.tool_called; interaction.dispatched. Use ActiveSupport::Notifications with safe IDs, duration, component key, revision; never include private props/secrets by default.

## Experiment log
Create an evidence row per test: ID, date, revision, participant (anonymized), environment, steps, pass/fail, artifacts, interpretation, next decision. Evidence that simply shows local implementation is not evidence of external demand.

## Gate decision
If technical loop works but independent developers do not save meaningful integration effort, upstream a narrower contribution instead of promoting a new Gem. No fabricated adoption metrics or score-only GO.

---


<!-- ==== SOURCE: 09_DEPLOYMENT_SECURITY_OPERATIONS.md ==== -->

# Deployment, security and operations boundary

## Packaging
Open-source Rails gem; core engine works in a host application. No hosted backend, queue server, database service, AI key or public account required. Migration installed into host app by generator; uninstall/export strategy must be documented. Adapter depends on the host's chosen RubyLLM gem version, not the core gem.

## Security
Core permission model default deny for Surface access and actions; host supplies actor/tenant/resource policy. Server verifies component-action-source linkage and ignores untrusted client/agent `business_rules` or scope claims. CSRF and authenticated POST for browser; strict JSON schema for tool props/actions; Rails escaping; allowlisted renderer/handler; refuse arbitrary HTML, code, class names and remote URL fetch. Details and negative cases in [supporting/04_SECURITY_VERIFICATION.md](supporting/04_SECURITY_VERIFICATION.md).

## Reliability
Persist accepted props/state/revision. Keep valid Surface when agent/API fails. Duplicate tool callbacks and browser requests deduplicated; stale versions rejected (409) and reloaded. JSON/Turbo/ActionCable must all observe the same committed transition; no format-specific mutations. Authenticated subscription plus actor/tenant-scoped ActionCable streams and Surface-bounded Turbo targets are mandatory if broadcasting is enabled. Transaction commits before Turbo broadcast. For external side effects host implements durable idempotency or outbox—Gem must never promise exactly-once without such guarantees.

## Compatibility
Phase 0 records supported Rails/Ruby, turbo-rails/stimulus, RubyLLM optional adapter versions, Partial/ViewComponent/Phlex renderer matrix. SQLite in CI for minimal demo; PostgreSQL optional matrix for concurrency semantics before release. Do not preclaim untested Rails compatibility.

## Runtime observability
ActiveSupport::Notifications event IDs and status; logs redact raw prompts, props, secrets. Document size/component count/action rate caps configurable. Provide error codes and admin recovery instructions without revealing sensitive payloads.

## Upstream reuse caveat
GenerativeUI source already offers Catalog, JSON/tree validation and ViewComponent/Partial rendering; isolate RubyLLM Tool eager loading before claiming independent Core. A2UI Rails is an interaction reference, not a production dependency: pinned source currently shows per-process Hash state, client-controlled rules, unscoped channel names, fixed component union and a gem packaging question. Verify these via the executable SP-09..12 matrix before dependency decisions; see [supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md](supporting/05_UPSTREAM_SOURCE_GAP_ANALYSIS.md).

## Release gate
CI green, dependency licenses reviewed, reproducible gem build, test dummy app, SECURITY.md / CONTRIBUTING.md / CHANGELOG and human-reviewed release notes. Sensitive issue disclosure path configured; no publication until naming/namespace and OSS license cleared.

---


<!-- ==== SOURCE: 10_GROWTH_DISTRIBUTION_MONETIZATION.md ==== -->

# OSS distribution and monetization

Primary distribution: RubyGems, GitHub, documentation and a runnable Rails demo. Target discovery: Rails/Hotwire developers, RubyLLM maintainers and OSS contributors; participate via useful upstream issues/PRs and technically accurate articles. No spam or affiliate-growth assumptions.

No paywall, hosted subscription or revenue target for V0. Indirect returns may include open-source reputation, consulting and subsequent product integration, but are not proof of market demand. Success is maintainer adoption, working examples, issue quality, compatibility, test reliability and reduced glue code.

First public release requires README quick start, 5-minute demo, licenses, changelog, known limitations, contributor guidelines and a small support/security policy. Review supply-chain permissions before automated release.

---


<!-- ==== SOURCE: 11_ROADMAP_EXECUTION_PLAN.md ==== -->

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

---


<!-- ==== SOURCE: 12_AI_DEVELOPMENT_WORKFLOW.md ==== -->

# AI-assisted development governance

Before coding, agent must read the [ten reference scenarios](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md) for scope/adoption evidence and ai/00_ENTRYPOINT.md through ai/08_AGENT_PRE_FLIGHT_CHECKLIST.md, canonical product Specs, SEC cases and Phase 0 spike. Never claim tools, providers, APIs, models or Rails versions are supported without tagged-source reproduction.

Implementation starts only after OddlyNiche Gate H2 and Gate I, in its own OSS repository bootstrapped from templates/implementation-repo-docs-template. OddlyNiche is a frozen intent baseline; code/tests/ADR and current status live in implementation repo. AI must never auto-approve human gates, release gems, publish credentials or merge significant code without the specified owner review.

**First slice:** offline register → present → render → select → persist → reload; do not start with AI-driven composition. Use real runnable failing tests and minimize glue. Evaluate reusing generative_ui rather than copying its schema compiler. Every AI output, including proposed code and security rules, is untrusted until verified.

Every authored implementation commit needs progress-ledger WORK and Work-ID trailer; maintain Acceptance Matrix mapped to FR/AC, and explicit discrepancy labels IMPLEMENTATION_BUG / INTENTIONAL_DELTA / PRODUCT_INTENT_CHANGE. Use current Rails initialization skill for framework defaults, but product intent overrides generic skill advice.

---


<!-- ==== SOURCE: 13_PRIVACY_ACCESSIBILITY_LEGAL.md ==== -->

# Privacy, accessibility, open-source legal

**Privacy:** Library is embedded in host application; by default store only validated props, minimal state, revision and scoped correlation references. No secret/API token/raw prompt storage, provider calls or telemetry network upload by core. Host must document retention/export/deletion, object-level tenant access and whether selected presentation fields are sent to LLM through optional adapter.

**Accessibility:** V0 selection form usable keyboard-only, with labels, error association, visible focus, appropriate aria-live notices and mobile 360px layout. Aim WCAG 2.2 AA for shipped example, with manual assistive-tech review before release; automated tests alone insufficient.

**Licensing:** Proposed MIT but not approved; inspect third-party components, copied assets, schemas and dependency licenses. Avoid copying OpenAI/Gemini UI or proprietary ChatGPT widgets. Do not imply endorsement/affiliation by RubyLLM, Google or OpenAI.

**Risk:** Agent-supplied choices/content can contain prompt injection or phishing text. Render through trusted Rails view with escaping and no model-defined active links/JS. External data may be sensitive; app governs data minimization and user consent. SECURITY.md and contributor CLA/DCO decision required at public release.

**Applicability:** This generic developer gem is not directly handling regulated data; host-specific legal/medical/child use requires its own independent assessment.

---


<!-- ==== SOURCE: 14_RESEARCH_SOURCES.md ==== -->

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

---


<!-- ==== SOURCE: 15_BUSINESS_MODEL_AND_OPERATIONS.md ==== -->

# Open-source business/operating model

Project is developer infrastructure, not a SaaS business. V0 value exchange: free permissive gem, documentation and reference application; maintenance time and compatibility reviews are costs. No pricing model, billing system, claims of monthly recurring revenue or fabricated TAM.

One primary maintainer initially. Budget a small compatibility matrix and predictable issue triage. Every major dependency bump requires release test evidence. Evaluate GitHub Sponsors/consulting only after adoption; no monetization pressure in initial product scope.

Operational metrics: new integrator completion, number of external reproductions, release regressions, test pass rate, security incident response, stale issues and dependency freshness. Stop independent project if upkeep consistently exceeds utility or upstream integration clearly dominates.

---


<!-- ==== SOURCE: 16_COLD_START_LAUNCH_PLAN.md ==== -->

# Cold start and OSS launch

**Reference-demo order:** Demo A ChoiceCard (UC-01/10) is V0 proof; Demo B Support Ticket Assistant (UC-03/05) and Demo C Generated Result Review (UC-04) are V1 candidate adoption proofs, not release blockers for initial Core. See [supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md).

Pre-public: private proof with two existing Rails applications or a dummy + one separate Rails project, plus three external developer setup trials. Publish a minimal README, install generator, API cookbook, tiny interactive demo, compatibility table and threat model. Verify name/namespace, MIT license and dependency notices before RubyGems publication.

Distribution: technical demo to Rails community and RubyLLM maintainers, invite feedback on use cases, report actionable upstream findings, avoid branding confusion. No growth campaign needed. Public launch gates require passing S1–S3 and security/CI review; release notes must list V0 limitations and deferred A2UI/MCP Apps/composition.

Feedback intake: issue templates distinguish bug, adapter compatibility, feature request and security report. Collect concrete reproduction plus Rails/Ruby/adapter version and anonymized fixture; never ask reporters to post API keys.

---


<!-- ==== SOURCE: 17_RISK_REGISTER.md ==== -->

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

---


<!-- ==== SOURCE: 18_LONGEVITY_AND_CONTINUITY.md ==== -->

# Long-term maintainability and continuity

Intent remains in OddlyNiche until formally revised. Separate OSS repository owns versioned code, migrations, changelog, current behavior docs, CI, release and security advisories after approved handoff.

Use semantic versioning; keep registry key and schema fingerprints stable, define documented deprecation for renamed props/actions, and provide explicit upgrade path for persisted Surfaces. No silent schema coercion or implicit backward-compatible rendering. Support rollback of gem code only when persisted format compatibility permits it; otherwise provide safe read-only fallback.

Maintain reproducible offline fixture tests independent of API keys and real-provider smoke jobs separate from baseline CI. Tests should survive provider discontinuation; adapter can be removed without corrupting saved Surfaces.

If abandoned or archived: publish final compatibility constraints, export/migration instructions, security limitations and recommended upstream alternatives. No telemetry/user-data service to shut down by default.

---


<!-- ==== SOURCE: 19_PROJECT_HANDOFF_AND_IMPLEMENTATION_GOVERNANCE.md ==== -->

# OddlyNiche → independent open-source implementation handoff

## Authority
OddlyNiche captures approved product intent and acceptance; implementation repository captures real code/schema/tests/ADR, current status, actual operations and per-commit progress. Do not mutate this baseline for routine refactors.

## H1 → H2 → C/R → I
1. REVIEW: execute missing ecosystem Spike, visual/UX review, release/legal naming and formal Spec review; resolve blockers.
2. Gate H1: pass SPEC_READINESS_CHECKLIST.md, source map and traceability, formal SPEC_REVIEW says READY_FOR_HUMAN_REVIEW; freeze human review candidate Q.
3. Gate H2: human signs human/06_FINAL_HUMAN_APPROVAL.md with exact Q SHA and date; AI cannot self-approve.
4. Content commit C freezes approved Specs; registration commit R records C separately in project-manifest.json and baseline changelog. Never write a commit's own SHA into it.
5. Gate I: create independent public project repository only after authorization; copy templates/implementation-repo-docs-template; record R/C in SPEC_BASELINE.md, bootstrap current-docs/agent/runbook, link first FR-AC slice and create adoption receipt.

## First implementation slice
S1: no model dependency; register select-card via explicit props/action schema; present in ordinary Rails; persist Surface; authorized select_option; revision/idempotency; Turbo rerender; refresh restores. Then S2: RubyLLM optional adapter tool call + chat reference. S3: host-owned structured agent return.

## Required implementation records
Independent repo must have AGENTS.md, docs/agent entry + pre/post flight, current implementation plan, Acceptance Matrix linked to FR/AC, per-commit Progress Ledger + Work-ID trailer, human System At A Glance/Status/Feature Map/Architecture/Flows/Changelog/Glossary, ADR, tests and operations/release checklists. Product intent deviations classified IMPLEMENTATION_BUG / INTENTIONAL_DELTA / PRODUCT_INTENT_CHANGE.

## Human escalation
Pause before: changing AI dependency from optional to required; adopting generated code; bypassing authorization; redefining tool/agent transcript semantics; introducing tree/protocol support into V0; changing license/public name; merging major PR or publishing gem. Phase 0 discoveries may propose ADRs, not silently change intent.

## Independent repo
Destination repository and license/public namespace are NOT YET CHOSEN. No implementation handoff, Gem or production system is claimed by these Specs.

---
