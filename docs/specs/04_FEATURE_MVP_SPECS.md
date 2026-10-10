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