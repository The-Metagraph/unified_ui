# Phase 29 - Canonical Unified-IUR Signal Coercion and Descriptor Hygiene

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/service_contract.md`
- `specs/contracts/widget_system_contract.md`
- `specs/events/event_type_catalog.md`
- `specs/conformance/spec_conformance_matrix.md`
- `https://github.com/pcharbon70/unified_iur`

## Relevant Assumptions / Defaults
- Canonical `UnifiedIUR.*` descriptors remain the source authority for structure and signal fields.
- Signal payloads from canonical descriptors may carry atom/string primitives and must normalize deterministically.
- Interpreted widget descriptors must separate event-signal configuration from render props.

[ ] 29 Phase 29 - Canonical Unified-IUR Signal Coercion and Descriptor Hygiene
  Normalize canonical signal payload primitives and descriptor props so equivalent input semantics produce stable interpreted outputs.

  [x] 29.1 Section - Signal Payload Primitive Coercion
    Extend canonical signal extraction to normalize atom/string payload primitives consistently before event mapping.

    [x] 29.1.1 Task - Implement deterministic canonical signal primitive coercion
      Support canonical atom/string primitive inputs for extended signal payload fields while preserving fail-closed invalid-shape handling.

      [x] 29.1.1.1 Subtask - Implement canonical string-like coercion for `action_id`, `column`, `tab_id`, and `node_id` fields.
      [x] 29.1.1.2 Subtask - Implement canonical coercion for row index and expanded-state primitives used by extended signals.
      [x] 29.1.1.3 Subtask - Implement unit tests for deterministic atom/string primitive coercion in extended signal mappings.

  [x] 29.2 Section - Descriptor Prop Hygiene
    Prevent event-signal configuration fields from leaking into normalized widget `props` descriptors.

    [x] 29.2.1 Task - Implement canonical signal-field prop stripping
      Ensure interpreter output keeps signal definitions in `signals/events` while preserving render-facing widget properties.

      [x] 29.2.1.1 Subtask - Implement signal-field exclusion for all mapped widget signal keys in widget prop normalization.
      [x] 29.2.1.2 Subtask - Implement unit tests verifying signal fields are excluded from normalized widget `props`.
      [x] 29.2.1.3 Subtask - Implement parity checks confirming event output remains unchanged after prop hygiene updates.

  [x] 29.3 Section - Scenario and Matrix Mapping
    Register canonical signal coercion and descriptor hygiene behavior in conformance coverage.

    [x] 29.3.1 Task - Implement conformance mappings for canonical signal coercion continuity
      Add scenario coverage for deterministic primitive coercion and signal-prop separation behavior.

      [x] 29.3.1.1 Subtask - Implement `SCN-034` scenario-catalog entry for canonical signal coercion and descriptor hygiene continuity.
      [x] 29.3.1.2 Subtask - Implement matrix updates linking `SCN-034` to service/widget requirement families.
      [x] 29.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 29.

  [ ] 29.4 Section - Phase 29 Integration Tests
    Validate canonical signal coercion and descriptor hygiene through conformance-tagged runtime flows.

    [ ] 29.4.1 Task - Canonical signal coercion and descriptor hygiene conformance scenarios
      Verify deterministic coercion/parity behavior, fail-closed invalid primitive handling, and equivalent-flow trace stability.

      [ ] 29.4.1.1 Subtask - Verify `SCN-034` equivalent canonical inputs with atom/string primitives produce deterministic event traces.
      [ ] 29.4.1.2 Subtask - Verify `SCN-034` invalid primitive payloads fail closed with typed validation errors.
      [ ] 29.4.1.3 Subtask - Verify `SCN-034` repeated equivalent interpretation flows produce equivalent traces and descriptor props.
