# Phase 13 - Advanced Widget Component Migration and Canonical Renderer Convergence

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Widgets.List`
- `LiveUi.Widgets.Table`
- `LiveUi.Widgets.TreeView`
- `LiveUi.Widgets.MarkdownViewer`
- `LiveUi.Widgets.LogViewer`
- `LiveUi.Widgets.Status`
- `LiveUi.Widgets.Progress`
- `LiveUi.Widgets.Gauge`
- `LiveUi.Widgets.InlineFeedback`
- `LiveUi.Widgets.Sparkline`
- `LiveUi.Widgets.BarChart`
- `LiveUi.Widgets.LineChart`
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
- `LiveUi.Renderer`

## Relevant Assumptions / Defaults
- Phases 11 and 12 have established the shared widget-component contract and migrated the most common widget families.
- Advanced widget families must converge on the same widget-component architecture rather than keeping a second tier of helper-only or markup-only implementations.
- Canonical rendering must target the same advanced widget component boundaries that direct-native usage targets.
- Some advanced surfaces may remain visually minimal at first, but they still need to respect the widget-component contract and event/lifecycle boundaries.

[ ] 13 Phase 13 - Advanced Widget Component Migration and Canonical Renderer Convergence
  Migrate advanced widget families onto explicit widget component boundaries and finish the renderer convergence work so canonical `UnifiedIUR` always targets the same widget architecture as direct-native `live_ui`.

  [ ] 13.1 Section - Data and Feedback Widget Component Migration
    Migrate structured data, document, and feedback surfaces onto the shared widget-component architecture.

    [ ] 13.1.1 Task - Convert data and document widgets to explicit component boundaries
      Migrate collection and document surfaces so they stop relying on passive markup-only implementations.

      [ ] 13.1.1.1 Subtask - Convert `list`, `table`, `tree_view`, `markdown_viewer`, and `log_viewer` to widget component implementations with explicit lifecycle and event semantics.
      [ ] 13.1.1.2 Subtask - Ensure collection-item identity, selection semantics, and canonical item attributes remain stable through mounted widget component boundaries.
      [ ] 13.1.1.3 Subtask - Add tests that prove data and document widgets preserve continuity across server updates and canonical rerenders.

    [ ] 13.1.2 Task - Convert feedback and chart widgets to explicit component boundaries
      Migrate feedback and chart surfaces so they share the same widget-component runtime contract even when their initial rendering remains visually simple.

      [ ] 13.1.2.1 Subtask - Convert `status`, `progress`, `gauge`, `inline_feedback`, `sparkline`, `bar_chart`, and `line_chart` to widget component implementations.
      [ ] 13.1.2.2 Subtask - Ensure state variants, style realization, and canonical renderer behavior continue to work after the migration.
      [ ] 13.1.2.3 Subtask - Add tests that prove feedback and chart widgets remain deterministic across direct-native and canonical paths.

  [ ] 13.2 Section - Overlay, Operational, and Display Widget Component Migration
    Migrate the more stateful widget families that most benefit from explicit widget-local lifecycle boundaries.

    [ ] 13.2.1 Task - Convert overlay widget surfaces to explicit component boundaries
      Migrate dialogs, overlays, and transient overlay surfaces so their bounded local lifecycle becomes explicit and testable.

      [ ] 13.2.1.1 Subtask - Convert `overlay_surface`, `dialog`, `alert_dialog`, `context_menu`, and `toast` to widget component implementations.
      [ ] 13.2.1.2 Subtask - Define how open, close, focus, anchor, placement, and dismissal behavior use bounded widget-local state without violating server authority.
      [ ] 13.2.1.3 Subtask - Add tests that prove overlay lifecycle behavior remains aligned across direct-native and canonical usage.

    [ ] 13.2.2 Task - Convert operational and display-system widgets to explicit component boundaries
      Migrate stream, monitoring, viewport, split, scroll, and canvas surfaces onto the widget-component model.

      [ ] 13.2.2.1 Subtask - Convert `stream_widget`, `process_monitor`, `supervision_tree_viewer`, and `cluster_dashboard` to widget component implementations.
      [ ] 13.2.2.2 Subtask - Convert `viewport`, `scroll_bar`, `split_pane`, and `canvas` to widget component implementations where they need lifecycle or event boundaries.
      [ ] 13.2.2.3 Subtask - Add tests that prove advanced widget-local lifecycle remains bounded and renderer continuity is preserved.

  [ ] 13.3 Section - Canonical Renderer Convergence
    Finish the convergence work so canonical `UnifiedIUR` rendering targets the same widget component boundaries used by direct native screens for every supported construct.

    [ ] 13.3.1 Task - Retarget canonical rendering to the migrated widget component architecture
      Remove remaining renderer-only widget paths and make the canonical renderer a thin adapter onto the native widget component set.

      [ ] 13.3.1.1 Subtask - Update `LiveUi.Renderer` so every advanced canonical widget maps into the same widget component boundary used by direct-native usage.
      [ ] 13.3.1.2 Subtask - Remove or isolate any remaining renderer-only markup generation paths that bypass widget component boundaries.
      [ ] 13.3.1.3 Subtask - Add tests that prove equivalent native and canonical widget trees converge on the same component boundaries and event semantics.

  [ ] 13.4 Section - Phase 13 Integration Tests
    Validate the advanced widget migrations and canonical renderer convergence end to end.

    [ ] 13.4.1 Task - Advanced widget family integration scenarios
      Verify advanced widgets now behave as real widget components across representative direct-native and canonical flows.

      [ ] 13.4.1.1 Subtask - Verify data, feedback, overlay, operational, and display widgets preserve identity and bounded local state through mounted component boundaries.
      [ ] 13.4.1.2 Subtask - Verify advanced widget event routing remains correct for collection, overlay, and viewport-style interactions.
      [ ] 13.4.1.3 Subtask - Verify visually minimal advanced widgets still respect the widget-component contract even before richer rendering improvements land.

    [ ] 13.4.2 Task - Canonical renderer convergence integration scenarios
      Verify canonical `UnifiedIUR` rendering now targets the same widget component architecture across the supported advanced surface.

      [ ] 13.4.2.1 Subtask - Verify equivalent direct-native and canonical advanced widgets converge on the same widget component boundaries.
      [ ] 13.4.2.2 Subtask - Verify canonical event lowering and transport still work after renderer-only paths are removed or isolated.
      [ ] 13.4.2.3 Subtask - Verify advanced widget continuity remains deterministic across rerenders, boundary translation, and browser-hosted demo review.
