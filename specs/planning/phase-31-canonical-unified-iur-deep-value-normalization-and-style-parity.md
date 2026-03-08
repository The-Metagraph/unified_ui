# Phase 31 - Canonical Unified-IUR Deep Value Normalization and Style Parity

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/service_contract.md`
- `specs/contracts/widget_system_contract.md`
- `specs/events/event_type_catalog.md`
- `specs/conformance/spec_conformance_matrix.md`
- `https://github.com/pcharbon70/unified_iur`

## Relevant Assumptions / Defaults
- Canonical `UnifiedIUR.*` descriptors remain the source authority for structure and signal fields.
- Equivalent canonical struct/map descriptors must remain parity-equivalent across nested prop values, not only top-level props.
- Style metadata (`UnifiedIUR.Style` structs and style maps) should normalize to the same canonical map shape.

[ ] 31 Phase 31 - Canonical Unified-IUR Deep Value Normalization and Style Parity
  Normalize nested canonical prop values so equivalent struct/map descriptors produce deeply parity-equivalent interpreted outputs.

  [x] 31.1 Section - Deep Value Normalization Primitives
    Define deterministic deep-value normalization for nested maps/lists/structs used in canonical widget props.

    [x] 31.1.1 Task - Implement deep canonical value normalization helpers
      Introduce canonical recursive value normalization to align nested struct and map representations.

      [x] 31.1.1.1 Subtask - Implement recursive normalization for nested maps/lists with key normalization.
      [x] 31.1.1.2 Subtask - Implement struct-to-map canonicalization for nested canonical values.
      [x] 31.1.1.3 Subtask - Implement focused unit tests for deep value normalization primitives.

  [x] 31.2 Section - Style and Nested-Prop Parity Integration
    Integrate deep value normalization into descriptor default canonicalization and interpreter outputs.

    [x] 31.2.1 Task - Implement canonical style/nested-prop parity in interpreted descriptors
      Ensure equivalent nested struct/map props (including style payloads) normalize to identical descriptor values.

      [x] 31.2.1.1 Subtask - Implement integration of deep value normalization in descriptor default canonicalization flow.
      [x] 31.2.1.2 Subtask - Implement interpreter parity tests for canonical style struct/map equivalence.
      [x] 31.2.1.3 Subtask - Implement regression checks preserving existing default-prop and event semantics.

  [x] 31.3 Section - Scenario and Matrix Mapping
    Register deep value/style parity behavior in conformance coverage.

    [x] 31.3.1 Task - Implement conformance mappings for deep value/style parity continuity
      Add scenario coverage for deterministic nested-value parity behavior under canonical struct/map interpretation.

      [x] 31.3.1.1 Subtask - Implement `SCN-036` scenario-catalog entry for deep value/style parity continuity.
      [x] 31.3.1.2 Subtask - Implement matrix updates linking `SCN-036` to service/widget requirement families.
      [x] 31.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 31.

  [ ] 31.4 Section - Phase 31 Integration Tests
    Validate deep value/style parity through conformance-tagged runtime flows.

    [ ] 31.4.1 Task - Deep value/style parity conformance scenarios
      Verify deterministic deep descriptor parity, fail-closed malformed nested payload handling, and repeated-flow stability.

      [ ] 31.4.1.1 Subtask - Verify `SCN-036` equivalent canonical nested struct/map inputs produce identical descriptor and event snapshots.
      [ ] 31.4.1.2 Subtask - Verify `SCN-036` malformed nested payloads fail closed with typed validation errors.
      [ ] 31.4.1.3 Subtask - Verify `SCN-036` repeated equivalent interpretation flows produce identical deep snapshots.
