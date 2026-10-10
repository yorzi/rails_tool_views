# Privacy, accessibility, open-source legal

**Privacy:** Library is embedded in host application; by default store only validated props, minimal state, revision and scoped correlation references. No secret/API token/raw prompt storage, provider calls or telemetry network upload by core. Host must document retention/export/deletion, object-level tenant access and whether selected presentation fields are sent to LLM through optional adapter.

**Accessibility:** V0 selection form usable keyboard-only, with labels, error association, visible focus, appropriate aria-live notices and mobile 360px layout. Aim WCAG 2.2 AA for shipped example, with manual assistive-tech review before release; automated tests alone insufficient.

**Licensing:** Proposed MIT but not approved; inspect third-party components, copied assets, schemas and dependency licenses. Avoid copying OpenAI/Gemini UI or proprietary ChatGPT widgets. Do not imply endorsement/affiliation by RubyLLM, Google or OpenAI.

**Risk:** Agent-supplied choices/content can contain prompt injection or phishing text. Render through trusted Rails view with escaping and no model-defined active links/JS. External data may be sensitive; app governs data minimization and user consent. SECURITY.md and contributor CLA/DCO decision required at public release.

**Applicability:** This generic developer gem is not directly handling regulated data; host-specific legal/medical/child use requires its own independent assessment.