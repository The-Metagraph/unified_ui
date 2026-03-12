# Phase 26 - Replay Baseline Registry and Selection Continuity

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/persistence_replay_contract.md`
- `specs/contracts/service_contract.md`
- `specs/conformance/spec_conformance_matrix.md`

## Relevant Assumptions / Defaults
- Replay baseline identities must be deterministic for equivalent replay logs.
- Baseline registries must preserve deterministic ordering/selection under equivalent capture flows.
- Missing or malformed baseline registry inputs must fail closed with typed validation errors.

[x] 26 Phase 26 - Replay Baseline Registry and Selection Continuity
  Add deterministic baseline registry and active-baseline selection controls for replay gate continuity across multiple captured baselines.

  [x] 26.1 Section - Baseline Identity and Registry Primitives
    Extend persistence helpers with deterministic baseline IDs and registry upsert/selection behaviors.

    [x] 26.1.1 Task - Implement baseline identity and registry APIs
      Provide typed APIs to assign deterministic baseline IDs and maintain baseline registries with retention controls.

      [x] 26.1.1.1 Subtask - Implement deterministic `baseline_id` generation in replay baseline capture/normalization.
      [x] 26.1.1.2 Subtask - Implement `ReplayBaselineRegistry` persistence helpers for upsert/list/fetch/activate flows.
      [x] 26.1.1.3 Subtask - Implement persistence unit tests for baseline ID alignment and registry retention/selection behavior.

  [x] 26.2 Section - Runtime Baseline Registry Integration
    Integrate baseline registry persistence and active-baseline selection into runtime message handling.

    [x] 26.2.1 Task - Implement runtime baseline registry flow
      Capture baselines into deterministic registries, allow explicit active-baseline selection, and gate against selected baselines.

      [x] 26.2.1.1 Subtask - Implement runtime baseline capture registry upsert and retention controls.
      [x] 26.2.1.2 Subtask - Implement runtime active-baseline selection and fallback gate resolution.
      [x] 26.2.1.3 Subtask - Implement runtime tests for baseline registry and selection behavior.

  [x] 26.3 Section - Scenario and Matrix Mapping
    Register replay baseline registry continuity in conformance coverage.

    [x] 26.3.1 Task - Implement conformance mappings for replay baseline registry continuity
      Add canonical scenario coverage for deterministic baseline registry ordering, activation, and gate selection behavior.

      [x] 26.3.1.1 Subtask - Implement `SCN-031` scenario-catalog entry for replay baseline registry continuity.
      [x] 26.3.1.2 Subtask - Implement matrix updates linking `SCN-031` to persistence replay requirement families.
      [x] 26.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 26.

  [x] 26.4 Section - Phase 26 Integration Tests
    Validate baseline registry and active-baseline gate behavior through conformance-tagged runtime flows.

    [x] 26.4.1 Task - Replay baseline registry conformance scenarios
      Verify deterministic registry retention ordering, active-baseline gate selection, and equivalent-flow registry trace continuity.

      [x] 26.4.1.1 Subtask - Verify `SCN-031` equivalent capture flows produce deterministic baseline registry ordering.
      [x] 26.4.1.2 Subtask - Verify `SCN-031` baseline activation/gate paths produce deterministic pass/fail diagnostics.
      [x] 26.4.1.3 Subtask - Verify `SCN-031` repeated equivalent registry flows produce equivalent registry traces.
