# Phase 21 - Replay Retention and Export Controls

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/persistence_replay_contract.md`
- `specs/contracts/service_contract.md`
- `specs/conformance/spec_conformance_matrix.md`

## Relevant Assumptions / Defaults
- Replay compaction must preserve cursor continuity while reducing retained entries.
- Replay snapshots and exports are diagnostics surfaces and must remain deterministic for equivalent flows.
- Runtime replay control operations must fail closed when option shapes are malformed.

[x] 21 Phase 21 - Replay Retention and Export Controls
  Add deterministic replay snapshot/export and retention controls for runtime diagnostics and recovery tooling.

  [x] 21.1 Section - Replay Snapshot and Compaction Primitives
    Extend replay-log helpers with deterministic snapshot/export and compaction behavior.

    [x] 21.1.1 Task - Implement replay snapshot/export and compaction APIs
      Provide typed helper APIs for replay slicing, export payload construction, and retention compaction.

      [x] 21.1.1.1 Subtask - Implement `ReplayLog.snapshot/2` for cursor-based deterministic replay slices.
      [x] 21.1.1.2 Subtask - Implement `ReplayLog.export/1` and `ReplayLog.compact/2` with fail-closed option validation.
      [x] 21.1.1.3 Subtask - Implement replay-log unit tests for snapshot/export/compaction behavior.

  [x] 21.2 Section - Runtime Replay Control Integration
    Integrate replay snapshot and retention controls into runtime message handling.

    [x] 21.2.1 Task - Implement replay control runtime messages
      Accept typed replay-control messages and persist deterministic diagnostics in recovery state.

      [x] 21.2.1.1 Subtask - Implement runtime replay snapshot request handling.
      [x] 21.2.1.2 Subtask - Implement runtime replay compaction request handling.
      [x] 21.2.1.3 Subtask - Implement runtime tests for replay control behavior.

  [x] 21.3 Section - Scenario and Matrix Mapping
    Register replay retention/export controls in conformance coverage.

    [x] 21.3.1 Task - Implement conformance mappings for replay control operations
      Add canonical scenario coverage for replay snapshot/export and compaction continuity.

      [x] 21.3.1.1 Subtask - Implement `SCN-026` scenario-catalog entry for replay retention/export controls.
      [x] 21.3.1.2 Subtask - Implement matrix updates linking `SCN-026` to persistence replay requirement families.
      [x] 21.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 21.

  [x] 21.4 Section - Phase 21 Integration Tests
    Validate replay snapshot/export and compaction behavior through conformance-tagged runtime flows.

    [x] 21.4.1 Task - Replay retention/export conformance scenarios
      Verify deterministic replay snapshot payloads, compaction continuity, and equivalent-flow export stability.

      [x] 21.4.1.1 Subtask - Verify `SCN-026` snapshot requests return deterministic checkpoint/cursor diagnostics.
      [x] 21.4.1.2 Subtask - Verify `SCN-026` compaction requests preserve cursor continuity with retained replay entries.
      [x] 21.4.1.3 Subtask - Verify `SCN-026` repeated equivalent flows produce equivalent replay export payloads.
