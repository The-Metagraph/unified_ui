# UnifiedIUR Implementation Plan Index

This directory contains a phased implementation plan for creating the current
`unified_iur` package defined by the root ecosystem and package design specs.

The plan aligns to:
- [Architecture](/Users/Pascal/code/unified/.spec/specs/architecture.spec.md)
- [DSL and IUR Symbiosis](/Users/Pascal/code/unified/.spec/specs/dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](/Users/Pascal/code/unified/.spec/specs/platform_runtimes.spec.md)
- [Signal Transport](/Users/Pascal/code/unified/.spec/specs/signal_transport.spec.md)
- [UnifiedIUR Package](/Users/Pascal/code/unified/.spec/specs/unified-iur/package.spec.md)
- [UnifiedIUR Structure](/Users/Pascal/code/unified/.spec/specs/unified-iur/structure.spec.md)
- [UnifiedIUR Core](/Users/Pascal/code/unified/.spec/specs/unified-iur/core.spec.md)
- [UnifiedIUR Constructs](/Users/Pascal/code/unified/.spec/specs/unified-iur/constructs.spec.md)
- [UnifiedIUR Widgets](/Users/Pascal/code/unified/.spec/specs/unified-iur/widgets.spec.md)
- [UnifiedIUR Display Systems](/Users/Pascal/code/unified/.spec/specs/unified-iur/display_systems.spec.md)
- [UnifiedIUR Theming](/Users/Pascal/code/unified/.spec/specs/unified-iur/theming.spec.md)
- [UnifiedIUR Interactions](/Users/Pascal/code/unified/.spec/specs/unified-iur/interactions.spec.md)
- [UnifiedIUR Interoperability](/Users/Pascal/code/unified/.spec/specs/unified-iur/interoperability.spec.md)
- [UnifiedIUR Tooling](/Users/Pascal/code/unified/.spec/specs/unified-iur/tooling.spec.md)

## Phase Files
1. [Phase 1 - Core Package Scaffold and Canonical Element Backbone](./phase-01-core-package-scaffold-and-canonical-element-backbone.md): implement the Mix package, pure-value element model, identity and metadata contracts, traversal shape, and package reference surfaces.
2. [Phase 2 - Foundational Widgets and Composition Primitives](./phase-02-foundational-widgets-and-composition-primitives.md): implement foundational canonical widgets together with the baseline composition and container constructs required by authored DSL output.
3. [Phase 3 - Advanced Display Systems and Operational Constructs](./phase-03-advanced-display-systems-and-operational-constructs.md): implement advanced display systems including layering, viewport, canvas, and operational or inspection-oriented canonical widgets.
4. [Phase 4 - Styling, Theming, and Interaction Descriptor Model](./phase-04-styling-theming-and-interaction-descriptor-model.md): implement canonical styling values, themes, design tokens, and renderer-independent interaction and binding descriptors.
5. [Phase 5 - Normalization, Interoperability, and Extension Safety](./phase-05-normalization-interoperability-and-extension-safety.md): implement normalization, deterministic canonical shaping, runtime-library consumption seams, and forward-compatible extension behavior.
6. [Phase 6 - Tooling, Fixtures, Validation, and Release Readiness](./phase-06-tooling-fixtures-validation-and-release-readiness.md): implement examples, inspection tooling, validation workflows, documentation surfaces, and release-readiness quality gates.

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
- `unified_iur` remains a pure Mix library and not a long-lived runtime.
- Canonical values are immutable and renderer-independent.
- `unified_iur` remains the exchange boundary between `unified_ui` authored output and runtime-library renderer entry points.
- Canonical constructs must preserve enough semantic information for `live_ui`, `web_ui`, and `desktop_ui` to realize their own native widget surfaces.
- Canonical widget, display-system, style, theme, and interaction changes remain bilaterally aligned with `unified_ui`.
