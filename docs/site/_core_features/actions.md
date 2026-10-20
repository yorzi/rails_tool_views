---
layout: default
title: "Actions and Forms"
nav_order: 3
description: "Handle user actions with explicit permissions, revision checks, and durable replay."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Build a form for a registered action.
* Dispatch with revision and idempotency checks.
* Keep business writes atomic with UI state.

## Build the Form

`rails_tool_views_action_form(surface, :select_option)` yields a Rails form builder and includes the routing fields. Use it as shown in [Getting Started]({% link _getting_started/getting-started.md %}#add-the-existing-view). For fixed arguments, use `rails_tool_views_action_button`; for your own form, include `rails_tool_views_action_fields`.

Both action helpers require a registered action. The action name, revision, and source fields are still untrusted inputs: the server checks them again. Keep CSRF protection enabled for browser requests.

## Dispatch from Ruby

After the tutorial creates `surface` and `scope`, run:

```ruby
# docs-example: dispatch
result = RailsToolViews.dispatch(surface.id,
  scope: scope, action: "select_option", arguments: { key: "compare" },
  base_revision: 1, idempotency_key: "tutorial-selection-1")
result.fetch(:revision)
# => 2
```

Reuse the same idempotency key and original arguments/revision to retry the same request. The saved receipt returns without repeating the handler. Reusing a key for changed input rejects. A new action uses the latest revision and a new key; stale revisions return `CONFLICT`.

## Commit Business Writes

An action handler returns `RailsToolViews::Transition.new(state: {...})`. Put host database writes in that handler and use the same database transaction as Surface for atomicity. Authorization must check the current business record, not just presentation props.

For external delivery, commit a host outbox record and deliver it separately with host idempotency. A database transaction cannot roll back an email, payment, or remote API request. `agent: true` requests a follow-up interaction after the action commits.

HTML form success redirects back to the embedding page when possible. JSON and Turbo use the same action transaction. Without Turbo, a rejected action renders a complete page with an authorized correction path.

## Next Steps

* [Validation and Errors]({% link _core_features/validation.md %}) rejects invalid form values.
* [Agent Continuation]({% link _advanced/continuation.md %}) handles follow-up failures.

* [Status and Temporary Feedback]({% link _core_features/feedback.md %}) keeps notices separate from saved state.
