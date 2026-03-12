# Phase 25 - Replay Baseline Capture and Gate Continuity

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/persistence_replay_contract.md`
- `specs/contracts/service_contract.md`
- `specs/conformance/spec_conformance_matrix.md`

## Relevant Assumptions / Defaults
- Replay baselines must be deterministic envelopes around replay exports and stable metadata.
- Baseline gate evaluations must remain deterministic for equivalent replay logs, baselines, and policy inputs.
- Malformed baseline payloads must fail closed before any recovery diagnostics are mutated.

[x] 25 Phase 25 - Replay Baseline Capture and Gate Continuity
  Add deterministic replay baseline capture and baseline-gate controls for runtime recovery diagnostics and release continuity.

  [x] 25.1 Section - Replay Baseline Primitives
    Extend replay-log helpers with deterministic baseline capture and baseline-gate evaluation behavior.

    [x] 25.1.1 Task - Implement replay baseline capture and gate APIs
      Provide typed helper APIs for baseline envelopes and policy-evaluated baseline verification summaries.

      [x] 25.1.1.1 Subtask - Implement `ReplayLog.capture_baseline/2` with deterministic baseline envelope fields.
      [x] 25.1.1.2 Subtask - Implement `ReplayLog.gate_baseline/3` with fail-closed baseline payload validation.
      [x] 25.1.1.3 Subtask - Implement replay-log unit tests for baseline capture, pass/fail gating, and malformed baseline errors.

  [x] 25.2 Section - Runtime Baseline Gate Integration
    Integrate replay baseline capture and gate controls into runtime message handling.

    [x] 25.2.1 Task - Implement replay baseline runtime flow
      Accept typed baseline capture and baseline gate requests and persist deterministic baseline diagnostics in recovery state.

      [x] 25.2.1.1 Subtask - Implement runtime baseline capture and gate request handling.
      [x] 25.2.1.2 Subtask - Implement deterministic recovery diagnostics/notices for baseline capture and gate outcomes.
      [x] 25.2.1.3 Subtask - Implement runtime tests for baseline capture and gate behavior.

  [x] 25.3 Section - Scenario and Matrix Mapping
    Register replay baseline gate continuity in conformance coverage.

    [x] 25.3.1 Task - Implement conformance mappings for replay baseline continuity
      Add canonical scenario coverage for replay baseline capture, baseline gate policy evaluation, and deterministic reason diagnostics.

      [x] 25.3.1.1 Subtask - Implement `SCN-030` scenario-catalog entry for replay baseline continuity.
      [x] 25.3.1.2 Subtask - Implement matrix updates linking `SCN-030` to persistence replay requirement families.
      [x] 25.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 25.

  [x] 25.4 Section - Phase 25 Integration Tests
    Validate replay baseline capture/gate behavior through conformance-tagged runtime flows.

    [x] 25.4.1 Task - Replay baseline conformance scenarios
      Verify deterministic baseline envelopes, baseline gate pass/fail diagnostics, and equivalent-flow baseline gate trace continuity.

      [x] 25.4.1.1 Subtask - Verify `SCN-030` equivalent replay flows produce deterministic baseline capture envelopes.
      [x] 25.4.1.2 Subtask - Verify `SCN-030` baseline drift paths produce deterministic baseline gate fail reason sets.
      [x] 25.4.1.3 Subtask - Verify `SCN-030` repeated equivalent baseline gate evaluations produce equivalent baseline gate traces.
