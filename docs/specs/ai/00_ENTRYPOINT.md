# ToolViews — mandatory AI Specs entrypoint

**Stage:** REVIEW. No final human approval, no frozen C/R baseline and no implementation repo. This is a proposed open-source Rails component/tool framework, working name only.

## Read order
01_PRODUCT_CONTRACT → 02_DOMAIN_OR_METHODOLOGY_CONTRACT → 03_UX_IMPLEMENTATION_CONTRACT → 04_TECHNICAL_BUILD_CONTRACT → 05_BUILD_SEQUENCE_AND_ACCEPTANCE → 06_SOURCE_OF_TRUTH_MAP → 07_DOCUMENT_STATUS_REGISTRY → 08_AGENT_PRE_FLIGHT_CHECKLIST. Then check ../SPEC_REVIEW.md and ../SPEC_READINESS_CHECKLIST.md.

## First executable objective (AFTER handoff)
Offline: register trusted Rails Partial with schema/action → ToolViews.present → persist Surface → render → authorized select → Turbo update → reload. No RubyLLM required. Only after this works add RubyLLM adapter for presentation and agent return.

## Forbidden shortcuts
Do not make RubyLLM required, generate arbitrary HTML/Ruby/JS, create universal workflow DSL, bypass tenant/object permissions, invent current upstream APIs, merge/publish without owner decision or mark HUMAN_REVIEW/HANDOFF_READY automatically.

## Handoff
Use ../19_PROJECT_HANDOFF_AND_IMPLEMENTATION_GOVERNANCE.md. New independent OSS repo owns actual implementation and working docs after Gate I; this folder is immutable-ish intended behavior.
**Name & scenario contract:** ToolViews (selected name), `toolviews/` Specs; start from [UC-01..10 and demo gates](../supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md). Only UC-01/10 are V0 obligations; do not infer acceptance of B/C from planned reference demos.
