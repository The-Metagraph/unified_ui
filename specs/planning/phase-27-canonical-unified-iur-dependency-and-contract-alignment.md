# Phase 27 - Canonical Unified-IUR Dependency and Contract Alignment

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/service_contract.md`
- `specs/contracts/widget_system_contract.md`
- `specs/events/event_type_catalog.md`
- `specs/conformance/spec_conformance_matrix.md`
- `https://github.com/pcharbon70/unified_iur`

## Relevant Assumptions / Defaults
- Unified-IUR format/schema authority is external and canonical in `unified_iur`.
- `web_ui` MUST interpret canonical Unified-IUR structures and MUST NOT redefine base schema ownership.
- Schema/source drift and unsupported Unified-IUR inputs must fail closed with typed validation errors.

[ ] 27 Phase 27 - Canonical Unified-IUR Dependency and Contract Alignment
  Enforce canonical Unified-IUR dependency authority across runtime interpretation, contracts, and conformance coverage.

  [x] 27.1 Section - Dependency and Compatibility Baseline
    Establish deterministic dependency strategy and compatibility expectations for Unified-IUR consumption.

    [x] 27.1.1 Task - Implement canonical Unified-IUR dependency policy
      Define pinned dependency/update policy and deterministic compatibility boundaries for `web_ui` runtime usage.

      [x] 27.1.1.1 Subtask - Implement explicit dependency pin/update policy for `unified_iur` (tag or commit-based strategy).
      [x] 27.1.1.2 Subtask - Implement compatibility checks for canonical Unified-IUR struct/map ingestion.
      [x] 27.1.1.3 Subtask - Implement unit tests for dependency-version and compatibility guard behavior.

  [ ] 27.2 Section - Runtime Interpreter Integration
    Integrate canonical Unified-IUR structures directly in runtime interpretation and signal extraction flows.

    [ ] 27.2.1 Task - Implement canonical Unified-IUR runtime integration
      Ensure interpreter paths consume canonical `UnifiedIUR.*` descriptors deterministically and preserve existing event compatibility.

      [ ] 27.2.1.1 Subtask - Implement explicit normalization paths for canonical `UnifiedIUR.*` structs.
      [ ] 27.2.1.2 Subtask - Implement fail-closed validation for unsupported schema/source markers.
      [ ] 27.2.1.3 Subtask - Implement runtime tests covering canonical struct ingestion and deterministic signal mapping.

  [ ] 27.3 Section - Scenario and Matrix Mapping
    Register canonical Unified-IUR dependency behavior in conformance coverage.

    [ ] 27.3.1 Task - Implement conformance mappings for canonical Unified-IUR continuity
      Add scenario coverage validating external schema authority, deterministic interpretation continuity, and fail-closed drift handling.

      [ ] 27.3.1.1 Subtask - Implement `SCN-032` scenario-catalog entry for canonical Unified-IUR dependency continuity.
      [ ] 27.3.1.2 Subtask - Implement matrix updates linking `SCN-032` to service/widget requirement families.
      [ ] 27.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 27.

  [ ] 27.4 Section - Phase 27 Integration Tests
    Validate canonical Unified-IUR dependency handling through conformance-tagged runtime flows.

    [ ] 27.4.1 Task - Canonical Unified-IUR conformance scenarios
      Verify deterministic canonical-struct interpretation, source/version guardrails, and equivalent-flow trace stability.

      [ ] 27.4.1.1 Subtask - Verify `SCN-032` equivalent canonical Unified-IUR inputs produce deterministic runtime descriptor trees.
      [ ] 27.4.1.2 Subtask - Verify `SCN-032` unsupported schema/source inputs fail closed with typed validation errors.
      [ ] 27.4.1.3 Subtask - Verify `SCN-032` repeated equivalent canonical interpretation flows produce equivalent traces.
