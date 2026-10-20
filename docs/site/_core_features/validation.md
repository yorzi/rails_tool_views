---
layout: default
title: "Validation and Errors"
nav_order: 4
description: "Return useful field feedback without committing a rejected action."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Return field errors and safe retained values.
* Translate host and Engine errors.

## Reject Invalid Form Values

Inside an action handler, raise `RailsToolViews::ValidationError.new(fields: { email: "must be a valid email address" }, values: access.arguments.slice("email"))` when host validation fails. Return only approved values, not full records or exception contents.

The action transaction rolls back. JSON receives HTTP 422 with `VALIDATION_FAILED`, `fields`, and `values`. Authorized HTML/Turbo rendering passes the error to your component. Label its inputs, connect field feedback with accessible descriptions, and escape retained values.

## Correct a Form without Turbo

A rejected HTML request returns a complete page with a title, viewport and main heading. If the current scope can still restore the Surface, the page renders your component with the error and a **Reload saved view** link. Your Partial controls the retained fields and their accessible descriptions. Follow the same approved-values rule as for Turbo.

Correct the fields and submit again. A successful request redirects to the embedding page when it is safe to read; after a correction on an Engine action page, it redirects to the saved Surface. Refresh reads saved state. Reloading the saved view discards unsaved corrections.

HTTP status codes remain unchanged: validation returns 422, conflicts return 409, missing Surfaces return 404, and missing identity or CSRF protection returns 403. An unauthorized Surface does not render props or a correction form. JSON and Turbo responses retain their existing formats.

Direct HTML reads of a Surface also use the complete page. Embedded `rails_tool_views_surface` rendering still returns a fragment. The Engine uses its own layout, so it does not require instance variables from your embedding controller. To customize it, override `app/views/layouts/rails_tool_views/application.html.erb`; preserve the document title, language, viewport, CSRF tags and main landmark. The page content lives at `app/views/rails_tool_views/surfaces/page.html.erb`.

## Give Errors Useful Wording

```ruby
# docs-example: error
error = RailsToolViews::Error.new("OUT_OF_STOCK", status: 422, message: "Only two left.")
error.message
# => "Only two left."
```

Translate error codes under `rails_tool_views.errors.<downcased_code>`. Engine status copy uses `rails_tool_views.surface.<key>`, and a Surface's accessible name uses `rails_tool_views.components.<key>`.

Renderer failures show `RENDER_FAILED` without deleting state and are reported through Rails error reporting. A deliberate `RailsToolViews::Error` from a renderer is shown as that error. A changed component contract yields `INCOMPATIBLE_COMPONENT`; do not bypass it by silently rewriting props.

## Next Steps

* [Production Boundaries]({% link _advanced/production.md %}) covers logs and privacy.
* [API Reference]({% link _reference/api-reference.md %}) lists error classes.

* [Status and Temporary Feedback]({% link _core_features/feedback.md %}) separates action acknowledgments from saved state.
