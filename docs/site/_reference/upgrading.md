---
layout: default
title: "Upgrading"
nav_order: 2
description: "Move an existing ToolViews host to RailsToolViews without replacing saved UI records."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Change the dependency and public namespace.
* Retain installed migrations and replay identifiers.
* Review bounded identifiers and custom rendering.

## Update the Package

Replace the `toolviews` dependency with `rails_tool_views`. Use `require "rails_tool_views"` and `RailsToolViews` in new code. For this unreleased candidate, use a local checkout or the private Git repository as described in [Getting Started]({% link _getting_started/getting-started.md %}).

Legacy `require "toolviews"`, `require "tool_views"`, `require "tool_views/core"`, and `require "tool_views/adapters/ruby_llm"` still load the same implementation. `ToolViews` shares the canonical registry and configuration; it is not a separate runtime.

## Retain Existing Database and Routes

Do not run the installer again on an existing host. Retain its initializer, migration history, and mount. Existing `:tool_views` mounts and `tool_views_*` helpers still work. New hosts may use `:rails_tool_views` and `rails_tool_views_*`.

The four `tool_views_*` tables, migration names, component keys/versions/digests, Surface IDs, DOM/Stimulus identifiers, translations, notification names, and continuation delivery keys remain unchanged. No schema or data migration accompanies the rename.

## Review Bounded Identifiers

The runtime bounds the actor, tenant, context, adapter, call and idempotency references to 150 bytes and stores them in byte-limited columns. A longer value is rejected with `INVALID_SCOPE`, `INVALID_CONTEXT`, `INVALID_CORRELATION` or `INVALID_IDEMPOTENCY_KEY` instead of being truncated. The bound keeps every index key inside utf8mb4's 3072-byte limit on MySQL and InnoDB, where the unbounded five-column presentation index would not fit.

If you already installed the migration, no change is required: the columns exist and the runtime still bounds values in code. Run the installer's migration only on a new host, or on MySQL where the original migration does not apply. The runtime also matches stored Surfaces, presentations, action receipts and correlations byte for byte after a lookup, so a non-binary database collation cannot resolve another actor's or tenant's row.

## Review Host Overrides

Move custom Engine partial overrides to `app/views/rails_tool_views/`. Review custom code that serializes Ruby class names. Do not rename your component classes or Partial paths as a side effect of the gem rename; renderer identity contributes to the digest.

If a host changes a component contract, use an explicit host migration or create a new Surface. Never change saved props to bypass `INCOMPATIBLE_COMPONENT`. Back up data before changing host contracts and verify both read and action paths on restored records.

## Next Steps

* [Release History]({% link _reference/release-history.md %}) records publication status.
* [Production Boundaries]({% link _advanced/production.md %}) covers operational checks.
