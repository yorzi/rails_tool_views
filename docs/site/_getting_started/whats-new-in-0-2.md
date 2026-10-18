---
layout: default
title: "What Is New in 0.2"
nav_order: 4
description: "Generate safe Partial components and correct forms on complete HTML pages without Turbo."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Start a Partial with denied policies and closed schemas.
* Correct a rejected action without JavaScript.
* Find the installation and upgrade steps.

## Generate a Partial

```sh
bin/rails generate rails_tool_views:component review_card
```

The [component generator]({% link _core_features/component-generator.md %}) creates a registration, Partial and Minitest scaffold. It refuses conflicting files and paths that escape your application. Configure both denied policies with trusted host authorization, then load the definition in your shared Rails reload block. Existing manual registrations keep working.

## Correct a Form without Turbo

An HTML error returns a complete document with a title, main heading and the authorized component. Correct the retained fields and submit again. The successful redirect avoids POST-only Engine routes. A reload link reads the saved view without keeping unsaved corrections. Missing identity or unavailable Surfaces do not expose component data.

Read [Validation and Errors]({% link _core_features/validation.md %}#correct-a-form-without-turbo) for status codes and layout overrides. Embedded helpers and JSON/Turbo responses keep their existing formats.

## Verify the Integration

The development suite uses real Chrome for Partial/ViewComponent persistence and mobile form correction, including a browser with JavaScript disabled. An isolated temporary Rails host tests the installed gem, generated scaffold and saved actions. These checks do not claim external adoption or live-provider coverage.

## Upgrade

Version {{ site.version }} requires no database migration or new runtime dependency. Follow [Upgrading]({% link _reference/upgrading.md %}) if you override Engine HTML templates. {% if site.docs_unreleased %}This version is under development; use stable documentation for the published gem.{% endif %}
