# Long-term maintainability and continuity

Intent remains in OddlyNiche until formally revised. Separate OSS repository owns versioned code, migrations, changelog, current behavior docs, CI, release and security advisories after approved handoff.

Use semantic versioning; keep registry key and schema fingerprints stable, define documented deprecation for renamed props/actions, and provide explicit upgrade path for persisted Surfaces. No silent schema coercion or implicit backward-compatible rendering. Support rollback of gem code only when persisted format compatibility permits it; otherwise provide safe read-only fallback.

Maintain reproducible offline fixture tests independent of API keys and real-provider smoke jobs separate from baseline CI. Tests should survive provider discontinuation; adapter can be removed without corrupting saved Surfaces.

If abandoned or archived: publish final compatibility constraints, export/migration instructions, security limitations and recommended upstream alternatives. No telemetry/user-data service to shut down by default.