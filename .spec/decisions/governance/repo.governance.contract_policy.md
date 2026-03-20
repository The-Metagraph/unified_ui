---
id: repo.governance.contract_policy
status: accepted
date: 2026-03-12
affects:
  - spec.system
  - repo.package
  - repo.governance
  - repo.governance.contract
---

# Repository Governance Uses Contracts and ADRs

## Context

The root `.spec` workspace already defines authored subjects and durable decisions, but it does not yet distinguish repository-wide governance from package intent. The Jido OS reference model shows a useful separation between normative contracts and ADR rationale. We want that same separation here without leaving the Spec Led file model.

## Decision

1. Repository-wide governance will live as authored `.spec.md` subjects under `.spec/specs/governance/`.
2. Durable, cross-cutting governance rationale will continue to live under `.spec/decisions/` as ADRs.
3. Governance contracts will use the same `spec-meta`, `spec-requirements`, `spec-verification`, and `spec-exceptions` blocks as other authored subjects.
4. Conformance lives as a separate layer rather than being merged into governance contracts.

## Consequences

- The root `.spec` workspace gains an explicit governance layer without changing `spec_led_ex` parsing rules.
- Governance policy remains current-truth and machine-indexable.
- Conformance can evolve independently from governance contracts without changing the governance authoring model.
