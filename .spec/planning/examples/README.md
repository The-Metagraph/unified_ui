# Example Apps Implementation Plan Index

This directory contains a phased implementation plan for creating the standalone
example-application suite defined by the root example specs and the current
ecosystem package specs.

The plan aligns to:
- [Repository Package](/Users/Pascal/code/unified/.spec/specs/package.spec.md)
- [Ecosystem Architecture](/Users/Pascal/code/unified/.spec/specs/architecture.spec.md)
- [Platform Runtimes](/Users/Pascal/code/unified/.spec/specs/platform_runtimes.spec.md)
- [Signal Transport](/Users/Pascal/code/unified/.spec/specs/signal_transport.spec.md)
- [Example Apps Suite](/Users/Pascal/code/unified/.spec/specs/examples/package.spec.md)
- [Example Apps Structure](/Users/Pascal/code/unified/.spec/specs/examples/structure.spec.md)
- [Example Apps DSL Template](/Users/Pascal/code/unified/.spec/specs/examples/dsl_template.spec.md)
- [Example Apps Catalog](/Users/Pascal/code/unified/.spec/specs/examples/catalog.spec.md)
- [Example Apps Tooling](/Users/Pascal/code/unified/.spec/specs/examples/tooling.spec.md)
- [UnifiedUi Package](/Users/Pascal/code/unified/.spec/specs/unified-ui/package.spec.md)
- [UnifiedUi DSL](/Users/Pascal/code/unified/.spec/specs/unified-ui/dsl.spec.md)
- [UnifiedUi Theming](/Users/Pascal/code/unified/.spec/specs/unified-ui/theming.spec.md)
- [LiveUi Package](/Users/Pascal/code/unified/.spec/specs/live_ui/package.spec.md)
- [LiveUi Native Widgets](/Users/Pascal/code/unified/.spec/specs/live_ui/native_widgets.spec.md)
- [LiveUi Tooling](/Users/Pascal/code/unified/.spec/specs/live_ui/tooling.spec.md)

## Phase Files
1. [Phase 1 - Shared Support Library and Suite Scaffold](./phase-01-shared-support-library-and-suite-scaffold.md): implement the root `examples/` suite scaffold, the shared support library, the common DSL template, and the first end-to-end example path.
2. [Phase 2 - Foundational Content and Form Input Example Apps](./phase-02-foundational-content-and-form-input-example-apps.md): implement the foundational content, form, and input example applications that establish the common app shape across the suite.
3. [Phase 3 - Layout, Navigation, Data, and Feedback Example Apps](./phase-03-layout-navigation-data-and-feedback-example-apps.md): implement the example applications for layout, navigation, data, and feedback constructs while preserving one shared theme and shell.
4. [Phase 4 - Display, Overlay, and Operational Example Apps](./phase-04-display-overlay-and-operational-example-apps.md): implement the display-system, overlay, and operational example applications together with the more advanced runtime flows they require.
5. [Phase 5 - Suite Catalog, Tooling, and Validation Workflow](./phase-05-suite-catalog-tooling-and-validation-workflow.md): implement the suite index, app discovery tooling, per-app preview workflows, and validation checks that enforce catalog and template continuity.
6. [Phase 6 - Documentation, Release Readiness, and Full Suite Integration](./phase-06-documentation-release-readiness-and-full-suite-integration.md): implement the final documentation surface, release-readiness gates, and full-suite integration coverage for the standalone example apps.
7. [Phase 7 - Phoenix LiveView App Runtime Alignment](./phase-07-phoenix-liveview-app-runtime-alignment.md): retrofit every example directory into a runnable Phoenix LiveView app with its own endpoint, router, and browser launch workflow.

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
- The example suite lives at the repository root under `examples/` and not under `packages/`.
- `examples/shared/` is a shared support library used by every example app.
- Every example app is a standalone Phoenix LiveView app, packaged as its own Mix project and focused on one primary widget or construct.
- Every example app uses one shared `unified_ui` DSL template, one shared default theme, and one shared default style profile.
- The authored path for every example app is `unified_ui` DSL -> canonical `UnifiedIUR` -> `live_ui` runtime rendering.
- Every example app should be directly launchable through its own Phoenix runtime entrypoint rather than only through shared preview helpers.
- The catalog is complete only when every current `live_ui` widget or construct named in the example catalog has its own example app directory.
