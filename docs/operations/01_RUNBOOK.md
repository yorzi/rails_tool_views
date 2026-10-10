# Local/host operations

Owner: Andy Wang. This is a Rails gem; no hosted service, production deploy, worker or backup service has been configured by this task.

Run local demo with bin/demo; it binds 127.0.0.1:3100. Stop with Ctrl-C. PORT can change the port but not the loopback binding. Tests use storage/test.sqlite3; the demo uses storage/development.sqlite3. Both are ignored. Never use the dummy session identity in production.

V1 entry points: `/v1/customer`, `/v1/support`, `/v1/review`. Select a fixed fixture identity to inspect role/tenant boundaries. Existing fixture records are preserved by seeds; inactive staff are not reactivated. Use the new-draft buttons to start again after a completed customer or accepted artifact. Reply queueing writes only a local outbox, with no delivery worker. Tests exercise domain services; this is not a configured support system.

Failure exercise: stop normal Puma, run `TOOLVIEWS_DEMO_AGENT_FAILURE=1 bin/demo`, explicitly request drafting/regeneration, then stop/restart normal `bin/demo` and retry the visible failed follow-up. The flag is a non-secret local fixture setting. Do not run two servers on the same database/port. Never leave either process running after the task. V1 continuation writes output and its host receipt together; do not delete receipts while retries can still occur.

| Symptom | Recovery |
|---|---|
| NOT_ALLOWED/NOT_FOUND | Verify host scope and policy, including tenant/domain record; do not relax to global access |
| CONFLICT | Reload snapshot; retry an uncertain request with the same key and original arguments |
| IDEMPOTENCY_CONFLICT | Investigate key reuse; do not replay a different action with the same key |
| INCOMPATIBLE_COMPONENT | Preserve snapshot; restore the old contract or perform explicit host migration/re-presentation |
| RENDER_FAILED | Check trusted partial/class and locals; saved state remains |
| VALIDATION_FAILED | Correct returned approved fields; no domain/Surface mutation committed; retain native field labels/error association |
| REVIEW_REQUIRED | Review current reply/version first; privileged actions still need current role and explicit confirmation |
| ALREADY_SUBMITTED/ALREADY_ACCEPTED | Use a new draft; completed records/accepted versions are preserved |
| AGENT_UNAVAILABLE | Action is committed; authorized explicit retry uses the same delivery key and rechecks domain version |
| delivering lease after crash | Reconcile host remote receipt; after 5 minutes deliver can reclaim, with host durable deduplication |
| RATE_LIMITED | Wait for budget window; tune host configuration and public endpoint rate limiting |

Observe metadata-only `*.tool_views` ActiveSupport notifications. Host must review Rails SQL/SDK logs and data projections. Export authorized `Surface#snapshot` plus host-selected metadata; delete with a freshly loaded `surface.destroy!` to cascade namespaced links/receipts/interactions. Business records remain host-owned. Preserve idempotency records while a Surface can receive retries.

V1's accepted text download checks role/tenant again and uses the exact persisted accepted version. Failed export generation rolls back its record and Surface action; retry the original key/arguments. Surface revision conflict and business version conflict both require reloading current data; do not silently substitute a newer approved version. `bin/check` runs suites sequentially because they share the dummy test DB.

Before uninstall, back up/export using the host's approved procedure, remove mounts/helpers/jobs/adapter code, then remove the gem. Drop namespaced tables only after an explicit owner-approved retention decision. The gem does not silently delete data or manage credentials/backups.
