---
layout: default
title: "How It Works"
nav_order: 2
description: "Understand the registry, persisted UI, and host-owned business actions."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Choose the correct entry point for each operation.
* Keep UI state separate from business records and agent messages.

## Start with a Trusted Component

`RailsToolViews.register` connects an explicit key to one existing Partial or ViewComponent, a closed props schema, and policies. The registry never resolves a renderer selected by a model. A component's version and contract digest describe what its saved props mean.

## Persist the UI

`RailsToolViews.present` validates props and authorizes presentation before saving a `Surface`. `RailsToolViews.restore` checks actor, tenant, component compatibility, and current read policy. `RailsToolViews.render` rechecks access before rendering the trusted view.

A Surface holds presentation props, UI state, revision, and an optional opaque context reference. Your customer, ticket, artifact, and approval records stay in the host application. The Surface does not become an alternate business database.

## Commit an Action

`RailsToolViews.dispatch` restores the Surface, validates the action, checks its policy, and executes the handler inside a transaction. The handler returns a `Transition`. A committed action advances the revision and records a durable replay receipt. JSON and Turbo describe the same committed state.

If a Transition requests an agent, `RailsToolViews.deliver` can call the host adapter after commit. Agent failure does not undo the completed business action. The optional RubyLLM adapter does not give models direct business authority.

## End a View Explicitly

Use [Surface Lifecycle]({% link _advanced/lifecycle.md %}) to distinguish active, closed and abandoned views. An action result or an agent status does not decide when host work is finished.

## Next Steps

* [Registering Components]({% link _core_features/components.md %}) defines the view contract.
* [Presenting and Restoring Surfaces]({% link _core_features/surfaces.md %}) manages persisted UI.
* [Agent Continuation]({% link _advanced/continuation.md %}) separates commit from follow-up.
