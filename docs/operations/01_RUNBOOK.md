# Local/host operations

Owner: Andy Wang. This is a Rails gem; no hosted service, production deploy, worker or backup service has been configured by this task.

Run local demo with bin/demo; it binds 127.0.0.1:3100. Stop with Ctrl-C. PORT can change the port but not the loopback binding. Tests use storage/test.sqlite3; the demo uses storage/development.sqlite3. Both are ignored. To run either on PostgreSQL, set `BUNDLE_GEMFILE=gemfiles/postgres.gemfile` and a `DATABASE_URL` for an existing database. Never use the dummy session identity in production.

V1 entry points: `/v1/customer`, `/v1/support`, `/v1/review`. Select a fixed fixture identity to inspect role/tenant boundaries. Existing fixture records are preserved by seeds; inactive staff are not reactivated. Use the new-draft buttons to start again after a completed customer or accepted artifact. Reply queueing writes only a local outbox, with no delivery worker. Tests exercise domain services; this is not a configured support system.

Failure exercise: stop normal Puma, run `TOOLVIEWS_DEMO_AGENT_FAILURE=1 bin/demo`, explicitly request drafting/regeneration, then stop/restart normal `bin/demo` and retry the visible failed follow-up. The flag is a non-secret local fixture setting. Do not run two servers on the same database/port. Never leave either process running after the task. V1 continuation writes output and its host receipt together; do not delete receipts while retries can still occur.

| Symptom | Recovery |
|---|---|
| NOT_ALLOWED/NOT_FOUND | Verify host scope and policy, including tenant/domain record; do not relax to global access. If identity is missing only on the mounted routes, authentication may live on a subclass: set `config.parent_controller` |
| UNKNOWN_FIELD | The form posts a field the Engine does not define; build it with `rails_tool_views_action_form` so inputs are named `arguments[...]` |
| CONFLICT | Reload snapshot; retry an uncertain request with the same key and original arguments. Also returned when the database rolls the action back (deadlock, serialization failure, lock timeout) |
| IDEMPOTENCY_CONFLICT | Investigate key reuse; do not replay a different action with the same key |
| INCOMPATIBLE_COMPONENT | Preserve snapshot; restore the old contract or perform explicit host migration/re-presentation |
| RENDER_FAILED | Read the `RailsToolViews surface.render_failed handled …` log line or the `Rails.error` report for the exception and template line; saved state remains |
| VALIDATION_FAILED | Correct returned approved fields; no domain/Surface mutation committed; retain native field labels/error association |
| REVIEW_REQUIRED | Review current reply/version first; privileged actions still need current role and explicit confirmation |
| ALREADY_SUBMITTED/ALREADY_ACCEPTED | Use a new draft; completed records/accepted versions are preserved |
| AGENT_UNAVAILABLE | Action is committed; the adapter exception is in the `agent_failed` log line and `Rails.error`; authorized explicit retry uses the same delivery key and rechecks domain version |
| delivering lease after crash | Reconcile host remote receipt; after `config.delivery_lease` seconds (default 300) deliver can reclaim, with host durable deduplication |
| RATE_LIMITED | Wait for budget window; tune host configuration and public endpoint rate limiting |
| INVALID_SCOPE / INVALID_CONTEXT / INVALID_CORRELATION / INVALID_IDEMPOTENCY_KEY | An actor, tenant, context, adapter, call or idempotency identifier is empty or longer than 150 bytes; shorten the value. INVALID_SCOPE is also raised for a malformed scope object |

Observe metadata-only `*.rails_tool_views` ActiveSupport notifications, including `surface.render_failed` and `agent_failed`. `INVALID_SCHEMA` at boot means a nested schema is untyped, open or an array without `items`. The Engine redacts only its own request parameters and JSON columns; host must review Rails SQL/SDK logs and data projections. Export authorized `Surface#snapshot` plus host-selected metadata; delete with a freshly loaded `surface.destroy!` to cascade namespaced links/receipts/interactions. Business records remain host-owned. Preserve idempotency records while a Surface can receive retries.

V1's accepted text download checks role/tenant again and uses the exact persisted accepted version. Failed export generation rolls back its record and Surface action; retry the original key/arguments. Surface revision conflict and business version conflict both require reloading current data; do not silently substitute a newer approved version. `bin/check` runs suites sequentially because they share the dummy test DB.

Before uninstall, back up/export using the host's approved procedure, remove mounts/helpers/jobs/adapter code, then remove the gem. Drop namespaced tables only after an explicit owner-approved retention decision. The gem does not silently delete data or manage credentials/backups.

## Single identity upgrade (0.3.0.pre.v3)

0.3 removes the `ToolViews` aliases that 0.1/0.2 carried before any release (ADR 006). A 0.2 host: drain pending/failed agent continuations (delivery keys change to `rails_tool_views:interaction:<id>`), back up, then run one host migration that renames the custom indexes and the four tables from `tool_views_*` to `rails_tool_views_*` (snippet in the Upgrading guide). Rename helpers, I18n keys, notification subscribers, the Stimulus registration/asset and CSS selectors; mount as `:rails_tool_views`. Do not rerun the installer. Reload pages rendered before the deploy, because Surface DOM ids change. Rollback: restore the 0.2 gem and reverse the migration (`rename_table`/`rename_index` are reversible) before any 0.3-only writes depend on new names.

## Bounded identifiers (audit hardening, 2026-10-17)

The runtime caps actor, tenant, context, adapter, call and idempotency identifiers at 150 bytes and rejects a longer value instead of storing it. The bundled migration now limits those columns to 150 bytes so every index key fits utf8mb4's 3072-byte limit on MySQL; the previous unbounded presentation index needed 5100 bytes and would not create on MySQL. An existing host needs no migration: the old columns remain and the bound is enforced in code.

A database created by the earlier unbounded migration keeps its unbounded columns. This only affects this repository's own schema-width test: recreate the schema (`DROP SCHEMA public CASCADE; CREATE SCHEMA public;` on PostgreSQL, or delete `test/dummy/storage/test.sqlite3`) and re-run `rake test:prepare`. Hosts on SQLite or PostgreSQL are unaffected because the runtime bound, not the column limit, enforces the value.
