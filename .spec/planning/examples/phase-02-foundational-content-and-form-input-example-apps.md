# Phase 2 - Foundational Content and Form Input Example Apps

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/shared`
- `UnifiedUi.Dsl`
- `UnifiedUi.Compiler`
- `UnifiedIUR.Widgets.Foundational`
- `UnifiedIUR.Widgets.Input`
- `UnifiedIUR.Forms`
- `LiveUi.Renderer`

## Relevant Assumptions / Defaults
- The shared support library, shared DSL template, and baseline example-app structure already exist from Phase 1.
- Each example app still focuses on one primary widget or construct, even when supporting form scaffolding is required around it.
- The shared default theme and style profile remain the baseline for all example apps in this phase.

[ ] 2 Phase 2 - Foundational Content and Form Input Example Apps
  Implement the foundational content, form, and input example applications that establish the suite-wide app shape for the largest baseline widget families.

  [ ] 2.1 Section - Foundational Content Example Apps
    Create the example applications that demonstrate the foundational content-oriented widgets through one shared shell and theme.

    [ ] 2.1.1 Task - Implement baseline content widget apps
      Add the standalone apps for the foundational content widgets and prove that they all share the same default shell and style baseline.

      [ ] 2.1.1.1 Subtask - Implement `label`, `icon`, `image`, `link`, `separator`, and `spacer` example apps.
      [ ] 2.1.1.2 Subtask - Implement `content` and `box` example apps as container-oriented foundational examples.
      [ ] 2.1.1.3 Subtask - Add tests that prove every foundational content app renders through the shared template and default theme.

  [ ] 2.2 Section - Form Scaffolding Example Apps
    Create the example applications that demonstrate the form-building scaffolding constructs required by input-oriented examples.

    [ ] 2.2.1 Task - Implement form scaffold apps
      Add the standalone apps for the shared form scaffolding constructs and keep their scope focused on one primary subject per app.

      [ ] 2.2.1.1 Subtask - Implement `form_builder`, `field_group`, and `field` example apps.
      [ ] 2.2.1.2 Subtask - Define the shared supporting scaffold allowed around those primary form subjects.
      [ ] 2.2.1.3 Subtask - Add tests that prove each form-scaffold app still uses the shared default theme and shared panel structure.

  [ ] 2.3 Section - Input Control Example Apps
    Create the standalone example applications for the baseline input-control surface.

    [ ] 2.3.1 Task - Implement text and selection input apps
      Add the apps for text, numeric, selection, and boolean input widgets that sit at the center of the baseline form surface.

      [ ] 2.3.1.1 Subtask - Implement `numeric_input`, `checkbox`, `radio_group`, `select`, and `pick_list` example apps.
      [ ] 2.3.1.2 Subtask - Implement `date_input`, `time_input`, `file_input`, and `toggle` example apps.
      [ ] 2.3.1.3 Subtask - Add tests that prove all input apps preserve the shared theme and expose the primary input widget clearly.

  [ ] 2.4 Section - Foundational Suite Index Updates
    Keep the root suite index and shared metadata in sync with the foundational apps added in this phase.

    [ ] 2.4.1 Task - Update foundational app discovery surfaces
      Ensure the example suite index reflects the foundational catalog entries and their app metadata cleanly.

      [ ] 2.4.1.1 Subtask - Add the Phase 2 apps to the suite index and shared review metadata surfaces.
      [ ] 2.4.1.2 Subtask - Confirm app identifiers and directory names match the example catalog exactly.
      [ ] 2.4.1.3 Subtask - Add tests that prove the suite index can discover the foundational apps correctly.

  [ ] 2.5 Section - Phase 2 Integration Tests
    Validate the foundational content, form, and input example applications through the shared suite architecture.

    [ ] 2.5.1 Task - Foundational example-app integration scenarios
      Verify the foundational example apps compile, run, and render consistently through one shared path.

      [ ] 2.5.1.1 Subtask - Verify every foundational example app boots as an independent Mix project.
      [ ] 2.5.1.2 Subtask - Verify each app compiles through the shared DSL template into canonical `UnifiedIUR` and renders through `live_ui`.
      [ ] 2.5.1.3 Subtask - Verify the shared theme and default style profile remain consistent across all foundational apps.
