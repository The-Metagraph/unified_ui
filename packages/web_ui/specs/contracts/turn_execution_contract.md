# Turn Execution Contract

This contract defines deterministic turn metadata progression and reconciliation semantics.

## Covered Runtime Modules

- `WebUi.Turn.Execution`
- `WebUi.Ui.Runtime`

## Requirement Set

- `REQ-TRN-001`: Runtime dispatch sequence numbers MUST be non-negative integers and MUST increment deterministically per outbound widget dispatch.
- `REQ-TRN-002`: Turn IDs MUST be derived deterministically from dispatch sequence as zero-padded canonical strings.
- `REQ-TRN-003`: Outbound widget-event `data` payloads MUST include `dispatch_sequence` and `turn_id` metadata before websocket dispatch.
- `REQ-TRN-004`: Turn-begin state transitions MUST set `slice_state.dispatch_sequence` and `slice_state.active_turn_id` from canonical turn metadata.
- `REQ-TRN-005`: Turn-complete transitions MUST clear `slice_state.active_turn_id` and preserve deterministic `last_completed_turn_id` tracking.
- `REQ-TRN-006`: Turn-complete logic MUST prefer active in-flight turn IDs over result-derived fallback IDs.
- `REQ-TRN-007`: Result-derived turn fallback extraction MUST support payload/context/ui_patch turn metadata and tolerate string/atom map keys.
- `REQ-TRN-008`: Empty or malformed turn-id fields MUST NOT overwrite previously stable turn-completion state.
- `REQ-TRN-009`: Equivalent dispatch/result flows MUST produce equivalent turn progression traces.
- `REQ-TRN-010`: Turn progression semantics MUST remain compatible with replay and scope/policy guarded dispatch flows in runtime reconciliation.

## Types

### TurnMetadata

```text
TurnMetadata {
  turn_id: string,
  dispatch_sequence: non_neg_integer
}
```

### TurnSliceState

```text
TurnSliceState {
  dispatch_sequence: non_neg_integer,
  active_turn_id?: string | nil,
  last_completed_turn_id?: string | nil
}
```

### TurnResultEnvelope

```text
TurnResultEnvelope {
  payload?: {
    turn_id?: string,
    ui_patch?: {
      turn_id?: string
    }
  },
  context?: {
    turn_id?: string
  }
}
```

## Canonical Turn Metadata Rules

1. Canonical turn IDs MUST follow `turn-%06d` formatting derived from dispatch sequence.
2. Outbound event metadata injection MUST write JSON-string keys:
   - `dispatch_sequence`
   - `turn_id`
3. Turn completion fallback extraction order MUST be:
   1. `slice_state.active_turn_id`
   2. `result.payload.turn_id`
   3. `result.context.turn_id`
   4. `result.payload.ui_patch.turn_id`
4. Turn completion MUST clear `active_turn_id` regardless of reconciliation outcome.

## Conformance Mapping

- `SCN-023`: deterministic turn-id progression, active/completed turn reconciliation semantics, and repeated-flow trace parity.

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
