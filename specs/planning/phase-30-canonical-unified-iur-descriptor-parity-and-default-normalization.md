# Phase 30 - Canonical Unified-IUR Descriptor Parity and Default Normalization

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/service_contract.md`
- `specs/contracts/widget_system_contract.md`
- `specs/events/event_type_catalog.md`
- `specs/conformance/spec_conformance_matrix.md`
- `https://github.com/pcharbon70/unified_iur`

## Relevant Assumptions / Defaults
- Canonical `UnifiedIUR.*` descriptors remain the source authority for structure and signal fields.
- Equivalent struct/map canonical inputs should normalize to identical descriptor trees, not only equivalent event traces.
- Default-only canonical widget props should be normalized to a deterministic minimal descriptor shape.

[ ] 30 Phase 30 - Canonical Unified-IUR Descriptor Parity and Default Normalization
  Normalize canonical default widget props to guarantee full descriptor parity for equivalent canonical struct and map interpretation flows.

  [x] 30.1 Section - Default-Prop Canonicalization Primitives
    Define deterministic default-prop filtering primitives for canonical widget descriptor normalization.

    [x] 30.1.1 Task - Implement canonical widget default-prop filters
      Introduce explicit default maps and canonical prop-pruning rules used by interpreter widget normalization.

      [x] 30.1.1.1 Subtask - Implement canonical default maps for covered built-in widget descriptor fields.
      [x] 30.1.1.2 Subtask - Implement deterministic nil/default prop pruning while preserving non-default render fields.
      [x] 30.1.1.3 Subtask - Implement focused unit tests for canonical default-prop normalization primitives.

  [x] 30.2 Section - Extended Descriptor Parity Integration
    Integrate default-prop canonicalization into extended canonical struct/map interpretation paths.

    [x] 30.2.1 Task - Implement full descriptor parity for canonical extended inputs
      Ensure extended canonical struct and map inputs normalize to identical root/widgets/signals/events outputs.

      [x] 30.2.1.1 Subtask - Implement interpreter integration of default-prop canonicalization for widget descriptor output.
      [x] 30.2.1.2 Subtask - Implement parity tests across menu/table/tabs/tree canonical struct/map inputs.
      [x] 30.2.1.3 Subtask - Implement regression checks preserving existing canonical event output semantics.

  [ ] 30.3 Section - Scenario and Matrix Mapping
    Register canonical descriptor-parity behavior in conformance coverage.

    [ ] 30.3.1 Task - Implement conformance mappings for canonical descriptor parity continuity
      Add scenario coverage for deterministic descriptor parity and default-prop normalization behavior.

      [ ] 30.3.1.1 Subtask - Implement `SCN-035` scenario-catalog entry for canonical descriptor parity continuity.
      [ ] 30.3.1.2 Subtask - Implement matrix updates linking `SCN-035` to service/widget requirement families.
      [ ] 30.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 30.

  [ ] 30.4 Section - Phase 30 Integration Tests
    Validate canonical descriptor parity and default normalization through conformance-tagged runtime flows.

    [ ] 30.4.1 Task - Canonical descriptor parity conformance scenarios
      Verify deterministic parity across equivalent struct/map inputs, fail-closed malformed payload handling, and repeated-flow stability.

      [ ] 30.4.1.1 Subtask - Verify `SCN-035` equivalent canonical extended struct/map inputs produce identical descriptor and event traces.
      [ ] 30.4.1.2 Subtask - Verify `SCN-035` malformed extended payloads fail closed with typed validation errors.
      [ ] 30.4.1.3 Subtask - Verify `SCN-035` repeated equivalent canonical interpretation flows produce identical snapshots.
