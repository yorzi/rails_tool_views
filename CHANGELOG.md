# Changelog

## [0.2.0] - 2026-10-18

- Add `rails_tool_views:component NAME` for a Partial, closed registration schemas and a Minitest scaffold. Component and action policies deny by default. Existing paths, unsafe names and symlink escapes are refused before writing.
- Render complete Engine HTML read/error pages with accessible document structure, authorized correction fields and a saved-view reload link. Embedded helpers and JSON/Turbo retain their formats.
- Fix redirects after correcting a non-Turbo error when the referrer is a POST-only Engine route.
- Add real Chrome E2E tests, including JavaScript-disabled mobile correction, fixture screenshots and a browser CI job. Keep browser dependencies in a development-only bundle.
- Exercise the installed gem and generated scaffold in a temporary Rails host, both with developer dependencies and an isolated network-resolved GEM_HOME.
- No database migration or new runtime dependency.

## [0.1.0] - 2026-10-18

First public release. Earlier version labels below describe unpublished development milestones.

- Register trusted Rails Partials and ViewComponents with closed schemas and explicit policies.
- Persist and restore scoped Surfaces; execute authorized actions with revisions, transactions and durable replay receipts.
- Render JSON/Turbo responses, accessible action forms and bounded validation feedback.
- Add optional RubyLLM presentation and durable host-managed continuation without a core AI dependency.
- Install the engine into Rails 7.2 and 8.1 on Ruby 3.3 or later; one `rails_tool_views` identity throughout.
- Publish versioned guides and an API reference on GitHub Pages; release gems through GitHub OIDC.
- Require patched CGI, ERB, Resolv, URI and Zlib gems so Ruby 3.3 default gems cannot silently satisfy the runtime dependencies. Test the Rails 7.2 line on patched 7.2.3.2.
- MySQL, live-provider behavior, independent security review and external adoption remain unverified.

## 0.3.0.pre.v3 — single identity, 2026-10-18 (unpublished)

Breaking for 0.2 development hosts; see the Upgrading guide and ADR 006.

- Removed: the `ToolViews` constant, the `toolviews`, `tool_views`, `tool_views/core` and `tool_views/adapters/ruby_llm` entrypoints, the `tool_views:install` generator, the `tool_views_*` view helpers and the `:tool_views` route-proxy fallback.
- Changed: tables and custom indexes use the `rails_tool_views_` prefix; the interaction/execution index has an explicit 44-byte name so it fits PostgreSQL. The install migration is `CreateRailsToolViews` and the initializer `config/initializers/rails_tool_views.rb`.
- Changed: I18n keys move to `rails_tool_views.*`, notifications to `*.rails_tool_views`, the `Rails.error` source to `rails_tool_views`, Surface DOM ids to `rails_tool_views_surface_<id>`, CSS classes to `rails-tool-views-*`, the Stimulus asset to `rails_tool_views_controller.js` (`railsToolViewsController`, identifier `rails-tool-views`) and delivery keys to `rails_tool_views:interaction:<id>`.
- Unchanged: component contracts and digests, Surface IDs, revisions, serialized data, error codes and replay behavior.

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
