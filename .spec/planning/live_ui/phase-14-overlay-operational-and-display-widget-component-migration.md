# Phase 14 - Overlay, Operational, and Display Widget Component Migration

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Widgets.OverlaySurface`
- `LiveUi.Widgets.Dialog`
- `LiveUi.Widgets.AlertDialog`
- `LiveUi.Widgets.ContextMenu`
- `LiveUi.Widgets.Toast`
- `LiveUi.Widgets.StreamWidget`
- `LiveUi.Widgets.ProcessMonitor`
- `LiveUi.Widgets.SupervisionTreeViewer`
- `LiveUi.Widgets.ClusterDashboard`
- `LiveUi.Widgets.Viewport`
- `LiveUi.Widgets.ScrollBar`
- `LiveUi.Widgets.SplitPane`
- `LiveUi.Widgets.Canvas`
- `LiveUi.Component`
- `LiveUi.Widget.Identity`

## Relevant Assumptions / Defaults
- Phases 11, 12, and 13 have established the widget-component contract across foundational, input, navigation, form, data, and feedback widget families.
- Overlay and operational widgets are more stateful and benefit significantly from explicit widget-local lifecycle boundaries.
- Display system widgets need explicit event boundaries for viewport, scroll, split, and canvas interactions.

[ ] 14 Phase 14 - Overlay, Operational, and Display Widget Component Migration
  Migrate the more stateful widget families that most benefit from explicit widget-local lifecycle boundaries.

  [ ] 14.1 Section - Overlay Widget Component Migration
    Migrate dialogs, overlays, and transient overlay surfaces so their bounded local lifecycle becomes explicit and testable.

    [ ] 14.1.1 Task - Convert overlay widget surfaces to explicit component boundaries
      Migrate overlay widgets to widget component implementations.

      [ ] 14.1.1.1 Subtask - Convert `overlay_surface`, `dialog`, `alert_dialog`, `context_menu`, and `toast` to widget component implementations.
      [ ] 14.1.1.2 Subtask - Define how open, close, focus, anchor, placement, and dismissal behavior use bounded widget-local state without violating server authority.
      [ ] 14.1.1.3 Subtask - Add tests that prove overlay lifecycle behavior remains aligned across direct-native and canonical usage.

  [ ] 14.2 Section - Operational Widget Component Migration
    Migrate stream, monitoring, and dashboard widgets onto the widget-component model.

    [ ] 14.2.1 Task - Convert operational widgets to explicit component boundaries
      Migrate operational widgets to widget component implementations.

      [ ] 14.2.1.1 Subtask - Convert `stream_widget`, `process_monitor`, `supervision_tree_viewer`, and `cluster_dashboard` to widget component implementations.
      [ ] 14.2.1.2 Subtask - Ensure streaming, monitoring, and dashboard state management works through bounded widget-local state.
      [ ] 14.2.1.3 Subtask - Add tests that prove operational widgets preserve real-time updates and bounded local state.

  [ ] 14.3 Section - Display System Widget Component Migration
    Migrate viewport, scroll, split, and canvas widgets onto the widget-component model.

    [ ] 14.3.1 Task - Convert display system widgets to explicit component boundaries
      Migrate display system widgets to widget component implementations.

      [ ] 14.3.1.1 Subtask - Convert `viewport`, `scroll_bar`, `split_pane`, and `canvas` to widget component implementations where they need lifecycle or event boundaries.
      [ ] 14.3.1.2 Subtask - Ensure viewport, scroll, split, and canvas interactions use proper event routing through widget boundaries.
      [ ] 14.3.1.3 Subtask - Add tests that prove display system widgets preserve interaction semantics through component boundaries.

  [ ] 14.4 Section - Phase 14 Integration Tests
    Validate the overlay, operational, and display widget migrations end to end.

    [ ] 14.4.1 Task - Overlay and operational widget integration scenarios
      Verify overlay and operational widgets now behave as real widget components.

      [ ] 14.4.1.1 Subtask - Verify overlay widgets preserve lifecycle, focus, and dismissal behavior through mounted component boundaries.
      [ ] 14.4.1.2 Subtask - Verify operational widgets preserve real-time updates and bounded local state.
      [ ] 14.4.1.3 Subtask - Verify display system widgets preserve interaction semantics through component boundaries.
