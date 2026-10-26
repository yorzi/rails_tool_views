---
layout: default
title: "RubyLLM Integration"
nav_order: 1
description: "Expose an approved component catalog through an optional RubyLLM tool."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Load the adapter explicitly.
* Bound the catalog and correlate real tool calls.

## Load Only When Needed

Add `ruby_llm` {{ site.requirements.ruby_llm }} to the host Gemfile, then load the adapter explicitly:

```ruby
require "rails_tool_views/adapters/ruby_llm"
```

The require raises `Gem::LoadError` when the bundle has no RubyLLM or only RubyLLM 1.x. The tool depends on RubyLLM 2.0 passing the real `ToolCall` to it, so on 1.x every call would be refused.

The core does not require RubyLLM or a provider. The adapter is [experimental]({% link _reference/public-contract.md %}#experimental-parts): it has offline coverage against RubyLLM {{ site.requirements.ruby_llm_tested }}, including a real chat loop, but no live provider has been exercised end to end, and it may change in a minor release. Configure provider credentials through the host's RubyLLM setup, not through RailsToolViews.

## Build the Approved Tool

After registering the tutorial component with `expose_to: [:agent]` and creating its authorized `scope`:

```ruby
# docs-example: tool
present_ui = RailsToolViews::Adapters::RubyLLM::PresentUI.new(
  keys: [:choice_card], scope: scope, context: "conversation:demo")
```

Pass this instance to the host chat's RubyLLM tool registration. Keep `keys`, scope, and context server-owned. The catalog applies discovery policy and exposes bounded schemas. Execution validates the exact selected component and current digest again.

The adapter requires a real `RubyLLM::ToolCall` with the correct tool name. Do not invent correlation IDs in model output. Durable presentation receipts deduplicate tool retries. `references` is request-local browser reference collection, separate from the acknowledgment returned to the model.

## Next Steps

* [Agent Continuation]({% link _advanced/continuation.md %}) resumes after user input.
* [Registering Components]({% link _core_features/components.md %}) explains discovery policies.
