---
layout: default
title: "Upgrading"
nav_order: 2
description: "Upgrade a RailsToolViews host from 0.1 to 0.2 without migrating saved data."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Update the gem without rerunning the installer.
* Review full-page HTML responses and host overrides.
* Add generated components without changing existing registrations.

## Update the Gem

Update the version requirement in your Gemfile, then run `bundle update rails_tool_views`:

```ruby
gem "rails_tool_views", "~> {{ site.version }}"
```

This release adds no database migration or runtime dependency. Do not rerun `rails_tool_views:install` on an existing host. Saved Surface IDs, revisions, component contracts and replay receipts remain unchanged. Keep host component definitions unchanged when verifying old saved Surfaces.

If you still use an unpublished candidate with the old `ToolViews` identity, first follow the [0.1 upgrade guide](https://github.com/yorzi/rails_tool_views/blob/v0.1.0/docs/site/_reference/upgrading.md). Its table and delivery-key migration does not apply to a host already on public 0.1.0.

## Review HTML Responses

Direct Engine HTML reads and rejected HTML actions now return a full document. The Engine supplies a language, title, viewport, CSRF tags and main landmark. If your code fetched a direct Surface URL as an HTML fragment, use the embedded `rails_tool_views_surface` helper in a host view instead.

Embedded helpers still return fragments. JSON and Turbo response formats, HTTP error statuses, scope policies, revisions and replay protection retain their existing behavior.

Without Turbo, an authorized error page retains the component and approved validation values. Correct and submit the form again. After a correction, a POST-only Engine referrer redirects to the readable saved Surface. The **Reload saved view** link discards unsaved corrections. Unavailable identity does not expose component data or a correction form.

Review any host overrides at:

```text
app/views/layouts/rails_tool_views/application.html.erb
app/views/rails_tool_views/surfaces/page.html.erb
```

The Engine layout does not depend on instance variables or assets from the embedding controller. Preserve its document structure and CSRF tags when overriding it. Test successful, invalid, stale and denied requests with JavaScript disabled. See [Validation and Errors]({% link _core_features/validation.md %}).

## Add a Generated Component

Existing manual registrations need no changes. The optional [Partial generator]({% link _core_features/component-generator.md %}) creates three files and denies both presentation and actions until you configure host policies.

Load its registration files in your existing shared `to_prepare` block after one `reset_registry!`. Do not reset for each file, since the next definition would remove earlier components. The generator refuses conflicting destinations, including `--force`; resolve them before retrying.

## Verify the Host

Restore an existing Surface, submit an action and replay its original request. Check that a different actor or tenant cannot read or act on it. For a form, test an invalid submission, correct the fields, and refresh after success. Your host owns business validation, trusted allowed values and field descriptions.

Read [What Is New]({% link _getting_started/whats-new-in-0-2.md %}) for the new workflow and [Production Boundaries]({% link _advanced/production.md %}) for the unchanged operational responsibilities.
