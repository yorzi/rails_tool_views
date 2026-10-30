---
layout: default
title: "Upgrading"
nav_order: 2
description: "Upgrade from 0.4 to 1.0 without a migration or a change to saved data."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Install 1.0 and keep saved data.
* Update RubyLLM before the 1.0.1 adapter loads.
* Update code that rescued raw registration or identifier exceptions.
* Configure every delivery worker with its adapter.
* Resolve uncertain deliveries and page through cleanup.
* Keep focus, styling and supported versions in view.

## Install 1.0

```ruby
# Gemfile
gem "rails_tool_views", "~> 1.0"
```

```sh
bundle update rails_tool_views
```

There is no new migration or runtime dependency. Existing Surfaces, action receipts, presentation correlations, component digests and delivery keys remain valid. The upgrade check saves data with every published release from 0.1.0 through 1.0.1 and replays it with {{ site.version }}.

Hosts on 0.3 or earlier first follow the [0.4 upgrade guide](https://github.com/yorzi/rails_tool_views/blob/v0.4.0/docs/site/_reference/upgrading.md). It covers draining old workers and delivering after commit.

## Update RubyLLM for 1.0.1

On RubyLLM 1.x the adapter loaded, but every `present_ui` call was refused: 1.x advertises the tool under a class-derived name and never passes the `ToolCall` to `execute`. From 1.0.1, `require "rails_tool_views/adapters/ruby_llm"` raises `Gem::LoadError` unless the bundle has RubyLLM {{ site.requirements.ruby_llm }}. Update both gems together:

```sh
bundle update ruby_llm rails_tool_views
```

Hosts that do not load the adapter, and hosts already on RubyLLM 2, need no change.

## Handle Stable Error Codes

A malformed registration used to raise `NoMethodError`, `KeyError` or `RegexpError`. It now raises `RailsToolViews::Error` during boot: `INVALID_SCHEMA` for an invalid `pattern`, `INVALID_ACTION` for an action definition that is not a Hash or lacks `schema:`, and `INVALID_COMPONENT` for a non-array `expose_to`. Correct registrations behave as before.

An identifier with invalid UTF-8 now raises its own code, such as `INVALID_SCOPE`, instead of `ArgumentError`. `Scope#actor` and `Scope#tenant` return UTF-8 Strings, so a binary-encoded identifier matches its stored row. Values stored in props and state are plain Strings in memory, as they already were after a reload. If your code rescued the old exception classes, rescue `RailsToolViews::Error` and check `code`.

## Configure Every Delivery Worker

`deliver` used to mark pending or failed work `skipped` when no adapter was passed or configured, which ended that follow-up for good. It now raises `AGENT_NOT_CONFIGURED` with HTTP 503 and changes nothing. Make sure every process that delivers loads the same adapter configuration as your web processes. If you relied on the old skip to drop follow-up, call `RailsToolViews.abandon` instead. Dispatch without a configured adapter still records `skipped`.

## Resolve Uncertain Deliveries

Views whose delivery became uncertain after a lease takeover, including rows the 0.3 migration marked conservatively, could never be closed or cleaned up. Check each one against your durable deduplication record, configure `reconciliation_policy`, then call `reconcile_delivery` as [Surface Lifecycle]({% link _advanced/lifecycle.md %}#reconcile-an-uncertain-delivery) shows. Until you do, they stay protected exactly as before.

## Page Through Cleanup

`purge_closed` accepts `after:` and its summary adds `next_after`. Code that compares the whole summary must accept the new key. Replace repeated full batches with the sweep loop in [Surface Lifecycle]({% link _advanced/lifecycle.md %}#sweep-every-batch), so protected views no longer stop newer views from being cleaned.

## Check the Browser

Focus now moves to a Surface's status only after a Turbo replacement. If a test expected focus on the status after a full page load, update it. If you override `app/views/layouts/rails_tool_views/application.html.erb`, keep `nonce: content_security_policy_nonce` on its stylesheet.

## Review the Contract

Read the [Public Contract]({% link _reference/public-contract.md %}) before relying on a name. The RubyLLM adapter is experimental and may change in a minor release. MySQL is outside the supported matrix; stay on a supported database or run your own migration and concurrency checks.
