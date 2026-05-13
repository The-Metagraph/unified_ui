# Phase 5 - Examples, Tooling, Documentation, and Conformance

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- root `examples/` catalog and example apps
- package inspection, export, and validation tasks
- package README and guide documentation
- `.spec/planning/*/spec-traceability.json`
- `.spec/conformance/*/manifest.json`
- `mix spec.plancheck`
- `mix spec.compliance`

## Relevant Assumptions / Defaults
- Examples should demonstrate the canonical authored path and runtime-native
  equivalents without making AshUi the owner of the final widget contracts.
- Traceability and conformance evidence remain separate from authored specs and
  generated state.
- Generated traceability markdown should be regenerated from JSON manifests,
  not hand-edited.

[ ] 5 Phase 5 - Examples, Tooling, Documentation, and Conformance
  Finish the promoted widget rollout with maintained examples, package tooling,
  documentation, traceability mappings, conformance evidence, and migration
  guidance for AshUi or other integration consumers.

  [x] 5.1 Section - Maintained Examples and Review Fixtures
    Add example coverage that demonstrates the promoted widgets across
    authored, canonical, native, and degraded runtime paths.

    [x] 5.1.1 Task - Add focused widget examples for the promoted surface
      Build maintained examples that make each promoted widget family visible
      to reviewers and downstream users.

      [x] 5.1.1.1 Subtask - Add examples for semantic micro widgets, workflow/document widgets, host-owned form shell, and chat composer flows.
      [x] 5.1.1.2 Subtask - Add repeated collection examples that render artifact rows, workflow rows, and row-level actions from list-oriented data.
      [x] 5.1.1.3 Subtask - Register examples in the root catalog with metadata for authored DSL, canonical IUR, and runtime coverage.

    [x] 5.1.2 Task - Add cross-runtime review fixtures
      Provide review artifacts that compare canonical meaning across runtime
      realizations.

      [x] 5.1.2.1 Subtask - Add fixtures that show authored `UnifiedUi`, exported `UnifiedIUR`, and runtime outputs for the same promoted widget examples.
      [x] 5.1.2.2 Subtask - Add fixture coverage for terminal and other constrained-runtime degradation.
      [x] 5.1.2.3 Subtask - Add snapshot or structured-output tests that keep review fixtures deterministic.

  [x] 5.2 Section - Tooling and Validation Workflows
    Extend package tooling so promoted widget support is visible and
    enforceable.

    [x] 5.2.1 Task - Extend inspection, export, and reporting tasks
      Make promoted widget and repeated collection support obvious in existing
      package tooling.

      [x] 5.2.1.1 Subtask - Extend `unified_ui`, `unified_iur`, and runtime inspection tasks to show promoted widget support, degradation status, and row-scope binding summaries.
      [x] 5.2.1.2 Subtask - Extend export tasks so promoted widget fixtures and repeated collection constructs are available for runtime review.
      [x] 5.2.1.3 Subtask - Add reporting output that identifies which runtimes have native support, IUR support, degraded support, or missing support for each promoted widget.

    [x] 5.2.2 Task - Extend validation and release-readiness gates
      Guard the rollout with automated checks instead of relying on examples
      alone.

      [x] 5.2.2.1 Subtask - Add validation that fails when a promoted canonical widget lacks a `UnifiedUi` authoring contract, `UnifiedIUR` representation, or required runtime renderer entry.
      [x] 5.2.2.2 Subtask - Add validation that fails when repeated collection row-scope bindings are dropped or rewritten into renderer-local callback shapes.
      [x] 5.2.2.3 Subtask - Add release-readiness checks for runtime parity matrix coverage, degradation diagnostics, and example catalog coverage.

  [x] 5.3 Section - Documentation, Traceability, and Conformance
    Update durable guidance and evidence so the promoted surface is
    maintainable after implementation.

    [x] 5.3.1 Task - Update user, developer, and runtime documentation
      Document the promoted widget surface and the boundaries between
      canonical, runtime, and integration-package responsibilities.

      [x] 5.3.1.1 Subtask - Update `UnifiedUi` and `UnifiedIUR` documentation with canonical widget names, repeated collection authoring, row-scope bindings, and host-owned form shell semantics.
      [x] 5.3.1.2 Subtask - Update runtime package documentation with native usage, IUR rendering behavior, host form lifecycle integration, and degradation notes.
      [x] 5.3.1.3 Subtask - Add migration guidance for AshUi showing how local widget proposals map to canonical equivalents and what remains AshUi-owned.

    [x] 5.3.2 Task - Update planning traceability and conformance manifests
      Make the new spec requirements visible in the package planning and
      conformance layers.

      [x] 5.3.2.1 Subtask - Update package planning JSON manifests for `unified_ui`, `unified_iur`, `live_ui`, `elm_ui`, `desktop_ui`, and `terminal_ui` so promoted widget requirements map to this rollout.
      [x] 5.3.2.2 Subtask - Regenerate traceability markdown mirrors with `mix spec.traceability.generate <package>` rather than hand-editing generated files.
      [x] 5.3.2.3 Subtask - Update conformance manifests and compliance evidence once package implementations and tests prove the requirements.

  [ ] 5.4 Section - Phase 5 Integration Tests
    Validate examples, tooling, documentation, traceability, and conformance
    evidence for the complete promoted widget rollout.

    [ ] 5.4.1 Task - Example and tooling integration scenarios
      Verify maintained examples and tooling expose the promoted surface
      consistently across authored, canonical, and runtime layers.

      [ ] 5.4.1.1 Subtask - Verify every promoted widget has at least one maintained example with authored DSL, canonical IUR, and runtime review paths.
      [ ] 5.4.1.2 Subtask - Verify repeated collection examples preserve row-scope binding meaning and row-level interaction payloads.
      [ ] 5.4.1.3 Subtask - Verify inspection, export, reporting, and validation tasks produce deterministic output for promoted widgets and repeated collections.

    [ ] 5.4.2 Task - Documentation and conformance integration scenarios
      Verify durable guidance and conformance evidence match the implemented
      runtime behavior.

      [ ] 5.4.2.1 Subtask - Verify documentation describes canonical, runtime, and AshUi responsibilities without contradicting the ADR.
      [ ] 5.4.2.2 Subtask - Verify package plancheck and compliance reports pass for the promoted widget requirements once implementation evidence is in place.
      [ ] 5.4.2.3 Subtask - Verify generated traceability mirrors, conformance manifests, examples, and runtime parity reports all describe the same promoted widget support matrix.
