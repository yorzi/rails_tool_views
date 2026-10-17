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

Keep translations under `tool_views.errors`, `tool_views.surface`, and `tool_views.components`. Provide labeled controls and accessible field feedback in your component. Turbo enhances updates; a non-Turbo rejected action currently displays a fragment page.

## Choose a Database and Integration

SQLite and PostgreSQL have local verification records. MySQL is unverified and the multi-column presentation index needs review for utf8mb4 limits. Run your own migration and concurrency checks on the actual deployment database.

OddlyDock is a planned reference host, not a runtime dependency or a completed integration. There are no built-in ActionCable subscriptions, remote UI protocols, billing, or hosted services. RubyLLM remains optional. No public gem release or license grant is implied by these prerelease docs.

## Next Steps

* [Configuration]({% link _getting_started/configuration.md %}) sets limits.
* [Upgrading]({% link _reference/upgrading.md %}) preserves existing records.
