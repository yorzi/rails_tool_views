---
layout: default
title: "Production Boundaries"
nav_order: 3
description: "Plan authorization, privacy, retention, and external effects in the host application."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Place business authority in the host.
* Plan retention and safe diagnostics.
* Understand current database and integration limits.

## Keep Authority in the Host

Resolve actor and tenant from authenticated server state. Check both component read policy and action policy against current domain records. Props and UI state describe a view; neither can grant permission or prove approval. A private repository and passing tests are not substitutes for application security review.

Use one database transaction for host writes that must commit with the Surface. Use a durable outbox for external effects. The gem owns UI records, not customer, ticket, artifact, or billing records.

## Plan Data Retention

Four Engine models persist Surfaces, presentations, action receipts, and agent interactions. They do not expire automatically. Define host retention and delete related data deliberately; do not expire receipts while clients can still retry an old action. There is no built-in retention scheduler.

## Inspect Failures Safely

Engine request/SQL/inspect logging masks sensitive Engine values. Notifications contain metadata. Host parameters called `state`, `result`, or `arguments` are not globally filtered by the gem, so the host must configure its own privacy rules. Exceptions raised by host renderers or adapters are reported to Rails and may contain host-supplied sensitive text; sanitize those exception messages.

Keep translations under `rails_tool_views.errors`, `rails_tool_views.surface`, and `rails_tool_views.components`. Provide labeled controls and accessible field feedback in your component. Turbo enhances updates; a non-Turbo rejected action currently displays a fragment page.

## Choose a Database and Integration

SQLite and PostgreSQL have local and release-CI verification records. MySQL is unverified. The bundled migration bounds every indexed identifier column to 150 bytes, so the five-column presentation index needs 3000 bytes, inside utf8mb4's 3072-byte limit. The runtime also bounds identifiers in bytes and matches stored identities byte for byte, so a case-insensitive collation cannot resolve another actor's or tenant's row. Run your own migration and concurrency checks on the actual deployment database.

Host examples and local integration work do not establish production adoption. OddlyDock is not a runtime dependency. There are no built-in ActionCable subscriptions, remote UI protocols, billing, or hosted services. RubyLLM remains optional. The gem is published under MIT; publication does not establish independent security review, live-provider qualification or external adoption.

## Next Steps

* [Configuration]({% link _getting_started/configuration.md %}) sets limits.
* [Upgrading]({% link _reference/upgrading.md %}) preserves existing records.
