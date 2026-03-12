# Persistence Replay Contract

This contract defines deterministic replay-log persistence, verification, and baseline-governance behavior.

## Covered Runtime Modules

- `WebUi.Persistence.ReplayLog`
- `WebUi.Persistence.ReplayBaselineRegistry`
- `WebUi.Ui.Runtime`

## Requirement Set

- `REQ-RPL-001`: Replay append operations MUST advance cursor monotonically and record deterministic outbound/inbound entries with stable metadata fingerprints.
- `REQ-RPL-002`: Replay checkpoints MUST use deterministic canonical IDs derived from cursor and retained entries.
- `REQ-RPL-003`: Snapshot requests MUST support deterministic `from_cursor` and `limit` filtering without mutating persisted replay state.
- `REQ-RPL-004`: Replay compaction MUST preserve current cursor continuity while deterministically retaining only requested trailing entries.
- `REQ-RPL-005`: Replay export payloads MUST use canonical format IDs and carry cursor/checkpoint/entries sufficient for deterministic restore.
- `REQ-RPL-006`: Replay restore operations MUST validate export shape, cursor/entry continuity, and checkpoint consistency; malformed restore payloads MUST fail closed with typed validation errors.
- `REQ-RPL-007`: Replay verification MUST produce deterministic `match`/`drift` summaries including stable first-drift diagnostics.
- `REQ-RPL-008`: Replay verification gates MUST evaluate drift against deterministic policy thresholds and emit stable pass/fail reason codes.
- `REQ-RPL-009`: Replay baseline capture MUST produce canonical baseline envelopes, and baseline registry retention/ordering/activation MUST remain deterministic.
- `REQ-RPL-010`: Equivalent replay-control flows (snapshot/export/compact/restore/verify/gate/baseline) MUST produce equivalent diagnostics and conformance traces.

## Types

### ReplayLogEntry

```text
ReplayLogEntry {
  cursor: non_neg_integer,
  direction: "outbound" | "inbound",
  event: string,
  payload_fingerprint: non_neg_integer,
  metadata: map
}
```

### ReplayLogState

```text
ReplayLogState {
  cursor: non_neg_integer,
  entries: ReplayLogEntry[],
  last_checkpoint_id?: string | nil
}
```

### ReplayExport

```text
ReplayExport {
  format: "web_ui.replay_log.export.v1",
  cursor: non_neg_integer,
  checkpoint_id: string,
  entries: ReplayLogEntry[]
}
```

### ReplayBaseline

```text
ReplayBaseline {
  format: "web_ui.replay_baseline.v1",
  baseline_id: string,
  cursor: non_neg_integer,
  checkpoint_id: string,
  entry_count: non_neg_integer,
  metadata: map,
  export: ReplayExport
}
```

### ReplayVerificationPolicy

```text
ReplayVerificationPolicy {
  allowed_statuses?: ["match" | "drift"],
  max_cursor_delta?: non_neg_integer,
  max_entry_count_delta?: non_neg_integer,
  allow_entry_mismatch?: boolean
}
```

## Canonical Deterministic Rules

1. Replay checkpoint IDs MUST follow `replay-%06d-%010d` formatting for cursor/hash continuity.
2. Replay baseline IDs MUST follow `baseline-%06d-%010d` formatting for baseline cursor/hash continuity.
3. Export payload format ID MUST be `web_ui.replay_log.export.v1`.
4. Baseline payload format ID MUST be `web_ui.replay_baseline.v1`.
5. Baseline registry order MUST be deterministic and sorted by newest capture first.
6. Baseline registry retention limits MUST prune oldest entries deterministically.

## Canonical Typed Error Code Families

- Replay log state validation: `replay_log.invalid_*`
- Replay verification/gate policy validation: `replay_log.invalid_verification_policy`
- Baseline registry shape/lookup errors: `replay_baseline_registry.*`

Typed replay errors MUST remain fail-closed and deterministic for equivalent invalid inputs.

## Conformance Mapping

- `SCN-025`: replay append cursor/checkpoint continuity.
- `SCN-026`: replay snapshot/retention/export continuity.
- `SCN-027`: replay restore/apply continuity.
- `SCN-028`: replay verification continuity.
- `SCN-029`: replay verification gate continuity.
- `SCN-030`: replay baseline capture/gate continuity.
- `SCN-031`: replay baseline registry retention/activation continuity.

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
