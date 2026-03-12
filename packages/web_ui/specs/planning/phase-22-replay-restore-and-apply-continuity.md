# Phase 22 - Replay Restore and Apply Continuity

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/persistence_replay_contract.md`
- `specs/contracts/service_contract.md`
- `specs/conformance/spec_conformance_matrix.md`

## Relevant Assumptions / Defaults
- Replay restore operations consume deterministic export payloads from trusted runtime diagnostics pathways.
- Restored replay state must preserve cursor/checkpoint continuity before accepting new dispatch/result appends.
- Restore failures must fail closed with typed errors and avoid mutating runtime state.

[x] 22 Phase 22 - Replay Restore and Apply Continuity
  Add deterministic replay restore/apply operations that rehydrate runtime replay state from exported payloads.

  [x] 22.1 Section - Replay Restore Primitives
    Extend replay-log helpers with deterministic restore and export-payload validation behavior.

    [x] 22.1.1 Task - Implement replay restore API and validation
      Validate exported replay payloads, restore cursor/checkpoint state, and preserve append continuity.

      [x] 22.1.1.1 Subtask - Implement `ReplayLog.restore/1` with deterministic payload and cursor validation.
      [x] 22.1.1.2 Subtask - Implement checkpoint mismatch detection for restore payload integrity.
      [x] 22.1.1.3 Subtask - Implement replay-log unit tests for restore and malformed payload behavior.

  [x] 22.2 Section - Runtime Replay Restore Integration
    Integrate replay restore controls into runtime message handling and recovery-state diagnostics.

    [x] 22.2.1 Task - Implement replay restore runtime message flow
      Accept typed replay-restore requests and rehydrate runtime recovery replay state.

      [x] 22.2.1.1 Subtask - Implement runtime replay restore request handling.
      [x] 22.2.1.2 Subtask - Implement restored-cursor continuity for subsequent replay appends.
      [x] 22.2.1.3 Subtask - Implement runtime tests for replay restore behavior.

  [x] 22.3 Section - Scenario and Matrix Mapping
    Register replay restore/apply continuity behavior in conformance coverage.

    [x] 22.3.1 Task - Implement conformance mappings for replay restore continuity
      Add canonical scenario coverage for replay restore determinism and post-restore append continuity.

      [x] 22.3.1.1 Subtask - Implement `SCN-027` scenario-catalog entry for replay restore/apply continuity.
      [x] 22.3.1.2 Subtask - Implement matrix updates linking `SCN-027` to persistence replay requirement families.
      [x] 22.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 22.

  [x] 22.4 Section - Phase 22 Integration Tests
    Validate replay restore/apply behavior through conformance-tagged runtime flows.

    [x] 22.4.1 Task - Replay restore/apply conformance scenarios
      Verify deterministic replay restoration, post-restore cursor progression, and equivalent-flow replay trace stability.

      [x] 22.4.1.1 Subtask - Verify `SCN-027` replay restore requests rehydrate deterministic cursor/checkpoint diagnostics.
      [x] 22.4.1.2 Subtask - Verify `SCN-027` post-restore dispatch/result paths preserve replay cursor continuity.
      [x] 22.4.1.3 Subtask - Verify `SCN-027` repeated equivalent restore/apply flows produce equivalent replay traces.
