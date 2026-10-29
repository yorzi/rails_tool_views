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
* Share one runtime with other gems in the same process.

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

Your filters then run inside the Engine's controller, where route helpers without a receiver resolve against the Engine's routes. A filter that redirects, such as a sign-in check, calls your routes through `main_app`:

```ruby
def request_authentication
  redirect_to main_app.new_session_path
end
```

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
| `retention_policy` | `nil` | Authorize `purge_closed`; unset denies |
| `reconciliation_policy` | `nil` | Authorize `reconcile_delivery`; unset denies |

Use `RailsToolViews.reset_registry!` in a reload hook to clear definitions while retaining configuration. `RailsToolViews.reset!` clears both and belongs in isolated tests.

## Share One Runtime

An admin engine or another gem in your application may present Surfaces too. It shares your runtime: there is one configuration, one registry and one mount per process.

```ruby
RailsToolViews.configure { |config| config.scope_resolver = host_resolver }
RailsToolViews.configure { |config| config.scope_resolver = admin_resolver }
RailsToolViews.configuration.scope_resolver # => admin_resolver, for every request
```

The last assignment wins for every Surface, so a second resolver or adapter changes who is authorized and how follow-ups are delivered for your own components too. Action forms always post to the mount named `:rails_tool_views`, whichever code renders them.

Keep `RailsToolViews.configure` in the host application. A gem that registers components should use its own key prefix, such as `admin_`, and document the scope, policies and adapter it expects from the host. Separate configurations or registries in one process are not supported.

## Next Steps

* [Production Boundaries]({% link _advanced/production.md %}) covers host responsibilities.
* [Agent Continuation]({% link _advanced/continuation.md %}) configures deferred delivery.

## Authorize Retention and Reconciliation

`config.retention_policy` defaults to `nil`, which disables payload cleanup. Set a callable that returns exactly `true` for authorized `:purge` access. See [Surface Lifecycle]({% link _advanced/lifecycle.md %}) for deadlines, dry runs and tombstone retention.

`config.reconciliation_policy` also defaults to `nil`, which disables `reconcile_delivery`. Set a callable that returns exactly `true` for authorized `:reconcile` access. It is separate from `retention_policy`, so an existing cleanup policy never gains this authority. See [Reconcile an Uncertain Delivery]({% link _advanced/lifecycle.md %}#reconcile-an-uncertain-delivery).
