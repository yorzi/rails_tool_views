# Surface and interactive action protocol — V0

## Surface snapshot
~~~json
{"id":"opaque-server-id","component":"choice_card","component_digest":"sha256:...","props":{"title":"Choose","options":[{"key":"a","label":"A"}]},"state":{"selected":null},"revision":1}
~~~
The snapshot is returned through authorized server rendering; do not expose owner IDs/secrets in client JSON. Props are model-proposed and accepted only after validation; state is server-authoritative.

## Submit action
~~~http
POST /tool_views/surfaces/:id/actions
Content-Type: application/json
X-CSRF-Token: <server token>
~~~
~~~json
{"action":"select_option","arguments":{"key":"a"},"base_revision":1,"idempotency_key":"request-uuid"}
~~~
The server resolves actor from authenticated session; never trusts actor, tenant, handler names, `business_rules`/policy text or component source claims in request. Server verifies that the originating component on the authorized Surface declares this action; it resolves domain records against host policy before mutation. Validate body size, schema, surface ownership, component action allowlist and permission against real business records.

## Results and error semantics
- 200 accepted/synchronous: {status:"completed",surface_id,revision}; Turbo HTML replacement allowed via Accept negotiation.
- 202 accepted async agent step: {status:"pending",interaction_id,surface_id,revision} with UI pending state.
- 400 invalid input; 403 forbidden; 404 not found or inaccessible if policy requires non-disclosure; 409 stale revision; 422 known domain rule violation; 429 budget/rate limit; 503 agent unavailable.
- Idempotent repeats return canonical prior result/status, not rerun side effect.
- Send CSRF and SameSite protection for browser-originating mutation; external API mode requires its own auth contract.

## State and side effects
Only server-owned UI state mutates. Host ActiveRecord/business state and Agent transcript have separate authorities; model/tool/browser props cannot impersonate either. Use a **single** server-side transition service for HTML/Turbo/JSON/ActionCable, with transaction plus optimistic locking for revision update; action record and state commit share transaction. Response negotiation takes place *after* the canonical state transition. Non-transactional external side effect needs application idempotency or an outbox/job protocol. No silent last-write-wins. Publish Turbo update after commit; clients disregard stale revision, reload snapshot on gaps. Restrict Turbo target IDs and ActionCable subscription/broadcast to the authorized Surface and actor/tenant; do not derive authorization from an arbitrary client-selected scope.

## Agent continuation
Action handler can produce:
~~~json
{"type":"agent_interaction","surface_id":"id","action":"select_option","values":{"key":"a"},"context_ref":"opaque-app-context"}
~~~
Host adapter decides whether to append a new **user** turn or resume a pending provider tool call. Tool result and user interaction must not be conflated. Preserve original conversation identity, pending tool state and idempotent delivery. The core can succeed even if adapter later fails; show retryable agent status.

## Recovery
Reload renders accepted state without network LLM. Missing component version renders explicit incompatible schema state; never delete the underlying snapshot. Agent error preserves prior usable Surface.