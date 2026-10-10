# Architecture Decision Records

Use ADRs for durable **implementation-level technical decisions** whose rationale a future maintainer would otherwise have to rediscover.

Product/business intent belongs in OddlyNiche, not here.

## When to write an ADR

Write one when the decision materially affects architecture boundaries, persistence, major dependency/provider choice, security/operational model, execution model, extensibility or migration cost.

Do not write an ADR for every small library or refactor.

## Template

Create `NNNN-short-title.md`:

```md
# ADR-NNNN — Title

Status: proposed | accepted | superseded | rejected
Date: YYYY-MM-DD
Related baseline / work / delta: ...

## Context
What constraint or problem forced a decision?

## Decision
What did we choose?

## Alternatives considered
What serious alternatives existed and why were they not chosen?

## Consequences
What becomes easier/harder? What new risks or migration costs exist?

## Human review trigger
What future evidence should cause this decision to be reconsidered?
```

Supersede old ADRs rather than rewriting historical rationale.
