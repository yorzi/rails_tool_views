# Security

This local v0 is unpublished and has not received independent security review. Do not post secrets, customer data, raw payloads or exploit instructions in a public issue. A verified private maintainer disclosure channel must be configured before public release; none is claimed to exist yet.

The host must resolve actor and tenant from authenticated server state, provide deny-by-default component/action policies, authorize domain records independently of props, keep CSRF enabled and project data before persistence. ToolViews rejects unregistered renderers/actions, extra parameters, client policy text, forged sources/targets, stale revisions and mismatched replays. Native escaping depends on trusted host templates. Parameter filters and metadata-only notifications reduce logging exposure; host SQL/SDK logging and retention still need review.

The gem stores approved display props/state and structured interaction values. It does not store transcripts, API credentials or raw business-record dumps by itself. Hosts control export/deletion and must not place sensitive data into these fields. Database handlers share Surface's transaction; external calls require host idempotency/outbox. Agent deliveries use a lease and stable delivery key, with explicit retry; a host must deduplicate across uncertain remote outcomes.

Supported transports are JSON and Turbo. ActionCable is absent. No executable model-generated HTML, JS, Ruby, arbitrary remote schema resolution or URL fetch is supported. Security coverage maps SEC-01..18 in the acceptance matrix; channel-specific checks remain N/A while broadcasting is disabled.
