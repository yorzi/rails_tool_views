---
layout: default
title: "What Is New"
nav_order: 4
description: "RailsToolViews now has one identity, with no legacy ToolViews aliases."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Use the single package, namespace, and prefix.
* Find the changes a 0.2 development host needs.

## Use RailsToolViews

The current unreleased candidate is {{ site.version }}. Its package is `rails_tool_views`, its Ruby namespace is `RailsToolViews`, and its installer is `rails_tool_views:install`. New hosts use the canonical helper prefix `rails_tool_views_`.

## One Identity

Version 0.3 removes the second identity that 0.1 and 0.2 carried before any release. The `ToolViews` constant, the `toolviews` and `tool_views` entrypoints, the `tool_views:install` command, and the `tool_views_*` helpers are gone. Tables, translations, notifications, DOM and Stimulus identifiers, and continuation delivery keys now use the `rails_tool_views` prefix. A 0.2 development host renames four tables with one migration; saved Surfaces, revisions, and replay receipts keep working.

The engine also provides field-validation feedback, host controller inheritance, action form helpers, and optional durable agent continuation. A Surface's accessible name can be translated under `rails_tool_views.components.<key>`. Without Turbo, a committed action now redirects correctly under any mount name, including the installer's `rails_tool_views`. Actor, tenant, context, adapter, call and idempotency identifiers are bounded to 150 bytes so every index key fits MySQL's utf8mb4 limit, and stored identities are matched byte for byte regardless of database collation. The reference host demonstrates customer forms, support workflows, and artifact review with offline data.

## Next Steps

* [Upgrading]({% link _reference/upgrading.md %}) lists the required host changes.
* [Release History]({% link _reference/release-history.md %}) distinguishes candidates from releases.
