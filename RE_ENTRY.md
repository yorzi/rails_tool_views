# Re-entry

Current milestone: local v0 complete, unpublished. Read README.md, SPEC_BASELINE.md and docs/human/01_PROJECT_STATUS.md. The exact source reference is copied under docs/specs; it remains REVIEW and was not self-approved.

Run `bundle exec rake test`, the separate adapter suite, and `bundle exec ruby scripts/package_smoke.rb`. `bin/demo` starts the offline demo on 127.0.0.1:3100 and is stopped with Ctrl-C. No task-owned server is intended to remain running after completion.

Next owner decision: review the API, policies and demo; then decide license/name, formal handoff and whether to publish a repository. Remote CI, PostgreSQL, real-provider smoke and external setup trials are release work, not completed evidence.
