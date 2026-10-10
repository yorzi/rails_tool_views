# AI-assisted development governance

Before coding, agent must read the [ten reference scenarios](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md) for scope/adoption evidence and ai/00_ENTRYPOINT.md through ai/08_AGENT_PRE_FLIGHT_CHECKLIST.md, canonical product Specs, SEC cases and Phase 0 spike. Never claim tools, providers, APIs, models or Rails versions are supported without tagged-source reproduction.

Implementation starts only after OddlyNiche Gate H2 and Gate I, in its own OSS repository bootstrapped from templates/implementation-repo-docs-template. OddlyNiche is a frozen intent baseline; code/tests/ADR and current status live in implementation repo. AI must never auto-approve human gates, release gems, publish credentials or merge significant code without the specified owner review.

**First slice:** offline register → present → render → select → persist → reload; do not start with AI-driven composition. Use real runnable failing tests and minimize glue. Evaluate reusing generative_ui rather than copying its schema compiler. Every AI output, including proposed code and security rules, is untrusted until verified.

Every authored implementation commit needs progress-ledger WORK and Work-ID trailer; maintain Acceptance Matrix mapped to FR/AC, and explicit discrepancy labels IMPLEMENTATION_BUG / INTENTIONAL_DELTA / PRODUCT_INTENT_CHANGE. Use current Rails initialization skill for framework defaults, but product intent overrides generic skill advice.