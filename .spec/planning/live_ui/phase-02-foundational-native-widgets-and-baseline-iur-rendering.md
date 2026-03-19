# Phase 2 - Foundational Native Widgets and Baseline IUR Rendering

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Widgets.*`
- `LiveUi.Forms`
- `LiveUi.Layout`
- `LiveUi.Renderer`
- `UnifiedIUR.Widgets`
- `UnifiedIUR.Layout`

## Relevant Assumptions / Defaults
- Native widget usability must arrive early so `live_ui` is a real runtime library and not just an adapter shell.
- Canonical `UnifiedIUR` rendering should begin with the same foundational surface used by direct native widgets.
- Foundational native and canonical rendering paths must share one runtime architecture rather than diverging into two stacks.

[x] 2 Phase 2 - Foundational Native Widgets and Baseline IUR Rendering
  Implement foundational native widgets, baseline forms and navigation, simple layout composition, and the first canonical `UnifiedIUR` rendering path.

  [x] 2.1 Section - Foundational Native Visual Widgets
    Implement the core directly usable widget surface that native `live_ui` applications rely on first.

    [x] 2.1.1 Task - Implement foundational display widgets
      Provide the basic visual widget families required for direct native use and baseline canonical rendering.

      [x] 2.1.1.1 Subtask - Implement native text, label, image, icon, button, link, separator, and spacer widgets.
      [x] 2.1.1.2 Subtask - Define common assigns, style hooks, and event surfaces shared across foundational widgets.
      [x] 2.1.1.3 Subtask - Add direct native rendering tests for foundational widgets through LiveView-native composition.

    [x] 2.1.2 Task - Implement foundational container and shell widgets
      Provide baseline container widgets that let foundational screens compose naturally.

      [x] 2.1.2.1 Subtask - Implement box or panel-like native container widgets for foundational screen shells.
      [x] 2.1.2.2 Subtask - Define slot and child rendering rules for foundational container composition.
      [x] 2.1.2.3 Subtask - Keep foundational container behavior reusable by the canonical `UnifiedIUR` renderer.

  [x] 2.2 Section - Input, Forms, and Navigation Baseline
    Implement the first interactive widget families needed for real user workflows.

    [x] 2.2.1 Task - Implement native input and form primitives
      Provide foundational input widgets and grouped form composition for direct native use.

      [x] 2.2.1.1 Subtask - Implement native text input, toggle, select, field, field-group, and form-builder primitives.
      [x] 2.2.1.2 Subtask - Define assigns, value, and validation surfaces for native input handling through LiveView updates.
      [x] 2.2.1.3 Subtask - Add tests for grouped form composition, input defaults, and field-to-input relationships.

    [x] 2.2.2 Task - Implement native navigation widgets
      Provide the navigation widgets needed for screen-level flows and quick actions.

      [x] 2.2.2.1 Subtask - Implement native menu, tabs, and command-palette widgets.
      [x] 2.2.2.2 Subtask - Define active-state, selection, and action routing behavior for navigation widgets.
      [x] 2.2.2.3 Subtask - Ensure navigation widget behavior is mappable from canonical `UnifiedIUR` constructs without inventing alternate semantics.

  [x] 2.3 Section - Layout Primitives and Baseline Canonical Renderer
    Implement the first layout primitives and map the foundational canonical surface into native components.

    [x] 2.3.1 Task - Implement foundational native layout primitives
      Provide the core layout model needed for both native and canonical screen realization.

      [x] 2.3.1.1 Subtask - Implement native row, column, grid, and shell layout primitives.
      [x] 2.3.1.2 Subtask - Define child ordering, slot mapping, and layout metadata handling for native composition.
      [x] 2.3.1.3 Subtask - Keep layout primitives directly reusable by later overlay, viewport, and split-pane constructs.

    [x] 2.3.2 Task - Implement baseline `UnifiedIUR` rendering for foundational families
      Start the canonical renderer by mapping foundational widgets and layouts into the native runtime model.

      [x] 2.3.2.1 Subtask - Implement canonical rendering for foundational widget, form, and navigation families.
      [x] 2.3.2.2 Subtask - Implement canonical rendering for foundational layout and container constructs.
      [x] 2.3.2.3 Subtask - Verify equivalent canonical input maps deterministically into the same native widget structure.

  [x] 2.4 Section - Maintained Baseline Native and IUR Examples
    Implement reference examples that show the foundational direct-native and canonical-rendered flows through one runtime.

    [x] 2.4.1 Task - Implement baseline screen examples
      Provide maintained examples that later phases can extend and use for regression testing.

      [x] 2.4.1.1 Subtask - Create foundational native screen examples for simple display, forms, and navigation workflows.
      [x] 2.4.1.2 Subtask - Create baseline canonical `UnifiedIUR` examples that render the same feature families through the package renderer.
      [x] 2.4.1.3 Subtask - Document example metadata so maintainers can compare native and canonical paths later.

  [x] 2.5 Section - Phase 2 Integration Tests
    Validate foundational native widget behavior and baseline canonical rendering end to end.

    [x] 2.5.1 Task - Native foundational workflow integration scenarios
      Verify native `live_ui` screens can compose foundational widgets, forms, and navigation through the runtime backbone.

      [x] 2.5.1.1 Subtask - Verify foundational native screens render through LiveView and preserve assigns-driven state updates.
      [x] 2.5.1.2 Subtask - Verify forms and navigation widgets behave consistently for direct native usage.
      [x] 2.5.1.3 Subtask - Verify foundational layout primitives keep native child ordering and slot semantics stable.

    [x] 2.5.2 Task - Canonical foundational renderer integration scenarios
      Verify canonical `UnifiedIUR` rendering reuses the same runtime surface for foundational constructs.

      [x] 2.5.2.1 Subtask - Verify foundational `UnifiedIUR` widgets and layouts map into the same native widget families used directly.
      [x] 2.5.2.2 Subtask - Verify deterministic rendering for equivalent foundational canonical input.
      [x] 2.5.2.3 Subtask - Verify maintained examples remain comparable across native and canonical foundational paths.
