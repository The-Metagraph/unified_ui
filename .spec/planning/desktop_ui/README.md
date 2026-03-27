# DesktopUi Implementation Plan Index

This directory contains a phased implementation plan for creating the current
`desktop_ui` package defined by the root ecosystem and package design specs.

The plan aligns to:
- [Architecture](../../specs/architecture.spec.md)
- [Platform Runtimes](../../specs/platform_runtimes.spec.md)
- [Signal Transport](../../specs/signal_transport.spec.md)
- [DesktopUi Package](../../specs/desktop_ui/package.spec.md)
- [DesktopUi Structure](../../specs/desktop_ui/structure.spec.md)
- [DesktopUi Native Widgets](../../specs/desktop_ui/native_widgets.spec.md)
- [DesktopUi Runtime](../../specs/desktop_ui/runtime.spec.md)
- [DesktopUi SDL3 Runtime And Native Rendering](../../specs/desktop_ui/sdl3_runtime_rendering.spec.md)
- [DesktopUi IUR Renderer](../../specs/desktop_ui/iur_renderer.spec.md)
- [DesktopUi Transport](../../specs/desktop_ui/transport.spec.md)
- [DesktopUi Platform Artifacts](../../specs/desktop_ui/platform_artifacts.spec.md)
- [DesktopUi Tooling](../../specs/desktop_ui/tooling.spec.md)
- [UnifiedIUR Package](../../specs/unified-iur/package.spec.md)
- [UnifiedIUR Widgets](../../specs/unified-iur/widgets.spec.md)
- [UnifiedIUR Display Systems](../../specs/unified-iur/display_systems.spec.md)
- [UnifiedIUR Theming](../../specs/unified-iur/theming.spec.md)
- [UnifiedIUR Interactions](../../specs/unified-iur/interactions.spec.md)
- [UnifiedUi Package](../../specs/unified-ui/package.spec.md)
- [UnifiedUi Signals](../../specs/unified-ui/signals.spec.md)

## Phase Files
1. [Phase 1 - Package Scaffold and SDL3 Runtime Backbone](./phase-01-package-scaffold-and-sdl3-runtime-backbone.md): implement the Mix package, shared SDL3 runtime backbone, platform adapter seams, and baseline reference surfaces.
1. [Phase 1.5 - SDL3 Native Adapter Seam and Render-Plan Skeleton](./phase-01-5-sdl3-native-adapter-seam-and-render-plan-skeleton.md): introduce the first concrete SDL3-facing adapter boundary for callback lifecycle ownership, native window coordination, render-plan presentation, event intake, and companion-resource seams before full widget-complete native rendering.
2. [Phase 2 - Foundational Native Widgets and Baseline IUR Rendering](./phase-02-foundational-native-widgets-and-baseline-iur-rendering.md): implement foundational native widgets, baseline screen composition, and the first canonical `UnifiedIUR` rendering path.
3. [Phase 3 - Advanced Widgets, Display Systems, and Layered Desktop Behavior](./phase-03-advanced-widgets-display-systems-and-layered-desktop-behavior.md): implement advanced data, overlay, viewport, split-pane, canvas, and multiwindow desktop behavior together with broader canonical renderer coverage.
4. [Phase 4 - Canonical Boundary Transport and Desktop Event Translation](./phase-04-canonical-boundary-transport-and-desktop-event-translation.md): implement canonical `Jido.Signal` and CloudEvents-compatible boundary translation for native desktop and IUR-rendered flows.
5. [Phase 5 - Native Styling, Platform Integration, and Artifact Workflows](./phase-05-native-styling-platform-integration-and-artifact-workflows.md): implement native theming and styling, bounded platform-specific runtime integration, and explicit Windows, macOS, and Linux artifact workflows.
6. [Phase 6 - Examples, Tooling, Documentation, and Release Readiness](./phase-06-examples-tooling-documentation-and-release-readiness.md): implement maintained reference examples, preview and inspection tooling, documentation, release-readiness gates, and package evolution workflows.
7. [Phase 7 - SDL3 Native Host Execution and First Presented Frames](./phase-07-sdl3-native-host-execution-and-first-presented-frames.md): implement the first real executable SDL3 host boundary, framed Elixir-to-native protocol, real window and frame presentation ownership, and event/resource round-trips that move `desktop_ui` from semantic scaffolding to actual native execution.
8. [Phase 8 - SDL3 Native Build, Visible Window Runtime, and Backend Selection](./phase-08-sdl3-native-build-visible-window-runtime-and-backend-selection.md): implement the first buildable native SDL3 host workflow, backend selection between compiled and fallback execution, and visible-window presentation for maintained package runs.
9. [Phase 9 - Platform Build, Packaging, and Compliance Activation](./phase-09-platform-build-packaging-and-compliance-activation.md): implement repeatable target staging and packaging workflows, surface shippability diagnostics, and onboard `desktop_ui` into package-scoped conformance.
10. [Phase 10 - Widget-Complete SDL3 Rendering and Interactive Native Behavior](./phase-10-widget-complete-sdl3-rendering-and-interactive-native-behavior.md): implement widget-complete native drawing, SDL3-backed text and image realization, and interactive visible-window behavior for maintained desktop flows.
11. [Phase 11 - IUR Widget Completeness](./phase-11-iur-widget-completeness.md): implement dedicated rendering for all remaining canonical IUR widget kinds, including foundational gaps, form input completeness, data display widgets, feedback widgets, and advanced operational widgets.
12. [Phase 12 - Screen Navigation and Multi-Screen Applications](./phase-12-screen-navigation-and-multi-screen-applications.md): implement screen-to-screen navigation within windows, including navigation controller, screen registry, navigation actions, history stack, modal stack, and integration with the existing runtime and transport layers.

## Supporting Docs
- [Spec Traceability Manifest](./spec-traceability.json): authoritative machine-readable mapping from applicable requirements into this plan.
- [Spec Traceability Matrix](./spec-traceability.md): human-facing mirror of the traceability manifest for review and discussion.

## Shared Conventions
- Numbering:
  - Phases: `N` or inserted decimal identifiers such as `1.5` when a new bridging phase is added between completed phases.
  - Sections: `<phase-id>.<M>`
  - Tasks: `<section-id>.<K>`
  - Subtasks: `<task-id>.<L>`
- Tracking:
  - Every phase, section, task, and subtask uses Markdown checkboxes (`[ ]`).
- Description requirement:
  - Every phase, section, and task starts with a short description paragraph.
- Integration-test requirement:
  - Each phase ends with a final integration-testing section.

## Shared Assumptions and Defaults
- `desktop_ui` is a runtime library and not an authored DSL package or canonical
  IUR ownership boundary.
- `desktop_ui` must support both direct native desktop usage and canonical
  `UnifiedIUR` rendering through one coherent runtime model.
- SDL3 is the shared rendering and input foundation, while Windows, macOS, and
  Linux integrations remain explicitly bounded behind platform adapter seams.
- Canonical boundary events use `Jido.Signal` and CloudEvents-compatible
  semantics whenever meaning crosses package boundaries.
- Native widgets, styling, desktop input handling, and packaging workflows must
  remain sufficient to realize the full canonical `UnifiedIUR` surface without
  introducing a second unrelated renderer stack.
