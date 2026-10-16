---
layout: default
title: "Configuration"
nav_order: 3
description: "Resolve host identity and configure runtime limits and agent delivery."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Configure authenticated actor and tenant resolution.
* Choose controller inheritance and delivery behavior.
* Find the default runtime limits.

## Resolve Identity in the Host

```ruby
RailsToolViews.configure do |config|
  config.scope_resolver = ->(controller) {
    user = controller.current_user
    account = controller.current_account
    user && account && RailsToolViews::Scope.new(
      actor: user.id.to_s, tenant: account.id.to_s
    )
  }
end
```

`current_user` and `current_account` belong to your host authentication layer. Return no scope when authentication is absent; the Engine denies access. Never select actor or tenant from submitted arguments.

Engine controllers inherit `ApplicationController`. Set `parent_controller` to your authenticated controller class name if required. It must inherit from `ActionController::Base`.

## Bound Requests and Delivery

Limits bound payloads, nesting, catalogs, and accepted action throughput. They do not replace host rate limiting or a provider budget. Configuration is process-local, so configure every application process consistently.

| Setting | Default | Purpose |
| --- | --- | --- |
| `scope_resolver` | `nil` | Resolve authenticated host scope |
| `parent_controller` | `"::ApplicationController"` | Preserve host controller filters |
| `max_payload_bytes` | 32768 | Bound serialized data |
| `max_depth` | 16 | Bound nested values |
| `max_catalog_components` | 20 | Bound an exposed component catalog |
| `max_actions_per_minute` | 60 | Bound committed actions per Surface |
| `agent_adapter` | `nil` | Host continuation callback |
| `auto_deliver` | `true` | Controller attempts continuation after commit |
| `delivery_lease` | 300 | Seconds before an unfinished delivery can be reclaimed |

Use `RailsToolViews.reset_registry!` in a reload hook to clear definitions while retaining configuration. `RailsToolViews.reset!` clears both and belongs in isolated tests.

## Next Steps

* [Production Boundaries]({% link _advanced/production.md %}) covers host responsibilities.
* [Agent Continuation]({% link _advanced/continuation.md %}) configures deferred delivery.
