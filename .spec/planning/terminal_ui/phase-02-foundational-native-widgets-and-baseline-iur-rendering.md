# Phase 2 - Foundational Native Widgets and Baseline IUR Rendering

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `TerminalUi.Widgets`
- `TerminalUi.Runtime.Screen`
- `TerminalUi.Runtime.Realization`
- `TerminalUi.Renderer`
- `TerminalUi.Renderer.Mapper`
- `UnifiedIUR.Element`

## Relevant Assumptions / Defaults
- Foundational direct-native widgets should arrive before advanced terminal
  constructs such as overlays, split panes, viewport-heavy flows, and canvas
  surfaces.
- The first canonical renderer path should reuse the native widget model rather
  than introducing a second rendering stack.
- Baseline screen composition, focus, and layout behavior should stabilize
  before transport translation and capability degradation expand further.

[ ] 2 Phase 2 - Foundational Native Widgets and Baseline IUR Rendering
  Implement foundational native widgets, baseline terminal composition, and the
  first canonical `UnifiedIUR` rendering path through the shared terminal
  runtime.

  [x] 2.1 Section - Foundational Native Widget Families
    Implement the initial directly usable native widget families required for
    content, actions, forms, and navigation.

    [x] 2.1.1 Task - Implement foundational content and action widgets
      Create the first direct-native `terminal_ui` widgets for text, icons,
      images or image degradations, buttons, and content containers.

      [x] 2.1.1.1 Subtask - Implement content widgets for text, labels, icons, image-or-placeholder surfaces, spacers, and separators.
      [x] 2.1.1.2 Subtask - Implement action widgets for buttons, toggles, links, and primary command surfaces.
      [x] 2.1.1.3 Subtask - Define foundational widget state and rendering metadata for focus, disabled state, and baseline style hooks.

    [x] 2.1.2 Task - Implement baseline forms and navigation widgets
      Add the input, selection, and navigation widgets required for canonical
      foundational screen coverage and direct-native usability.

      [x] 2.1.2.1 Subtask - Implement text entry, checkbox, radio, select, and baseline data-binding friendly form controls.
      [x] 2.1.2.2 Subtask - Implement tabs, menus, breadcrumbs, lists, and foundational navigation surfaces appropriate to keyboard-first terminal usage.
      [x] 2.1.2.3 Subtask - Define keyboard focus, shortcut hooks, and interaction metadata shared by foundational form and navigation widgets.

  [x] 2.2 Section - Foundational Shared Runtime and Screen Composition
    Implement the shared runtime realization model that can mount and compose
    foundational native screens before advanced layering exists.

    [x] 2.2.1 Task - Implement foundational layout and screen composition
      Define the baseline direct-native realization model for stacking,
      alignment, bindings, and screen-level composition.

      [x] 2.2.1.1 Subtask - Implement foundational screen composition structures for containers, box layouts, stacks, alignment, and common screen metadata.
      [x] 2.2.1.2 Subtask - Implement runtime realization hooks for widget tree assembly, baseline focus traversal, and data-binding surfaces.
      [x] 2.2.1.3 Subtask - Keep foundational layout realization shared between direct-native and future canonical rendering paths.

    [x] 2.2.2 Task - Implement baseline direct-native rendering flow
      Render foundational native widget trees through the shared terminal
      runtime using one coherent realization model.

      [x] 2.2.2.1 Subtask - Implement shared runtime realization for foundational widget drawing, event targeting, and cell-surface realization.
      [x] 2.2.2.2 Subtask - Reuse the same runtime surfaces for direct-native screens and future canonical renderer output.
      [x] 2.2.2.3 Subtask - Add diagnostics for unsupported foundational widgets, invalid layout state, and realization mismatches.

  [x] 2.3 Section - Baseline Canonical IUR Rendering
    Implement the first canonical `UnifiedIUR` rendering path using the same
    native widget and runtime model already used by direct-native screens.

    [x] 2.3.1 Task - Implement foundational canonical mapper coverage
      Map foundational canonical widgets, layout primitives, bindings, and
      interaction descriptors into the native `terminal_ui` surface.

      [x] 2.3.1.1 Subtask - Implement canonical mapping for foundational content, action, form, and navigation widgets.
      [x] 2.3.1.2 Subtask - Implement canonical mapping for foundational layout and display primitives needed by the first screen compositions.
      [x] 2.3.1.3 Subtask - Accept canonical bindings and interaction descriptors without requiring authored DSL modules inside `terminal_ui`.

    [x] 2.3.2 Task - Implement deterministic native-widget reuse for canonical rendering
      Reuse the same native runtime realization model so canonical input and
      direct-native screens converge on one rendering stack.

      [x] 2.3.2.1 Subtask - Reuse foundational native widget modules and runtime realization paths for canonical rendering output.
      [x] 2.3.2.2 Subtask - Define deterministic canonical-to-native mapping expectations for widget structure, focus behavior, style hooks, and initial degradation hooks.
      [x] 2.3.2.3 Subtask - Add diagnostics for unsupported canonical constructs, invalid bindings, and renderer-native mismatches.

  [ ] 2.4 Section - Foundational Reference Examples
    Implement maintained foundational examples that compare direct-native and
    canonical rendering through the same runtime backbone.

    [ ] 2.4.1 Task - Implement foundational direct-native and canonical examples
      Provide small maintained screens that let maintainers exercise the first
      widget families and canonical renderer path end to end.

      [ ] 2.4.1.1 Subtask - Add direct-native foundational examples for content, actions, forms, and navigation.
      [ ] 2.4.1.2 Subtask - Add canonical foundational examples that render the same screen intent through `UnifiedIUR`.
      [ ] 2.4.1.3 Subtask - Keep example metadata aligned with the package reference surface and future tooling workflows.

    [ ] 2.4.2 Task - Implement foundational comparison helpers
      Make it easy to compare direct-native and canonical output while coverage
      is still limited to the foundational surface.

      [ ] 2.4.2.1 Subtask - Add helper workflows that compare foundational native and canonical render trees.
      [ ] 2.4.2.2 Subtask - Expose which widget families and display constructs are covered by the foundational examples.
      [ ] 2.4.2.3 Subtask - Document where advanced widget and display coverage will extend the examples in later phases.

  [ ] 2.5 Section - Phase 2 Integration Tests
    Validate foundational native widgets, baseline screen composition, and the
    first canonical renderer path end to end.

    [ ] 2.5.1 Task - Foundational native and canonical rendering scenarios
      Verify the package can realize the same foundational screen intent
      directly and from canonical `UnifiedIUR`.

      [ ] 2.5.1.1 Subtask - Verify direct-native foundational screens render through the shared runtime with working focus and baseline input handling.
      [ ] 2.5.1.2 Subtask - Verify canonical foundational screens map into the same native widget and runtime realization model.
      [ ] 2.5.1.3 Subtask - Verify unsupported foundational widgets or invalid canonical bindings fail with deterministic diagnostics.

    [ ] 2.5.2 Task - Foundational example and comparison scenarios
      Verify maintained foundational examples remain aligned with the package
      reference surface and renderer coverage.

      [ ] 2.5.2.1 Subtask - Verify maintained examples report the expected foundational widget and layout coverage.
      [ ] 2.5.2.2 Subtask - Verify comparison helpers show direct-native and canonical rendering through the same runtime backbone.
      [ ] 2.5.2.3 Subtask - Verify foundational example metadata stays usable by future tooling and validation workflows.
