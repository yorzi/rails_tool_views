# Upstream source-level gap analysis — GenerativeUI vs A2UI Rails

**Evidence captured:** 2026-10-10. **Method:** GitHub source and selected test files inspected at pinned commits, **not** a runnable audit. This document is evidence for ToolViews Phase 0, not a claim that either upstream project is insecure in every host configuration.

| Upstream | Inspected commit | Role in ToolViews decision |
|---|---|---|
| [GenerativeUI](https://github.com/kryzhovnik/generative_ui/tree/994410c95042b9c8da660fbf425cee99fb3e2066) | `994410c95042b9c8da660fbf425cee99fb3e2066` | Reuse candidate: trusted Catalog, Schematist/JSON Schema, tree validation, Partial/ViewComponent renderers |
| [A2UI Rails](https://github.com/vicentereig/a2ui-rails/tree/d409b71670febabc46d64694461ec1adddd5996f) | `d409b71670febabc46d64694461ec1adddd5996f` | Interaction reference: Surface, Stimulus binding/action, Turbo updates; **not** a production runtime dependency |

## Evidence classification

- **SOURCE_CONFIRMED:** Behavior is visible in the cited source at the pinned commit. The absence of a general-purpose facility means only that it was not found in inspected core paths; it does not prove that host apps cannot implement it.
- **DESIGN_INFERENCE:** Architectural consequence or risk inferred from source, to reproduce in Phase 0.
- **NOT_RUN:** Unit/integration tests, `gem build`, concurrency and cross-session security probes have **not** been executed. Do not mark an SP or security gate PASS on this evidence alone.

## Capability matrix

| Dimension | GenerativeUI — source evidence | A2UI Rails — source evidence | ToolViews V0 action |
|---|---|---|---|
| Component registry | `lib/generative_ui/catalog.rb` + `component_definition.rb`: register, prompt/schema export, explicit render targets; no universal discovery of all host components | `lib/a2ui/types.rb`: static `T.any` component Union; `app/components/a2ui/components/renderer.rb` `case` dispatch, not open registration DSL | Trusted explicit registry; reusable Parts only, no reflection of arbitrary constructors |
| Rendering / validation | `component_validator.rb` JSONSchemer; `component_tree_validator.rb` references, cycles, limits (500 components/64 depth/2000 refs); `renderers/{partial,view_component}.rb` | Fixed ViewComponents, typed DSPy result; `Renderer.for` has no Tabs/Modal dispatch although `types.rb` declares them | Single existing Partial and ViewComponent in V0; do not duplicate tree compiler |
| State | `component_set.rb` represents one tree; no authoritative persisted Surface in inspected core | `surface.rb` stores components/data/action schemas; `surface_manager.rb` uses class-instance in-process Hash `@stores`, despite configuration `cache_store` | ActiveRecord-backed actor-scoped Surface; state revision, recovery and lock |
| Action | `tool.rb` executes *validation*, returns status; no registered Rails domain handler | `action_handler.rb` is `DSPy::ChainOfThought(HandleAction)`; client POST + Turbo integration exists, but not trusted Rails business executor | Deterministic allowlisted ActionDispatcher first, optional agent-return separate |
| Security | Catalog allowlist + JSON/tree checks, not object-level business authorization | `actions_controller.rb` accepts client `business_rules`; `surface_channel.rb` subscribes/broadcasts on `a2ui:${surface_id}` without visible ownership check; stream target passed through; review host controls before calling this exploitable | Default-deny actor/tenant/resource authorization; server-owned rules; scoped targets and channels |
| Framework coupling | GemSpec requires `ruby_llm ~>2.0`; `lib/generative_ui/tool.rb` subclasses `RubyLLM::Tool` and main loader eagerly requires it | GemSpec requires DSPy; generators/handlers inherit `DSPy::Module`, signatures `DSPy::Signature`, type coercion imports DSPy | Core package loads with neither LLM library; adapter owns framework-specific class and transcript |
| Packaging/test evidence | `test/generative_ui/{tool_test,catalog_test}.rb` covers catalog/schema/tool assertions | `spec/a2ui/{types_spec,surface_manager_spec}.rb` covers model and happy path; GemSpec `spec.files` only includes `lib/**/*`, LICENSE, README despite runtime `app/...` | Isolated fresh Rails install and `gem build` before adoption or release |

## Key code findings with direct pointers

### GenerativeUI

1. [Catalog](https://github.com/kryzhovnik/generative_ui/blob/994410c95042b9c8da660fbf425cee99fb3e2066/lib/generative_ui/catalog.rb) compiles `tool_arguments_schema` and an explicit registry. Components do **not** automatically become application actions.
2. [Tool](https://github.com/kryzhovnik/generative_ui/blob/994410c95042b9c8da660fbf425cee99fb3e2066/lib/generative_ui/tool.rb) calls `ComponentTreeValidator` and returns `status: ok/invalid`, not a mounted browser UI nor a Rails business mutation. The actual rendering happens in view/helper paths.
3. [Main require graph](https://github.com/kryzhovnik/generative_ui/blob/994410c95042b9c8da660fbf425cee99fb3e2066/lib/generative_ui.rb) eagerly loads `tool`; removing only GemSpec dependency is insufficient. Extract a framework-neutral loader and test without installing `ruby_llm`.
4. [Renderer](https://github.com/kryzhovnik/generative_ui/blob/994410c95042b9c8da660fbf425cee99fb3e2066/lib/generative_ui/renderers/view_component.rb) instantiates an application-chosen component with validated props; the host still must resolve resource IDs through authorization. Valid props do not imply an authorized record.
5. A persisted tool-call's Catalog identity is not captured in its arguments; README requires consistent Catalog routing. Any reuse adapter must persist catalog identity/version or a stable component contract fingerprint.

### A2UI Rails

1. [SurfaceManager](https://github.com/vicentereig/a2ui-rails/blob/d409b71670febabc46d64694461ec1adddd5996f/lib/a2ui/modules/surface_manager.rb) stores Surface objects in a per-process Hash; unavailable across workers/restarts. `update` and `handle_action` return LLM decisions while controllers apply mutations, so state submission is split between layers.
2. [ActionsController](https://github.com/vicentereig/a2ui-rails/blob/d409b71670febabc46d64694461ec1adddd5996f/app/controllers/a2ui/actions_controller.rb) forwards request `business_rules` into LLM handling. The Turbo format path applies `data_updates`; the JSON branch only renders the result (response-format-dependent mutation). Neither is an application-owned authorization policy.
3. [SurfaceChannel](https://github.com/vicentereig/a2ui-rails/blob/d409b71670febabc46d64694461ec1adddd5996f/app/channels/a2ui/surface_channel.rb) subscribes to `a2ui:${surface_id}` without a visible ownership check and can fall back to client `params[:scope]`. Reproduce with two authenticated identities and overlapping IDs before assessing exploitability.
4. [StreamOp](https://github.com/vicentereig/a2ui-rails/blob/d409b71670febabc46d64694461ec1adddd5996f/lib/a2ui/types/stream_op.rb) permits arbitrary `target` strings; server must constrain Turbo target IDs to current authorized Surface, including websocket updates.
5. [TypeCoercion](https://github.com/vicentereig/a2ui-rails/blob/d409b71670febabc46d64694461ec1adddd5996f/lib/a2ui/type_coercion.rb) delegates to DSPy; a strict `T::Struct` is input-shape validation, not proof that source component/action/resource is authorized.
6. [GemSpec](https://github.com/vicentereig/a2ui-rails/blob/d409b71670febabc46d64694461ec1adddd5996f/a2ui-rails.gemspec) excludes `app/` from `spec.files` and does not declare all Rails/ViewComponent runtime libraries from Gemfile. Confirm with `gem build` and a clean dummy Rails app; don't treat README's Rails Engine claims as packaging proof.

## Reuse decision — do not precommit to a fork

**Candidate A — upstream collaboration:** Ask whether GenerativeUI's author accepts a neutral Catalog/Renderer core and optional RubyLLM adapter. Prefer minimal upstream change if API stability, licensing and maintenance are workable.

**Candidate B — adapter against an upstream API:** Keep ToolViews State/Actions/Hotwire independent; bridge existing GenerativeUI catalogs **only if** they can load without mandatory framework deps and remain versioned/stable. No vendor copy solely to avoid a small adapter.

**Candidate C — narrow independent registry:** If upstream extraction is incompatible with the intended API or maintainer direction, build only a *single-component* schema/renderer registry with existing JSON Schema libraries; postpone tree composition and cross-protocol bridges. Write a decision ADR with observed tests and maintenance tradeoffs.

**Estimation (planning-only, not measured):** GenerativeUI core/Tool separation could be a small multi-day code change; A2UI Rails DSPy removal affects signatures, generators, action handling and coercion and is considerably broader. No time estimate is an evidence-based promise; log actual spike effort.

## Mandatory runnable spike checks before Gate V

| Spike | Reproduce, measure, archive | PASS condition |
|---|---|---|
| SP-09 | Pin both upstream SHAs; exercise catalog/schema/renderer and confirm require graph with `ruby_llm` absent, keep upstream original passing as control | Pure core boots without loading RubyLLM; upstream behavior unchanged under original env |
| SP-10 | Build each gem and install in empty Rails app; inspect actual package file list, ViewComponent + Partial behavior, possible A2UI Tabs/Modal fallback | Claims match installed files and rendered behavior, or mismatches explicitly recorded |
| SP-11 | Two-user same Surface ID; wrong-tenant action; client `business_rules`; forged component source; JSON vs Turbo mutation; ActionCable subscription; arbitrary stream target | Failing reference probes captured; ToolViews design must explicitly prevent each failure, rather than claiming upstream exploit |
| SP-12 | Compare (a) upstream extension, (b) upstream adapter, (c) smallest independent registry with same one-component scenario, stable input/output and actual glue-code cost | Choose path via executable evidence, API surface, legal/license review, and maintenance cost; record PIVOT if no material standalone value |

All SP-09..12 start **NOT_TESTED**. Keep SP-01..08 from the existing spike plan. Attach commands, exact Git SHAs, fixtures, output, sample Rails versions and a decision record to Phase 0 evidence. Tests must run from the actual implementation repo after human approval; these Specs cannot certify them.

## Consequences for ToolViews contract

- Default to **single-component, Rails-owned presentation and deterministic action**. Agent may select a trusted component; only authorized Rails handlers mutate business records.
- Separate three authorities: UI Surface state, host ActiveRecord/domain state, and Agent transcript. Never persist raw business records as UI props/state or treat model-returned state as truth.
- Persist `component_key + schema_digest + catalog/contract_version + adapter/call correlation` so replay cannot silently reinterpret an old component under a new catalog.
- One server-side commit path for state transitions; JSON, Turbo and WebSocket only select output formats **after** the same transaction.
- Require actor/tenant authorization at both Surface read and each mutation, approved action-source matching, deny-by-default, idempotency and revision checks, scoped DOM/ActionCable targets, and no client-controlled policy text.
- A2UI, AG-UI and MCP Apps are **future interoperability adapters**, not implied V0 standards compliance.

## Gate status

**SOURCE_REVIEWED / RUNNABLE_EVIDENCE_PENDING; REVIEW / CHANGES_REQUIRED.** This audit narrows uncertainty, but does not pass Gate V, H1, H2, Q, C, R or I.