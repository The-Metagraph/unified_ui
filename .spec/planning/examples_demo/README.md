# Examples Demo Application Implementation Plan Index

This directory contains a phased implementation plan for creating the aggregate
demo application defined by the `examples_demo` specs and its surrounding
example-suite contracts.

The plan aligns to:
- [Repository Package](/Users/Pascal/code/unified/.spec/specs/package.spec.md)
- [Ecosystem Architecture](/Users/Pascal/code/unified/.spec/specs/architecture.spec.md)
- [Platform Runtimes](/Users/Pascal/code/unified/.spec/specs/platform_runtimes.spec.md)
- [Signal Transport](/Users/Pascal/code/unified/.spec/specs/signal_transport.spec.md)
- [Example Apps Suite](/Users/Pascal/code/unified/.spec/specs/examples/package.spec.md)
- [Example Apps Structure](/Users/Pascal/code/unified/.spec/specs/examples/structure.spec.md)
- [Example Apps Catalog](/Users/Pascal/code/unified/.spec/specs/examples/catalog.spec.md)
- [Example Apps DSL Template](/Users/Pascal/code/unified/.spec/specs/examples/dsl_template.spec.md)
- [Example Apps Tooling](/Users/Pascal/code/unified/.spec/specs/examples/tooling.spec.md)
- [Examples Demo Application](/Users/Pascal/code/unified/.spec/specs/examples_demo/package.spec.md)
- [Examples Demo Application Structure](/Users/Pascal/code/unified/.spec/specs/examples_demo/structure.spec.md)
- [Examples Demo Application Interface](/Users/Pascal/code/unified/.spec/specs/examples_demo/interface.spec.md)
- [Examples Demo Application Theming](/Users/Pascal/code/unified/.spec/specs/examples_demo/theming.spec.md)
- [Examples Demo Application Interaction Lab](/Users/Pascal/code/unified/.spec/specs/examples_demo/interaction_lab.spec.md)
- [Examples Demo Application Tooling](/Users/Pascal/code/unified/.spec/specs/examples_demo/tooling.spec.md)
- [UnifiedUi Package](/Users/Pascal/code/unified/.spec/specs/unified-ui/package.spec.md)
- [UnifiedUi DSL](/Users/Pascal/code/unified/.spec/specs/unified-ui/dsl.spec.md)
- [UnifiedUi Signals](/Users/Pascal/code/unified/.spec/specs/unified-ui/signals.spec.md)
- [UnifiedUi Theming](/Users/Pascal/code/unified/.spec/specs/unified-ui/theming.spec.md)
- [UnifiedIUR Interactions](/Users/Pascal/code/unified/.spec/specs/unified-iur/interactions.spec.md)
- [LiveUi Package](/Users/Pascal/code/unified/.spec/specs/live_ui/package.spec.md)
- [LiveUi Runtime](/Users/Pascal/code/unified/.spec/specs/live_ui/runtime.spec.md)
- [LiveUi Transport](/Users/Pascal/code/unified/.spec/specs/live_ui/transport.spec.md)

## Phase Files
1. [Phase 1 - App Scaffold, Shared Theme Continuity, and Demo Backbone](./phase-01-app-scaffold-shared-theme-continuity-and-demo-backbone.md): implement the standalone Phoenix LiveView app scaffold, reuse the shared button-example theme/style contract, and establish the root demo screen plus category registry.
2. [Phase 2 - Tabbed Shell and Foundational Category Galleries](./phase-02-tabbed-shell-and-foundational-category-galleries.md): implement the tabbed shell and the first category galleries for foundational content, forms/input, and layout/display controls.
3. [Phase 3 - Advanced Category Galleries and Cross-Category Review Flow](./phase-03-advanced-category-galleries-and-cross-category-review-flow.md): implement the navigation, data/feedback, and overlay/operational category tabs together with the shared reviewer cues that tie them together.
4. [Phase 4 - Signal Lab and Cross-Control Reactivity Stories](./phase-04-signal-lab-and-cross-control-reactivity-stories.md): implement the dedicated signal lab where authored canonical interactions produce meaningful visible changes across controls and panels.
5. [Phase 5 - Tooling, Documentation, and Suite Traceability](./phase-05-tooling-documentation-and-suite-traceability.md): implement launcher integration, review metadata, validation, and documentation so the demo app is discoverable and auditable alongside the per-widget apps.
6. [Phase 6 - Release Readiness, Accessibility, and Full Demo Validation](./phase-06-release-readiness-accessibility-and-full-demo-validation.md): implement the final accessibility, fixture stability, release checks, and full-app integration coverage required to keep the demo app maintainable.

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
- The aggregate demo application lives at the repository root under `examples/demo/` as a standalone Phoenix LiveView app.
- The aggregate demo application uses the same shared theme identity, shared style profile, and shared LiveView shell styling as the current `examples/button/` application.
- The authored path for the aggregate demo application is `unified_ui` DSL -> canonical `UnifiedIUR` -> `live_ui` runtime rendering.
- The aggregate demo application complements the existing per-widget example suite and does not replace the dedicated example directories.
- The top-level review surface is a tabbed interface organized by category rather than by internal module or directory structure.
- The category tabs are `foundational_content`, `forms_and_input`, `layout_and_display`, `navigation_and_selection`, `data_and_feedback`, `overlays_and_operational`, and `signal_lab`.
- The signal lab must demonstrate authored canonical interactions in a reviewer-friendly way, showing both meaningful visible outcomes and the associated canonical signal meaning.
