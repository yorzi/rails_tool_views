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

## Give Errors Useful Wording

```ruby
# docs-example: error
error = RailsToolViews::Error.new("OUT_OF_STOCK", status: 422, message: "Only two left.")
error.message
# => "Only two left."
```

Translate error codes under `tool_views.errors.<downcased_code>`. Engine status copy uses `tool_views.surface.<key>`, and a Surface's accessible name uses `tool_views.components.<key>`. The old translation namespace stays stable after the rename.

Renderer failures show `RENDER_FAILED` without deleting state and are reported through Rails error reporting. A deliberate `RailsToolViews::Error` from a renderer is shown as that error. A changed component contract yields `INCOMPATIBLE_COMPONENT`; do not bypass it by silently rewriting props.

## Next Steps

* [Production Boundaries]({% link _advanced/production.md %}) covers logs and privacy.
* [API Reference]({% link _reference/api-reference.md %}) lists error classes.
