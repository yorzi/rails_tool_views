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