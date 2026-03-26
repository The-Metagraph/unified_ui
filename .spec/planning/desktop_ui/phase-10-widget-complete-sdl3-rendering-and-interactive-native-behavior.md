# Phase 10 - Widget-Complete SDL3 Rendering and Interactive Native Behavior

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `DesktopUi.Sdl3.Renderer`
- `DesktopUi.Sdl3.Text`
- `DesktopUi.Sdl3.Images`
- `DesktopUi.Sdl3.Events`
- `DesktopUi.Sdl3.Window`
- `DesktopUi.Sdl3.VisibleRunner`
- `DesktopUi.Runtime`
- `DesktopUi.Inspect`
- `DesktopUi.Validate`
- `mix desktop_ui.run`

## Relevant Assumptions / Defaults
- Phases 1 through 9 are complete, so `desktop_ui` already has a real SDL3
  host boundary, visible-window execution path, packaging workflows, and
  package-scoped compliance coverage.
- `SDL_Renderer` remains the first concrete backend in this phase; any future
  SDL3 GPU exploration must stay behind the existing bounded evolution rules.
- This phase upgrades renderer completeness from first-presented-frame and
  placeholder semantics to maintained-example widget completeness on SDL3-ready
  machines.
- Text and image realization should prefer SDL3 companion-library-backed native
  rendering while continuing to report deterministic fallback diagnostics when a
  companion library is absent.
- Interactive visible-window behavior should match the same semantic outcomes
  already expected from the fallback host and canonical runtime paths.

