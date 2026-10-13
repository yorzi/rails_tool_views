# ADR 004 — action form helpers, ViewComponent context, host controller choice and PostgreSQL

Date: 2026-10-13. Status: implemented locally. Work: WORK-20261013-01; FR-02, FR-05, FR-07, FR-08, NFR-03; continues ADR 003. Amends two choices in ADR 001 and ADR 002 without rewriting them.

## Context

After the audit fixes, the largest remaining risk was the cost of writing one interactive component, not correctness. Probes against the reference host showed where that cost came from.

1. Every component template hand-wrote the action URL and four hidden routing fields and built element ids by hand. The reference host had written its own helper for this.
2. Rails' own `form.submit` and `form.button` post `commit` and `button`. The controller rejected both as `UNKNOWN_FIELD`, so the idiomatic Rails form returned 400. The reference host avoided it with nameless `<button>` tags.
3. ADR 001 passed a ViewComponent only its props. It could not see the Surface, its state or a validation error, so it could not render an action form; the documented workaround was a wrapper Partial.
4. ADR 002 fixed the superclass to the host's `ApplicationController`. Hosts that keep authentication on a subclass got no identity on the mounted routes.
5. Without Turbo, a committed HTML action redirected to the Engine's own Surface page, which renders a bare fragment with no layout or way back.
6. Only SQLite had been exercised. ADR 003 added a database bind type whose behavior on PostgreSQL was unknown, and PostgreSQL raises rollback errors SQLite does not.

## Decision

Ship three view helpers. `tool_views_action_form(surface, action)` wraps `form_with` with `scope: :arguments` and `namespace: surface.dom_id`, so builder fields are named `arguments[...]` and ids are unique per Surface, and emits the action name, current revision, a fresh idempotency key and the source component. `tool_views_action_button` is the one-button form with fixed arguments. `tool_views_action_fields` returns the routing fields alone. All three raise `ArgumentError` naming the action when the component does not register it, which surfaces at render through ADR 003's reporting.

Accept `commit` and `button` as inert fields next to `authenticity_token`. Their values are never read and they stay masked in request logs. Every other unknown field still rejects.

Pass `surface:`, `state:` and `error:` to a ViewComponent only for the keywords its initializer names, computed once at registration as `Component#context`. A component that names none is called exactly as before. Registration rejects a props schema that declares a property with a context name the component accepts. The component includes `ToolViews::SurfacesHelper` to use the form helpers; `tool_views_routes` falls back to the component's view context for the mounted route proxy.

Add `config.parent_controller` (default `"::ApplicationController"`), resolved when the controller class loads and required to descend from `ActionController::Base`, and `config.delivery_lease` in seconds (default 300) in place of the fixed five minutes.

Redirect a committed non-Turbo HTML action with `redirect_back_or_to(..., allow_other_host: false)`: the embedding page re-renders saved state, and a missing or foreign `Referer` falls back to the Engine's Surface page.

Map `ActiveRecord::TransactionRollbackError` (deadlock, serialization failure) and `ActiveRecord::LockWaitTimeout` to the existing `CONFLICT`, because the whole action transaction has rolled back and a retry with the same key is safe. Add `gemfiles/postgres.gemfile` and a CI job, and select the database with `DATABASE_URL`.

## Alternatives considered

A custom form builder that strips submit names would not help a host that writes `form_with` itself. Passing context to every ViewComponent would break components with strict keyword signatures; a `with_surface` setter would make the component mutable after construction. Rendering the standalone Surface page inside the host layout fails in an isolated engine as soon as the layout calls a host route helper. A component generator would cut more setup time but adds a second surface to keep in step with the registry; it is deferred until an outside developer has tried the helpers.

## Consequences

`commit` and `button` are now reserved names that cannot be detected as injected fields. The redirect depends on the `Referer` header, which browsers may omit; the fallback is the previous behavior. `parent_controller` is read once per process outside development reloading, so it must be set in an initializer. Components that include the helper module gain its method names.

PostgreSQL 17.11 with Rails 8.1.4 passed the full suite, eager load, five fixed seeds and the demo over HTTP, including separate-process concurrency and bind redaction. This is one local version on macOS. MySQL remains unverified, and the five-column unique index on presentations would exceed its index key limit by arithmetic.

## Human review trigger

Reconsider the tolerated field names if Rails changes what its submit helpers post. Reconsider keyword-based context if a real component needs context under different names. Reconsider the rollback mapping if a host reports a `CONFLICT` that was not safe to retry.
