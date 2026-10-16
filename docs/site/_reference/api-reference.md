---
layout: default
title: "API Reference"
nav_order: 1
description: "Find the Ruby entry points for registration, UI state, actions, and optional adapters."
guide: false
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

Open the generated [RailsToolViews API]({{ '/api/' | relative_url }}) for signatures and source comments. The [Markdown class index]({{ '/api/index.md' | relative_url }}) provides the same reference for text tools.

The module-level methods orchestrate registration, persistence, actions, and delivery. Value objects carry authorized context and handler results. The optional adapter is loaded explicitly.

| Task | Reference |
| --- | --- |
| Register, present, restore, dispatch, deliver | [RailsToolViews]({{ '/api/RailsToolViews.html' | relative_url }}) |
| Resolve identity | [Scope]({{ '/api/RailsToolViews/Scope.html' | relative_url }}) |
| Configure limits | [Configuration]({{ '/api/RailsToolViews/Configuration.html' | relative_url }}) |
| Return field feedback | [ValidationError]({{ '/api/RailsToolViews/ValidationError.html' | relative_url }}) |
| Define a component contract | [Component]({{ '/api/RailsToolViews/Component.html' | relative_url }}) |
| Present through RubyLLM | [PresentUI]({{ '/api/RailsToolViews/Adapters/RubyLLM/PresentUI.html' | relative_url }}) |

RDoc is generated from source. Do not edit its output. For the supported usage contract, start with [Getting Started]({% link _getting_started/getting-started.md %}) and the feature guides.
