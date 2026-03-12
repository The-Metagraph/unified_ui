# Phase 23 - Replay Drift Detection and Verification

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/persistence_replay_contract.md`
- `specs/contracts/service_contract.md`
- `specs/conformance/spec_conformance_matrix.md`

## Relevant Assumptions / Defaults
- Replay verification compares deterministic replay traces, not business-domain state authority.
- Drift summaries must be reproducible for equivalent replay logs and expected export payloads.
- Verification operations must fail closed for malformed export payloads before mutating recovery diagnostics.

[x] 23 Phase 23 - Replay Drift Detection and Verification
  Add deterministic replay drift detection and verification controls for runtime diagnostics and governance conformance.

  [x] 23.1 Section - Replay Verification Primitives
    Extend replay-log helpers with deterministic comparison and export-verification behavior.

    [x] 23.1.1 Task - Implement replay comparison and verification helpers
      Provide typed APIs that compare replay logs and verify expected replay export payloads with deterministic drift summaries.

      [x] 23.1.1.1 Subtask - Implement `ReplayLog.compare/2` with deterministic first-drift diagnostics.
      [x] 23.1.1.2 Subtask - Implement `ReplayLog.verify_export/2` for export-to-log replay verification.
      [x] 23.1.1.3 Subtask - Implement replay-log unit tests for verification match/drift behavior.

  [x] 23.2 Section - Runtime Replay Verification Integration
    Integrate replay verification controls into runtime message handling.

    [x] 23.2.1 Task - Implement replay verification runtime message flow
      Accept typed replay verification requests and persist deterministic verification diagnostics in recovery state.

      [x] 23.2.1.1 Subtask - Implement runtime replay verification request handling.
      [x] 23.2.1.2 Subtask - Implement deterministic recovery diagnostics for match/drift verification outcomes.
      [x] 23.2.1.3 Subtask - Implement runtime tests for replay verification behavior.

  [x] 23.3 Section - Scenario and Matrix Mapping
    Register replay verification and drift detection behavior in conformance coverage.

    [x] 23.3.1 Task - Implement conformance mappings for replay verification continuity
      Add canonical scenario coverage for replay verification drift detection and deterministic diagnostics.

      [x] 23.3.1.1 Subtask - Implement `SCN-028` scenario-catalog entry for replay verification continuity.
      [x] 23.3.1.2 Subtask - Implement matrix updates linking `SCN-028` to persistence replay requirement families.
      [x] 23.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 23.

  [x] 23.4 Section - Phase 23 Integration Tests
    Validate replay verification and drift diagnostics through conformance-tagged runtime flows.

    [x] 23.4.1 Task - Replay verification conformance scenarios
      Verify deterministic verification match summaries, drift diagnostics, and equivalent-flow verification traces.

      [x] 23.4.1.1 Subtask - Verify `SCN-028` equivalent replay logs produce deterministic verification match summaries.
      [x] 23.4.1.2 Subtask - Verify `SCN-028` replay drift paths produce deterministic first-drift diagnostics.
      [x] 23.4.1.3 Subtask - Verify `SCN-028` repeated equivalent verification flows produce equivalent verification traces.