[ ] 10 Phase 10 - Widget-Complete SDL3 Rendering and Interactive Native Behavior
  Upgrade `desktop_ui` from first-presented-frame visible execution to
  widget-complete maintained-example rendering by implementing real
  SDL_Renderer drawing, native text and image realization, and interactive
  visible-window behavior that preserves existing runtime and transport
  semantics.

  [x] 10.1 Section - Widget-Complete SDL_Renderer Realization
    Turn the current retained render plan into real on-screen widget visuals so
    maintained native and canonical examples display meaningful desktop UI
    instead of placeholder-only geometry.

    [x] 10.1.1 Task - Implement concrete drawing for foundational and semantic widget families
      Realize the maintained foundational and semantic widget surface through
      real SDL_Renderer drawing primitives, state-aware visuals, and bounded
      layout chrome.

      [x] 10.1.1.1 Subtask - Draw foundational content, action, form, and navigation widgets with visible labels, focus states, selection states, and disabled states.
      [x] 10.1.1.2 Subtask - Draw maintained semantic widget families such as badge, hero, stat, key-value, info-list, and form-field through the same native renderer path.
      [x] 10.1.1.3 Subtask - Keep widget drawing derived from the retained render plan rather than introducing an unrelated imperative widget renderer.

    [x] 10.1.2 Task - Implement concrete drawing for advanced, layered, and multiwindow surfaces
      Realize the maintained advanced desktop flows so tables, operational
      widgets, overlays, viewports, split panes, canvas surfaces, and secondary
      windows present concrete visuals in the compiled visible runner.

      [x] 10.1.2.1 Subtask - Draw advanced data, feedback, visualization, and operational widgets with maintained-example-level completeness.
      [x] 10.1.2.2 Subtask - Realize layered shells, overlay surfaces, viewport regions, split panes, and multiwindow chrome through SDL_Renderer.
      [x] 10.1.2.3 Subtask - Preserve logical-unit layout, clip regions, and bounded platform variation while upgrading visual completeness.

  [ ] 10.2 Section - Native Text, Image, and Style Realization
    Replace text and image placeholders with real native resource realization so
    the visible runner can present meaningful labels, icons, imagery, and style
    states.

    [ ] 10.2.1 Task - Realize native text and image resources through SDL3 companion libraries
      Make the compiled visible runner render maintained text and image content
      through native SDL3-backed preparation, caching, and draw operations.

      [ ] 10.2.1.1 Subtask - Implement font loading, text measurement, glyph surface preparation, and texture caching through the SDL3 text companion path.
      [ ] 10.2.1.2 Subtask - Implement image decode, surface preparation, texture caching, and bounded raw-pixel fallback through the SDL3 image companion path.
      [ ] 10.2.1.3 Subtask - Surface native-versus-fallback text and image realization state through inspection, validation, and run diagnostics.

    [ ] 10.2.2 Task - Realize resolved styles in the visible native renderer
      Carry the existing style and theme model through to actual native
      rendering so maintained examples display meaningful component variants and
      state-aware visuals.

      [ ] 10.2.2.1 Subtask - Map resolved colors, borders, spacing, emphasis, and semantic roles to concrete SDL_Renderer draw operations.
      [ ] 10.2.2.2 Subtask - Preserve component variants, state variants, and inherited theme behavior in visible native output.
      [ ] 10.2.2.3 Subtask - Keep style realization consistent between direct-native and canonical-IUR-driven screens.

  [ ] 10.3 Section - Interactive Native Behavior and Event Realization
    Upgrade the visible runner from static frame presentation to real
    interactive native behavior so maintained flows can be exercised by hand in
    desktop windows.

    [ ] 10.3.1 Task - Implement hit-testing, focus, and command interaction
      Make visible native widgets respond to real keyboard and pointer input
      through hit-testing and focus movement that preserve existing runtime
      semantics.

      [ ] 10.3.1.1 Subtask - Implement hit-testing and focus targeting for maintained foundational and advanced widget surfaces.
      [ ] 10.3.1.2 Subtask - Route keyboard, pointer, and command interactions through the compiled visible runner with the same semantic outcomes as the fallback host.
      [ ] 10.3.1.3 Subtask - Preserve command shortcuts, selection changes, submit behavior, and dialog or menu transitions in native execution.

    [ ] 10.3.2 Task - Implement scrolling, viewport, and multiwindow interaction behavior
      Make the visible runner support the maintained desktop interaction flows
      that depend on scroll regions, layered surfaces, and more than one native
      window.

      [ ] 10.3.2.1 Subtask - Implement wheel and scroll-region behavior for maintained viewport and document-like surfaces.
      [ ] 10.3.2.2 Subtask - Coordinate overlay, popover, dialog, and context-menu interaction semantics inside owning windows.
      [ ] 10.3.2.3 Subtask - Coordinate window activation, focus transfer, and bounded secondary-window interactions across multiwindow maintained flows.

  [ ] 10.4 Section - Tooling, Diagnostics, and Renderer Completeness Reporting
    Update the maintainer tooling and review surfaces so the package clearly
    reports when widget-complete native rendering and interactive behavior are
    available.

    [ ] 10.4.1 Task - Expose renderer-completeness and interaction diagnostics through maintainer tooling
      Make run, inspect, validate, and reference surfaces reflect the new
      widget-complete native runtime status instead of the older
      first-presented-frame milestone.

      [ ] 10.4.1.1 Subtask - Update inspection and run surfaces to distinguish placeholder-only execution from widget-complete interactive execution.
      [ ] 10.4.1.2 Subtask - Update validation and release-readiness reporting to include widget-complete rendering, native text-image realization, and interactive execution gates.
      [ ] 10.4.1.3 Subtask - Document the expected manual-review workflow for maintained examples on SDL3-ready maintainer machines.

  [ ] 10.5 Section - Phase 10 Integration Tests
    Validate widget-complete rendering, native resource realization, and
    interactive visible-window behavior end to end while preserving bounded
    fallback behavior on machines without SDL3.

    [ ] 10.5.1 Task - Widget-complete rendering and interaction integration scenarios
      Verify maintained examples render and behave natively through the
      compiled SDL3 visible runner while preserving runtime and transport
      meaning.

      [ ] 10.5.1.1 Subtask - Verify maintained foundational, advanced, transport, and styled examples render widget-complete frames with native text and image realization when companion libraries are present.
      [ ] 10.5.1.2 Subtask - Verify focus, pointer, scrolling, command, and multiwindow interaction flows preserve the same semantic outcomes across compiled-native and fallback host paths.
      [ ] 10.5.1.3 Subtask - Verify inspection, validation, and run diagnostics report widget-complete native execution accurately and degrade explicitly when SDL3 or companion resources are unavailable.
