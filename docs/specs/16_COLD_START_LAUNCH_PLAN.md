# Cold start and OSS launch

**Reference-demo order:** Demo A ChoiceCard (UC-01/10) is V0 proof; Demo B Support Ticket Assistant (UC-03/05) and Demo C Generated Result Review (UC-04) are V1 candidate adoption proofs, not release blockers for initial Core. See [supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md).

Pre-public: private proof with two existing Rails applications or a dummy + one separate Rails project, plus three external developer setup trials. Publish a minimal README, install generator, API cookbook, tiny interactive demo, compatibility table and threat model. Verify name/namespace, MIT license and dependency notices before RubyGems publication.

Distribution: technical demo to Rails community and RubyLLM maintainers, invite feedback on use cases, report actionable upstream findings, avoid branding confusion. No growth campaign needed. Public launch gates require passing S1–S3 and security/CI review; release notes must list V0 limitations and deferred A2UI/MCP Apps/composition.

Feedback intake: issue templates distinguish bug, adapter compatibility, feature request and security report. Collect concrete reproduction plus Rails/Ruby/adapter version and anonymized fixture; never ask reporters to post API keys.