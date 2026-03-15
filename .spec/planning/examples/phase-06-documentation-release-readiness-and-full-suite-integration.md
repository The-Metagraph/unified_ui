# Phase 6 - Documentation, Release Readiness, and Full Suite Integration

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/README`
- `examples/shared`
- `Mix.Tasks.LiveUi.*`
- `LiveUi.Tooling`
- `UnifiedUi`
- `LiveUi`

## Relevant Assumptions / Defaults
- The full example-app catalog, root suite index, and validation workflows already exist.
- The final phase should leave the example suite understandable to downstream users and maintainers, not just runnable.
- Release readiness should treat catalog completeness and shared-template continuity as explicit gates.

[ ] 6 Phase 6 - Documentation, Release Readiness, and Full Suite Integration
  Implement the final documentation surface, release-readiness checks, and full-suite integration coverage needed to treat the standalone example apps as a durable ecosystem asset.

  [ ] 6.1 Section - User-Facing Example Suite Documentation
    Implement the documentation that explains what the example suite is, how the apps are organized, and how to use the shared template and shared theme.

    [ ] 6.1.1 Task - Document the suite and shared support library
      Provide the user-facing and maintainer-facing documentation needed to understand the example suite structure and common DSL template contract.

      [ ] 6.1.1.1 Subtask - Document the example suite root, shared support library, and per-widget app convention.
      [ ] 6.1.1.2 Subtask - Document the shared DSL template, default theme, and default style profile.
      [ ] 6.1.1.3 Subtask - Add tests or checks that prove the documentation surface stays synchronized with the example catalog and suite tooling.

  [ ] 6.2 Section - Release-Readiness Gates
    Implement the release-readiness checks that make the suite trustworthy as a review and onboarding surface.

    [ ] 6.2.1 Task - Implement example-suite release gates
      Define the minimum conditions that must hold before the suite is considered healthy and complete.

      [ ] 6.2.1.1 Subtask - Define release gates for catalog completeness and one-primary-subject-per-app coverage.
      [ ] 6.2.1.2 Subtask - Define release gates for shared-template reuse and shared-theme/style continuity.
      [ ] 6.2.1.3 Subtask - Add tests that prove the release gates fail when catalog or template integrity drifts.

  [ ] 6.3 Section - Cross-Package Traceability
    Implement the documentation and review surfaces that tie the example suite back to the `unified_ui`, `unified_iur`, and `live_ui` package contracts.

    [ ] 6.3.1 Task - Implement cross-package traceability workflows
      Ensure reviewers can trace an example app back to the DSL, canonical IUR, and runtime-library contracts it is demonstrating.

      [ ] 6.3.1.1 Subtask - Document how the shared template compiles through `unified_ui` into canonical `UnifiedIUR`.
      [ ] 6.3.1.2 Subtask - Document how `live_ui` renders the resulting canonical output under the shared theme and style baseline.
      [ ] 6.3.1.3 Subtask - Add checks that prove example-suite metadata stays linked to the underlying package and spec contracts.

  [ ] 6.4 Section - Full Suite Maintenance Workflow
    Implement the final maintainer workflow that combines app discovery, per-app preview, validation, and release-readiness review.

    [ ] 6.4.1 Task - Implement the final suite maintainer flow
      Provide one repeatable workflow that maintainers use when adding, reviewing, or repairing example apps.

      [ ] 6.4.1.1 Subtask - Implement the final documented workflow for adding a new example app when the catalog grows.
      [ ] 6.4.1.2 Subtask - Implement the final documented workflow for reviewing shared-template or shared-theme changes across the suite.
      [ ] 6.4.1.3 Subtask - Add tests that prove the final maintainer workflow remains actionable and repeatable.

  [ ] 6.5 Section - Phase 6 Integration Tests
    Validate the full suite documentation, release-readiness gates, and maintenance workflow end to end.

    [ ] 6.5.1 Task - Full example-suite integration scenarios
      Verify the example suite is ready to act as one coherent onboarding, review, and maintenance surface.

      [ ] 6.5.1.1 Subtask - Verify the full widget catalog is represented by runnable example-app directories and discoverable metadata.
      [ ] 6.5.1.2 Subtask - Verify the shared DSL template and shared default theme/style remain consistent across representative apps from every family.
      [ ] 6.5.1.3 Subtask - Verify the suite passes its release-readiness workflow through one repeatable maintainer command path.
