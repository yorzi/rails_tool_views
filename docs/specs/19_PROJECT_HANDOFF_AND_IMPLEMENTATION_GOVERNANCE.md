# OddlyNiche → independent open-source implementation handoff

## Authority
OddlyNiche captures approved product intent and acceptance; implementation repository captures real code/schema/tests/ADR, current status, actual operations and per-commit progress. Do not mutate this baseline for routine refactors.

## H1 → H2 → C/R → I
1. REVIEW: execute missing ecosystem Spike, visual/UX review, release/legal naming and formal Spec review; resolve blockers.
2. Gate H1: pass SPEC_READINESS_CHECKLIST.md, source map and traceability, formal SPEC_REVIEW says READY_FOR_HUMAN_REVIEW; freeze human review candidate Q.
3. Gate H2: human signs human/06_FINAL_HUMAN_APPROVAL.md with exact Q SHA and date; AI cannot self-approve.
4. Content commit C freezes approved Specs; registration commit R records C separately in project-manifest.json and baseline changelog. Never write a commit's own SHA into it.
5. Gate I: create independent public project repository only after authorization; copy templates/implementation-repo-docs-template; record R/C in SPEC_BASELINE.md, bootstrap current-docs/agent/runbook, link first FR-AC slice and create adoption receipt.

## First implementation slice
S1: no model dependency; register select-card via explicit props/action schema; present in ordinary Rails; persist Surface; authorized select_option; revision/idempotency; Turbo rerender; refresh restores. Then S2: RubyLLM optional adapter tool call + chat reference. S3: host-owned structured agent return.

## Required implementation records
Independent repo must have AGENTS.md, docs/agent entry + pre/post flight, current implementation plan, Acceptance Matrix linked to FR/AC, per-commit Progress Ledger + Work-ID trailer, human System At A Glance/Status/Feature Map/Architecture/Flows/Changelog/Glossary, ADR, tests and operations/release checklists. Product intent deviations classified IMPLEMENTATION_BUG / INTENTIONAL_DELTA / PRODUCT_INTENT_CHANGE.

## Human escalation
Pause before: changing AI dependency from optional to required; adopting generated code; bypassing authorization; redefining tool/agent transcript semantics; introducing tree/protocol support into V0; changing license/public name; merging major PR or publishing gem. Phase 0 discoveries may propose ADRs, not silently change intent.

## Independent repo
Destination repository and license/public namespace are NOT YET CHOSEN. No implementation handoff, Gem or production system is claimed by these Specs.