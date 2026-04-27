# Phase 18 - Focused Example Alignment and Demo Retirement

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Tooling`
- `LiveUi.Examples`
- `LiveUi.Demo`
- `LiveUi.Info`
- `LiveUi.Reference`
- `LiveUi.Renderer`
- `LiveUi.Runtime`
- `LiveUi.Component`
- `UnifiedExamples.*`
- `mix live_ui.preview`
- `mix live_ui.inspect`
- `mix live_ui.export`
- `mix live_ui.validate`

## Relevant Assumptions / Defaults
- The repository `examples/` inventory is now the authoritative widget-focused example catalog for the ecosystem.
- `live_ui` should specialize that same inventory for direct native runtime review instead of maintaining a second demo/workbench or divergent example taxonomy.
- Native `live_ui` widget usage remains the primary package-specialized example path, while canonical `UnifiedIUR` review, transport inspection, and continuity checks remain available as maintainer tooling on the same example ids.
- This phase is expected to retire the current package-local demo/workbench and the small native/canonical/mixed package-owned example catalog once aligned focused examples replace them.

[ ] 18 Phase 18 - Focused Example Alignment and Demo Retirement
  Replace the current package-local demo and divergent example catalog with the same focused widget example inventory used by the repository suite, specialized for direct native `live_ui` widgets and runtime entrypoints while keeping canonical review and transport tooling attached to those same example ids.

  [ ] 18.1 Section - Focused Example Inventory Alignment
    Align the package example inventory one-for-one with the authoritative repository widget example catalog.

    [ ] 18.1.1 Task - Define the aligned `live_ui` example identity and coverage model
      Establish the package-owned example ids, naming, metadata, and coverage rules so every repository example has one matching `live_ui` specialization.

      [ ] 18.1.1.1 Subtask - Create a one-for-one mapping between the root `examples/` inventory and the package-specialized `live_ui` example ids, preserving widget identity and reviewer intent.
      [ ] 18.1.1.2 Subtask - Define package metadata for each aligned example, including native runtime entrypoint, canonical review obligations, transport coverage, and continuity expectations.
      [ ] 18.1.1.3 Subtask - Add tests that fail when a repository example id is missing from the `live_ui` package-specialized inventory or when a retired package-only id remains exposed.

    [ ] 18.1.2 Task - Implement the package-local structure for aligned focused examples
      Replace the current divergent example surface with a structure that is clearly organized around the same widget-focused examples as the root suite.

      [ ] 18.1.2.1 Subtask - Create or reorganize the package example modules so maintainers can locate each `live_ui` specialization by the same widget-focused identity used in the repository suite.
      [ ] 18.1.2.2 Subtask - Ensure each aligned example uses direct native `live_ui` widgets and runtime entrypoints rather than re-authoring the example through `unified_ui`.
      [ ] 18.1.2.3 Subtask - Add tests that prove the aligned examples remain package-local `live_ui` specializations rather than thin wrappers around the root example applications.

  [ ] 18.2 Section - Tooling and Review Workflow Realignment
    Move maintainer tooling from the old demo/catalog model onto the aligned focused example inventory.

    [ ] 18.2.1 Task - Retarget preview, inspection, export, and validation workflows to aligned example ids
      Make the package tooling operate on the same focused example identities that the repository suite exposes publicly.

      [ ] 18.2.1.1 Subtask - Update `mix live_ui.preview`, `mix live_ui.inspect`, and `mix live_ui.export` so they resolve aligned focused example ids instead of the current native/canonical/mixed package catalog.
      [ ] 18.2.1.2 Subtask - Keep canonical rendering, transport diagnostics, and continuity review available as inspection modes on the aligned example ids rather than as separate example families.
      [ ] 18.2.1.3 Subtask - Add tests that prove tooling output stays deterministic when maintainers review native runtime behavior and canonical behavior for the same aligned example id.

    [ ] 18.2.2 Task - Remove the package-local demo/workbench and divergent example taxonomy
      Retire the surfaces that no longer match the package and tooling specs.

      [ ] 18.2.2.1 Subtask - Remove `LiveUi.Demo` and its package-local workbench routing, catalog, and widget preview entrypoints once aligned focused examples replace them.
      [ ] 18.2.2.2 Subtask - Remove or migrate the current native/canonical/mixed package-owned example catalog so no divergent package-only example names remain public.
      [ ] 18.2.2.3 Subtask - Add tests that fail if demo-only commands, divergent review artifacts, or package-only example ids are accidentally reintroduced.

  [ ] 18.3 Section - Documentation, Validation, and Release Policy Alignment
    Make the aligned focused example model the official package story in docs, validation, and release-readiness workflows.

    [ ] 18.3.1 Task - Update package documentation and maintainer guidance
      Replace the old demo-and-catalog narrative with the new aligned focused example story.

      [ ] 18.3.1.1 Subtask - Update `packages/live_ui/README.md` and the package guides to describe the aligned focused example inventory as the maintainer entry point.
      [ ] 18.3.1.2 Subtask - Document how native runtime review, canonical review, transport inspection, and continuity checks attach to the same aligned example ids.
      [ ] 18.3.1.3 Subtask - Add documentation tests that fail if package docs mention the retired demo/workbench or divergent example taxonomy.

    [ ] 18.3.2 Task - Tighten validation and traceability around aligned examples
      Make the new example contract enforceable and visible in release-readiness workflows.

      [ ] 18.3.2.1 Subtask - Extend `mix live_ui.validate` so it verifies one-for-one coverage against the repository example inventory and fails when package examples drift or disappear.
      [ ] 18.3.2.2 Subtask - Update the live_ui planning traceability manifest so the new package and tooling requirements point at this phase explicitly.
      [ ] 18.3.2.3 Subtask - Add release-readiness checks that fail when tooling, docs, and validation disagree about the aligned example inventory or the removal of the package-local demo.

  [ ] 18.4 Section - Phase 18 Integration Tests
    Validate the aligned example inventory, tooling migration, and demo retirement end to end.

    [ ] 18.4.1 Task - Focused example alignment integration scenarios
      Verify the package now exposes the same focused example identities as the repository suite for `live_ui`-native review.

      [ ] 18.4.1.1 Subtask - Verify every repository widget-focused example id has one matching `live_ui` package specialization.
      [ ] 18.4.1.2 Subtask - Verify native runtime review and canonical inspection operate on the same aligned example ids without introducing package-only aliases.
      [ ] 18.4.1.3 Subtask - Verify package examples remain direct native `live_ui` widget/runtime specializations instead of reusing the authored `unified_ui` example implementations.

    [ ] 18.4.2 Task - Demo retirement and release-readiness integration scenarios
      Verify the old demo/workbench surface is fully retired and the new example model is the only supported maintainer path.

      [ ] 18.4.2.1 Subtask - Verify `LiveUi.Demo`, demo-only routes, and divergent example commands are gone or fail with explicit migration guidance.
      [ ] 18.4.2.2 Subtask - Verify package validation and release-readiness gates fail when aligned example coverage drifts from the repository example inventory.
      [ ] 18.4.2.3 Subtask - Verify package docs, tooling output, and traceability all describe the same focused example alignment story.
