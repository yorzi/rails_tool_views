# ADR 006 — One public identity before the first release

2026-10-18; WORK-20261018-01. Supersedes the compatibility half of ADR 005. Owner decision in the 2026-10-18 session: keep the gem name `rails_tool_views` and remove every legacy `ToolViews` identifier before any release ("Full single identity").

## Context

ADR 005 renamed the package to `rails_tool_views` / `RailsToolViews` but kept a second identity so early development hosts kept working: the top-level `ToolViews` constant, `toolviews` / `tool_views` / `tool_views/core` / `tool_views/adapters/ruby_llm` entrypoints, the `tool_views:install` generator, `tool_views_*` helpers, a `:tool_views` mount fallback, and the `tool_views` prefix on tables, I18n keys, notifications, `Rails.error` source, DOM/CSS/Stimulus identifiers and continuation delivery keys.

No version was ever published. The only consumer is OddlyDock, a local, undeployed reference host that already used the canonical Ruby names. A first release would have made every alias a permanent SemVer contract, and the top-level `ToolViews` constant would claim a generic name this gem does not own, breaking the RubyGems rule that the gem name maps to its constant.

Name review (2026-10-18): `rails_tool_views` follows the underscore convention (one constant, like `rails_admin`/`RailsAdmin`). Rejected: `tool_views-rails` (implies a separate non-Rails core; this core needs ActiveRecord and the engine), `ruby_llm-tool_views` (core is AI-free; RubyLLM is an optional adapter), `Rails::ToolViews` (implies Rails core). RubyGems exact-name lookups for these returned 404 on 2026-10-18; this is an observation, not a reservation or legal clearance.

## Decision

Version `0.3.0.pre.v3` has one identity, `rails_tool_views`:

- Ruby: only `require "rails_tool_views"`, `rails_tool_views/core`, `rails_tool_views/adapters/ruby_llm`; only `RailsToolViews`; only `rails_tool_views:install`; helpers only `rails_tool_views_*`; route proxy only `:rails_tool_views`.
- Database: tables `rails_tool_views_surfaces`, `_presentations`, `_action_executions`, `_agent_interactions`; custom indexes `index_rails_tool_views_call_scope`, `index_rails_tool_views_action_replay`, `index_rails_tool_views_interaction_execution` (the default name would be 64 bytes, over PostgreSQL's 63). Migration `CreateRailsToolViews`, same version number.
- Strings: I18n `rails_tool_views.{errors,surface,components}`, notifications `*.rails_tool_views`, `Rails.error` source `rails_tool_views`, DOM id `rails_tool_views_surface_<id>`, CSS `rails-tool-views-*`, Stimulus asset `rails_tool_views_controller.js` exporting `railsToolViewsController`, identifier `rails-tool-views`, delivery key `rails_tool_views:interaction:<id>`.

Unchanged: component keys/versions/digests (`contract_version: 1`), Surface IDs, revisions, serialized props/state/results, error codes, routes under the mount, authorization and replay semantics.

## Consequences

A 0.2 host runs one reversible migration (`rename_index` then `rename_table`) and renames helpers, translations, subscribers, the Stimulus registration and CSS selectors. Pending continuations must be drained first, because the host deduplicates by delivery key. Pages rendered before the deploy need a reload. The Upgrading guide holds the exact steps.

`test/identity_test.rb` now asserts that the legacy constant, entrypoints, generator and helpers are absent, that tables/DOM/delivery identifiers use the new prefix, and that every index name fits 63 bytes. `scripts/rename_smoke.rb` (pre-rename data replay through the alias) was deleted with the compatibility it verified. ADR 005 remains as history for the package rename itself.
