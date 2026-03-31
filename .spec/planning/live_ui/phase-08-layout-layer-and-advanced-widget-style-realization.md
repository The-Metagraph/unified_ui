# Phase 8 - Layout, Layer, and Advanced Widget Style Realization

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Style`
- `LiveUi.Theme`
- `LiveUi.Renderer`
- `LiveUi.Layout`
- `LiveUi.Widgets.OverlaySurface`
- `LiveUi.Widgets.Dialog`
- `LiveUi.Widgets.AlertDialog`
- `LiveUi.Widgets.Viewport`
- `LiveUi.Widgets.Canvas`
- `UnifiedIUR.Style`
- `UnifiedIUR.Theme`
- `UnifiedIUR.Display`
- `UnifiedIUR.Layout`

## Relevant Assumptions / Defaults
- Foundational widget realization should be in place before broader layout, layered, and advanced browser surfaces are lowered.
- Layout and layer constructs need more than color tokens; they must realize spacing, sizing, alignment, clipping, background treatment, and state-aware transitions in a deterministic way.
- Advanced widget coverage should continue to reuse one shared runtime and one shared browser stylesheet, not a second specialized renderer stack.
- Unsupported or partially supported canonical style fields should become diagnosable rather than silently ignored.

[ ] 8 Phase 8 - Layout, Layer, and Advanced Widget Style Realization
  Extend browser-visible canonical style realization from foundational widgets into layout primitives, layered constructs, and advanced widgets so the broader `UnifiedIUR` surface gains meaningful browser styling parity.

  [ ] 8.1 Section - Layout and Container Geometry Realization
    Make canonical spacing, sizing, alignment, and container treatment materially affect browser layout behavior.

    [ ] 8.1.1 Task - Implement layout primitive realization
      Realize canonical layout style values for rows, columns, grids, boxes, and related composition primitives.

      [ ] 8.1.1.1 Subtask - Implement browser realization for padding, gap, width, height, min and max sizing, alignment, and justification across layout primitives.
      [ ] 8.1.1.2 Subtask - Define how layout-specific authored attrs such as `padding`, `border`, `background`, and canonical style values combine without contradictory output.
      [ ] 8.1.1.3 Subtask - Add regression coverage that proves canonical geometry changes alter browser layout deterministically.

    [ ] 8.1.2 Task - Implement container inheritance and nested-style behavior
      Ensure nested composition surfaces inherit and override browser-realized styles predictably.

      [ ] 8.1.2.1 Subtask - Define inheritance rules for nested containers, mixed direct-native and canonical trees, and state-aware container overrides.
      [ ] 8.1.2.2 Subtask - Implement nested style realization without leaking parent-only browser attrs into children incorrectly.
      [ ] 8.1.2.3 Subtask - Add tests that prove nested layout and container realization remains deterministic across renderer paths.

  [ ] 8.2 Section - Layered, Display-System, and Surface Realization
    Extend the browser style contract into overlays, dialogs, viewport surfaces, canvas-like displays, and other layered constructs.

    [ ] 8.2.1 Task - Implement layered surface realization
      Realize the canonical style fields that control layered and contextual browser surfaces.

      [ ] 8.2.1.1 Subtask - Implement browser realization for overlay, dialog, alert-dialog, and contextual-surface background, scrim, border, and emphasis styling.
      [ ] 8.2.1.2 Subtask - Define how modal, layered, and contextual state variants affect realized browser output without breaking transport or local event semantics.
      [ ] 8.2.1.3 Subtask - Add regression coverage that proves layered browser surfaces preserve authored meaning and visible continuity.

    [ ] 8.2.2 Task - Implement viewport and canvas style realization
      Realize the browser-visible style behavior for clipping, viewport, scroll, and canvas-adjacent display constructs.

      [ ] 8.2.2.1 Subtask - Implement browser realization for viewport backgrounds, clipping-adjacent treatment, divider visuals, and scroll-related surface styling where applicable.
      [ ] 8.2.2.2 Subtask - Implement canvas-surface and analysis-surface realization that honors canonical colors and authored local style hooks without inventing non-canonical meaning.
      [ ] 8.2.2.3 Subtask - Add tests that prove advanced display-system browser styling remains deterministic and reviewable.

  [ ] 8.3 Section - Advanced Widget and State-Variant Realization
    Extend browser-visible canonical styling into the broader advanced widget catalog together with state-variant handling.

    [ ] 8.3.1 Task - Implement advanced widget style lowering
      Realize browser-visible style behavior for data, feedback, and operational widgets that currently depend mostly on classes and semantic hooks.

      [ ] 8.3.1.1 Subtask - Implement style realization coverage for representative advanced widgets such as list, tabs, tree_view, status, toast, markdown_viewer, charts, and operational surfaces.
      [ ] 8.3.1.2 Subtask - Ensure advanced widgets can consume resolved canonical color, text, and emphasis meaning without each widget inventing bespoke lowering rules.
      [ ] 8.3.1.3 Subtask - Add regression coverage that proves advanced widgets respect shared browser style semantics rather than demo-only CSS assumptions.

    [ ] 8.3.2 Task - Implement state-variant realization and unsupported-field reporting
      Make canonical state variants visibly affect browser output and report the remaining unsupported edges clearly.

      [ ] 8.3.2.1 Subtask - Realize browser-visible active, focused, disabled, selected, and custom state variants where the native widget surface supports them.
      [ ] 8.3.2.2 Subtask - Add diagnostics for canonical state variants or style fields that the browser renderer still cannot realize faithfully.
      [ ] 8.3.2.3 Subtask - Add focused tests that prove state-aware browser styling remains aligned across direct-native and canonical-rendered flows.

  [ ] 8.4 Section - Phase 8 Integration Tests
    Validate layout, layered, and advanced widget browser-style realization end to end.

    [ ] 8.4.1 Task - Layout and layered browser-realization integration scenarios
      Verify canonical geometry and layered style meaning visibly affect the browser across representative layout and display-system workflows.

      [ ] 8.4.1.1 Subtask - Verify spacing, sizing, alignment, and nested-container realization produce the expected browser-visible layout behavior.
      [ ] 8.4.1.2 Subtask - Verify overlays, dialogs, and viewports honor canonical style values without breaking interaction continuity.
      [ ] 8.4.1.3 Subtask - Verify advanced display surfaces remain deterministic across direct-native and canonical-rendered examples.

    [ ] 8.4.2 Task - Advanced widget and state-variant integration scenarios
      Verify representative advanced widgets and stateful flows now reflect canonical style values in the browser.

      [ ] 8.4.2.1 Subtask - Verify advanced widgets no longer depend solely on local demo CSS classes for visible styling differences.
      [ ] 8.4.2.2 Subtask - Verify state variants produce browser-visible active, focused, selected, and disabled treatment where supported.
      [ ] 8.4.2.3 Subtask - Verify unsupported advanced-style fields are reported clearly instead of failing silently.
