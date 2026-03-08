# Phase 32 - Canonical Unified-IUR Nested Default Profile Parity

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/service_contract.md`
- `specs/contracts/widget_system_contract.md`
- `specs/events/event_type_catalog.md`
- `specs/conformance/spec_conformance_matrix.md`
- `https://github.com/pcharbon70/unified_iur`

## Relevant Assumptions / Defaults
- Canonical `UnifiedIUR.*` descriptors remain the source authority for structure and signal fields.
- Deep parity must include nested descriptor defaults (for example nested column/style defaults), not only top-level descriptor fields.
- Nested default pruning must preserve non-default nested render values and deterministic event outputs.

[ ] 32 Phase 32 - Canonical Unified-IUR Nested Default Profile Parity
  Normalize nested canonical default profiles so equivalent struct/map nested descriptors produce identical interpreted deep descriptor trees.

  [x] 32.1 Section - Nested Default Profile Primitives
    Define deterministic nested default-pruning profiles for canonical nested descriptor values.

    [x] 32.1.1 Task - Implement canonical nested default profile helpers
      Introduce explicit nested default-pruning helpers for recurring nested canonical payloads.

      [x] 32.1.1.1 Subtask - Implement nested default profiles for canonical style and table-column payloads.
      [x] 32.1.1.2 Subtask - Implement deterministic nested default-pruning helpers preserving non-default values.
      [x] 32.1.1.3 Subtask - Implement focused unit tests for nested default-pruning primitives.

  [x] 32.2 Section - Nested Default Integration
    Integrate nested default profiles into descriptor canonicalization and interpreter parity flows.

    [x] 32.2.1 Task - Implement nested default parity in interpreted descriptors
      Ensure nested canonical struct/map payloads with default-only differences normalize to identical descriptor values.

      [x] 32.2.1.1 Subtask - Implement descriptor canonicalization integration for nested default profiles.
      [x] 32.2.1.2 Subtask - Implement interpreter parity tests for nested table column/style default normalization.
      [x] 32.2.1.3 Subtask - Implement regression checks preserving existing deep parity and event semantics.

  [x] 32.3 Section - Scenario and Matrix Mapping
    Register nested default profile parity behavior in conformance coverage.

    [x] 32.3.1 Task - Implement conformance mappings for nested default profile parity continuity
      Add scenario coverage for deterministic nested default normalization under canonical struct/map interpretation.

      [x] 32.3.1.1 Subtask - Implement `SCN-037` scenario-catalog entry for nested default profile parity continuity.
      [x] 32.3.1.2 Subtask - Implement matrix updates linking `SCN-037` to service/widget requirement families.
      [x] 32.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 32.

  [ ] 32.4 Section - Phase 32 Integration Tests
    Validate nested default profile parity through conformance-tagged runtime flows.

    [ ] 32.4.1 Task - Nested default profile parity conformance scenarios
      Verify deterministic nested parity, fail-closed malformed payload handling, and repeated-flow stability.

      [ ] 32.4.1.1 Subtask - Verify `SCN-037` equivalent canonical nested inputs with default-profile differences produce identical snapshots.
      [ ] 32.4.1.2 Subtask - Verify `SCN-037` malformed nested payloads fail closed with typed validation errors.
      [ ] 32.4.1.3 Subtask - Verify `SCN-037` repeated equivalent interpretation flows produce identical snapshots.
