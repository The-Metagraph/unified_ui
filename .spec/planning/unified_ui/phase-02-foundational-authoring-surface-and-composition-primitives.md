# Phase 2 - Foundational Authoring Surface and Composition Primitives

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `UnifiedUi.Dsl`
- `UnifiedUi.Widgets`
- `UnifiedUi.Layout`
- `UnifiedUi.Forms`
- `UnifiedUi.Navigation`
- `UnifiedUi.Reference`

## Relevant Assumptions / Defaults
- Foundational authored constructs must map directly to canonical `UnifiedIUR` families rather than package-local-only shapes.
- Baseline examples are part of the package contract and should be introduced alongside the authored surface.
- Composition primitives must remain subordinate to the shared authored module model from Phase 1.

[x] 2 Phase 2 - Foundational Authoring Surface and Composition Primitives
  Implement the foundational authored widget, form, navigation, and composition surface required to author baseline screens in `unified_ui`.

  [x] 2.1 Section - Foundational Visual Widgets
    Implement the baseline authored widgets that carry text, imagery, content, and common action semantics.

    [x] 2.1.1 Task - Implement foundational text and content-bearing widget declarations
      Provide authored DSL entities for the canonical foundational visual surface.

      [x] 2.1.1.1 Subtask - Implement authored declarations for text, label, icon, and image widgets.
      [x] 2.1.1.2 Subtask - Implement authored declarations for content container widgets and foundational content-bearing wrappers.
      [x] 2.1.1.3 Subtask - Implement authored declarations that preserve canonical metadata and accessibility-facing hooks for foundational content.

    [x] 2.1.2 Task - Implement foundational action and spacing widget declarations
      Provide the remaining foundational widgets required for authored actions and layout spacing.

      [x] 2.1.2.1 Subtask - Implement authored declarations for button, link, separator, and spacer widgets.
      [x] 2.1.2.2 Subtask - Define authored attributes for labels, emphasis, content text, and action intent on foundational widgets.
      [x] 2.1.2.3 Subtask - Define how foundational widgets expose canonical style and interaction attachment points without runtime-specific callbacks.

  [x] 2.2 Section - Input, Forms, and Navigation Baseline
    Implement the baseline input, navigation, and form-composition constructs needed for authored user workflows.

    [x] 2.2.1 Task - Implement authored input and navigation entity declarations
      Provide the first canonical authored controls for data entry and navigation.

      [x] 2.2.1.1 Subtask - Implement authored declarations for text input and baseline selection controls needed by the current package specs.
      [x] 2.2.1.2 Subtask - Implement authored declarations for menu, tabs, and command-palette-driven navigation patterns.
      [x] 2.2.1.3 Subtask - Define authored attributes for values, options, active state, and baseline interaction hooks on input and navigation controls.

    [x] 2.2.2 Task - Implement authored form and field composition
      Provide the authored structures needed to declare grouped forms and field relationships.

      [x] 2.2.2.1 Subtask - Implement authored declarations for form builders, field groups, and field-level composition.
      [x] 2.2.2.2 Subtask - Implement baseline authored binding hooks for field names, value paths, default values, and submit intent metadata.
      [x] 2.2.2.3 Subtask - Define authored relationships between inputs, labels, help text, and grouped form actions.

  [x] 2.3 Section - Container and Layout Primitives
    Implement the baseline authored composition primitives that organize foundational widgets into canonical structure.

    [x] 2.3.1 Task - Implement baseline authored container and layout declarations
      Provide the authored layout entities needed for simple but expressive canonical screen structure.

      [x] 2.3.1.1 Subtask - Implement authored declarations for box or container composition primitives.
      [x] 2.3.1.2 Subtask - Implement authored declarations for row, column, grid, and stack layout primitives.
      [x] 2.3.1.3 Subtask - Define authored layout attributes for ordering, spacing, sizing, alignment, and content slots.

    [x] 2.3.2 Task - Implement simple composition and placement rules
      Define the initial authored semantics that keep baseline composition deterministic and compiler-friendly.

      [x] 2.3.2.1 Subtask - Define how foundational widgets and forms may be nested inside containers and directional layouts.
      [x] 2.3.2.2 Subtask - Define baseline slot and child-order rules for authored composition primitives.
      [x] 2.3.2.3 Subtask - Define compile-time placement validation for invalid container or layout usage in baseline authored modules.

  [x] 2.4 Section - Authored Examples for Baseline Screen Authoring
    Implement maintained reference modules that demonstrate the foundational authored surface in real DSL modules.

    [x] 2.4.1 Task - Implement foundational and form-oriented reference examples
      Provide example authored modules that show how baseline widgets and layouts are intended to be used together.

      [x] 2.4.1.1 Subtask - Create a minimal single-screen example that uses foundational widgets and basic layout primitives.
      [x] 2.4.1.2 Subtask - Create a baseline form example that exercises fields, grouped actions, and navigation constructs.
      [x] 2.4.1.3 Subtask - Create example metadata or categorization that distinguishes foundational and form-oriented authored workflows.

    [x] 2.4.2 Task - Implement example loading and package reference wiring
      Make baseline examples discoverable through package reference surfaces and future tooling workflows.

      [x] 2.4.2.1 Subtask - Register baseline example modules so maintainers can list or inspect them from package helpers.
      [x] 2.4.2.2 Subtask - Expose how baseline examples map to the canonical construct families introduced in Phase 2.
      [x] 2.4.2.3 Subtask - Keep examples independent from `live_ui`, `elm_ui`, and `desktop_ui` package availability.

  [x] 2.5 Section - Phase 2 Integration Tests
    Validate foundational authored widgets, forms, navigation, and baseline composition end to end.

    [x] 2.5.1 Task - Baseline authored screen integration scenarios
      Verify the foundational authored surface can express simple but complete screens without runtime-library code.

      [x] 2.5.1.1 Subtask - Verify foundational widgets compose correctly inside containers, rows, columns, grids, and stacks.
      [x] 2.5.1.2 Subtask - Verify authored menus, tabs, and command palette declarations coexist with foundational screen structure.
      [x] 2.5.1.3 Subtask - Verify baseline reference examples remain valid and introspectable through package helpers.

    [x] 2.5.2 Task - Form and composition validation integration scenarios
      Verify baseline form composition and placement rules stay deterministic and author-friendly.

      [x] 2.5.2.1 Subtask - Verify form builders, field groups, and field declarations preserve label, value-path, and action relationships.
      [x] 2.5.2.2 Subtask - Verify invalid placement and incomplete baseline authored declarations fail at compile time.
      [x] 2.5.2.3 Subtask - Verify equivalent authored baseline inputs yield stable canonical authored summaries ahead of full compilation.
