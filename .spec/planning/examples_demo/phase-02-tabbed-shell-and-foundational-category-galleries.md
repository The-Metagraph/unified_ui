# Phase 2 - Tabbed Shell and Foundational Category Galleries

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/demo`
- `UnifiedExamples.Shared.Template`
- `UnifiedExamples.Shared.App`
- `UnifiedUi.Dsl`
- `UnifiedUi` widget and layout sections
- `UnifiedIUR`
- `LiveUi.Runtime.ScreenComponent`
- `Phoenix.LiveView`

## Relevant Assumptions / Defaults
- The standalone demo app scaffold, shared theme continuity, and root category registry already exist from Phase 1.
- The aggregate demo shell should be tab-driven and browser-readable before the more advanced category galleries and signal stories are added.
- The first implementation pass should cover the categories reviewers are most likely to use first: foundational content, forms/input, and layout/display.

[x] 2 Phase 2 - Tabbed Shell and Foundational Category Galleries
  Implement the tabbed shell, category switching behavior, and the first set of category galleries so the aggregate demo already serves as a useful browser-review surface for the most common control families.

  [ ] 2.1 Section - Tabbed Shell and Active-Category Flow
    Build the reusable tabbed interface that selects category fragments, exposes category summaries, and keeps the active review context obvious.

    [ ] 2.1.1 Task - Implement the top-level tab navigation contract
      Create the tab selection surface and bind it to the root category registry so reviewers can move between categories predictably.

      [ ] 2.1.1.1 Subtask - Implement the tab bar using the shared button-example visual treatment for primary selection controls.
      [ ] 2.1.1.2 Subtask - Bind tab selection to the active category state in the root screen and LiveView assigns.
      [ ] 2.1.1.3 Subtask - Add tests that prove tab selection updates the visible category content and current-review labeling.

    [ ] 2.1.2 Task - Implement the shared category presentation frame
      Create the common panel structure that each category gallery will render inside.

      [ ] 2.1.2.1 Subtask - Add a shared category header area showing the category label, summary, and catalog linkage cues.
      [ ] 2.1.2.2 Subtask - Add a shared gallery panel structure that can host multiple representative controls with short reviewer-facing descriptions.
      [ ] 2.1.2.3 Subtask - Add regression coverage that proves category panels keep the shared shell, spacing, and styling baseline.

  [ ] 2.2 Section - Foundational Content Gallery
    Implement the foundational-content tab so reviewers can inspect the core content controls together in one shared visual surface.

    [ ] 2.2.1 Task - Author the foundational content gallery fragment
      Populate the foundational-content tab with representative controls and descriptive copy while keeping the shared style contract intact.

      [ ] 2.2.1.1 Subtask - Add representative `text`, `label`, `icon`, `image`, `button`, `link`, `separator`, `spacer`, and `content` demonstrations.
      [ ] 2.2.1.2 Subtask - Add short per-control descriptions that explain the intended review focus without resorting to implementation-only language.
      [ ] 2.2.1.3 Subtask - Add tests that verify the foundational gallery renders all required representatives and shared style refs.

  [ ] 2.3 Section - Forms and Input Gallery
    Implement the forms-and-input tab so the aggregate demo can already act as a quick comparison surface for the suite's input controls.

    [ ] 2.3.1 Task - Author the forms and input gallery fragment
      Populate the forms/input tab with representative controls and panel-level descriptions.

      [ ] 2.3.1.1 Subtask - Add representative `form_builder`, `field_group`, `field`, `text_input`, `numeric_input`, `checkbox`, `radio_group`, `select`, `pick_list`, `date_input`, `time_input`, `file_input`, and `toggle` demonstrations.
      [ ] 2.3.1.2 Subtask - Reuse the shared input treatment from the current text-input and button example stack for the gallery controls.
      [ ] 2.3.1.3 Subtask - Add tests that verify the required input controls render with the expected shared theme and style treatment.

  [ ] 2.4 Section - Layout and Display Gallery Baseline
    Implement the initial layout-and-display tab so the aggregate demo covers the foundational composition and display primitives early.

    [ ] 2.4.1 Task - Author the layout and display gallery fragment
      Populate the layout/display tab with representative layout primitives and display-system demonstrations that stay readable in the shared gallery shell.

      [ ] 2.4.1.1 Subtask - Add representative `box`, `row`, `column`, `grid`, `viewport`, `scroll_bar`, `split_pane`, and `canvas` demonstrations.
      [ ] 2.4.1.2 Subtask - Add reviewer-facing descriptions that explain what to compare or inspect in each layout/display panel.
      [ ] 2.4.1.3 Subtask - Add tests that verify the layout/display gallery remains stable across tab switches and shared shell rendering.

  [ ] 2.5 Section - Phase 2 Integration Tests
    Validate that the tabbed shell, foundational-content gallery, forms/input gallery, and layout/display gallery all render through the shared theme/style baseline and switch cleanly inside the aggregate demo app.

    [ ] 2.5.1 Task - Tab-switching and foundational gallery integration scenarios
      Verify the first three galleries can be selected, rendered, and reviewed through one consistent runtime shell.

      [ ] 2.5.1.1 Subtask - Verify tab selection changes the visible category content and active-state labeling.
      [ ] 2.5.1.2 Subtask - Verify the foundational-content and forms/input galleries render all required representative controls.
      [ ] 2.5.1.3 Subtask - Verify the layout/display gallery renders correctly while preserving the shared shell and category framing.
