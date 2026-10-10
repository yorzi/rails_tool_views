# ADR 001 — narrow independent registry and durable Rails runtime

Date: 2026-10-10. Status: implemented locally; release/adoption decision remains open.

The pinned GenerativeUI loader/catalog control passes with RubyLLM 2.1. Blocking the SDK require fails its eager Tool load. Its built gem includes 24 files, 3 under app/. The pinned A2UI Rails built gem has 85 files and zero app/ files, consistent with its inspected gemspec. It requires DSPy; its full runtime was not installed or security-tested here. Runnable command: scripts/upstream_probe.rb with the two pinned checkout paths under the optional adapter bundle.

Choose specification Candidate C: a closed single-component registry using JSONSchemer, plus ActiveRecord Surface/action/interaction persistence. The differentiating technical surface is authorization, durable transitions/replay and Rails transports; no upstream tree compiler or application code is copied. A bridge would still bring a mandatory SDK and would not replace the required durable action runtime. Upstream extraction remains a possible future collaboration; no maintainer contact or measured upstream extension was performed.

Explicit keyword registration replaces the proposed DSL. Partial locals are props/state/surface/error; ViewComponent receives validated props kwargs. Fingerprint covers key, explicit version, schema, renderer identity and action schemas. Host must bump version for code semantic changes. Props/state belong to presentation; domain records and transcripts remain host-owned. Receipts retain digests/results, not raw action arguments except explicitly requested structured continuation values.

JSON and Turbo are implemented; no ActionCable. UUIDs and named mount helper constrain targets. Concurrent DB transactions + optimistic locking + uniqueness prevent duplicated database effects; retry uncertain conflicts with the same key. Remote side effects and delivery deduplication are host contracts. SQLite is verified; PostgreSQL is a release gate. Runtime limits are configurable host settings, not client inputs.

This is a technical feasibility choice, not proof of reduced adoption cost. A measured bespoke comparison, external trials, license/name review, complete SP-09..12 upstream runtime comparison and formal human gates remain open. Do not mark Gate V/R approved from local tests alone.
