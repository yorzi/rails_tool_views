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