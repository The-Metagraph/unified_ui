# Phase 2 - Foundational Widgets and Composition Primitives

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `UnifiedIUR.Widgets`
- `UnifiedIUR.Layout`
- `UnifiedIUR.Container`
- `UnifiedIUR.Reference`
- `UnifiedIUR.Element`
- `UnifiedIUR.Tree`

## Relevant Assumptions / Defaults
- Foundational widgets must be renderer-independent but expressive enough for runtime parity.
- Composition primitives must integrate with the shared element backbone from Phase 1.
- Canonical widget and container shape must remain bilateral with `unified_ui` authoring needs.

[ ] 2 Phase 2 - Foundational Widgets and Composition Primitives
  Implement the foundational canonical widget and container surface needed for authored DSL output and runtime-library rendering parity.

  [ ] 2.1 Section - Foundational Visual and Content Widgets
    Implement the baseline widget families that carry text, content, and common visual semantics.

    [ ] 2.1.1 Task - Implement text and content-bearing widget families
      Provide canonical widgets for basic authored content and presentation.

      [ ] 2.1.1.1 Subtask - Implement canonical text, label, icon, and image-bearing element representations.
      [ ] 2.1.1.2 Subtask - Implement canonical button-like, link-like, separator, and spacer element representations.
      [ ] 2.1.1.3 Subtask - Implement canonical content-container representations that compose nested children cleanly.

    [ ] 2.1.2 Task - Implement foundational widget semantics and attributes
      Preserve the shared semantic hooks required by runtime libraries to realize foundational elements.

      [ ] 2.1.2.1 Subtask - Define content-bearing fields, accessibility-facing metadata, and descriptive annotations for foundational widgets.
      [ ] 2.1.2.2 Subtask - Define state and emphasis hooks needed for buttons, links, labels, and separators.
      [ ] 2.1.2.3 Subtask - Define style-attachment points for foundational widgets without embedding renderer-local style objects.

  [ ] 2.2 Section - Canonical Input and Form Primitives
    Implement the baseline input, selection, and form-composition constructs that authored UI needs to express user input.

    [ ] 2.2.1 Task - Implement canonical input-control representations
      Represent the common families of text and selection input as canonical elements.

      [ ] 2.2.1.1 Subtask - Implement text-entry and numeric-entry canonical element structures.
      [ ] 2.2.1.2 Subtask - Implement toggles, checkboxes, radios, selects, and pick-list-oriented canonical element structures.
      [ ] 2.2.1.3 Subtask - Implement slider, date or time, and file-oriented input placeholders or canonical structures where the spec surface requires them.

    [ ] 2.2.2 Task - Implement form composition and field grouping primitives
      Provide canonical structures for multi-field authored forms and grouped input experiences.

      [ ] 2.2.2.1 Subtask - Implement canonical form containers, field grouping, and field labeling relationships.
      [ ] 2.2.2.2 Subtask - Implement bound-value slots and validation-oriented metadata attachment points.
      [ ] 2.2.2.3 Subtask - Implement submission-oriented canonical structure for grouped forms without runtime callback logic.

  [ ] 2.3 Section - Composition Containers and Layout Baseline
    Implement the baseline composition primitives that organize foundational widgets into canonical structure.

    [ ] 2.3.1 Task - Implement canonical container and directional layout primitives
      Represent the core authored composition forms that arrange widgets hierarchically.

      [ ] 2.3.1.1 Subtask - Implement box-style containers and generic content containers.
      [ ] 2.3.1.2 Subtask - Implement row, column, stack, and basic grid canonical layout structures.
      [ ] 2.3.1.3 Subtask - Implement spacing, alignment, sizing, and ordering metadata needed by directional layouts.

    [ ] 2.3.2 Task - Implement split and scroll-oriented baseline constructs
      Provide the first composition structures that anticipate more advanced display systems in later phases.

      [ ] 2.3.2.1 Subtask - Implement split-oriented layout structures with pane relationships and sizing metadata.
      [ ] 2.3.2.2 Subtask - Implement scroll-region and scroll-bar baseline representations where canonical content exceeds viewport bounds.
      [ ] 2.3.2.3 Subtask - Define baseline composition rules between containers, splits, scrollable content, and foundational widgets.

  [ ] 2.4 Section - Foundational Navigation, Feedback, and Data Views
    Implement the baseline navigation and data-display constructs that are not yet advanced overlay or canvas systems.

    [ ] 2.4.1 Task - Implement menus, tabs, and list-oriented data structures
      Represent canonical navigation and item-based data-display constructs with portable semantics.

      [ ] 2.4.1.1 Subtask - Implement canonical menu and tab structures with item collections and active-state metadata.
      [ ] 2.4.1.2 Subtask - Implement list and table baseline structures with row, column, and cell relationships.
      [ ] 2.4.1.3 Subtask - Implement tree-view baseline structures with hierarchical item semantics and expansion metadata.

    [ ] 2.4.2 Task - Implement baseline feedback and status constructs
      Represent authored feedback and progress concepts needed by canonical screens.

      [ ] 2.4.2.1 Subtask - Implement status, progress, and gauge-style canonical element structures.
      [ ] 2.4.2.2 Subtask - Implement placeholder feedback structures for alert-like and inline-feedback content.
      [ ] 2.4.2.3 Subtask - Implement consistent severity and status metadata hooks for feedback constructs.

  [ ] 2.5 Section - Phase 2 Integration Tests
    Validate foundational widgets, forms, containers, and baseline data views end-to-end.

    [ ] 2.5.1 Task - Foundational widget and container integration scenarios
      Verify baseline canonical widgets and composition primitives behave as one coherent tree model.

      [ ] 2.5.1.1 Subtask - Verify foundational visual widgets compose correctly inside boxes, rows, columns, and stacks.
      [ ] 2.5.1.2 Subtask - Verify input widgets and form containers preserve bound-value and label relationships.
      [ ] 2.5.1.3 Subtask - Verify split and scroll-oriented containers preserve stable canonical child shape and metadata.

    [ ] 2.5.2 Task - Navigation and data-view integration scenarios
      Verify canonical navigation and data-display structures remain portable and deterministic.

      [ ] 2.5.2.1 Subtask - Verify menus, tabs, lists, tables, and trees share stable item and state semantics.
      [ ] 2.5.2.2 Subtask - Verify feedback and progress constructs compose with foundational styling hooks.
      [ ] 2.5.2.3 Subtask - Verify equivalent authored inputs yield deterministic canonical shapes for foundational constructs.
