# Phase 20 - Persistence Replay Determinism and Checkpointing

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/persistence_replay_contract.md`
- `specs/contracts/service_contract.md`
- `specs/contracts/turn_execution_contract.md`
- `specs/conformance/spec_conformance_matrix.md`

## Relevant Assumptions / Defaults
- Replay logs are deterministic traces for recovery/reconciliation, not alternate state authorities.
- Replay checkpoints must be reproducible for equivalent event flows.
- Replay bookkeeping failures must fail closed without mutating domain authority semantics.

[x] 20 Phase 20 - Persistence Replay Determinism and Checkpointing
  Add deterministic persistence-replay logging and checkpoint semantics for runtime dispatch and reconciliation.

  [x] 20.1 Section - Replay Log Baseline
    Introduce a replay-log helper module with deterministic append and checkpoint semantics.

    [x] 20.1.1 Task - Implement replay log primitives
      Provide append, checkpoint, and slicing helpers with typed fail-closed validation.

      [x] 20.1.1.1 Subtask - Implement `WebUi.Persistence.ReplayLog` log-state and append behavior.
      [x] 20.1.1.2 Subtask - Implement deterministic checkpoint ID generation and cursor-based slicing.
      [x] 20.1.1.3 Subtask - Implement replay-log unit tests for deterministic and malformed-input behavior.

  [x] 20.2 Section - Runtime Replay Integration
    Integrate replay bookkeeping into runtime dispatch and result reconciliation flows.

    [x] 20.2.1 Task - Implement runtime replay cursor and checkpoint propagation
      Track replay cursor/checkpoint state in recovery metadata and append outbound/inbound replay entries.

      [x] 20.2.1.1 Subtask - Implement runtime dispatch replay append behavior.
      [x] 20.2.1.2 Subtask - Implement result reconciliation replay append behavior and checkpoint updates.
      [x] 20.2.1.3 Subtask - Implement runtime tests for replay cursor/checkpoint progression.

  [x] 20.3 Section - Scenario and Matrix Mapping
    Register persistence-replay behavior in conformance coverage.

    [x] 20.3.1 Task - Implement conformance mappings for replay determinism
      Add canonical scenario coverage for replay cursor/checkpoint continuity.

      [x] 20.3.1.1 Subtask - Implement `SCN-025` scenario-catalog entry for replay checkpoint continuity.
      [x] 20.3.1.2 Subtask - Implement matrix updates linking `SCN-025` to service/persistence replay families.
      [x] 20.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 20.

  [x] 20.4 Section - Phase 20 Integration Tests
    Validate replay append/checkpoint behavior end-to-end through runtime conformance flows.

    [x] 20.4.1 Task - Replay determinism conformance scenarios
      Verify deterministic replay cursor progression, checkpoint updates, and equivalent-flow trace stability.

      [x] 20.4.1.1 Subtask - Verify `SCN-025` dispatch/result flows advance replay cursor deterministically.
      [x] 20.4.1.2 Subtask - Verify `SCN-025` checkpoint identifiers evolve deterministically with replay appends.
      [x] 20.4.1.3 Subtask - Verify `SCN-025` repeated equivalent flows produce equivalent replay traces.
