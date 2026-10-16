---
layout: home
title: RailsToolViews
description: Register trusted Rails components, persist UI state, and authorize user actions with optional AI adapters.
permalink: /
hero:
  name: RailsToolViews
  text: Existing views.
    Durable interactions.
  tagline: Turn trusted Rails components into persistent, interactive tools. Start without AI and add an adapter when you need one.
  actions:
    - theme: brand
      text: Build your first view
      link: /getting-started/
    - theme: alt
      text: Explore the API
      link: /api-reference/
features:
  - title: Keep your components
    details: Register an existing Partial or ViewComponent with a closed schema and explicit policies.
    link: /components/
    link_text: Register a component
  - title: Restore the interaction
    details: Save UI state, validate revisions, and replay an action without repeating its business write.
    link: /actions/
    link_text: Handle an action
  - title: Add AI deliberately
    details: Expose an approved catalog through RubyLLM while keeping business authority in your Rails host.
    link: /ruby-llm/
    link_text: Connect an adapter
---

## Start in Your Rails App

Current candidate: **{{ site.version }}**, unreleased. Repository access is required while development remains private.

```sh
{% if site.docs_unreleased %}bundle add rails_tool_views --git https://github.com/yorzi/rails_tool_views --branch main{% else %}bundle add rails_tool_views --version {{ site.version }}{% endif %}
```

## Present Once, Restore Later

After you register the tutorial ChoiceCard:

```ruby
scope = RailsToolViews::Scope.new(actor: "alice", tenant: "demo")
surface = RailsToolViews.present(:choice_card, props: { title: "Next step" }, scope: scope)
RailsToolViews.restore(surface.id, scope: scope)
```

[Build the complete example]({% link _getting_started/getting-started.md %}) or [understand the state boundary]({% link _getting_started/overview.md %}).
