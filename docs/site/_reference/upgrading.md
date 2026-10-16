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
* Review custom rendering and contract changes.

## Update the Package

Replace the `toolviews` dependency with `rails_tool_views`. Use `require "rails_tool_views"` and `RailsToolViews` in new code. For this unreleased candidate, use a local checkout or the private Git repository as described in [Getting Started]({% link _getting_started/getting-started.md %}).

Legacy `require "toolviews"`, `require "tool_views"`, `require "tool_views/core"`, and `require "tool_views/adapters/ruby_llm"` still load the same implementation. `ToolViews` shares the canonical registry and configuration; it is not a separate runtime.

## Retain Existing Database and Routes

Do not run the installer again on an existing host. Retain its initializer, migration history, and mount. Existing `:tool_views` mounts and `tool_views_*` helpers still work. New hosts may use `:rails_tool_views` and `rails_tool_views_*`.

The four `tool_views_*` tables, migration names, component keys/versions/digests, Surface IDs, DOM/Stimulus identifiers, translations, notification names, and continuation delivery keys remain unchanged. No schema or data migration accompanies the rename.

## Review Host Overrides

Move custom Engine partial overrides to `app/views/rails_tool_views/`. Review custom code that serializes Ruby class names. Do not rename your component classes or Partial paths as a side effect of the gem rename; renderer identity contributes to the digest.

If a host changes a component contract, use an explicit host migration or create a new Surface. Never change saved props to bypass `INCOMPATIBLE_COMPONENT`. Back up data before changing host contracts and verify both read and action paths on restored records.

## Next Steps

* [Release History]({% link _reference/release-history.md %}) records publication status.
* [Production Boundaries]({% link _advanced/production.md %}) covers operational checks.
