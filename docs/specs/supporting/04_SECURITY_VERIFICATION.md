# Security verification — V0 threat and negative-test contract

Untrusted model arguments and browser requests may describe component/props/actions; only application-registered component and handler code is trusted. Scope every Surface read/write to host actor and tenant. Authentication alone is not object authorization. JSON schema validity does not imply permission.

| ID | Attack/failure | Required result |
|---|---|---|
| SEC-01 | Unknown component or model-provided renderer name | reject, no unsafe constantize/eval |
| SEC-02 | Script markup injected into title/props | HTML escaped, no active script |
| SEC-03 | Forged arbitrary handler/action | reject with zero side effects |
| SEC-04 | User A accesses User B tenant Surface | 403/404, no props leak |
| SEC-05 | Option value not authorized by server | reject despite JSON type validity |
| SEC-06 | Stale base revision after concurrent action | 409, no silent overwrite |
| SEC-07 | Replayed model tool call or action idempotency | one Surface/side effect |
| SEC-08 | Model call ID reused across chat/adapter scopes | no cross-context mutation |
| SEC-09 | Component contract changed at reload | explicit recoverable incompatibility |
| SEC-10 | Oversized/deep/unknown JSON fields | reject before rendering/persisting |
| SEC-11 | Provider unavailable after valid user action | state remains, continuation retryable |
| SEC-12 | Leaked private model/properties | project data projection/privacy audit |
| SEC-13 | Client supplies `business_rules` or equivalent authorization policy text | ignore/reject policy input; use server-owned rules and deterministic checks |
| SEC-14 | Forged source component invokes action declared only on another component | reject before handler/agent invocation, zero side effects |
| SEC-15 | Two actors subscribe/use same public Surface ID; untrusted channel `scope` | no cross-actor read, mutation, Turbo broadcast or data leak |
| SEC-16 | Agent/client sets Turbo target outside authorized Surface | reject target; no DOM mutation outside current Surface |
| SEC-17 | Same accepted action via JSON versus Turbo/WebSocket | identical persisted state/revision and idempotency; response format only changes transport |
| SEC-18 | State update across restart, workers and concurrent submissions | persisted coherent revision, no in-process Hash as authoritative store |

Default deny component exposure, Surface access and mutating actions; CSRF+SameSite for browser POST, strict parameter schema, actor policies, revision/idempotency, post-commit UI publication. Authorization is checked independently of typed coercion, including actor+tenant+resource+source-component+allowed-action. All transports perform the same durable state transition before response/broadcast; channel names and DOM targets are Surface/actor-scoped. Never accept security/business rules from client or model as authoritative. Host owns external service idempotency. No arbitrary remote fetch, JS/Ruby/ERB generation or uncontrolled agent loop.

Risk motivation and pinned code pointers: [05_UPSTREAM_SOURCE_GAP_ANALYSIS.md](05_UPSTREAM_SOURCE_GAP_ANALYSIS.md). These are preventive ToolViews requirements, not proof of an upstream exploit.

Security release requirements: tests for all SEC cases, source and license audit, accessibility keyboard checks, Security Disclosure path and maintenance/support policy. None have been executed in this Specs-only phase.