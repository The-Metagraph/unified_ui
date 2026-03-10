# Eval Governance and Calibration Runbook

## Purpose

Provide deterministic operational guidance for replay verification, gate policy calibration, and baseline-governance decisions.

## Scope

This runbook applies when replay verification/gate outputs drift, when baseline-gate outcomes are unstable, or when eval policy thresholds require adjustment.

## Core Contracts and Scenarios

- Contract: [eval_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/eval_contract.md)
- Contract: [persistence_replay_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/persistence_replay_contract.md)
- Scenarios: `SCN-028`, `SCN-029`, `SCN-030`, `SCN-031`

## Triage Checklist

1. Confirm latest replay cursor/checkpoint in runtime recovery state.
2. Capture expected replay export or baseline payload under investigation.
3. Run deterministic verification and gate commands/tests.
4. Compare gate reason codes against current policy thresholds.
5. Decide policy calibration change only after equivalent-flow reproducibility is confirmed.

## Deterministic Validation Commands

```bash
mix test test/web_ui/integration/phase_23_replay_verification_test.exs
mix test test/web_ui/integration/phase_24_replay_verification_gate_test.exs
mix test test/web_ui/integration/phase_25_replay_baseline_gate_test.exs
mix test test/web_ui/integration/phase_26_replay_baseline_registry_test.exs
./scripts/run_conformance.sh --report-only
```

Release-governance confirmation:

```bash
./scripts/run_release_readiness.sh --report-only
```

## Calibration Policy Workflow

1. Identify failing reason codes (`status_not_allowed`, `cursor_delta_exceeded`, `entry_count_delta_exceeded`, `entry_mismatch_not_allowed`).
2. Confirm the reason set is stable across repeated equivalent runs.
3. Propose policy-threshold change with explicit before/after expected outcomes.
4. Update contract/matrix/ADR artifacts in the same change set.
5. Re-run conformance + release-readiness report checks before merge.

## Incident Escalation Conditions

Escalate when any condition is true:

1. Equivalent eval inputs produce inconsistent gate outcomes.
2. Baseline registry active selection is unstable across repeated equivalent capture flows.
3. Gate policy changes are required to pass without clear deterministic justification.

## Post-Incident Follow-up

1. Archive failing and passing eval artifacts with scenario IDs.
2. Record policy calibration decision rationale.
3. Add/update conformance scenarios when new drift class is discovered.
4. Link related RFC/spec updates if ownership boundaries or policy assumptions changed.
