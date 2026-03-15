# Phase 5 - Native Styling, Runtime Inspection, and Native-IUR Continuity

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Style`
- `LiveUi.Theme`
- `LiveUi.Renderer`
- `LiveUi.Info`
- `LiveUi.Reference`
- `LiveUi.Tooling`

## Relevant Assumptions / Defaults
- Native styling and theming must be directly usable by `live_ui` developers while still preserving canonical `UnifiedIUR` meaning.
- Maintainers need to inspect and compare native and canonical-rendered runtime behavior without a separate renderer stack.
- Direct native and canonical-rendered paths should converge on deterministic runtime shape and event behavior.

[ ] 5 Phase 5 - Native Styling, Runtime Inspection, and Native-IUR Continuity
  Implement native styling and theming, runtime inspection and comparison helpers, and the continuity rules that keep direct-native and canonical-rendered behavior aligned.

  [ ] 5.1 Section - Native Styling and Theming Surface
    Implement the package-native style and theme surface used by direct-native and canonical-rendered widgets.

    [ ] 5.1.1 Task - Implement native theme and token surfaces
      Provide directly usable native styling and theming constructs that can express canonical meaning.

      [ ] 5.1.1.1 Subtask - Implement native theme identity, palette, semantic roles, tokens, and component-style surfaces.
      [ ] 5.1.1.2 Subtask - Define how native styling maps onto LiveView component rendering and assigns usage.
      [ ] 5.1.1.3 Subtask - Ensure the native style surface can realize the canonical `UnifiedIUR` style and theme model without lossy translation.

    [ ] 5.1.2 Task - Implement native style application and override behavior
      Provide predictable runtime behavior for native styles, variants, and state-aware rendering.

      [ ] 5.1.2.1 Subtask - Implement style inheritance and override behavior for container, overlay, and advanced widgets.
      [ ] 5.1.2.2 Subtask - Implement state-aware native styling without introducing renderer-local leakage into canonical transport.
      [ ] 5.1.2.3 Subtask - Add tests for theme and style behavior across direct-native and canonical-rendered widgets.

  [ ] 5.2 Section - Canonical Style and Theme Lowering
    Implement the canonical-to-native style resolution needed for the `UnifiedIUR` renderer.

    [ ] 5.2.1 Task - Implement canonical style and theme mapping
      Lower canonical style and theme values into native runtime styling behavior deterministically.

      [ ] 5.2.1.1 Subtask - Implement lowering of canonical palette, semantic role, token, and component-style meaning into native widget rendering.
      [ ] 5.2.1.2 Subtask - Implement canonical style handling for layered constructs, viewports, and canvas-related widgets.
      [ ] 5.2.1.3 Subtask - Verify equivalent canonical style input yields deterministic native runtime results.

  [ ] 5.3 Section - Runtime Inspection and Native-IUR Comparison
    Implement the package-facing inspection surfaces that let maintainers compare direct-native and canonical-rendered behavior.

    [ ] 5.3.1 Task - Implement inspection helpers for runtime and renderer output
      Provide inspection surfaces that summarize native widget trees, canonical render mappings, and runtime event state.

      [ ] 5.3.1.1 Subtask - Implement inspection helpers for native widget trees, layout and layer structure, and style application.
      [ ] 5.3.1.2 Subtask - Implement inspection helpers for canonical `UnifiedIUR` renderer mappings into native components.
      [ ] 5.3.1.3 Subtask - Implement comparison helpers that show how direct-native and canonical-rendered flows converge or drift.

    [ ] 5.3.2 Task - Implement continuity and parity validation
      Define the checks that keep native and canonical paths aligned for maintained examples.

      [ ] 5.3.2.1 Subtask - Implement validation that equivalent feature areas produce aligned native and canonical runtime meaning.
      [ ] 5.3.2.2 Subtask - Implement diagnostics for native-only behavior that cannot be represented canonically.
      [ ] 5.3.2.3 Subtask - Implement diagnostics for canonical constructs that lack a corresponding native runtime realization.

  [ ] 5.4 Section - Maintained Continuity Examples
    Implement reference examples that compare direct-native and canonical-rendered flows under one runtime model.

    [ ] 5.4.1 Task - Implement paired native and canonical examples
      Provide paired scenarios that prove continuity across styling, runtime behavior, and event handling.

      [ ] 5.4.1.1 Subtask - Create paired foundational examples for direct-native and canonical rendering of the same screen.
      [ ] 5.4.1.2 Subtask - Create paired advanced examples for overlays, viewports, and dashboard flows.
      [ ] 5.4.1.3 Subtask - Create paired style and signal examples that exercise native and canonical equivalence expectations.

  [ ] 5.5 Section - Phase 5 Integration Tests
    Validate native styling, inspection helpers, and native-IUR continuity end to end.

    [ ] 5.5.1 Task - Native styling and inspection integration scenarios
      Verify native style application and runtime inspection remain deterministic and actionable.

      [ ] 5.5.1.1 Subtask - Verify native themes and component styles apply consistently across maintained examples.
      [ ] 5.5.1.2 Subtask - Verify runtime inspection helpers expose native widget, layer, and style structure clearly.
      [ ] 5.5.1.3 Subtask - Verify inspection output remains usable without introducing a second renderer abstraction.

    [ ] 5.5.2 Task - Native and canonical continuity integration scenarios
      Verify direct-native and canonical-rendered paths stay aligned for maintained workflows.

      [ ] 5.5.2.1 Subtask - Verify paired examples preserve the same user-visible runtime meaning across both paths.
      [ ] 5.5.2.2 Subtask - Verify continuity diagnostics catch unsupported native-only or canonical-only behavior.
      [ ] 5.5.2.3 Subtask - Verify the package can compare native and canonical outputs through one repeatable maintainer workflow.
