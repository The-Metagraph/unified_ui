# Phase 33 - Canonical Unified-IUR Collection Normalization and Set Parity

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/service_contract.md`
- `specs/contracts/widget_system_contract.md`
- `specs/events/event_type_catalog.md`
- `specs/conformance/spec_conformance_matrix.md`
- `https://github.com/pcharbon70/unified_iur`

## Relevant Assumptions / Defaults
- Canonical `UnifiedIUR.*` descriptors remain the source authority for structure and signal fields.
- Equivalent struct/map descriptors must normalize collection values into the same portable representation.
- Set-like canonical values (for example `MapSet`) must normalize deterministically and avoid runtime-internal structural leakage.

[x] 33 Phase 33 - Canonical Unified-IUR Collection Normalization and Set Parity
  Normalize canonical collection values into deterministic portable shapes so equivalent struct/map descriptors produce parity-equivalent interpreted outputs.

  [x] 33.1 Section - Collection Normalization Primitives
    Define deterministic canonical collection normalization primitives for nested descriptor values.

    [x] 33.1.1 Task - Implement canonical set/collection normalization helpers
      Introduce explicit normalization for set-like canonical values and deterministic collection ordering behavior.

      [x] 33.1.1.1 Subtask - Implement `MapSet` normalization into deterministic portable list form.
      [x] 33.1.1.2 Subtask - Implement deterministic ordering rules for normalized set-like collections.
      [x] 33.1.1.3 Subtask - Implement focused unit tests for collection normalization primitives.

  [x] 33.2 Section - Collection Parity Integration
    Integrate collection normalization into descriptor canonicalization and interpreter parity flows.

    [x] 33.2.1 Task - Implement collection parity for interpreted descriptors
      Ensure equivalent struct/map collection payloads (including set-like values) normalize to identical descriptor values.

      [x] 33.2.1.1 Subtask - Implement descriptor canonicalization integration for collection normalization.
      [x] 33.2.1.2 Subtask - Implement interpreter parity tests for canonical `expanded_nodes` set/list equivalence.
      [x] 33.2.1.3 Subtask - Implement regression checks preserving existing deep parity and event semantics.

  [x] 33.3 Section - Scenario and Matrix Mapping
    Register collection normalization parity behavior in conformance coverage.

    [x] 33.3.1 Task - Implement conformance mappings for collection normalization continuity
      Add scenario coverage for deterministic collection normalization under canonical struct/map interpretation.

      [x] 33.3.1.1 Subtask - Implement `SCN-038` scenario-catalog entry for collection normalization parity continuity.
      [x] 33.3.1.2 Subtask - Implement matrix updates linking `SCN-038` to service/widget requirement families.
      [x] 33.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 33.

  [x] 33.4 Section - Phase 33 Integration Tests
    Validate collection normalization parity through conformance-tagged runtime flows.

    [x] 33.4.1 Task - Collection normalization parity conformance scenarios
      Verify deterministic collection parity, fail-closed malformed payload handling, and repeated-flow stability.

      [x] 33.4.1.1 Subtask - Verify `SCN-038` equivalent canonical set/list inputs produce identical interpreted snapshots.
      [x] 33.4.1.2 Subtask - Verify `SCN-038` malformed payloads fail closed with typed validation errors.
      [x] 33.4.1.3 Subtask - Verify `SCN-038` repeated equivalent interpretation flows produce identical snapshots.
