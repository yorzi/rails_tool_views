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