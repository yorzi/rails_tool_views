# Local/host operations

Owner: Andy Wang. This is a Rails gem; no hosted service, production deploy, worker or backup service has been configured by this task.

Run local demo with bin/demo; it binds 127.0.0.1:3100. Stop with Ctrl-C. PORT can change the port but not the loopback binding. Tests use storage/test.sqlite3; the demo uses storage/development.sqlite3. Both are ignored. Never use the dummy session identity in production.

| Symptom | Recovery |
|---|---|
| NOT_ALLOWED/NOT_FOUND | Verify host scope and policy, including tenant/domain record; do not relax to global access |
| CONFLICT | Reload snapshot; retry an uncertain request with the same key and original arguments |
| IDEMPOTENCY_CONFLICT | Investigate key reuse; do not replay a different action with the same key |
| INCOMPATIBLE_COMPONENT | Preserve snapshot; restore the old contract or perform explicit host migration/re-presentation |
| RENDER_FAILED | Check trusted partial/class and locals; saved state remains |
| AGENT_UNAVAILABLE | Selection is committed; authorized explicit retry uses the same delivery key |
| delivering lease after crash | Reconcile host remote receipt; after 5 minutes deliver can reclaim, with host durable deduplication |
| RATE_LIMITED | Wait for budget window; tune host configuration and public endpoint rate limiting |

Observe metadata-only `*.tool_views` ActiveSupport notifications. Host must review Rails SQL/SDK logs and data projections. Export authorized `Surface#snapshot` plus host-selected metadata; delete with a freshly loaded `surface.destroy!` to cascade namespaced links/receipts/interactions. Business records remain host-owned. Preserve idempotency records while a Surface can receive retries.

Before uninstall, back up/export using the host's approved procedure, remove mounts/helpers/jobs/adapter code, then remove the gem. Drop namespaced tables only after an explicit owner-approved retention decision. The gem does not silently delete data or manage credentials/backups.
