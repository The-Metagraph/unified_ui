# Phase 6 - Examples, Tooling, Documentation, and Release Readiness

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `Mix.Tasks.LiveUi.*`
- `LiveUi.Examples`
- `LiveUi.Tooling`
- `LiveUi.Reference`
- `LiveUi.Info`
- `LiveUi.Transport`

## Relevant Assumptions / Defaults
- Maintained examples are part of the `live_ui` package contract and must cover both direct-native and canonical-rendered usage.
- Tooling must let maintainers inspect runtime behavior, compare native and canonical paths, and review canonical boundary translation.
- Release readiness must reinforce canonical IUR coverage, server-authoritative runtime behavior, and boundary transport clarity.

[x] 6 Phase 6 - Examples, Tooling, Documentation, and Release Readiness
  Implement maintained examples, preview and inspection tooling, package documentation, and quality gates needed to evolve `live_ui` safely.

  [x] 6.1 Section - Maintained Native and Canonical Examples
    Implement reference examples that demonstrate the package as both a native runtime library and a canonical `UnifiedIUR` renderer.

    [x] 6.1.1 Task - Implement direct-native and canonical example suites
      Provide maintained examples that cover the native and canonical runtime surface together.

      [x] 6.1.1.1 Subtask - Create direct-native foundational and advanced examples for real `live_ui` screen workflows.
      [x] 6.1.1.2 Subtask - Create canonical-rendered examples that exercise the same major feature areas through `UnifiedIUR`.
      [x] 6.1.1.3 Subtask - Create mixed examples that compare native and canonical behavior for one maintained scenario.

    [x] 6.1.2 Task - Implement example organization and review metadata
      Make maintained examples usable for package validation, docs, and review workflows.

      [x] 6.1.2.1 Subtask - Organize examples by direct-native usage, canonical rendering, and transport-validation purpose.
      [x] 6.1.2.2 Subtask - Define stable naming conventions for example identifiers, preview routes, and review artifacts.
      [x] 6.1.2.3 Subtask - Define example metadata for canonical coverage, transport obligations, and runtime continuity expectations.

  [x] 6.2 Section - Preview, Inspection, and Export Tooling
    Implement maintainer-facing tooling for previewing, inspecting, and exporting runtime behavior.

    [x] 6.2.1 Task - Implement preview and inspection workflows
      Provide workflows that let maintainers inspect native widget behavior and canonical rendering without inventing ad hoc debug paths.

      [x] 6.2.1.1 Subtask - Implement Mix tasks or helper workflows that preview maintained native and canonical examples.
      [x] 6.2.1.2 Subtask - Implement inspection helpers for runtime structure, style application, canonical mapping, and translated signal flow.
      [x] 6.2.1.3 Subtask - Implement export helpers for review-friendly runtime summaries, example metadata, and comparison output.

    [x] 6.2.2 Task - Implement actionable diagnostics and comparison ergonomics
      Make renderer coverage gaps, transport leakage, and runtime divergence understandable during package maintenance.

      [x] 6.2.2.1 Subtask - Implement diagnostics for native widget coverage gaps, canonical renderer gaps, and transport leakage.
      [x] 6.2.2.2 Subtask - Implement diff-oriented reporting for native versus canonical runtime behavior across maintained examples.
      [x] 6.2.2.3 Subtask - Implement helper surfaces that map issues back to maintained examples, canonical construct families, and package specs.

  [x] 6.3 Section - Validation Workflow and Release-Readiness Gates
    Implement the repeatable quality gates that define when `live_ui` is safe to treat as a stable runtime boundary.

    [x] 6.3.1 Task - Implement package validation workflows
      Provide one repeatable validation baseline for native runtime behavior, canonical renderer coverage, and boundary event translation.

      [x] 6.3.1.1 Subtask - Implement validation commands that check maintained example health for native and canonical paths.
      [x] 6.3.1.2 Subtask - Implement validation commands that check canonical `UnifiedIUR` coverage, native widget coverage, and transport translation behavior.
      [x] 6.3.1.3 Subtask - Implement validation commands that reject renderer-local boundary leakage and server-authority regressions.

    [x] 6.3.2 Task - Implement release-readiness criteria and review gates
      Define the checks required before `live_ui` changes can be considered stable ecosystem-boundary changes.

      [x] 6.3.2.1 Subtask - Define minimum example, documentation, and validation coverage expectations for new native widget families and canonical mappings.
      [x] 6.3.2.2 Subtask - Define change-review expectations for transport changes, canonical renderer changes, and native-IUR continuity changes.
      [x] 6.3.2.3 Subtask - Define release-readiness criteria for server-authoritative behavior, canonical event clarity, and package maintainability.

  [x] 6.4 Section - Documentation Surface
    Implement the package documentation needed for maintainers and downstream users to adopt `live_ui` safely.

    [x] 6.4.1 Task - Implement native runtime and canonical renderer documentation
      Document the package as both a directly usable runtime library and a canonical renderer entry point.

      [x] 6.4.1.1 Subtask - Document the native widget surface, runtime model, and maintained example catalog.
      [x] 6.4.1.2 Subtask - Document canonical `UnifiedIUR` rendering, boundary event translation, and server-authoritative runtime expectations.
      [x] 6.4.1.3 Subtask - Document hook boundaries, inspection workflows, and comparison workflows for native versus canonical paths.

    [x] 6.4.2 Task - Implement maintainer reference workflows
      Ensure maintainers can evolve the runtime package safely over time.

      [x] 6.4.2.1 Subtask - Document how to add a new native widget family together with its canonical `UnifiedIUR` mapping.
      [x] 6.4.2.2 Subtask - Document how to review transport and canonical-boundary changes without leaking renderer-local behavior.
      [x] 6.4.2.3 Subtask - Document how to evaluate likely compatibility impacts on ecosystem users that depend on canonical rendering.

  [x] 6.5 Section - Phase 6 Integration Tests
    Validate examples, tooling, validation gates, and release-readiness checks through end-to-end maintainer workflows.

    [x] 6.5.1 Task - Example and tooling integration scenarios
      Verify maintainers can preview, inspect, and compare native and canonical runtime behavior through one package workflow.

      [x] 6.5.1.1 Subtask - Verify maintained examples cover direct-native, canonical-rendered, and mixed runtime scenarios.
      [x] 6.5.1.2 Subtask - Verify preview, inspection, and export tooling produce stable, review-friendly output.
      [x] 6.5.1.3 Subtask - Verify diagnostics remain actionable across runtime gaps, transport leakage, and native-IUR continuity drift.

    [x] 6.5.2 Task - Validation and release-readiness integration scenarios
      Verify package quality gates enforce the intended runtime-library contract.

      [x] 6.5.2.1 Subtask - Verify validation workflows catch missing canonical coverage, runtime-authority regressions, and malformed transport behavior.
      [x] 6.5.2.2 Subtask - Verify direct-native and canonical paths can be assessed together through the same quality-gate workflow.
      [x] 6.5.2.3 Subtask - Verify the package can be evaluated for release readiness through one repeatable maintainer command path.
