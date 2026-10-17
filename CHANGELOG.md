# Changelog

## Unreleased — audit hardening, 2026-10-17

Fixed: the bundled migration created the five-column presentation unique index with unbounded `varchar` columns, so `CREATE TABLE` failed on MySQL/InnoDB under utf8mb4 (5 x 255 x 4 = 5100 bytes against a 3072-byte limit). Identifiers are now bounded to 150 bytes, so the widest index needs 3000 bytes. Changed: stored actor, tenant, context, adapter, call and idempotency references are byte-capped in `RailsToolViews::Data.identifier`; a longer value is rejected (`INVALID_SCOPE`, `INVALID_CONTEXT`, `INVALID_CORRELATION`, `INVALID_IDEMPOTENCY_KEY`) instead of overflowing a column. Descriptions and versions keep the wider 255-byte cap. Fixed: a non-binary database collation could resolve another actor's or tenant's Surface, another correlation's presentation, or another idempotency key's action receipt; every lookup now confirms a byte-exact match before it stands in for the request. Added regression tests for index-key width, the identifier cap, and collation-safe identity matching. No data migration: existing rows are unchanged and the runtime bound is enforced in code.

## Unreleased — audit hardening and component authoring, 2026-10-13

Fixed: nested schemas that were untyped, empty or arrays without `items` registered successfully and accepted arbitrary JSON inside a closed object; they are now rejected with `INVALID_SCHEMA`. Fixed: a native form for an action without arguments was rejected with `INVALID_ARGUMENTS` because it posts no `arguments` field. Changed: log redaction is scoped to the Engine's controller and models; installing the gem no longer adds `props`, `state`, `payload`, `result`, `arguments` and `values` to the host's `filter_parameters`, which had redacted matching host parameters and columns. Changed: renderer and continuation-adapter exceptions are reported to `Rails.error`, logged, and emitted as `surface.render_failed` / `agent_failed` events instead of being swallowed; `surface.rendered` fires only for a successful render. Added: `message:` on `ToolViews::Error` and `ValidationError`, I18n lookup under `tool_views.errors.*`, and overridable Engine copy under `tool_views.surface.*`. Changed: the status line no longer interprets a `selected` state key; handlers set `state["message"]`. Removed from core: the reference host's `ALREADY_SUBMITTED`, `ALREADY_ACCEPTED` and `REVIEW_REQUIRED` wording, now in its own locale file. No database change.

Added: `tool_views_action_form`, `tool_views_action_button` and `tool_views_action_fields` view helpers. Fixed: Rails' own `form.submit` and `form.button` were rejected as `UNKNOWN_FIELD`; `commit` and `button` are now accepted and ignored. Added: a ViewComponent whose initializer names `surface:`, `state:` or `error:` receives them and can be interactive. Added: `config.parent_controller` and `config.delivery_lease`. Changed: without Turbo, a committed HTML action redirects back to the same-host embedding page instead of the Engine's bare Surface fragment. Changed: a database deadlock, serialization failure or lock timeout returns `CONFLICT` instead of an unhandled error. Verified locally on PostgreSQL 17 (`gemfiles/postgres.gemfile`, `DATABASE_URL`); CI job added, not yet run.

## 0.2.0.pre.v1 — 2026-10-11 (unpublished)

Host-owned customer form, scoped support workflows and versioned result review reference demos (UC-02..05). Add bounded validation feedback with retained form values, authorized HTML error rendering, host ApplicationController inheritance and general action announcements. Demo services independently enforce role/tenant/domain versions, human review before a local outbox, immutable accepted artifacts, authorized export and durable continuation receipts. No new gem database tables or core RubyLLM dependency. Local matrix, packaged install, privacy, recovery and browser evidence: docs/evidence/V1_VALIDATION.md. Manual review and release gates remain open.

## 0.1.0.pre.v0 — 2026-10-10 (unpublished)

Strict registry and trusted Partial/ViewComponent rendering; scoped ActiveRecord Surfaces; atomic authorized actions with revision/replay receipts; JSON/Turbo controller and optional Stimulus focus/loading support; optional RubyLLM present_ui and structured continuation; installer and offline ChoiceCard demo. Local integration/security/concurrency/package/browser verification is recorded in docs/evidence/VALIDATION.md. Release and adoption gates remain open.

## Unreleased — first host integration fixes (2026-10-17)

- Fix: without Turbo and without a same-host referrer, a committed HTML action redirected through a hard-coded `tool_views` route proxy. Under the installer's `rails_tool_views` mount it raised `NameError` (500). It now uses the Engine's own route helper and keeps any mount path and name.
- Add: `rails_tool_views_component_name` / `tool_views_component_name`. The Surface's accessible name is looked up under `tool_views.components.<key>` on every render and falls back to the registered description.
- Docs: renderers and parent-controller filters run inside the Engine's controller and call host routes through `main_app`.
- No database change.

## Unreleased — RailsToolViews identity (2026-10-16)

- Rename the package to `rails_tool_views` and the canonical namespace to `RailsToolViews`.
- Preserve legacy Ruby requires/constants/helpers/mounts, database and wire identifiers.
- Add independent packaged-host and pre-rename persisted-data compatibility verification. No RubyGems release.
