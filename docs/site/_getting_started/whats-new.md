---
layout: default
title: "What Is New"
nav_order: 4
description: "Use the RailsToolViews identity while preserving existing Surface data."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Use the canonical package and namespace.
* Keep old data and host routes compatible.

## Use RailsToolViews

The current unreleased candidate is {{ site.version }}. Its package is `rails_tool_views`, its Ruby namespace is `RailsToolViews`, and its installer is `rails_tool_views:install`. New hosts use the canonical helper prefix `rails_tool_views_`.

## Preserve Existing Hosts

`ToolViews` remains an alias to the same module. Legacy requires, helpers, and mount names remain supported. Database tables, component contracts, replay receipts, and delivery identifiers stay stable. No database migration is required for the rename.

The engine also provides field-validation feedback, host controller inheritance, action form helpers, and optional durable agent continuation. A Surface's accessible name can be translated under `tool_views.components.<key>`. Without Turbo, a committed action now redirects correctly under any mount name, including the installer's `rails_tool_views`. The reference host demonstrates customer forms, support workflows, and artifact review with offline data.

## Next Steps

* [Upgrading]({% link _reference/upgrading.md %}) lists the required host changes.
* [Release History]({% link _reference/release-history.md %}) distinguishes candidates from releases.
