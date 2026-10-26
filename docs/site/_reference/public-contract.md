---
layout: default
title: "Public Contract"
nav_order: 3
description: "Know which names, fields and behaviors 1.0 keeps stable, and which stay internal or experimental."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Which Ruby, HTTP, browser and data names 1.0 keeps stable.
* Which parts are internal or experimental.
* Which Ruby, Rails and database versions are supported.

## Rely on the Declared Contract

Your host code, saved data and browser markup depend on names the gem chooses. This page lists those names. From 1.0.0 they follow [Semantic Versioning](https://semver.org/): a patch release fixes behavior, a minor release only adds, and only a major release removes or changes a listed name. A deprecated name keeps working for at least one minor release and is listed in [Upgrading]({% link _reference/upgrading.md %}) before a major release removes it.

The contract is frozen from 1.0.0. Anything not listed here is internal and may change in any release. That includes code marked `:nodoc:`, code absent from the [API Reference]({% link _reference/api-reference.md %}), private methods, `RailsToolViews::Data`, the Engine controller class and the Engine's own partials.

The guides own behavior. This page names what is stable and links to the guide that explains it.

## Ruby API

```ruby
RailsToolViews.configure { |config| config.scope_resolver = resolver }
RailsToolViews.register(key, description:, schema:, partial: nil, component: nil,
  policy: nil, actions: {}, expose_to: [], version: "1")
RailsToolViews.present(key, props:, scope:, context: nil, correlation: nil)
RailsToolViews.restore(id, scope:)
RailsToolViews.dispatch(id, scope:, action:, arguments:, base_revision:,
  idempotency_key:, source_component: nil, target: nil)
RailsToolViews.deliver(id, scope:, adapter: RailsToolViews.configuration.agent_adapter,
  retry_failed: false)
RailsToolViews.render(surface, view_context:, scope:, error: nil, notice: nil)
RailsToolViews.reconcile_delivery(id, scope:, outcome:)
RailsToolViews.close(id, scope:, retain_until: nil)
RailsToolViews.abandon(id, scope:, retain_until: nil)
RailsToolViews.purge_closed(scope:, closed_before:, batch_size: 100, dry_run: true,
  after: nil)
```

`present` and `restore` return a `RailsToolViews::Surface`. `close` and `abandon` return the Surface; a repeated call returns it unchanged. `deliver` and `reconcile_delivery` return the reloaded `RailsToolViews::AgentInteraction`; `outcome:` is `:completed` or `:failed`. `render` returns HTML. `RailsToolViews.registry`, `RailsToolViews.configuration`, `reset_registry!` for reload hooks and `reset!` for tests are also stable.

`dispatch` returns a receipt with `status: "completed"`, `surface_id` and `revision`, plus `notice` and `interaction_id` when present. An exact retry returns the same receipt. `purge_closed` returns `examined`, `eligible`, `purged`, `protected`, `dry_run` and `next_after`, an opaque cursor string or nil. A later minor release may add summary keys.

These classes and their documented readers are stable:

| Class | Stable members |
| --- | --- |
| `Scope` | `actor`, `tenant` |
| `Access` | `actor`, `tenant`, `operation`, `props`, `surface`, `action`, `arguments`, `context_ref` |
| `Transition` | `state`, `agent`, `notice` |
| `Error` | `code`, `status`, `message`, `to_h`, `Error.message_for` |
| `ValidationError` | `fields`, `values`, plus `Error` |
| `Component` | `key`, `description`, `version`, `digest`, `schema`, `partial`, `component`, `policy`, `actions`, `expose_to`, `context` |
| `Registry` | `register`, `fetch`, `catalog` |
| `Schema` | `json`, `validate!` |
| `Configuration` | every attribute in [Configuration]({% link _getting_started/configuration.md %}) |
| `Surface` | `id`, `actor_ref`, `tenant_ref`, `context_ref`, `component_key`, `component_digest`, `contract_version`, `props`, `state`, `revision`, `closed_at`, `abandoned_at`, `retain_until`, `purged_at`, `agent_interactions`, `dom_id`, `closed?`, `purged?`, `lifecycle_status`, `snapshot` |
| `AgentInteraction` | `id`, `surface_id`, `surface`, `status`, `attempts`, `claimed_at`, `error_code`, `delivery_uncertain`, `delivery_key` |

A policy receives `Access#operation` as one of `:present`, `:read`, `:action`, `:discover`, `:close`, `:abandon`, `:purge` or `:reconcile`. An interaction's `status` is one of `pending`, `delivering`, `completed`, `failed`, `skipped` or `abandoned`. `Surface#lifecycle_status` is one of `active`, `closed`, `abandoned` or `purged`.

## Error Codes

Every rejection is a `RailsToolViews::Error` with a stable `code` and HTTP `status`. Message wording is not part of the contract; translate it under `rails_tool_views.errors.<code>`, as [Validation and Errors]({% link _core_features/validation.md %}) shows.

* Registration: `INVALID_COMPONENT`, `INVALID_RENDERER`, `INVALID_SCHEMA`, `INVALID_ACTION`, `DUPLICATE_COMPONENT`.
* Input bounds: `INVALID_JSON`, `PAYLOAD_TOO_LARGE`, `PAYLOAD_TOO_DEEP`, `INVALID_SCOPE`, `INVALID_CONTEXT`, `INVALID_CORRELATION`, `INVALID_IDEMPOTENCY_KEY`, `UNKNOWN_FIELD`, `INVALID_CSRF`.
* Presentation and reads: `UNKNOWN_COMPONENT`, `INVALID_PROPS`, `NOT_FOUND`, `NOT_ALLOWED`, `INCOMPATIBLE_COMPONENT`, `RENDER_FAILED`, `CATALOG_TOO_LARGE`.
* Actions: `UNKNOWN_ACTION`, `INVALID_ARGUMENTS`, `INVALID_REVISION`, `INVALID_SOURCE`, `INVALID_TARGET`, `INVALID_TRANSITION`, `INVALID_VALIDATION_FEEDBACK`, `VALIDATION_FAILED`, `CONFLICT`, `IDEMPOTENCY_CONFLICT`, `RATE_LIMITED`.
* Continuation: `AGENT_NOT_CONFIGURED`, `DELIVERY_IN_TRANSACTION`, `DELIVERY_ACTIVE`, `RECONCILIATION_CONFLICT` and `INVALID_RECONCILIATION`. A failed attempt stores `AGENT_UNAVAILABLE` as the interaction's `error_code`.
* Lifecycle: `SURFACE_CLOSED`, `SURFACE_PURGED`, `LIFECYCLE_BUSY`, `INVALID_RETENTION_REQUEST`, `INVALID_RETENTION_WINDOW`.

Codes use HTTP 400 unless listed here. `NOT_ALLOWED`, `INVALID_CSRF`, and `INVALID_SCOPE` for a call without a `Scope`, use 403. `NOT_FOUND` and `UNKNOWN_COMPONENT` use 404. `CONFLICT`, `IDEMPOTENCY_CONFLICT`, `LIFECYCLE_BUSY`, `DELIVERY_IN_TRANSACTION`, `DELIVERY_ACTIVE` and `RECONCILIATION_CONFLICT` use 409. `SURFACE_CLOSED` and `SURFACE_PURGED` use 410. `PAYLOAD_TOO_LARGE` uses 413. `VALIDATION_FAILED`, `INVALID_TRANSITION`, `INCOMPATIBLE_COMPONENT` and `RENDER_FAILED` use 422. `RATE_LIMITED` uses 429. `AGENT_NOT_CONFIGURED` uses 503. A host may raise its own codes; they keep the status it chooses.

## Views, Helpers and Generators

These view helpers are stable: `rails_tool_views_surface`, `rails_tool_views_action_form`, `rails_tool_views_action_button`, `rails_tool_views_action_fields`, `rails_tool_views_component_name` and `rails_tool_views_text`. Engine copy keys under `rails_tool_views.surface` and component names under `rails_tool_views.components` are stable.

A Partial receives the `props`, `state`, `surface` and `error` locals. A ViewComponent receives props as keywords and may name `surface:`, `state:` or `error:`. You may override `app/views/layouts/rails_tool_views/application.html.erb` and `app/views/rails_tool_views/surfaces/page.html.erb`.

The generators are `rails_tool_views:install` and `rails_tool_views:component NAME`. Their output is a starting point you own; regenerating is not an upgrade path.

## HTTP Endpoints

Mount the Engine under the name `:rails_tool_views`; the path is yours. Three routes are stable:

| Route | Purpose |
| --- | --- |
| `GET surfaces/:id` | Read a Surface: a JSON snapshot or a complete HTML page |
| `POST surfaces/:id/actions` | Dispatch an action |
| `POST surfaces/:id/continuations/:interaction_id` | Retry a failed follow-up |

An action request carries `action` or `action_name`, `arguments`, `base_revision` and `idempotency_key`, and may carry `source_component` and `target`. Any other field is rejected with `UNKNOWN_FIELD`, apart from Rails' `authenticity_token`, `commit` and `button`. A JSON success returns the receipt plus `current_revision`, and `agent_status` when a follow-up exists. A pending follow-up sets `status: "pending"` and HTTP 202. A rejection returns `status: "rejected"`, `code` and `message`, plus `fields` and `values` for `VALIDATION_FAILED`.

Turbo responses replace the element with the Surface's `dom_id`. A browser without Turbo receives a 303 redirect after success and a complete correction page after a rejection. A JSON snapshot contains `id`, `component`, `component_digest`, `props`, `state`, `revision` and `lifecycle` with `status`, `closed_at`, `retain_until` and `purged_at`.

## Browser Identifiers

The Surface element's id is `rails_tool_views_surface_<id>`. Its status and error elements append `_status` and `_error`. The stable classes are `rails-tool-views-surface`, `rails-tool-views-error`, `rails-tool-views-revision` and `rails-tool-views-page`; an error element carries `data-error-code`.

The asset `rails_tool_views_controller.js` exports a default factory that takes your Stimulus `Controller` class. Register its result as `rails-tool-views`. The `revision`, `saving` and `failed` values and the `status` and `error` targets are stable. Other `data-` attributes and flash keys are internal.

## Events, Delivery Keys and Data

Every event in the [Operational Diagnostics]({% link _advanced/diagnostics.md %}) catalog is stable, with its name and metadata keys. A minor release may add a metadata key, so ignore keys you do not use. A delivery key is `rails_tool_views:interaction:<id>` and never changes across retries.

The Engine owns four tables with the `rails_tool_views_` prefix. You may query `Surface` and `AgentInteraction` by the members listed above, for example to find uncertain deliveries to reconcile. Change Engine rows only through the Ruby API; unlisted columns, including interaction payloads, are internal. Saved Surfaces carry `contract_version` 1. Their component digests stay valid across releases until you change the component contract, as [Components]({% link _core_features/components.md %}#change-a-contract) explains. Data saved by any 0.x release upgrades through the migrations and steps in [Upgrading]({% link _reference/upgrading.md %}).

## Experimental Parts

The RubyLLM adapter, loaded with `require "rails_tool_views/adapters/ruby_llm"`, is experimental. It is tested offline against RubyLLM {{ site.requirements.ruby_llm_tested }} through a real chat loop, but no live provider has been exercised end to end. `PresentUI`, `Continuation` and the codes they return (`EMPTY_CATALOG`, `MISSING_TOOL_CALL` and `INVALID_TOOL_CALL`) may change in a minor release. The provider-free core is not affected.

## Supported Versions

Ruby 3.3 and 4.0 are tested, with Rails 7.2 and 8.1. The gemspec admits Rails releases from 7.2 up to, but not including, 9; versions between the tested lines are untested. SQLite and PostgreSQL 17 are supported and run in CI.

MySQL is not supported. The migration fits utf8mb4 index limits, but no real MySQL migration or concurrency run backs a support claim. See [Production Boundaries]({% link _advanced/production.md %}#choose-a-database-and-integration).

## Next Steps

* [Upgrading]({% link _reference/upgrading.md %}) lists the steps between releases.
* [Operational Diagnostics]({% link _advanced/diagnostics.md %}) holds the event catalog.
* [Release History]({% link _reference/release-history.md %}) explains each release.
