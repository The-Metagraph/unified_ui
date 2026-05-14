# TerminalUi Implementation Plan Index

This directory contains a phased implementation plan for creating the current
`terminal_ui` package defined by the root ecosystem and package design specs.

The plan aligns to:
- [Architecture](/Users/Pascal/code/unified/.spec/specs/architecture.spec.md)
- [Platform Runtimes](/Users/Pascal/code/unified/.spec/specs/platform_runtimes.spec.md)
- [Signal Transport](/Users/Pascal/code/unified/.spec/specs/signal_transport.spec.md)
- [TerminalUi Package](/Users/Pascal/code/unified/.spec/specs/terminal_ui/package.spec.md)
- [TerminalUi Structure](/Users/Pascal/code/unified/.spec/specs/terminal_ui/structure.spec.md)
- [TerminalUi Native Widgets](/Users/Pascal/code/unified/.spec/specs/terminal_ui/native_widgets.spec.md)
- [TerminalUi Runtime](/Users/Pascal/code/unified/.spec/specs/terminal_ui/runtime.spec.md)
- [TerminalUi Capabilities](/Users/Pascal/code/unified/.spec/specs/terminal_ui/capabilities.spec.md)
- [TerminalUi IUR Renderer](/Users/Pascal/code/unified/.spec/specs/terminal_ui/iur_renderer.spec.md)
- [TerminalUi Transport](/Users/Pascal/code/unified/.spec/specs/terminal_ui/transport.spec.md)
- [TerminalUi Tooling](/Users/Pascal/code/unified/.spec/specs/terminal_ui/tooling.spec.md)
- [UnifiedIUR Package](/Users/Pascal/code/unified/.spec/specs/unified-iur/package.spec.md)
- [UnifiedIUR Widgets](/Users/Pascal/code/unified/.spec/specs/unified-iur/widgets.spec.md)
- [UnifiedIUR Display Systems](/Users/Pascal/code/unified/.spec/specs/unified-iur/display_systems.spec.md)
- [UnifiedIUR Theming](/Users/Pascal/code/unified/.spec/specs/unified-iur/theming.spec.md)
- [UnifiedIUR Interactions](/Users/Pascal/code/unified/.spec/specs/unified-iur/interactions.spec.md)
- [UnifiedUi Package](/Users/Pascal/code/unified/.spec/specs/unified-ui/package.spec.md)
- [UnifiedUi Signals](/Users/Pascal/code/unified/.spec/specs/unified-ui/signals.spec.md)

## Phase Files
1. [Phase 1 - Package Scaffold and TermUI Runtime Adapter Backbone](./phase-01-package-scaffold-and-termui-runtime-adapter-backbone.md): implement the Mix package, `term_ui` runtime adapter backbone, backend and capability seams, and baseline reference surfaces.
2. [Phase 2 - Foundational Native Widgets and Baseline IUR Rendering](./phase-02-foundational-native-widgets-and-baseline-iur-rendering.md): implement foundational native widgets, baseline terminal composition, and the first canonical `UnifiedIUR` rendering path.
3. [Phase 3 - Advanced Widgets, Display Systems, and Capability-Aware Terminal Behavior](./phase-03-advanced-widgets-display-systems-and-capability-aware-terminal-behavior.md): implement advanced data, overlay, viewport, split-pane, canvas, and capability-aware layered terminal behavior together with broader canonical renderer coverage.
4. [Phase 4 - Canonical Boundary Transport and Terminal Event Translation](./phase-04-canonical-boundary-transport-and-terminal-event-translation.md): implement canonical `Jido.Signal` and CloudEvents-compatible boundary translation for native terminal and IUR-rendered flows.
5. [Phase 5 - Native Styling, Capability Degradation, and Runtime Inspection](./phase-05-native-styling-capability-degradation-and-runtime-inspection.md): implement native theming and styling, explicit capability and degradation policies, and runtime continuity inspection across richer and limited terminal environments.
6. [Phase 6 - Examples, Tooling, Documentation, and Release Readiness](./phase-06-examples-tooling-documentation-and-release-readiness.md): implement maintained reference examples, preview and inspection tooling, documentation, release-readiness gates, and package evolution workflows.
7. [Phase 7 - Canonical Navigation Runtime Support](./phase-07-canonical-navigation-runtime-support.md): implement canonical screen-transition handling inside the shared terminal runtime, including symbolic screen resolution, bounded history and modal semantics, and transport-to-runtime integration without browser-route assumptions.

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
- `terminal_ui` is a runtime library and not an authored DSL package or
  canonical IUR ownership boundary.
- `terminal_ui` must support both direct native terminal usage and canonical
  `UnifiedIUR` rendering through one coherent runtime model.
- `term_ui` is the intended runtime foundation, while backend selection,
  capability detection, and degradation remain explicitly bounded inside
  `terminal_ui` package seams.
- Canonical boundary events use `Jido.Signal` and CloudEvents-compatible
  semantics whenever meaning crosses package boundaries.
- Native widgets, styling, terminal input normalization, and degradation
  policies must remain sufficient to realize the full canonical `UnifiedIUR`
  surface without introducing a second unrelated renderer stack.
