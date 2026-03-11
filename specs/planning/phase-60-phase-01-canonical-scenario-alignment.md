# Phase 60 - Phase 01 Canonical Scenario Alignment

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `test/web_ui/integration/phase_01_transport_test.exs`
- `specs/conformance/phase-01-integration-scenarios.md`
- `specs/conformance/scenario_catalog.md`
- `scripts/run_conformance.sh`

## Relevant Assumptions / Defaults
- Phase-level integration test labels SHOULD reference canonical `SCN-###` identifiers for auditable traceability.
- Phase 01 conformance semantics remain unchanged; this phase normalizes labels only.
- Deterministic conformance and release-readiness validations MUST remain green after label alignment.

[x] 60 Phase 60 - Phase 01 Canonical Scenario Alignment
  Align Phase 01 transport integration test labels to canonical conformance scenario IDs from the scenario catalog.

  [x] 60.1 Section - Phase 01 Transport Test Label Canonicalization
    Replace legacy `SCN-transport-*` labels in Phase 01 transport tests with canonical `SCN-###` identifiers.

    [x] 60.1.1 Task - Map Phase 01 transport tests to canonical scenario IDs
      Keep existing assertions and behavior coverage intact while normalizing test labels.

      [x] 60.1.1.1 Subtask - Map topic-boundary and accepted-ingress tests to `SCN-002`.
      [x] 60.1.1.2 Subtask - Map malformed/unknown-event protocol error tests to `SCN-003`.
      [x] 60.1.1.3 Subtask - Map typed-error and context-continuity tests to `SCN-005` and `SCN-004`.

  [x] 60.2 Section - Planning Index Continuity
    Keep planning index continuity by registering this canonical-label alignment phase.

    [x] 60.2.1 Task - Add Phase 60 planning index entry
      Register Phase 60 in planning README with concise scope summary and link.

      [x] 60.2.1.1 Subtask - Add ordered phase-list item and link for Phase 60.
      [x] 60.2.1.2 Subtask - Preserve phase numbering continuity.
      [x] 60.2.1.3 Subtask - Align wording with canonical label-alignment objective.

  [x] 60.3 Section - Phase 60 Integration Tests
    Verify canonical label normalization keeps deterministic conformance and release-readiness behavior intact.

    [x] 60.3.1 Task - Run deterministic validation suite after label alignment
      Validate that Phase 01 conformance coverage and global report gates remain green.

      [x] 60.3.1.1 Subtask - Verify `mix test test/web_ui/integration/phase_01_transport_test.exs` passes.
      [x] 60.3.1.2 Subtask - Verify `./scripts/run_conformance.sh --report-only` passes.
      [x] 60.3.1.3 Subtask - Verify `./scripts/run_release_readiness.sh --report-only` passes.
