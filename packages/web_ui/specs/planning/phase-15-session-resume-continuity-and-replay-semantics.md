# Phase 15 - Session Resume Continuity and Replay Semantics

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/service_contract.md`
- `specs/contracts/observability_contract.md`
- `specs/conformance/spec_conformance_matrix.md`
- `specs/conformance/fault_recovery_and_determinism_hardening.md`

## Relevant Assumptions / Defaults
- Reconnect flows should carry deterministic resume cursors derived from UI dispatch sequence state.
- Resume command dedupe should consider cursor continuity, not just topic identity.
- Resume acknowledgements should be reflected in deterministic recovery state and diagnostics.

[x] 15 Phase 15 - Session Resume Continuity and Replay Semantics
  Harden session resume behavior with explicit cursor continuity and deterministic replay acknowledgement semantics.

  [x] 15.1 Section - Resume Cursor Propagation Baseline
    Propagate dispatch-sequence cursor metadata through reconnect command generation and recovery state.

    [x] 15.1.1 Task - Implement reconnect command cursor continuity and dedupe keys
      Ensure reconnect commands include stable cursor metadata and dedupe logic honors cursor changes.

      [x] 15.1.1.1 Subtask - Implement recovery-state fields for session resume cursor tracking.
      [x] 15.1.1.2 Subtask - Implement reconnect join payload with `resume_from_sequence` continuity.
      [x] 15.1.1.3 Subtask - Implement runtime recovery tests for cursor-aware reconnect dedupe behavior.

  [x] 15.2 Section - Resume Acknowledgement Reconciliation
    Apply resume acknowledgement metadata to deterministic view/recovery reconciliation state.

    [x] 15.2.1 Task - Implement reconnect acknowledgement handling
      Update model diagnostics and recovery fields when join acknowledgements include resume sequence metadata.

      [x] 15.2.1.1 Subtask - Implement recovery-state `last_resumed_sequence` updates from join success payloads.
      [x] 15.2.1.2 Subtask - Implement deterministic resume acknowledgement notices for operator diagnostics.
      [x] 15.2.1.3 Subtask - Implement bootstrap/recovery tests verifying acknowledgement continuity behavior.

  [x] 15.3 Section - Scenario and Matrix Mapping
    Register resume continuity behavior in conformance scenario coverage.

    [x] 15.3.1 Task - Implement scenario catalog and matrix entries for resume continuity
      Add a canonical scenario and map it to appropriate requirement families.

      [x] 15.3.1.1 Subtask - Implement `SCN-020` scenario-catalog entry for resume cursor continuity.
      [x] 15.3.1.2 Subtask - Implement matrix mapping updates linking `SCN-020` to service/observability coverage.
      [x] 15.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 15.

  [x] 15.4 Section - Phase 15 Integration Tests
    Validate resume cursor and acknowledgement continuity end-to-end under reconnect/replay flows.

    [x] 15.4.1 Task - Resume continuity conformance scenarios
      Verify cursor propagation, dedupe semantics, and acknowledgement reconciliation through runtime flows.

      [x] 15.4.1.1 Subtask - Verify `SCN-020` reconnect commands include deterministic resume cursors.
      [x] 15.4.1.2 Subtask - Verify `SCN-020` dedupe behavior emits new joins when cursor changes.
      [x] 15.4.1.3 Subtask - Verify `SCN-020` resume acknowledgement updates recovery diagnostics deterministically.
