# Ecosystem validation and Phase 0 spike plan

**Evidence date:** 2026-10-10. **Status:** Pinned, source-level findings recorded in [05_UPSTREAM_SOURCE_GAP_ANALYSIS.md](05_UPSTREAM_SOURCE_GAP_ANALYSIS.md); no local install/benchmark/browser/security reproduction or user interview yet. Source facts are distinguished from risks and not-run claims.

## Upstream references
1. RubyLLM repo https://github.com/crmne/ruby_llm — tool API, callbacks, Rails integration and structured output; check tagged version and API compatibility at spike time.
2. generative_ui https://github.com/kryzhovnik/generative_ui — Catalog/ComponentTreeValidator/Rails Partial and ViewComponent renderers; current lib/generative_ui/tool.rb subclasses RubyLLM::Tool and requires ruby_llm.
3. A2UI Rails https://github.com/vicentereig/a2ui-rails — typed Component Union, DSPy Signature/Module generator, in-memory Surface and Stimulus/Turbo action reference; not a generic Rails business action dispatcher. Pin `d409b71670febabc46d64694461ec1adddd5996f`.
4. A2UI https://github.com/a2ui-project/a2ui — open agent-to-UI declarative protocol; confirm canonical spec before interoperating.
5. AG-UI https://github.com/ag-ui-protocol/ag-ui — agent/frontend event transport, not a replacement for Rails state/actions.
6. MCP Apps https://modelcontextprotocol.io/extensions/apps/overview — tool-attached UI resources with sandboxed host integration; not equivalent to rendering a Rails Partial in arbitrary MCP clients.
7. Hotwire https://turbo.hotwired.dev/ and Rails https://guides.rubyonrails.org/ — native server-driven interaction.

## Verification questions (must reproduce in fresh clone, record versions)
SP-01: Can registry + rendering work with RubyLLM entirely absent (Gemfile excludes dependency)?
SP-02: Does generative_ui provide a public independent catalog/renderer API that can be reused without its Tool class eager-loading RubyLLM? Inspect require graph and tests.
SP-03: Does a minimal RubyLLM Tool send schema-correct present_ui and preserve response history + tool correlation? Test actual supported version using mocks, then one real provider.
SP-04: In a Rails Engine, can the same existing Partial and ViewComponent be rendered safely in both chat and normal page after refresh?
SP-05: Can selected form POST → authorized Action → Turbo replace → optional agent continuation work with CSRF, ordering and duplicate attempts?
SP-06: Can you prove 1, 5, 20 declared component schemas have acceptable token/call behavior for individual tools vs one bounded present_ui?
SP-07: Does an upstream PR to generative_ui solve the exact missing primitive at lower maintenance cost? Contact author before duplicating.
SP-08: Validate dependency licenses and public gem/Rails compatibility matrix, naming conflicts and chosen license.

## Source-derived regression probes (NOT_TESTED)
SP-09..12 in [05_UPSTREAM_SOURCE_GAP_ANALYSIS.md](05_UPSTREAM_SOURCE_GAP_ANALYSIS.md) add: GenerativeUI eager require graph and framework-free load; clean gem packaging and renderer coverage; A2UI Rails two-user/ActionCable/stream target/client-policy/action-format tests; measurable upstream-vs-bridge-vs-independent decision. These are required before Gate V, not evidence of confirmed upstream exploits.

## Decision score and evidence log
For each SP: record date, repository+tag/SHA, environment, command, fixture, expected, actual, conclusion, issue/PR if any. Outcome: PASS, FAIL, NOT_TESTED. Do not replace measurements with a model opinion.

## Continue / Pivot / Kill
- Continue only if SP-01/03/04/05 **and SP-09/10/11/12** pass and test app demonstrates full roundtrip; 2 external Rails reviewers report useful reduction in glue code; specific gap vs generative_ui confirmed.
- Pivot to upstream generative_ui contribution if only a few additions are needed; pivot to narrowly scoped Rails adapter if general core adds little value.
- Kill independent gem if no differentiated state/action/interaction gap, if core independence requires invasive architecture, or if permission/state safety cannot be demonstrated.
- Pricing/commercial testing is not a prerequisite: this is an OSS developer tool. Adoption requires docs, reliability and realistic maintenance budget, not invented TAM.
## Scenario validation boundary
Only **UC-01** (ChoiceCard) and **UC-10** (offline Rails widget) are permitted Phase 0/V0 end-to-end fixtures. UC-03/05 and UC-04 are later real Rails-app adoption candidates; do not implement all ten in this spike. See [06_USE_CASES_AND_REFERENCE_DEMOS.md](06_USE_CASES_AND_REFERENCE_DEMOS.md).
