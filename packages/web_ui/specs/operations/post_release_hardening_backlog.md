# Post-Release Hardening Backlog

## Purpose

Convert first-release learnings into actionable RFC, conformance, and spec updates.

## Ownership Assignment

| Area | Owner Group | Primary Inputs | Output Artifact |
|---|---|---|---|
| Transport + runtime authority | Runtime team | error metrics, typed-error logs, conformance failures | RFC seed + contract/spec updates |
| UI runtime + widget flow | UI team | retry/cancel/reconnect telemetry, UX incident reports | conformance additions + UI spec clarifications |
| Governance and release operations | Platform team | release-readiness reports, debt scans, CI failures | workflow/runbook updates |

## RFC Seeds

The following RFC seeds SHOULD be authored first:

1. `RFC-00XX` Retry backoff policy and duplicate suppression for reconnect/retry storms.
2. `RFC-00XY` Session resume continuity guarantees and replay semantics.
3. `RFC-00XZ` First-slice outcome envelope expansion for richer UI reconciliation hints.

## Planned Conformance Additions

1. Add scenarios for reconnect loops and resume-topic continuity.
2. Add scenarios for retry/cancel command replay determinism.
3. Add scenarios for release gate false-positive/false-negative regression checks.

## Planned Spec Updates

1. Clarify Transport Plane vs UI Runtime Plane responsibilities for reconnect orchestration.
2. Clarify Runtime Authority Plane responsibilities for retryable vs non-retryable categorization.
3. Clarify Product Plane ownership for release go/no-go and rollback decisions.

## Intake Flow

1. Run telemetry and debt review.
2. Prioritize backlog items using criteria from [`fault_recovery_and_determinism_hardening.md`](../conformance/fault_recovery_and_determinism_hardening.md).
3. Promote top items into RFCs and register in `rfcs/index.md`.
4. Land linked updates to contracts, matrix, and integration scenarios in same change sets.
