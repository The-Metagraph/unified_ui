# UnifiedUi Implementation Plan Index

This directory contains a phased implementation plan for creating the current
`unified_ui` package defined by the root ecosystem and package design specs.

The plan aligns to:
- [Architecture](/Users/Pascal/code/unified/.spec/specs/architecture.spec.md)
- [DSL and IUR Symbiosis](/Users/Pascal/code/unified/.spec/specs/dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](/Users/Pascal/code/unified/.spec/specs/platform_runtimes.spec.md)
- [Signal Transport](/Users/Pascal/code/unified/.spec/specs/signal_transport.spec.md)
- [UnifiedUi Package](/Users/Pascal/code/unified/.spec/specs/unified-ui/package.spec.md)
- [UnifiedUi Structure](/Users/Pascal/code/unified/.spec/specs/unified-ui/structure.spec.md)
- [UnifiedUi DSL](/Users/Pascal/code/unified/.spec/specs/unified-ui/dsl.spec.md)
- [UnifiedUi Widgets](/Users/Pascal/code/unified/.spec/specs/unified-ui/widgets.spec.md)
- [Unified UI Display Systems](/Users/Pascal/code/unified/.spec/specs/unified-ui/display_systems.spec.md)
- [Unified UI Theming](/Users/Pascal/code/unified/.spec/specs/unified-ui/theming.spec.md)
- [UnifiedUi Compiler](/Users/Pascal/code/unified/.spec/specs/unified-ui/compiler.spec.md)
- [UnifiedUi Signals](/Users/Pascal/code/unified/.spec/specs/unified-ui/signals.spec.md)
- [UnifiedUi Tooling](/Users/Pascal/code/unified/.spec/specs/unified-ui/tooling.spec.md)
- [UnifiedIUR Package](/Users/Pascal/code/unified/.spec/specs/unified-iur/package.spec.md)
- [UnifiedIUR Widgets](/Users/Pascal/code/unified/.spec/specs/unified-iur/widgets.spec.md)
- [UnifiedIUR Display Systems](/Users/Pascal/code/unified/.spec/specs/unified-iur/display_systems.spec.md)
- [UnifiedIUR Theming](/Users/Pascal/code/unified/.spec/specs/unified-iur/theming.spec.md)
- [UnifiedIUR Interactions](/Users/Pascal/code/unified/.spec/specs/unified-iur/interactions.spec.md)
- [UnifiedIUR Tooling](/Users/Pascal/code/unified/.spec/specs/unified-iur/tooling.spec.md)

## Phase Files
1. [Phase 1 - Package Scaffold and DSL Backbone](./phase-01-package-scaffold-and-dsl-backbone.md): implement the Mix package, Spark-based DSL backbone, authored identity rules, and baseline reference surfaces.
2. [Phase 2 - Foundational Authoring Surface and Composition Primitives](./phase-02-foundational-authoring-surface-and-composition-primitives.md): implement foundational widgets, forms, navigation, layout primitives, and baseline authored examples.
3. [Phase 3 - Advanced Widget Families and Display Systems](./phase-03-advanced-widget-families-and-display-systems.md): implement advanced data, feedback, overlay, viewport, and canvas authoring constructs together with their placement rules.
4. [Phase 4 - Theming, Style, and Signal Descriptor Authoring](./phase-04-theming-style-and-signal-descriptor-authoring.md): implement theme and style declarations, canonical interaction authoring, and compile-time validation for authored semantics.
5. [Phase 5 - Canonical IUR Compilation, Introspection, and Parity Validation](./phase-05-canonical-iur-compilation-introspection-and-parity-validation.md): implement deterministic compilation into `UnifiedIUR`, compiled-output inspection, and bilateral parity checks.
6. [Phase 6 - Examples, Tooling, Documentation, and Release Readiness](./phase-06-examples-tooling-documentation-and-release-readiness.md): implement maintained examples, maintainer tooling, validation gates, documentation, and release-readiness workflows.

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
- `unified_ui` uses a Spark-style DSL substrate rather than ad-hoc macros or runtime-builder APIs.
- `unified_ui` remains a pure authored DSL and compiler package with no required long-lived runtime.
- Authored modules compile into canonical `UnifiedIUR` output plus canonical signal descriptors rather than renderer-specific widget trees.
- Canonical authored widgets, display systems, theming concepts, and signal descriptors remain bilaterally aligned with `unified_iur`.
- Authored modules do not embed renderer-specific callbacks, payload keys, transport envelopes, or runtime-library widget calls.
