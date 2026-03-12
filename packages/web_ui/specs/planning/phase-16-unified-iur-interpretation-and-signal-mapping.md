# Phase 16 - Unified IUR Interpretation and Signal Mapping

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/service_contract.md`
- `specs/contracts/widget_system_contract.md`
- `specs/events/event_type_catalog.md`
- `specs/conformance/spec_conformance_matrix.md`

## Relevant Assumptions / Defaults
- `unified_iur` structures are treated as transport-adjacent input descriptors, not as runtime authority.
- IUR interpretation must remain deterministic for equivalent inputs.
- Signal extraction must preserve canonical `unified.*` event compatibility.

[x] 16 Phase 16 - Unified IUR Interpretation and Signal Mapping
  Introduce a deterministic interpretation baseline for Unified-IUR layouts and signal definitions to WebUi runtime/event structures.

  [x] 16.1 Section - IUR Normalization Baseline
    Normalize IUR layout/widget trees into deterministic runtime-friendly descriptors with stable IDs.

    [x] 16.1.1 Task - Implement IUR interpreter tree normalization
      Add a baseline interpreter module that accepts map/struct IUR shapes and emits normalized layout/widget trees.

      [x] 16.1.1.1 Subtask - Implement `WebUi.Iur.Interpreter.interpret/2` with deterministic layout/widget node normalization.
      [x] 16.1.1.2 Subtask - Implement deterministic auto-ID generation and type inference for map/struct inputs.
      [x] 16.1.1.3 Subtask - Implement unit tests for normalization and fail-closed validation behavior.

  [x] 16.2 Section - Signal Extraction and Event Mapping
    Project widget signal definitions into canonical event envelopes validated against the event catalog.

    [x] 16.2.1 Task - Implement IUR signal-to-event mapping
      Convert IUR signal fields (`on_click`, `on_change`, `on_submit`) into canonical event payloads.

      [x] 16.2.1.1 Subtask - Implement button and text-input signal extraction.
      [x] 16.2.1.2 Subtask - Implement event payload normalization and event-catalog validation.
      [x] 16.2.1.3 Subtask - Implement unit tests for deterministic signal/event extraction behavior.

  [x] 16.3 Section - Scenario and Matrix Mapping
    Register Unified-IUR interpretation behavior in conformance coverage.

    [x] 16.3.1 Task - Implement scenario-catalog and matrix mapping for IUR interpretation
      Add canonical scenario coverage for deterministic IUR interpretation and signal mapping.

      [x] 16.3.1.1 Subtask - Implement `SCN-021` scenario-catalog entry for IUR interpretation continuity.
      [x] 16.3.1.2 Subtask - Implement matrix mapping updates linking `SCN-021` to service/widget coverage.
      [x] 16.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 16.

  [x] 16.4 Section - Phase 16 Integration Tests
    Validate IUR interpretation and signal extraction end-to-end under conformance flows.

    [x] 16.4.1 Task - IUR interpretation conformance scenarios
      Verify deterministic layout normalization, signal extraction, and event payload continuity.

      [x] 16.4.1.1 Subtask - Verify `SCN-021` normalizes equivalent IUR inputs deterministically.
      [x] 16.4.1.2 Subtask - Verify `SCN-021` extracts canonical button/text-input events from IUR signals.
      [x] 16.4.1.3 Subtask - Verify `SCN-021` fail-closed behavior on malformed IUR descriptors.
