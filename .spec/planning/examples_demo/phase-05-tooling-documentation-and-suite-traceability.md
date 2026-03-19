# Phase 5 - Tooling, Documentation, and Suite Traceability

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/README.md`
- `examples/catalog.tsv`
- `examples/shared`
- `UnifiedExamples.Shared.Tooling`
- `UnifiedExamples.Shared.Validation`
- `mix examples.list`
- `mix examples.launch`
- `mix examples.validate`

## Relevant Assumptions / Defaults
- The aggregate demo app now exists as a standalone Phoenix LiveView app with full category galleries and a dedicated signal lab.
- The demo app should be easy to discover through the existing examples-suite tooling without obscuring the focused per-widget example applications.
- Validation should treat the category tabs, button-example style continuity, and signal-lab story inventory as first-class demo-app requirements.

[x] 5 Phase 5 - Tooling, Documentation, and Suite Traceability
  Integrate the aggregate demo app into the shared examples tooling and documentation so maintainers can discover it, launch it, validate it, and trace it back to the suite catalog and per-widget examples.

  [ ] 5.1 Section - Examples Index and Launcher Integration
    Update the suite-level discovery surfaces so the aggregate demo app appears as the category-oriented review surface for the examples suite.

    [ ] 5.1.1 Task - Add the demo app to the shared examples index and launcher
      Make the aggregate demo app discoverable through the existing root examples documentation and launcher commands.

      [ ] 5.1.1.1 Subtask - Add the aggregate demo app to the root examples index with a clear explanation of when to use it versus per-widget example apps.
      [ ] 5.1.1.2 Subtask - Update shared launcher tooling so `examples/demo/` appears as a first-class launch target.
      [ ] 5.1.1.3 Subtask - Add tests that verify the launcher and root index both expose the aggregate demo app correctly.

  [ ] 5.2 Section - Review Metadata and Validation Workflow
    Add the metadata and validation checks required to keep the aggregate demo app aligned with its category and signal-lab contract.

    [ ] 5.2.1 Task - Extend shared review metadata for the aggregate demo
      Expose the information needed to audit category coverage, signal-lab story completeness, and theme continuity.

      [ ] 5.2.1.1 Subtask - Add metadata for category ids, category counts, signal-lab story inventory, theme identity, and shared style profile usage.
      [ ] 5.2.1.2 Subtask - Add metadata that maps each category tab back to the relevant per-widget example directories or control families.
      [ ] 5.2.1.3 Subtask - Add tests that verify review metadata stays synchronized with the actual demo implementation.

    [ ] 5.2.2 Task - Extend validation and release-readiness tooling
      Make the shared suite tooling fail when the aggregate demo app loses required tabs, story inventory, or styling continuity.

      [ ] 5.2.2.1 Subtask - Add validation for the required tab ids and the presence of a dedicated signal-lab tab.
      [ ] 5.2.2.2 Subtask - Add validation for the minimum story inventory and the shared button-example theme/style continuity requirements.
      [ ] 5.2.2.3 Subtask - Add tests that prove validation fails on missing tabs, missing stories, or style drift.

  [ ] 5.3 Section - Documentation and Maintainer Guidance
    Document how reviewers and maintainers should use the aggregate demo app without confusing it with the per-widget examples.

    [ ] 5.3.1 Task - Document the aggregate demo app's role in the example suite
      Clarify how the app should be used for overview browsing, category review, and interaction inspection.

      [ ] 5.3.1.1 Subtask - Add a dedicated README for `examples/demo/` explaining the category tabs, signal lab, and shared styling baseline.
      [ ] 5.3.1.2 Subtask - Update suite-level docs to explain how the aggregate demo complements, but does not replace, the per-widget apps.
      [ ] 5.3.1.3 Subtask - Add maintainer guidance describing how to add a new representative control or signal-lab story when the catalog evolves.

  [ ] 5.4 Section - Per-Widget and Demo Cross-Linking
    Make the aggregate demo app traceable back to the focused example apps so reviewers can move from overview to detail smoothly.

    [ ] 5.4.1 Task - Add cross-links between category panels and focused examples
      Provide one consistent way to move from the aggregate review surface to the dedicated example app for a given control family.

      [ ] 5.4.1.1 Subtask - Add links or review cues that point from category panels to the relevant per-widget example directories.
      [ ] 5.4.1.2 Subtask - Add matching docs or metadata cues in the focused examples that mention the aggregate demo app as the category overview surface.
      [ ] 5.4.1.3 Subtask - Add tests that verify cross-links and traceability metadata remain present.

  [ ] 5.5 Section - Phase 5 Integration Tests
    Validate that the aggregate demo app is now fully integrated into the examples-suite discovery, validation, and documentation workflow.

    [ ] 5.5.1 Task - Tooling and traceability integration scenarios
      Verify the aggregate demo app can be found, launched, validated, and mapped back to the example catalog through the shared suite tooling.

      [ ] 5.5.1.1 Subtask - Verify the root index and launcher surface expose the aggregate demo app correctly.
      [ ] 5.5.1.2 Subtask - Verify validation catches missing tabs, missing stories, or broken style continuity in the aggregate demo app.
      [ ] 5.5.1.3 Subtask - Verify cross-links between the aggregate demo and focused examples remain intact and reviewable.
