# Phase 1 - Self-Contained Suite Scaffold

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/catalog.tsv`
- `examples/<widget_name>`
- `UnifiedUi`
- `UnifiedUi.Dsl`
- `UnifiedUi.Compiler`
- `LiveUi.Runtime`
- `LiveUi.Renderer`
- `LiveUi.Theme`
- `LiveUi.Style`

## Relevant Assumptions / Defaults
- The example suite starts from an empty `examples/` directory except for the root index and catalog placeholder.
- Each focused example app owns its example shell, default theme, default style, and authored DSL modules locally while preserving the common suite contract.
- The first phase should prove the full authored DSL to `live_ui` runtime path before the suite expands to the full widget catalog.

[x] 1 Phase 1 - Self-Contained Suite Scaffold
  Implement the root `examples/` suite scaffold, the common app-local DSL template contract, and the first runnable example apps that prove the common example architecture.

  [ ] 1.1 Section - Root Example Suite and App-Local Scaffold
    Create the top-level `examples/` suite shape and the app-local structure that every standalone example app will own.

    [ ] 1.1.1 Task - Create the root examples directory layout
      Establish the suite root, catalog, and the base directory conventions that every example app will follow.

      [ ] 1.1.1.1 Subtask - Create the root catalog and documentation surfaces for the example suite.
      [ ] 1.1.1.2 Subtask - Create the baseline `README` and catalog index surfaces at the root `examples/` directory.
      [ ] 1.1.1.3 Subtask - Create the baseline directory convention for standalone app subdirectories at `examples/<widget_name>/`.

    [ ] 1.1.2 Task - Define app-local dependency and package wiring
      Make each focused example app own the local package path dependencies needed for its maintained launch targets.

      [ ] 1.1.2.1 Subtask - Define the app-local dependencies on `unified_ui`, `unified_iur`, and the maintained runtime packages.
      [ ] 1.1.2.2 Subtask - Define the standard path-dependency wiring each example app will carry in its own `mix.exs`.
      [ ] 1.1.2.3 Subtask - Add tests that prove representative example apps compile independently.

  [ ] 1.2 Section - Common DSL Template Contract and Default Theme
    Implement the common DSL template contract, example shell, and default theme/style profile used across the full suite.

    [ ] 1.2.1 Task - Implement the common example shell template
      Provide one reusable authored DSL shell that all example apps can instantiate with a title, description, and one focused demonstration panel.

      [ ] 1.2.1.1 Subtask - Implement the common `unified_ui` DSL template shape inside the proof example apps.
      [ ] 1.2.1.2 Subtask - Define the shell slots or configuration surface for title, summary, primary widget content, and supporting notes.
      [ ] 1.2.1.3 Subtask - Add tests that prove the template compiles into canonical `UnifiedIUR`.

    [ ] 1.2.2 Task - Implement the suite-wide default theme and style profile
      Define the common theme identity and common style baseline that every example app will inherit by default.

      [ ] 1.2.2.1 Subtask - Implement the shared default theme identity `:example_suite_default`.
      [ ] 1.2.2.2 Subtask - Implement the shared default style profile for shell, panel, and primary widget presentation.
      [ ] 1.2.2.3 Subtask - Add tests that prove native `live_ui` rendering observes the shared default theme and style assignments consistently.

  [ ] 1.3 Section - Standalone Example App Baseline
    Implement the first standalone example app shape so every later widget-specific app can reuse one consistent app baseline.

    [ ] 1.3.1 Task - Create the standard example app skeleton
      Define the minimal standalone Mix app structure, runtime entrypoint, and app-local support modules that every per-widget app will own.

      [ ] 1.3.1.1 Subtask - Create the standard example app `mix.exs`, `config/`, `lib/`, and `test/` layout.
      [ ] 1.3.1.2 Subtask - Create the standard runtime entrypoint that renders one shared-template-authored example screen through `live_ui`.
      [ ] 1.3.1.3 Subtask - Add tests that prove the baseline example app can boot and render through the shared runtime path.

  [ ] 1.4 Section - First Proof Example Apps
    Implement the first small set of proof apps that validate the shared example architecture before the suite expands to full catalog coverage.

    [ ] 1.4.1 Task - Implement the first foundational proof apps
      Create a minimal set of proof apps that cover content, action, and input behavior under the shared DSL template and shared theme.

      [ ] 1.4.1.1 Subtask - Implement the `text` example app as the first shell and template proof.
      [ ] 1.4.1.2 Subtask - Implement the `button` example app as the first action-oriented proof.
      [ ] 1.4.1.3 Subtask - Implement the `text_input` example app as the first input-oriented proof.

  [ ] 1.5 Section - Phase 1 Integration Tests
    Validate the root suite scaffold, common template contract, and first proof example apps end to end.

    [ ] 1.5.1 Task - Shared template and proof-app integration scenarios
      Verify the suite root and first proof apps behave as one coherent authored-to-runtime flow.

      [ ] 1.5.1.1 Subtask - Verify representative standalone example apps compile independently.
      [ ] 1.5.1.2 Subtask - Verify the shared DSL template compiles to canonical `UnifiedIUR` and renders through `live_ui`.
      [ ] 1.5.1.3 Subtask - Verify the first proof example apps share the same default theme and default style profile while differing only in their primary widget content.
