# Eval Contract

This contract defines deterministic replay-evaluation, verification-gate, and baseline-calibration semantics.

## Covered Runtime Modules

- `WebUi.Persistence.ReplayLog`
- `WebUi.Persistence.ReplayBaselineRegistry`
- `WebUi.Ui.Runtime`

## Requirement Set

- `REQ-EVL-001`: Replay evaluation inputs MUST be canonical map payloads and MUST fail closed with typed validation errors on malformed input shape.
- `REQ-EVL-002`: Replay verification MUST return deterministic `match`/`drift` status and stable first-drift diagnostics for equivalent traces.
- `REQ-EVL-003`: Verification gate policy evaluation MUST emit deterministic pass/fail status and stable reason code sets.
- `REQ-EVL-004`: Verification gate reason codes MUST remain canonical (`status_not_allowed`, `cursor_delta_exceeded`, `entry_count_delta_exceeded`, `entry_mismatch_not_allowed`).
- `REQ-EVL-005`: Replay baseline capture MUST emit canonical baseline envelopes and maintain cursor/checkpoint continuity with underlying replay exports.
- `REQ-EVL-006`: Baseline registry operations (upsert/list/activate/active) MUST preserve deterministic ordering and active-baseline resolution.
- `REQ-EVL-007`: Baseline gate evaluation MUST support active-baseline defaulting and explicit baseline selection with deterministic diagnostics.
- `REQ-EVL-008`: Equivalent evaluation policy inputs MUST produce equivalent verification/gate outputs and equivalent operator-facing notices.
- `REQ-EVL-009`: Evaluation flows MUST remain read-oriented for baseline references and MUST NOT introduce alternate domain-state authority boundaries.
- `REQ-EVL-010`: Evaluation outputs MUST remain auditable through deterministic runtime recovery-state snapshots and conformance traces.

## Types

### ReplayVerificationSummary

```text
ReplayVerificationSummary {
  status: "match" | "drift",
  actual_cursor: non_neg_integer,
  expected_cursor: non_neg_integer,
  actual_entry_count: non_neg_integer,
  expected_entry_count: non_neg_integer,
  actual_checkpoint_id: string,
  expected_checkpoint_id: string,
  first_drift?: map | nil
}
```

### ReplayGateResult

```text
ReplayGateResult {
  status: "pass" | "fail",
  reasons: [map],
  cursor_delta: non_neg_integer,
  entry_count_delta: non_neg_integer,
  policy: map,
  verification: ReplayVerificationSummary
}
```

### ReplayBaselineGateResult

```text
ReplayBaselineGateResult {
  status: "pass" | "fail",
  baseline_id: string,
  gate: ReplayGateResult
}
```

## Canonical Eval Policy Fields

Evaluation and calibration policies SHOULD support:

- `allowed_statuses`
- `max_cursor_delta`
- `max_entry_count_delta`
- `allow_entry_mismatch`

Missing policy fields MUST default deterministically.

## Conformance Mapping

- `SCN-028`: replay verification determinism.
- `SCN-029`: replay verification gate policy determinism.
- `SCN-030`: replay baseline capture and baseline-gate determinism.
- `SCN-031`: replay baseline registry ordering, activation, and gate-resolution determinism.

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
