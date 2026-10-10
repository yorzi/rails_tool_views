# Adoption metrics, evidence and experiments

## Hypothesis measurement
- EV-01 (developer completion): >=3 independent Rails developers attempt the setup; >=2 complete register→present→interact→restore in <=60 min from clean app without guidance beyond docs. Record versions, elapsed time, blockers.
- EV-02 (glue-code reduction): compare a documented bespoke Rails implementation with gem demo, same features and auth requirements; target >=30% fewer custom integration statements/steps without extra runtime dependencies. Note that LOC alone can be gamed.
- EV-03 (tech independence): CI Gemfile matrix excludes RubyLLM yet core demo and tests pass.
- EV-04 (model loop): one supported RubyLLM model tool call yields validated Surface and later action uses correct chat continuation; fixture tests plus opted-in live smoke.
- EV-05 (safety): all SEC-01..18 applicable tests pass; no forbidden action/tenant write.
- EV-06 (latency): measure Rails present/action/render timings under fixture workloads, record machine and P50/P95, avoid invented performance guarantees.

## Scenario adoption evidence
For every study, record `UC-ID` from [the ten use-case contracts](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md), Rails app baseline, existing component/action reused, independent developer, authorization expectations, equivalent bespoke alternative, time and maintenance burden. UC-01/10 must establish **technical feasibility**; UC-05/04 (V1) should establish **business workflow differentiation** only after prior gates. A useful demo does not by itself confirm adoption or product-market fit.

## Instrumentation
Events: registry.registered; presentation.accepted/rejected; surface.rendered; action.accepted/rejected/conflict; adapter.tool_called; interaction.dispatched. Use ActiveSupport::Notifications with safe IDs, duration, component key, revision; never include private props/secrets by default.

## Experiment log
Create an evidence row per test: ID, date, revision, participant (anonymized), environment, steps, pass/fail, artifacts, interpretation, next decision. Evidence that simply shows local implementation is not evidence of external demand.

## Gate decision
If technical loop works but independent developers do not save meaningful integration effort, upstream a narrower contribution instead of promoting a new Gem. No fabricated adoption metrics or score-only GO.