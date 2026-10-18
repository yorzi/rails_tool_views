---
layout: default
title: "Upgrading"
nav_order: 2
description: "Move an unpublished development host to the first public RailsToolViews release."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Which legacy names the first release removes and what replaces each one.
* How to rename the four tables without losing saved Surfaces.
* What to drain or reload before you deploy the change.
* How bounded identifiers and custom rendering affect an upgrade.

## From 0.1 to the 0.2 Preview

No database migration is needed for the new component generator. Existing manual registrations keep working. Load generated definitions in your existing shared `to_prepare` block after `reset_registry!`; do not add a reset for each file. See [Generating a Component]({% link _core_features/component-generator.md %}).

Direct Engine HTML reads and errors now render a full document with the Engine layout. Embedded helpers, JSON and Turbo remain fragments or structured responses. If you override Engine templates, review `layouts/rails_tool_views/application` and `rails_tool_views/surfaces/page`. See [Validation and Errors]({% link _core_features/validation.md %}).

## Start with One Identity

The internal candidates `0.1.0.pre.v0`, `0.2.0.pre.v2` and `0.3.0.pre.v3` were never published. They carried a second `ToolViews` identity so early development hosts kept working after the package rename. A first public release would have turned every one of those aliases into a permanent contract, and the top-level `ToolViews` constant would have claimed a name this package does not own. The first public version, {{ site.version }}, keeps one identity: the package `rails_tool_views`, the module `RailsToolViews`, and the prefix `rails_tool_views` everywhere else.

## Update Ruby Code

Use `require "rails_tool_views"` and `RailsToolViews`. The `toolviews`, `tool_views`, `tool_views/core`, and `tool_views/adapters/ruby_llm` entrypoints and the `ToolViews` constant are gone, so loading them raises `LoadError` or `NameError`. Require the adapter as `rails_tool_views/adapters/ruby_llm`.

Rename view helpers from `tool_views_` to `rails_tool_views_`:

| Unpublished helper | Public helper |
| --- | --- |
| `tool_views_surface` | `rails_tool_views_surface` |
| `tool_views_action_form` | `rails_tool_views_action_form` |
| `tool_views_action_button` | `rails_tool_views_action_button` |
| `tool_views_action_fields` | `rails_tool_views_action_fields` |
| `tool_views_component_name` | `rails_tool_views_component_name` |

Mount the engine with the name `:rails_tool_views`. The helpers no longer look for a `:tool_views` mount. You can keep any URL path:

```ruby
mount RailsToolViews::Engine => "/tool_views", as: :rails_tool_views
```

The installer is now only `rails_tool_views:install`. It writes `config/initializers/rails_tool_views.rb`; rename an existing `tool_views.rb` initializer if you want the file to match. Do not run the installer again on an existing host.

## Rename the Tables

The engine now reads `rails_tool_views_surfaces`, `rails_tool_views_presentations`, `rails_tool_views_action_executions`, and `rails_tool_views_agent_interactions`. Add one host migration. It renames the custom indexes first, so no renamed index exceeds PostgreSQL's 63-byte identifier limit:

```ruby
class RenameToolViewsToRailsToolViews < ActiveRecord::Migration[7.2]
  def change
    rename_index :tool_views_presentations, "index_tool_views_call_scope", "index_rails_tool_views_call_scope"
    rename_index :tool_views_action_executions, "index_tool_views_action_replay", "index_rails_tool_views_action_replay"
    rename_index :tool_views_agent_interactions, "index_tool_views_agent_interactions_on_action_execution_id",
      "index_rails_tool_views_interaction_execution"
    rename_table :tool_views_surfaces, :rails_tool_views_surfaces
    rename_table :tool_views_presentations, :rails_tool_views_presentations
    rename_table :tool_views_action_executions, :rails_tool_views_action_executions
    rename_table :tool_views_agent_interactions, :rails_tool_views_agent_interactions
  end
end
```

`rename_table` also renames the indexes Rails named by default. Rows, Surface IDs, revisions, component digests, and replay receipts are unchanged, so saved Surfaces restore and retried actions replay as before. Keep the original install migration in your history.

## Update Translations and Instrumentation

Move translations from `tool_views.errors`, `tool_views.surface`, and `tool_views.components` to the same keys under `rails_tool_views`. Subscribers to `*.tool_views` notifications now subscribe to `*.rails_tool_views`, and errors reported to `Rails.error` use the source `rails_tool_views`.

## Update the Browser Contract

The Stimulus asset is `rails_tool_views_controller.js` and exports `railsToolViewsController`. Register it as `rails-tool-views`:

```js
import railsToolViewsController from "rails_tool_views_controller";
application.register("rails-tool-views", railsToolViewsController(Controller));
```

Surface elements use the id `rails_tool_views_surface_<id>` and the classes `rails-tool-views-surface`, `rails-tool-views-error`, and `rails-tool-views-revision`. Rename host CSS selectors. A page rendered before the deploy targets the old id, so its next Turbo Stream replacement does not apply; reloading the page fixes it.

## Drain Agent Continuations

Delivery keys change from `toolviews:interaction:<id>` to `rails_tool_views:interaction:<id>`. Your delivery callback deduplicates by that key, so a continuation retried after the upgrade does not match a receipt stored under the old key. Before you deploy, let pending deliveries finish and either retry or abandon failed ones. Alternatively, rewrite the stored keys in your deduplication table in the same migration.

## Review Bounded Identifiers

The runtime bounds the actor, tenant, context, adapter, call and idempotency references to 150 bytes and stores them in byte-limited columns. A longer value is rejected with `INVALID_SCOPE`, `INVALID_CONTEXT`, `INVALID_CORRELATION` or `INVALID_IDEMPOTENCY_KEY` instead of being truncated. The bound keeps every index key inside utf8mb4's 3072-byte limit on MySQL and InnoDB, where the unbounded five-column presentation index would not fit.

If you already installed the migration, no column change is required: the runtime still bounds values in code. The runtime also matches stored Surfaces, presentations, action receipts and correlations byte for byte after a lookup, so a non-binary database collation cannot resolve another actor's or tenant's row.

## Review Host Overrides

Custom Engine partial overrides stay in `app/views/rails_tool_views/`. Do not rename your component classes or Partial paths as a side effect of this upgrade; renderer identity contributes to the digest.

If a host changes a component contract, use an explicit host migration or create a new Surface. Never change saved props to bypass `INCOMPATIBLE_COMPONENT`. Back up data before changing host contracts and verify both read and action paths on restored records.

## Next Steps

* [Release History]({% link _reference/release-history.md %}) records publication status.
* [Production Boundaries]({% link _advanced/production.md %}) covers operational checks.
