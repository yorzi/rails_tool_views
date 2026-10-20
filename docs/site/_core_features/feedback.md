---
layout: default
title: "Status and Temporary Feedback"
nav_order: 5
description: "Separate persistent UI state from temporary action notices and validation errors."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Return a notice without adding it to Surface state.
* Display the same feedback through JSON, Turbo and HTML.
* Preserve persistent messages and deterministic action replay.

## Return a Temporary Notice

```ruby
# docs-example: notice
transition = RailsToolViews::Transition.new(
  state: { selected: "compare" }, notice: "Selection saved.")
transition.notice
# => "Selection saved."
```

Return this `Transition` from a registered action handler. `state` becomes the saved UI state. `notice` is optional plain text, limited to 500 bytes, and belongs to the action response. It does not become part of Surface state or its GET snapshot. HTML escapes it, including a string marked HTML-safe by the host.

Use a notice for an acknowledgment such as "Selection saved." Put facts needed on reload in `state`, or read them from the host's business records. Continue using [ValidationError]({% link _core_features/validation.md %}) for rejected fields; a notice does not replace validation or error handling.

## Use Each Transport

The mounted controller includes `notice` in a successful JSON response when supplied. Turbo displays it in the Surface's existing live status region and focuses that status after replacement. A refreshed Surface renders its saved state without the notice.

A normal HTML form redirects as before. Rails flash carries the notice to the next request, bound to the exact Surface, actor and tenant. The `rails_tool_views_surface` helper consumes only a matching notice. The host needs standard Rails session/flash middleware and must use the helper on an embedding page. No notice is added to the URL.

For direct Ruby dispatch, pass the response notice explicitly when you render:

```erb
<%= rails_tool_views_surface(surface, scope: scope,
  notice: result[:notice]) %>
```

You can pass the same `notice:` to `RailsToolViews.render`. A later render without that argument shows the normal saved status. Do not manually pass an old notice on every page load.

## Keep Existing Messages

A response notice takes precedence over `state["message"]` in the status region. On refresh, an existing string message still displays. Without either, the Engine uses its translated ready/saved wording. Existing components and persisted messages need no migration.

The action receipt stores the notice with the committed response. An exact authorized retry returns that same notice without repeating the handler. Temporary describes display lifetime, not storage erasure: do not put secrets in a notice. Engine receipt logs are redacted, and notifications exclude notice text. Lifecycle retention covers these receipt payloads.

## Verify the Host Flow

In the local demo, choose **Try temporary feedback**, save a selection and refresh. The acknowledgment disappears while the checked option remains. Both Turbo and JavaScript-disabled browser tests cover this flow. The other choice demos keep the earlier persistent-message behavior for comparison.

## Next Steps

* [Actions and Forms]({% link _core_features/actions.md %}) explains receipts and transactions.
* [Validation and Errors]({% link _core_features/validation.md %}) explains rejected input.
* [Operational Diagnostics]({% link _advanced/diagnostics.md %}) distinguishes replay from execution.
