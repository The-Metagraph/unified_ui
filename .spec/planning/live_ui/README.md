# LiveUi Implementation Plan Index

This directory contains a phased implementation plan for creating the current
`live_ui` package defined by the root ecosystem and package design specs.

The plan aligns to:
- [Architecture](/Users/Pascal/code/unified/.spec/specs/architecture.spec.md)
- [Platform Runtimes](/Users/Pascal/code/unified/.spec/specs/platform_runtimes.spec.md)
- [Signal Transport](/Users/Pascal/code/unified/.spec/specs/signal_transport.spec.md)
- [LiveUi Package](/Users/Pascal/code/unified/.spec/specs/live_ui/package.spec.md)
- [LiveUi Structure](/Users/Pascal/code/unified/.spec/specs/live_ui/structure.spec.md)
- [LiveUi Native Widgets](/Users/Pascal/code/unified/.spec/specs/live_ui/native_widgets.spec.md)
- [LiveUi Runtime](/Users/Pascal/code/unified/.spec/specs/live_ui/runtime.spec.md)
- [LiveUi IUR Renderer](/Users/Pascal/code/unified/.spec/specs/live_ui/iur_renderer.spec.md)
- [LiveUi Transport](/Users/Pascal/code/unified/.spec/specs/live_ui/transport.spec.md)
- [LiveUi Tooling](/Users/Pascal/code/unified/.spec/specs/live_ui/tooling.spec.md)
- [UnifiedIUR Package](/Users/Pascal/code/unified/.spec/specs/unified-iur/package.spec.md)
- [UnifiedIUR Widgets](/Users/Pascal/code/unified/.spec/specs/unified-iur/widgets.spec.md)
- [UnifiedIUR Display Systems](/Users/Pascal/code/unified/.spec/specs/unified-iur/display_systems.spec.md)
- [UnifiedIUR Theming](/Users/Pascal/code/unified/.spec/specs/unified-iur/theming.spec.md)
- [UnifiedIUR Interactions](/Users/Pascal/code/unified/.spec/specs/unified-iur/interactions.spec.md)
- [UnifiedUi Package](/Users/Pascal/code/unified/.spec/specs/unified-ui/package.spec.md)
- [UnifiedUi Signals](/Users/Pascal/code/unified/.spec/specs/unified-ui/signals.spec.md)

## Phase Files
1. [Phase 1 - Package Scaffold and LiveView Runtime Backbone](./phase-01-package-scaffold-and-liveview-runtime-backbone.md): implement the Mix package, Phoenix LiveView runtime backbone, native widget/component boundaries, and baseline inspection surfaces.
2. [Phase 2 - Foundational Native Widgets and Baseline IUR Rendering](./phase-02-foundational-native-widgets-and-baseline-iur-rendering.md): implement foundational native widgets, forms and navigation basics, and the first canonical `UnifiedIUR` rendering path.
3. [Phase 3 - Advanced Widgets, Display Systems, and Layered Runtime Behavior](./phase-03-advanced-widgets-display-systems-and-layered-runtime-behavior.md): implement advanced data, overlay, viewport, split-pane, scroll, and canvas behavior together with broader canonical renderer coverage.
4. [Phase 4 - Canonical Boundary Transport and Event Translation](./phase-04-canonical-boundary-transport-and-event-translation.md): implement canonical `Jido.Signal` and CloudEvents-compatible boundary translation for direct native and IUR-rendered flows.
5. [Phase 5 - Native Styling, Runtime Inspection, and Native-IUR Continuity](./phase-05-native-styling-runtime-inspection-and-native-iur-continuity.md): implement native theming and styling, runtime inspection surfaces, and deterministic continuity between native and canonical rendering paths.
6. [Phase 6 - Examples, Tooling, Documentation, and Release Readiness](./phase-06-examples-tooling-documentation-and-release-readiness.md): implement maintained reference examples, preview and inspection tooling, documentation, and release-readiness gates.
7. [Phase 7 - Browser Style Output Contract and Foundational Realization](./phase-07-browser-style-output-contract-and-foundational-realization.md): define the browser-facing style contract, lower foundational canonical style values into browser-visible output, and establish the shared realization pattern for later widget coverage.
8. [Phase 8 - Layout, Layer, and Advanced Widget Style Realization](./phase-08-layout-layer-and-advanced-widget-style-realization.md): extend browser-visible canonical styling into layout geometry, layered display surfaces, and the advanced widget catalog.
9. [Phase 9 - Canonical-Native Parity, Tooling, and Demo Alignment](./phase-09-canonical-native-parity-tooling-and-demo-alignment.md): add browser-visible parity rules, richer style-realization tooling, and demo/example upgrades that prove canonical styling now affects browser output directly.
10. [Phase 10 - Documentation, Validation, and Release Readiness for Style Realization](./phase-10-documentation-validation-and-release-readiness-for-style-realization.md): finish the rollout with migration guidance, validation gates, hardening, and release-readiness coverage for browser-realized canonical styling.
11. [Phase 11 - Widget LiveComponent Contract and Runtime Backbone Realignment](./phase-11-widget-livecomponent-contract-and-runtime-backbone-realignment.md): establish the shared widget LiveComponent contract, stable widget identity and routing model, and the runtime backbone needed to make widgets real mountable component boundaries.
12. [Phase 12 - Foundational, Input, Navigation, and Form Widget Component Migration](./phase-12-foundational-input-navigation-and-form-widget-component-migration.md): migrate the foundational widget families, forms, and navigation surfaces onto the new widget-component architecture while keeping the direct-use API ergonomic.
13. [Phase 13 - Advanced Widget Component Migration and Canonical Renderer Convergence](./phase-13-advanced-widget-component-migration-and-canonical-renderer-convergence.md): migrate advanced data, feedback, overlay, operational, and display widgets and make canonical rendering target the same widget component boundaries.
14. [Phase 14 - Tooling, Demo, Validation, and Release Readiness for Widget Components](./phase-14-tooling-demo-validation-and-release-readiness-for-widget-components.md): finish the widget-component transition with demo/example upgrades, tooling visibility, validation gates, documentation, and cleanup of legacy helper-only paths.

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
- `live_ui` is a Phoenix LiveView-native runtime library and not an authored DSL package.
- `live_ui` must support both direct native widget usage and canonical `UnifiedIUR` rendering through the same runtime architecture.
- The runtime remains server-authoritative; browser hooks are bounded support surfaces rather than independent runtime authorities.
- Canonical boundary events use `Jido.Signal` and CloudEvents-compatible semantics whenever meaning crosses package boundaries.
- Native widgets, styling, and interactions must be sufficient to realize the full canonical `UnifiedIUR` surface without introducing a second unrelated renderer stack.
- Post-baseline phases may extend the original six-phase plan when package behavior exposes a meaningful gap between preserved canonical semantics and browser-visible realization.
- The current intended architecture for `live_ui` is that native widgets are real mountable LiveComponent-backed runtime units composed inside a shared server-authoritative screen runtime.
