# Documentation Maintenance & Commit Protocol

## One authored commit, one inspectable section

Every authored commit, including docs, tests, maintenance, fixes and reverts, adds a new section to `docs/human/05_PROGRESS_LEDGER.md` in that same commit. Assign a unique `WORK-YYYYMMDD-NN` ID and include exactly one `Work-ID: WORK-YYYYMMDD-NN` trailer in the commit message. Split a multi-commit task into child work IDs; a shared task header or PR description does not replace per-commit sections.

The section states what/why, FR/AC or maintenance rationale, concrete human review steps, validation result (or not run + reason), risk/data/security impact, docs updated or no-impact reason, alignment and next action. Human prose should use the owner's preferred language (default concise Chinese); identifiers and paths remain exact. Never fabricate a test, approval or result to fill the form.

No future SHA is required. Find a section's commit with:

```sh
git log --all --fixed-strings --grep='Work-ID: WORK-20260916-01'
```

Use `node scripts/check-progress-ledger.mjs --staged` after staging; use `node scripts/check-progress-ledger.mjs --range <base>..<head>` after commits and in project CI. The script checks linkage, not prose quality. Install it into the project's real test/CI workflow at bootstrap. Select an explicit base commit; do not assume a default branch name.

For a new repository's root commit, use `<root-sha>^!` as the range. An amend updates the same section until the commit is finalized. A squash keeps the combined review evidence in one new section and one trailer; retain subordinate entries if useful. A revert gets a new Work ID, reason and resulting state.

Merge commits require an added section and trailer by default. An unchanged tree-only merge may use `Ledger-Exempt: topology-only` after human verification. An automated metadata-only commit may use `Ledger-Exempt: automation-metadata` only with explicit review confirming no authored change; the mechanical checker reports, but cannot semantically verify, such exemptions. Never exempt docs or a manual dependency upgrade.

## Public documentation responsibilities

README provides purpose, minimal installation, demo and navigation. `docs/site/` owns user tutorials and API behavior, including their generated Markdown copies. CONTRIBUTING, SECURITY and CHANGELOG own contribution instructions, disclosure and release changes. Root ROADMAP.md is the single maintained proposed version plan; link to it from the site instead of duplicating a roadmap guide. Mark future features as proposed and keep them out of delivered API examples. Internal status and Current Work summarize the present and next action; completed detail stays in the ledger/evidence.

## Keep a single owner for each fact

| Fact | Canonical living location | Update trigger |
|---|---|---|
| Current milestone, risk, next human decision | human/01_PROJECT_STATUS | milestone/risk change |
| Current capability and module entry points | human/02_FEATURE_MAP | capability/status/module boundary change |
| Components, data relationships, trust boundaries | human/03_SYSTEM_ARCHITECTURE | architecture change |
| Important runtime sequences and failures | human/04_RUNTIME_FLOWS | runtime behavior change |
| Every authored commit | human/05_PROGRESS_LEDGER | every commit |
| Human mental-model change | human/06_HUMAN_CHANGELOG | meaningful conceptual change |
| Execution sequence | agent/01_IMPLEMENTATION_PLAN | evidence changes plan |
| Immediate checklist | agent/02_CURRENT_WORK | starting/finishing/pausing work |
| Actual acceptance evidence | agent/06_ACCEPTANCE_MATRIX | verification or affected behavior changes |
| Run/recover/release procedures | operations/ | operating changes |
| Baseline mismatch | agent/05_SPEC_DELTA_PROTOCOL | discovery/decision/resolution |

Other docs summarize and link; don't copy whole tables. Split lengthy ledgers into monthly files under `docs/human/progress/`, preserving IDs and index links. Use module pages only when Feature Map/Architecture become hard to read; describe purpose, responsibility, inputs/outputs, data, failures, code entry points and tests. Avoid one file per class.

## Pause and re-entry

Update active checklist, evidence, blockers and exact next action before pausing. Keep planned diagrams visibly PLANNED. At a milestone, perform a five-minute human reading check: can the owner describe the product, implemented capabilities, main components, next work and largest risk without asking the agent?

Stop all task-created services/watchers/tunnels before completion and verify they stopped. Bind temporary servers to loopback; record PID/port/stop command during the task. Secrets belong in protected env files or stdin, never inline arguments or exports. If continuing a service is explicitly required, document its purpose, port and stop command.
