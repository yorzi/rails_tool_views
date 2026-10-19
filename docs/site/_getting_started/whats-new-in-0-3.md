---
layout: default
title: "What Is New in 0.3"
nav_order: 4
description: "End a Surface explicitly while preserving action replay and protecting unfinished delivery."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Close a finished view without repeating its business actions.
* Abandon pending follow-up explicitly.
* Upgrade persisted data before using lifecycle APIs.

## End a View from the Host

```ruby
RailsToolViews.close(surface.id, scope: scope,
  retain_until: 30.days.from_now)
```

The [lifecycle guide]({% link _advanced/lifecycle.md %}) describes host policies, first-termination deadlines and readable closed state. New actions stop; exact committed requests keep their receipts. Use `abandon` only when the host intends to stop pending or failed follow-up.

## Preserve Delivery Boundaries

Closure and delivery claims coordinate through the Surface lock. Provider callbacks remain outside transactions. An expired lease does not imply that a callback stopped; a durable uncertainty guard protects reclaimed or ambiguous old delivery histories from lifecycle cleanup.

## Upgrade First

This release adds a migration and lifecycle snapshot fields. Stop old workers, install missing engine migrations and restart only the new runtime. See [Upgrading]({% link _reference/upgrading.md %}) for rollback limits. The public gem remains 0.2.0 until a separately authorized release.
