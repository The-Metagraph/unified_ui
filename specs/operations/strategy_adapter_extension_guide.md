# Strategy Adapter Extension Guide

## Purpose

Define extension guardrails for introducing alternate runtime strategy adapters without breaking deterministic governance contracts.

## Adapter Boundaries

Strategy adapters MAY extend orchestration behavior in these areas:

1. policy evaluation strategy (allow/deny composition details),
2. scope resolution strategy (context-derived scope conventions),
3. replay verification and gate policy strategy (threshold interpretation),
4. observability emission strategy (event/metric sink integration).

Adapters MUST NOT become alternate domain-state authorities.

## Required Contract Compatibility

Every adapter change MUST preserve compatibility with:

- [service_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/service_contract.md)
- [policy_authorization_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/policy_authorization_contract.md)
- [scope_resolution_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/scope_resolution_contract.md)
- [supervision_restart_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/supervision_restart_contract.md)
- [persistence_replay_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/persistence_replay_contract.md)
- [eval_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/eval_contract.md)
- [observability_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/observability_contract.md)

## Adapter Design Rules

1. Inputs and outputs MUST remain typed and deterministic for equivalent inputs.
2. Failures MUST be surfaced as typed errors with stable error codes.
3. Correlation/request continuity MUST be preserved.
4. CloudEvent and runtime-context envelope shapes MUST remain canonical.
5. Adapter configuration MUST be explicit, versioned, and reversible.

## Validation Requirements Before Merge

1. Run conformance scenario alignment report.
2. Run scenario-targeted integration tests for affected contract families.
3. Run release-readiness report mode.
4. Update conformance matrix mappings if requirement-family ownership shifts.
5. Update ADR when control-plane ownership or authority assumptions change.

## Suggested Adapter Rollout Pattern

1. Implement adapter in shadow/observe mode.
2. Capture equivalent-flow traces for baseline adapter vs candidate adapter.
3. Compare determinism and typed-error parity.
4. Gate rollout behind explicit runtime configuration.
5. Promote only after deterministic parity criteria are met.
