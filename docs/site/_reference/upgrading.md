---
layout: default
title: "Upgrading"
nav_order: 2
description: "Upgrade from 0.2 with additive lifecycle columns while preserving saved views and replay receipts."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Install the lifecycle migration on an existing host.
* Stop old writers before enabling lifecycle operations.
* Review delivery uncertainty and rollback limits.

## Stop Old Writers and Back Up

Back up the Engine tables and relevant host business data. Stop old web processes and delivery workers, then update the gem. Do not run a mixture of old and new writers: the old runtime does not enforce closed or purged states. Requests from old browser tabs must reach only the new server.

For an older upgrade, follow the [0.2 upgrade guide](https://github.com/yorzi/rails_tool_views/blob/v0.2.0/docs/site/_reference/upgrading.md) first.

## Copy and Run Missing Migrations

Existing hosts use the standard Rails task:

```sh
bin/rails railties:install:migrations FROM=rails_tool_views
bin/rails db:migrate
```

Do not rerun `rails_tool_views:install` on an existing host. Rails skips the existing create migration by name and copies the lifecycle migration. New installations receive both migrations from the installer.

The migration adds Surface lifecycle timestamps and an interaction uncertainty flag. Existing Surface IDs, props, state, revisions, correlation and replay receipts stay unchanged; existing views start active. No runtime dependency is added.

Old delivering interactions and rows with multiple attempts are marked uncertain. Their old history cannot distinguish an explicit failed retry from overlapping lease takeovers. The new runtime preserves delivery behavior but blocks lifecycle termination for these records, including after a terminal acknowledgment. Inspect them through host operations; do not clear the flag based on elapsed time.

## Review New Fields and Policies

Snapshots add a `lifecycle` object. Update strict consumers that reject unknown response keys. Existing component contracts and digests are unchanged.

Lifecycle calls recheck normal read policy plus the component policy for `:close` or `:abandon`. Review policies before wiring host routes; there are no built-in Engine lifecycle endpoints or AI tools. Existing active actions and optional continuation remain available.

## Verify Before Enabling Retention

Restore a saved 0.2 Surface and replay its original action with the same key. Check current read/action policy and tenant isolation. Test closure, rejected new actions, permitted old receipts and explicit abandonment. Leave uncertain or delivering work protected. A nil retention deadline keeps data indefinitely. Configure the separate `retention_policy` before previewing `purge_closed`; it defaults to deny. Apply removes receipt payloads and preserves replay tombstones and business records.

The migration can roll back only while no Surface has been closed. Once lifecycle is used, it refuses downgrade, since an old runtime could reopen work and payload cleanup cannot reconstruct data. Restore the complete pre-upgrade backup if a rollback is necessary; coordinate host business effects separately. See [Surface Lifecycle]({% link _advanced/lifecycle.md %}).
