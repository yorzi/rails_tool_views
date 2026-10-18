---
layout: default
title: "What Is New in 0.1"
nav_order: 4
description: "The first release provides persistent Rails views with authorized actions and optional AI adapters."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Use the single package, namespace, and prefix.
* Find the changes a 0.2 development host needs.

## Use RailsToolViews

The first public release is {{ site.version }}. Its package is `rails_tool_views`, its Ruby namespace is `RailsToolViews`, and its installer is `rails_tool_views:install`. New hosts use the canonical helper prefix `rails_tool_views_`.

## One Identity

The first release removes the second identity carried by unpublished development candidates. The `ToolViews` constant, the `toolviews` and `tool_views` entrypoints, the `tool_views:install` command, and the `tool_views_*` helpers are gone. Tables, translations, notifications, DOM and Stimulus identifiers, and continuation delivery keys now use the `rails_tool_views` prefix. An earlier development host renames four tables with one migration; saved Surfaces, revisions, and replay receipts keep working.

The engine also provides field-validation feedback, host controller inheritance, action form helpers, and optional durable agent continuation. A Surface's accessible name can be translated under `rails_tool_views.components.<key>`. Without Turbo, a committed action now redirects correctly under any mount name, including the installer's `rails_tool_views`. Actor, tenant, context, adapter, call and idempotency identifiers are bounded to 150 bytes so every index key fits MySQL's utf8mb4 limit, and stored identities are matched byte for byte regardless of database collation. The reference host demonstrates customer forms, support workflows, and artifact review with offline data.

## Patched Runtime Dependencies

A clean Ruby installation may include older default gems even when your application lockfile uses patched versions. RailsToolViews requires patched CGI, ERB, Resolv, URI and Zlib versions. Use a patched Rails release in the host; the compatibility suite uses Rails 7.2.3.2 and 8.1.4.

## Next Steps

* [Upgrading]({% link _reference/upgrading.md %}) lists the required host changes.
* [Release History]({% link _reference/release-history.md %}) distinguishes candidates from releases.
