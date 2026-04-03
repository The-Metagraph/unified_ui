# Phase 15 - Canonical Renderer Convergence

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Renderer`
- `LiveUi.Component`
- `LiveUi.Widget.Identity`
- `UnifiedIUR.Element`
- `UnifiedIUR.Layout`

## Relevant Assumptions / Defaults
- Phases 11-14 have migrated all widget families to the widget-component architecture.
- The canonical renderer must target the same widget component boundaries used by direct-native usage.
- Remaining renderer-only markup generation paths must be removed or isolated.

[ ] 15 Phase 15 - Canonical Renderer Convergence
  Finish the convergence work so canonical `UnifiedIUR` rendering targets the same widget component boundaries used by direct native screens for every supported construct.

  [ ] 15.1 Section - Retarget Canonical Rendering to Widget Components
    Remove remaining renderer-only widget paths and make the canonical renderer a thin adapter onto the native widget component set.

    [ ] 15.1.1 Task - Update canonical renderer to use migrated widget components
      Make the canonical renderer target widget component boundaries for all constructs.

      [ ] 15.1.1.1 Subtask - Update `LiveUi.Renderer` so every canonical widget maps into the same widget component boundary used by direct-native usage.
      [ ] 15.1.1.2 Subtask - Remove or isolate any remaining renderer-only markup generation paths that bypass widget component boundaries.
      [ ] 15.1.1.3 Subtask - Add tests that prove equivalent native and canonical widget trees converge on the same component boundaries and event semantics.

  [ ] 15.2 Section - Canonical Event Transport Alignment
      Ensure canonical event lowering and transport work through widget component boundaries.

    [ ] 15.2.1 Task - Align event handling for canonical rendering
      Make canonical events route through widget component boundaries correctly.

      [ ] 15.2.1.1 Subtask - Verify canonical event lowering and transport still work after renderer-only paths are removed or isolated.
      [ ] 15.2.1.2 Subtask - Ensure event routing preserves widget identity and bounded local state across canonical/native boundary.
      [ ] 15.2.1.3 Subtask - Add tests that prove canonical events route correctly through widget component boundaries.

  [ ] 15.3 Section - Phase 15 Integration Tests
    Validate canonical renderer convergence end to end.

    [ ] 15.3.1 Task - Canonical renderer convergence integration scenarios
      Verify canonical `UnifiedIUR` rendering targets the same widget component architecture.

      [ ] 15.3.1.1 Subtask - Verify equivalent direct-native and canonical widgets converge on the same widget component boundaries.
      [ ] 15.3.1.2 Subtask - Verify canonical event lowering and transport work through widget component boundaries.
      [ ] 15.3.1.3 Subtask - Verify widget continuity remains deterministic across rerenders and boundary translation.
