# ElmUi Implementation Plan Index

This directory contains a phased implementation plan for creating the current
`elm_ui` package defined by the root ecosystem and package design specs.

The plan aligns to:
- [Architecture](/Users/Pascal/code/unified/.spec/specs/architecture.spec.md)
- [Platform Runtimes](/Users/Pascal/code/unified/.spec/specs/platform_runtimes.spec.md)
- [Signal Transport](/Users/Pascal/code/unified/.spec/specs/signal_transport.spec.md)
- [ElmUi Package](/Users/Pascal/code/unified/.spec/specs/elm_ui/package.spec.md)
- [ElmUi Structure](/Users/Pascal/code/unified/.spec/specs/elm_ui/structure.spec.md)
- [ElmUi Native Widgets](/Users/Pascal/code/unified/.spec/specs/elm_ui/native_widgets.spec.md)
- [ElmUi Server Runtime](/Users/Pascal/code/unified/.spec/specs/elm_ui/server_runtime.spec.md)
- [ElmUi Frontend Runtime](/Users/Pascal/code/unified/.spec/specs/elm_ui/frontend_runtime.spec.md)
- [ElmUi IUR Renderer](/Users/Pascal/code/unified/.spec/specs/elm_ui/iur_renderer.spec.md)
- [ElmUi Transport](/Users/Pascal/code/unified/.spec/specs/elm_ui/transport.spec.md)
- [ElmUi Tooling](/Users/Pascal/code/unified/.spec/specs/elm_ui/tooling.spec.md)
- [UnifiedIUR Package](/Users/Pascal/code/unified/.spec/specs/unified-iur/package.spec.md)
- [UnifiedIUR Widgets](/Users/Pascal/code/unified/.spec/specs/unified-iur/widgets.spec.md)
- [UnifiedIUR Display Systems](/Users/Pascal/code/unified/.spec/specs/unified-iur/display_systems.spec.md)
- [UnifiedIUR Theming](/Users/Pascal/code/unified/.spec/specs/unified-iur/theming.spec.md)
- [UnifiedIUR Interactions](/Users/Pascal/code/unified/.spec/specs/unified-iur/interactions.spec.md)
- [UnifiedUi Package](/Users/Pascal/code/unified/.spec/specs/unified-ui/package.spec.md)
- [UnifiedUi Signals](/Users/Pascal/code/unified/.spec/specs/unified-ui/signals.spec.md)

## Phase Files
1. [Phase 1 - Package Scaffold and Phoenix-Elm Runtime Backbone](./phase-01-package-scaffold-and-phoenix-elm-runtime-backbone.md): implement the Mix package, Phoenix server backbone, Elm frontend backbone, browser bridge entrypoints, and baseline inspection surfaces.
2. [Phase 2 - Foundational Native Widgets and Baseline IUR Rendering](./phase-02-foundational-native-widgets-and-baseline-iur-rendering.md): implement foundational native widgets, baseline forms and navigation, and the first canonical `UnifiedIUR` rendering path across the server and frontend runtimes.
3. [Phase 3 - Advanced Widgets, Display Systems, and Layered Web Runtime Behavior](./phase-03-advanced-widgets-display-systems-and-layered-web-runtime-behavior.md): implement advanced data, feedback, overlay, viewport, split-pane, scroll, canvas, and layered runtime behavior together with broader canonical renderer coverage.
4. [Phase 4 - Canonical Boundary Transport and Phoenix-Elm Event Translation](./phase-04-canonical-boundary-transport-and-phoenix-elm-event-translation.md): implement canonical `Jido.Signal` and CloudEvents-compatible boundary translation for direct native and IUR-rendered flows across the Phoenix and Elm runtime split.
5. [Phase 5 - Native Styling, Runtime Inspection, and Native-IUR Continuity](./phase-05-native-styling-runtime-inspection-and-native-iur-continuity.md): implement native theming and styling, cross-runtime inspection surfaces, and deterministic continuity between direct native and canonical rendering paths.
6. [Phase 6 - Examples, Tooling, Documentation, and Release Readiness](./phase-06-examples-tooling-documentation-and-release-readiness.md): implement maintained reference examples, preview and inspection tooling, documentation, release-readiness gates, and package evolution workflows.

## Supporting Docs
- [Spec Traceability Manifest](./spec-traceability.json): authoritative machine-readable mapping from applicable requirements into this plan.
- [Spec Traceability Matrix](./spec-traceability.md): human-facing mirror of the traceability manifest for review and discussion.

## Shared Conventions
- Numbering:
  - Phases: `N`
  - Sections: `N.M`
  - Tasks: `N.M.K`
  - Subtasks: `N.M.K.L`
- Tracking:
  - Every phase, section, task, and subtask uses Markdown checkboxes (`[ ]`).
- Description requirement:
  - Every phase, section, and task starts with a short description paragraph.
- Integration-test requirement:
  - Each phase ends with a final integration-testing section.

## Shared Assumptions and Defaults
- `elm_ui` is a Phoenix-and-Elm runtime library and not an authored DSL package.
- `elm_ui` must support both direct native widget usage and canonical `UnifiedIUR` rendering through one coherent split runtime architecture.
- The Phoenix side remains authoritative for package-boundary meaning and canonical event translation even when Elm holds bounded local browser state.
- Canonical boundary events use `Jido.Signal` and CloudEvents-compatible semantics whenever meaning crosses package boundaries.
- Native widgets, styling, frontend rendering, and transport behavior must be sufficient to realize the full canonical `UnifiedIUR` surface without introducing a second unrelated renderer stack.
