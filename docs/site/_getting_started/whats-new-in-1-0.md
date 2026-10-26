---
layout: default
title: "What Is New in 1.0"
nav_order: 5
description: "Build on a frozen public contract with clearer registration errors and safer browser feedback."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Find the names 1.0 keeps stable.
* Recognize registration and identifier errors by their stable codes.
* Keep focus and styling correct in the browser.

## Rely on a Frozen Contract

```ruby
gem "rails_tool_views", "~> 1.0"
```

1.0 freezes the [Public Contract]({% link _reference/public-contract.md %}): the Ruby API, error codes and statuses, helpers, HTTP fields, browser identifiers, events, delivery keys and saved data. From 1.0.0, only a major release removes or changes a listed name.

The RubyLLM adapter is experimental and may change in a minor release. MySQL is outside the supported matrix. SQLite and PostgreSQL remain supported on Ruby 3.3 and 4.0 with Rails 7.2 and 8.1.

## Read Stable Registration Errors

A malformed registration now raises `RailsToolViews::Error` during boot instead of a raw Ruby exception. An invalid schema `pattern` raises `INVALID_SCHEMA`. An action definition that is not a Hash, or lacks `schema:`, raises `INVALID_ACTION`. A non-array `expose_to` raises `INVALID_COMPONENT`. See [Components]({% link _core_features/components.md %}).

An identifier with invalid UTF-8 raises its own code, such as `INVALID_SCOPE`. A digest no longer rejects props or arguments that passed validation close to the size or depth limit.

## Keep Follow-up Work Safe

A delivery call without an adapter now raises `AGENT_NOT_CONFIGURED` and keeps the interaction for a configured worker, instead of marking committed work skipped. See [Agent Continuation]({% link _advanced/continuation.md %}#deliver-explicitly).

## Reconcile Uncertain Deliveries

`RailsToolViews.reconcile_delivery(id, scope:, outcome: :completed)` records the outcome your deduplication record shows for a delivery whose lease was taken over. Its uncertainty clears, so the view can close and be cleaned up. A default-deny `reconciliation_policy` authorizes it, and a running delivery is never overridden. See [Surface Lifecycle]({% link _advanced/lifecycle.md %}#reconcile-an-uncertain-delivery).

## Clean Up Past Protected Views

`purge_closed` returns a `next_after` cursor. Pass it back as `after:` to page past views your policy protects, so a hold on old views no longer blocks newer ones. See [Surface Lifecycle]({% link _advanced/lifecycle.md %}#sweep-every-batch).

## Keep Browser Feedback Accessible

Focus moves to a Surface's status only after a Turbo replacement. A page load or refresh keeps the reader's place. The Engine's complete HTML page carries your Content Security Policy nonce on its stylesheet. See [Status and Temporary Feedback]({% link _core_features/feedback.md %}) and [Validation and Errors]({% link _core_features/validation.md %}).

## Upgrade

There is no migration or runtime dependency. Data saved by every release from 0.1.0 through 0.4.0 upgrades unchanged. Read [Upgrading]({% link _reference/upgrading.md %}) before you switch.
