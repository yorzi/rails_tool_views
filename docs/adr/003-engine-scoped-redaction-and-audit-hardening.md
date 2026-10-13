# ADR 003 — engine-scoped log redaction, total schema walk and visible host failures

Date: 2026-10-13. Status: implemented locally. Work: WORK-20261013-01; SEC-10, SEC-12, FR-01-AC-02, FR-05, FR-07; owner-requested review and audit.

## Context

An audit of local v1 reproduced four defects against the gem's own stated contract.

1. `Schema#inspect_schema!` only descended into subschemas that declared `type: "object"`. An untyped subschema, an empty one, or an array without `items` registered successfully and then accepted any JSON, including open nested objects; a `$ref` under an untyped parent was never inspected. README and SEC-10 promise closed nested objects.
2. The Engine appended `props state payload result arguments values` to the host's global `filter_parameters`. Rails matches those names by substring and reuses the list for `ActiveRecord::Base.filter_attributes`, so every host parameter and column named `state`, `result`, `statement_id` or `search_results` became `[FILTERED]` in request logs, SQL bind logs and `#inspect`.
3. `tool_views_body` and `ToolViews.deliver` rescued `StandardError` and discarded it. A missing partial or a bug in the host adapter produced a generic message with nothing in the log, the error reporter or notifications, and `surface.rendered` still fired.
4. `Error::MESSAGES` was frozen and held three codes that belong to the reference host; a host could not word its own codes. Engine chrome was hardcoded English and special-cased a `selected` state key from the ChoiceCard demo. A native form for an action with no arguments was rejected because it cannot post an empty `arguments` object.

## Decision

Walk every subschema. Each value position must declare `type`, `enum` or `const`, or be a combinator whose branches do; objects must be closed, arrays must have an `items` schema, and `additionalProperties` may only be `false`. A combinator branch may omit `type` only when its enclosing schema already constrains the same value, which keeps the common `anyOf: [{required: [...]}, ...]` form.

Scope redaction to the Engine. `SurfacesController#process_action` appends one filter to the request's own parameter filter before Rails reads it, masking every field except routing metadata. The four models declare per-model `filter_attributes`, following what Active Record Encryption does. SQL bind logs are filtered by attribute name through `ActiveRecord::Base` only, so the JSON columns use `ToolViews::RedactedJson`, whose database bind is a `String` subclass that inspects and JSON-encodes as `[FILTERED]`. The host-wide initializer is removed.

Report host failures through `ToolViews.report`: a metadata-only `surface.render_failed` or `agent_failed` event, `Rails.error.report(handled: true, source: "tool_views")`, and one log line in the format Rails uses for handled exceptions. `surface.rendered` moves to the successful path. A `ToolViews::Error` raised by a renderer is shown as itself and not reported.

`Error` and `ValidationError` accept `message:`; otherwise wording resolves from `tool_views.errors.<code>` with the built-in text as default. Engine chrome resolves from `tool_views.surface.<key>` with defaults in `SurfacesHelper::TEXT`; the Stimulus controller receives its two strings as values. The status line reads only `state["message"]`. A missing `arguments` field is treated as `{}`; an explicit `null` still fails validation.

## Alternatives considered

Anchoring the global filter names with `\A…\z` still redacts a host column called exactly `state`. Renaming the Engine's columns to unique names would need a schema migration and still leave request parameters. Declaring the JSON type as binary uses Rails' own bind redaction but misreports the column to adapters. Making SQL redaction an opt-in host setting would have dropped a tested default. Shipping a locale file would duplicate the Ruby defaults that `core.rb` needs when I18n is absent.

Re-raising renderer errors in development was rejected because the visible fallback is itself part of FR-04-AC-02; the log line and reporter give the same information.

## Consequences

Stricter registration can reject a schema that previously loaded; this is intended and the gem is unpublished. The bind redaction relies on Rails logging binds with `inspect` and on adapters accepting a `String` subclass; it is covered by a real SQL log test on Rails 7.2.3 and 8.1.4 with SQLite, and is unverified on PostgreSQL and MySQL. On Rails 8.1 a per-model `filter_attributes` declaration makes Rails add model-scoped parameter keys such as `surface.state` to the host list; these mask only a parameter nested as `surface[state]`, verified by probe. Rails' "Started" line logs the URL query string before routing; the Engine reads only the request body. Renderer and adapter exception messages now reach the host log and error reporter, as any Rails exception does, so host code must not put secrets in them. Hosts subscribed to `surface.rendered` no longer receive it for failed renders.

## Human review trigger

Reconsider the bind mechanism if a supported Rails version changes how binds are logged, if PostgreSQL or MySQL verification fails, or if Rails gains per-model bind filtering. Reconsider the schema rules if a real host needs a JSON Schema form they reject.
