---
layout: default
title: "Upgrading"
nav_order: 2
description: "Upgrade from 0.4 to the 1.0 candidate without a migration or a change to saved data."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Install the candidate and keep saved data.
* Update code that rescued raw registration or identifier exceptions.
* Keep focus, styling and supported versions in view.

## Install the Candidate

```ruby
# Gemfile
gem "rails_tool_views", "1.0.0.rc1"
```

```sh
bundle update rails_tool_views
```

A release candidate installs only by exact version. There is no new migration or runtime dependency. Existing Surfaces, action receipts, presentation correlations, component digests and delivery keys remain valid. The upgrade check saves data with every published release from 0.1.0 through 0.4.0 and replays it with {{ site.version }}.

Hosts on 0.3 or earlier first follow the [0.4 upgrade guide](https://github.com/yorzi/rails_tool_views/blob/v0.4.0/docs/site/_reference/upgrading.md). It covers draining old workers and delivering after commit.

## Handle Stable Error Codes

A malformed registration used to raise `NoMethodError`, `KeyError` or `RegexpError`. It now raises `RailsToolViews::Error` during boot: `INVALID_SCHEMA` for an invalid `pattern`, `INVALID_ACTION` for an action definition that is not a Hash or lacks `schema:`, and `INVALID_COMPONENT` for a non-array `expose_to`. Correct registrations behave as before.

An identifier with invalid UTF-8 now raises its own code, such as `INVALID_SCOPE`, instead of `ArgumentError`. `Scope#actor` and `Scope#tenant` return UTF-8 Strings, so a binary-encoded identifier matches its stored row. Values stored in props and state are plain Strings in memory, as they already were after a reload. If your code rescued the old exception classes, rescue `RailsToolViews::Error` and check `code`.

## Check the Browser

Focus now moves to a Surface's status only after a Turbo replacement. If a test expected focus on the status after a full page load, update it. If you override `app/views/layouts/rails_tool_views/application.html.erb`, keep `nonce: content_security_policy_nonce` on its stylesheet.

## Review the Contract

Read the [Public Contract]({% link _reference/public-contract.md %}) before relying on a name. The RubyLLM adapter is experimental and may change in a minor release. MySQL is outside the supported matrix; stay on a supported database or run your own migration and concurrency checks.
