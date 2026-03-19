# Phase 4 - Display, Overlay, and Operational Example Apps

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/shared`
- `UnifiedUi.Dsl`
- `UnifiedIUR.Layer`
- `UnifiedIUR.Viewport`
- `UnifiedIUR.Canvas`
- `UnifiedIUR.Widgets.Advanced`
- `LiveUi.Runtime`
- `LiveUi.Transport`

## Relevant Assumptions / Defaults
- The suite already covers the foundational, layout, navigation, data, and feedback catalog entries.
- This phase covers the most structurally complex example apps in the suite.
- Even advanced apps still rely on the shared example shell, shared theme, and one-primary-subject-per-app rule.

[x] 4 Phase 4 - Display, Overlay, and Operational Example Apps
  Implement the display-system, overlay, and operational example applications together with the more advanced runtime flows they require.

  [ ] 4.1 Section - Display-System Example Apps
    Create the example applications for the display-system constructs that shape clipping, scroll, split, and drawing behavior.

    [ ] 4.1.1 Task - Implement display-system apps
      Add the standalone apps for the advanced display-system constructs and keep their supporting content intentionally narrow.

      [ ] 4.1.1.1 Subtask - Implement `viewport`, `scroll_bar`, `split_pane`, and `canvas` example apps.
      [ ] 4.1.1.2 Subtask - Define the minimal supporting data and content needed to make each display-system subject understandable.
      [ ] 4.1.1.3 Subtask - Add tests that prove these apps preserve the shared shell and theme while foregrounding the display construct clearly.

  [ ] 4.2 Section - Overlay Example Apps
    Create the example applications for the overlay and layered constructs that demonstrate modal, popup, and transient behavior.

    [ ] 4.2.1 Task - Implement overlay and modal apps
      Add the example applications for the overlay-oriented constructs and preserve a consistent suite shell around them.

      [ ] 4.2.1.1 Subtask - Implement `overlay`, `dialog`, `alert_dialog`, `context_menu`, and `toast` example apps.
      [ ] 4.2.1.2 Subtask - Define the standard interaction triggers and demo content allowed inside these overlay examples.
      [ ] 4.2.1.3 Subtask - Add tests that prove the overlay apps remain consistent with the shared theme and one-primary-subject rule.

  [ ] 4.3 Section - Operational Example Apps
    Create the example applications for the operational and monitoring constructs that use richer sample data under the shared shell.

    [ ] 4.3.1 Task - Implement operational and monitoring apps
      Add the standalone apps for the advanced operational widgets and keep their runtime behavior reviewable through one shared suite pattern.

      [ ] 4.3.1.1 Subtask - Implement `stream_widget`, `process_monitor`, `supervision_tree_viewer`, and `cluster_dashboard` example apps.
      [ ] 4.3.1.2 Subtask - Define reusable operational sample data fixtures for these apps.
      [ ] 4.3.1.3 Subtask - Add tests that prove the operational apps render consistently and remain catalog-traceable.

  [ ] 4.4 Section - Advanced Catalog Completion Sweep
    Close the remaining advanced catalog gaps and confirm the full widget and construct list is represented in the suite.

    [ ] 4.4.1 Task - Verify advanced catalog completeness
      Ensure every remaining catalog entry in the advanced families maps to a concrete example-app directory and runnable app skeleton.

      [ ] 4.4.1.1 Subtask - Compare the implemented suite directories against the full example catalog.
      [ ] 4.4.1.2 Subtask - Add any missing advanced app directories and shared metadata entries.
      [ ] 4.4.1.3 Subtask - Add tests that fail when any advanced catalog entry is missing.

  [ ] 4.5 Section - Phase 4 Integration Tests
    Validate the display, overlay, and operational example applications through one advanced-suite workflow.

    [ ] 4.5.1 Task - Advanced example-app integration scenarios
      Verify the most complex example apps remain runnable, understandable, and aligned with the shared suite contract.

      [ ] 4.5.1.1 Subtask - Verify the display-system, overlay, and operational apps all run independently through the same suite conventions.
      [ ] 4.5.1.2 Subtask - Verify the shared DSL template and theme remain intact even in the most complex app families.
      [ ] 4.5.1.3 Subtask - Verify advanced catalog completeness is enforced automatically.
