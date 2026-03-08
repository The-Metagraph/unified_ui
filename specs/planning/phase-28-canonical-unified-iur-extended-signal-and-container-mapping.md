# Phase 28 - Canonical Unified-IUR Extended Signal and Container Mapping

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/service_contract.md`
- `specs/contracts/widget_system_contract.md`
- `specs/events/event_type_catalog.md`
- `specs/conformance/spec_conformance_matrix.md`
- `https://github.com/pcharbon70/unified_iur`

## Relevant Assumptions / Defaults
- Canonical `UnifiedIUR.*` descriptors remain the source authority for structure and signal fields.
- Extended signal mappings (menu/table/tabs/tree) must normalize into canonical `unified.*` event envelopes deterministically.
- Container widgets carrying child descriptors must preserve deterministic traversal and fail closed on malformed child payloads.

[x] 28 Phase 28 - Canonical Unified-IUR Extended Signal and Container Mapping
  Extend canonical Unified-IUR interpretation with deterministic container child traversal and extended signal/event mappings.

  [x] 28.1 Section - Extended Event Binding Primitives
    Expand Elm binding helpers for canonical extended widget event families used by Unified-IUR descriptors.

    [x] 28.1.1 Task - Implement extended canonical event binding APIs
      Provide typed helper APIs for menu, table, tabs, and tree signal mappings to canonical `unified.*` event types.

      [x] 28.1.1.1 Subtask - Implement extended Elm binding helpers for menu/table/tabs/tree event families.
      [x] 28.1.1.2 Subtask - Implement fail-closed validation for required extended signal payload fields.
      [x] 28.1.1.3 Subtask - Implement unit tests for deterministic extended event binding behavior.

  [x] 28.2 Section - Interpreter Container and Signal Integration
    Integrate container widget child traversal and extended signal extraction into canonical Unified-IUR interpretation.

    [x] 28.2.1 Task - Implement container-aware canonical interpreter flow
      Normalize canonical container widgets with deterministic child descriptor traversal and map extended signal fields into event envelopes.

      [x] 28.2.1.1 Subtask - Implement deterministic traversal for canonical container widgets (`menu`, `tabs`, `tree_view`, etc.).
      [x] 28.2.1.2 Subtask - Implement interpreter mappings for `action`, `on_row_select`, `on_sort`, `on_change`, `on_select`, and `on_toggle`.
      [x] 28.2.1.3 Subtask - Implement interpreter tests for extended canonical container/signal behavior.

  [x] 28.3 Section - Scenario and Matrix Mapping
    Register canonical Unified-IUR extended mapping behavior in conformance coverage.

    [x] 28.3.1 Task - Implement conformance mappings for extended canonical IUR continuity
      Add scenario coverage for deterministic extended signal mapping and container descriptor traversal behavior.

      [x] 28.3.1.1 Subtask - Implement `SCN-033` scenario-catalog entry for canonical extended IUR mapping continuity.
      [x] 28.3.1.2 Subtask - Implement matrix updates linking `SCN-033` to service/widget requirement families.
      [x] 28.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 28.

  [x] 28.4 Section - Phase 28 Integration Tests
    Validate canonical extended signal/container interpretation through conformance-tagged runtime flows.

    [x] 28.4.1 Task - Canonical extended IUR conformance scenarios
      Verify deterministic extended event mapping outputs, fail-closed malformed signal handling, and equivalent-flow trace stability.

      [x] 28.4.1.1 Subtask - Verify `SCN-033` equivalent extended canonical IUR inputs produce deterministic event traces.
      [x] 28.4.1.2 Subtask - Verify `SCN-033` malformed extended signal payloads fail closed with typed validation errors.
      [x] 28.4.1.3 Subtask - Verify `SCN-033` repeated equivalent extended interpretation flows produce equivalent traces.
