---
layout: default
title: "Presenting and Restoring Surfaces"
nav_order: 2
description: "Render a persistent UI and restore it with fresh authorization."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Distinguish presenting from restoring.
* Keep Surface identifiers and context references in host state.

## Present Once, Restore Later

Use the [Getting Started lifecycle example]({% link _getting_started/getting-started.md %}#present-and-restore). `present` returns a persisted `Surface`. Save its ID in your authorized host context, then call `restore` on reload. Each new uncorrelated `present` call creates a new Surface.

`context:` is an optional opaque string reference. It is useful for associating a presentation with a host conversation or workflow, but is not authorization. Always resolve that reference through host access checks.

## Render in the Host

```erb
<%= rails_tool_views_surface(surface, scope: scope) %>
```

The helper renders the current authorized Surface. You can also call `RailsToolViews.render(surface, view_context: view_context, scope: scope)`. A previously loaded ActiveRecord object does not bypass restore or read policy.

A Surface exposes its `props`, `state`, `revision`, and `snapshot`. Treat the snapshot as UI data, not as a permission grant. Engine tables use the `rails_tool_views_` prefix.

## Correlate Tool Retries

A server-owned `correlation:` has exactly `adapter:`, `call_id:`, and `context:`. Repeating the same presentation with the same scope and input returns the prior Surface. Reusing correlation with changed input rejects with `IDEMPOTENCY_CONFLICT`. The RubyLLM adapter supplies this correlation from a real ToolCall.

## Close a Finished View

Use [Surface Lifecycle]({% link _advanced/lifecycle.md %}) to stop new actions while keeping authorized reads and committed request replay. Closing is an explicit host decision, independent of business or delivery status.

## Next Steps

* [Actions and Forms]({% link _core_features/actions.md %}) changes state safely.
* [Upgrading]({% link _reference/upgrading.md %}) preserves old saved Surfaces.
