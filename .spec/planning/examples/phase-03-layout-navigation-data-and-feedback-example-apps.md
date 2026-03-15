# Phase 3 - Layout, Navigation, Data, and Feedback Example Apps

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/shared`
- `UnifiedUi.Dsl`
- `UnifiedIUR.Layout`
- `UnifiedIUR.Widgets.Navigation`
- `UnifiedIUR.Widgets.Foundational`
- `LiveUi.Renderer`
- `LiveUi.Tooling`

## Relevant Assumptions / Defaults
- Foundational example apps already establish the standalone app shape and the shared suite shell.
- Layout, navigation, data, and feedback examples still use one primary subject per app, even when surrounding scaffolding is needed to make the subject understandable.
- The suite index and shared metadata are updated continuously as new example apps are added.

[ ] 3 Phase 3 - Layout, Navigation, Data, and Feedback Example Apps
  Implement the example applications for layout, navigation, data, and feedback constructs while preserving the shared shell, shared theme, and one-primary-subject-per-app rule.

  [ ] 3.1 Section - Layout Example Apps
    Create the standalone apps that demonstrate the layout primitives and show how the shared template hosts them without losing focus.

    [ ] 3.1.1 Task - Implement layout primitive apps
      Add the example applications for directional and grid layout primitives that shape the authored screen surface.

      [ ] 3.1.1.1 Subtask - Implement `row`, `column`, and `grid` example apps.
      [ ] 3.1.1.2 Subtask - Define the minimal supporting children each layout example is allowed to include.
      [ ] 3.1.1.3 Subtask - Add tests that prove the layout apps still foreground one primary layout subject each.

  [ ] 3.2 Section - Navigation Example Apps
    Create the standalone apps for navigation-oriented widgets and list-like selection flows.

    [ ] 3.2.1 Task - Implement navigation and list apps
      Add the example applications that demonstrate navigation surfaces under the shared template and theme.

      [ ] 3.2.1.1 Subtask - Implement `menu`, `tabs`, and `command_palette` example apps.
      [ ] 3.2.1.2 Subtask - Implement the `list` example app for list-oriented navigation and selection.
      [ ] 3.2.1.3 Subtask - Add tests that prove the navigation apps remain traceable to the correct catalog entries and families.

  [ ] 3.3 Section - Data Example Apps
    Create the standalone apps for the core data-view widgets that reviewers need to compare across one shared shell.

    [ ] 3.3.1 Task - Implement data-view apps
      Add the example applications for the baseline data-oriented widgets and document their focused demonstration scope.

      [ ] 3.3.1.1 Subtask - Implement `table`, `tree_view`, `markdown_viewer`, and `log_viewer` example apps.
      [ ] 3.3.1.2 Subtask - Define the standard sample data fixtures shared across these data-view examples.
      [ ] 3.3.1.3 Subtask - Add tests that prove the data-view apps compile and render predictably through `live_ui`.

  [ ] 3.4 Section - Feedback Example Apps
    Create the standalone apps for the feedback and chart-style widgets that still fit inside the common suite shell.

    [ ] 3.4.1 Task - Implement feedback and chart-oriented apps
      Add the example applications for progress and chart-like feedback widgets while preserving the common default theme and style.

      [ ] 3.4.1.1 Subtask - Implement `status`, `progress`, `gauge`, and `inline_feedback` example apps.
      [ ] 3.4.1.2 Subtask - Implement `sparkline`, `bar_chart`, and `line_chart` example apps.
      [ ] 3.4.1.3 Subtask - Add tests that prove the feedback and chart apps share the common default theme without obscuring their primary subject.

  [ ] 3.5 Section - Phase 3 Integration Tests
    Validate the layout, navigation, data, and feedback example applications through one suite-level workflow.

    [ ] 3.5.1 Task - Mid-catalog example-app integration scenarios
      Verify the suite continues to scale cleanly as the middle catalog families are added.

      [ ] 3.5.1.1 Subtask - Verify all Phase 3 apps can be discovered and run independently from the suite index.
      [ ] 3.5.1.2 Subtask - Verify the shared DSL template and default theme remain intact across layout, navigation, data, and feedback families.
      [ ] 3.5.1.3 Subtask - Verify no Phase 3 app loses its one-primary-subject focus as surrounding scaffolding becomes more complex.
