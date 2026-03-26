# Phase 11 - IUR Widget Completeness

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `DesktopUi.Widgets`
- `DesktopUi.Sdl3.RenderPlan`
- `DesktopUi.Renderer.Mapper`
- `UnifiedIUR.Widgets`
- `UnifiedIUR.Widgets.Foundational`
- `UnifiedIUR.Widgets.Input`
- `UnifiedIUR.Widgets.Navigation`
- `UnifiedIUR.Widgets.Data`
- `UnifiedIUR.Widgets.Feedback`
- `UnifiedIUR.Widgets.Advanced`

## Relevant Assumptions / Defaults
- Phases 1 through 10 are complete, so `desktop_ui` already has widget-complete SDL3 rendering, native text and image realization, and interactive visible-window behavior.
- The canonical IUR renderer currently falls back to `:container_surface` for ~28 of 45 IUR widget kinds.
- Each phase should add dedicated draw kinds, render plan handling, and SDL3 host drawing for the target widget families.
- Form widgets should preserve keyboard focus, input validation, and data-binding semantics across native and canonical paths.
- Missing foundational and data widgets should arrive before more specialized feedback and advanced operational widgets.

[ ] 11 Phase 11 - IUR Widget Completeness
  Complete the canonical IUR renderer coverage by implementing dedicated
  rendering for all remaining canonical widget kinds, including foundational
  gaps, form input completeness, data display widgets, feedback widgets, and
  advanced operational widgets.

  [ ] 11.1 Section - Foundational Widget Completeness
    Implement the remaining foundational widgets that currently fall through to
    generic container rendering.

    [ ] 11.1.1 Task - Implement semantic content widgets
      Add dedicated rendering for badge, hero, link, separator, and spacer
      constructs so canonical screens render with proper semantic visuals.

      [ ] 11.1.1.1 Subtask - Implement badge widget rendering with size variants, color role mapping, and container-aware positioning.
      [ ] 11.1.1.2 Subtask - Implement hero widget rendering with headline typography, optional imagery, and call-to-action button placement.
      [ ] 11.1.1.3 Subtask - Implement link widget rendering with text styling, hover states, and keyboard navigation support.
      [ ] 11.1.1.4 Subtask - Implement separator widget rendering with orientation variants, spacing, and theme-aware color rendering.
      [ ] 11.1.1.5 Subtask - Implement spacer widget rendering with configurable size, axis alignment, and layout-aware behavior.

    [ ] 11.1.2 Task - Add foundational widgets to render plan and native host
      Extend the render plan and SDL3 host drawing to support the new semantic
      content widgets.

      [ ] 11.1.2.1 Subtask - Add draw kinds for badge, hero, link, separator, and spacer in `DesktopUi.Sdl3.RenderPlan`.
      [ ] 11.1.2.2 Subtask - Implement SDL3 host drawing operations for badge, hero, and link with proper text measurement and bounds.
      [ ] 11.1.2.3 Subtask - Implement separator and spacer as layout-aware render plan directives that affect composition but may not generate draw operations.

  [ ] 11.2 Section - Form Input Widget Completeness
    Implement the remaining form input widgets needed for complete canonical
    form coverage.

    [ ] 11.2.1 Task - Implement selection and toggle input widgets
      Add dedicated rendering for numeric_input, toggle, radio_group, select,
      and pick_list widgets.

      [ ] 11.2.1.1 Subtask - Implement numeric_input widget rendering with value bounds, step constraints, and keyboard increment/decrement handling.
      [ ] 11.2.1.2 Subtask - Implement toggle widget rendering with on/off states, animated transitions, and keyboard activation.
      [ ] 11.2.1.3 Subtask - Implement radio_group widget rendering with option layout, selection state, and mutual exclusion behavior.
      [ ] 11.2.1.4 Subtask - Implement select widget rendering with dropdown presentation, option list, and selection confirmation.
      [ ] 11.2.1.5 Subtask - Implement pick_list widget rendering with searchable options, multi-selection support, and keyboard navigation.

    [ ] 11.2.2 Task - Implement range and temporal input widgets
      Add dedicated rendering for slider, date_input, and time_input widgets.

      [ ] 11.2.2.1 Subtask - Implement slider widget rendering with track, thumb, value indicator, and keyboard/mouse drag interaction.
      [ ] 11.2.2.2 Subtask - Implement date_input widget rendering with calendar presentation, date validation, and keyboard navigation.
      [ ] 11.2.2.3 Subtask - Implement time_input widget rendering with time picker presentation, format validation, and keyboard entry support.

    [ ] 11.2.3 Task - Implement file-oriented input widgets
      Add dedicated rendering for file_input widget with desktop-native file
      picker integration.

      [ ] 11.2.3.1 Subtask - Implement file_input widget rendering with browse button, file name display, and selection state.
      [ ] 11.2.3.2 Subtask - Integrate platform file picker dialogs for Windows, macOS, and Linux through SDL3 native host seam.
      [ ] 11.2.3.3 Subtask - Implement file validation, multiple selection support, and clear selection handling.

    [ ] 11.2.4 Task - Add form input widgets to render plan and native host
      Extend the render plan and SDL3 host drawing to support all form input
      widgets with proper focus and validation states.

      [ ] 11.2.4.1 Subtask - Add draw kinds for numeric_input, toggle, radio_group, select, pick_list, slider, date_input, time_input, and file_input in `DesktopUi.Sdl3.RenderPlan`.
      [ ] 11.2.4.2 Subtask - Implement SDL3 host drawing operations for all form input widgets with focus ring, disabled, and error state rendering.
      [ ] 11.2.4.3 Subtask - Implement hit-testing, focus targeting, and keyboard navigation for all form input widgets through the interaction script.

  [ ] 11.3 Section - Data Display Widget Completeness
    Implement the remaining data display widgets needed for complete canonical
    data view coverage.

    [ ] 11.3.1 Task - Implement hierarchical and structured data widgets
      Add dedicated rendering for tree_view, stat, key_value, and info_list
      widgets.

      [ ] 11.3.1.1 Subtask - Implement tree_view widget rendering with expand/collapse, indent depth, selection state, and keyboard navigation.
      [ ] 11.3.1.2 Subtask - Implement stat widget rendering with value presentation, label layout, trend indicators, and semantic color roles.
      [ ] 11.3.1.3 Subtask - Implement key_value widget rendering with label/value pairs, alignment options, and multi-line value support.
      [ ] 11.3.1.4 Subtask - Implement info_list widget rendering with item layout, icon support, and compact/verbose variants.

    [ ] 11.3.2 Task - Add data display widgets to render plan and native host
      Extend the render plan and SDL3 host drawing to support all data display
      widgets.

      [ ] 11.3.2.1 Subtask - Add draw kinds for tree_view, stat, key_value, and info_list in `DesktopUi.Sdl3.RenderPlan`.
      [ ] 11.3.2.2 Subtask - Implement SDL3 host drawing operations for hierarchical data visualization with proper state management.
      [ ] 11.3.2.3 Subtask - Implement tree_view expand/collapse interaction, stat trend animation, and info_list item selection.

  [ ] 11.4 Section - Feedback Widget Completeness
    Implement the remaining feedback widgets needed for complete canonical
    progress and status coverage.

    [ ] 11.4.1 Task - Implement progress and status feedback widgets
      Add dedicated rendering for status, progress, and inline_feedback widgets.

      [ ] 11.4.1.1 Subtask - Implement status widget rendering with semantic color roles, icon presentation, and label layout.
      [ ] 11.4.1.2 Subtask - Implement progress widget rendering with determinate and indeterminate modes, percentage display, and animation.
      [ ] 11.4.1.3 Subtask - Implement inline_feedback widget rendering with contextual placement, dismissal affordance, and auto-hide behavior.

    [ ] 11.4.2 Task - Add feedback widgets to render plan and native host
      Extend the render plan and SDL3 host drawing to support all feedback
      widgets.

      [ ] 11.4.2.1 Subtask - Add draw kinds for status, progress, and inline_feedback in `DesktopUi.Sdl3.RenderPlan`.
      [ ] 11.4.2.2 Subtask - Implement SDL3 host drawing operations for status pills, progress bars, and inline toast/alert feedback.
      [ ] 11.4.2.3 Subtask - Implement inline_feedback placement relative to parent widgets, dismissal interaction, and timeout handling.

  [ ] 11.5 Section - Advanced Widget Completeness
    Implement the remaining advanced operational widgets needed for complete
    canonical advanced coverage.

    [ ] 11.5.1 Task - Implement stream and supervision widgets
      Add dedicated rendering for stream_widget, markdown_viewer, and
      supervision_tree_viewer widgets.

      [ ] 11.5.1.1 Subtask - Implement stream_widget rendering with append-only scrolling, line limits, and stream pausing controls.
      [ ] 11.5.1.2 Subtask - Implement markdown_viewer rendering with inline formatting, code blocks, and header hierarchy.
      [ ] 11.5.1.3 Subtask - Implement supervision_tree_viewer rendering with tree topology, process state colors, and collapse/expand interaction.

    [ ] 11.5.2 Task - Add advanced widgets to render plan and native host
      Extend the render plan and SDL3 host drawing to support all advanced
      operational widgets.

      [ ] 11.5.2.1 Subtask - Add draw kinds for stream_widget, markdown_viewer, and supervision_tree_viewer in `DesktopUi.Sdl3.RenderPlan`.
      [ ] 11.5.2.2 Subtask - Implement SDL3 host drawing operations for stream buffering, markdown parsing, and supervision tree layout.
      [ ] 11.5.2.3 Subtask - Implement stream scroll interaction, markdown link navigation, and supervision tree selection and expansion.

  [ ] 11.6 Section - Mapper Coverage and Diagnostics
    Update the canonical mapper and diagnostics surfaces to reflect complete
    IUR widget coverage.

    [ ] 11.6.1 Task - Update canonical mapper for all widget kinds
      Extend `DesktopUi.Renderer.Mapper` to cover all 45 canonical IUR widget
      kinds with deterministic native widget mapping.

      [ ] 11.6.1.1 Subtask - Add mapper clauses for badge, hero, link, separator, spacer, numeric_input, toggle, radio_group, select, pick_list, slider, date_input, time_input, file_input.
      [ ] 11.6.1.2 Subtask - Add mapper clauses for tree_view, stat, key_value, info_list, status, progress, inline_feedback.
      [ ] 11.6.1.3 Subtask - Add mapper clauses for stream_widget, markdown_viewer, supervision_tree_viewer.
      [ ] 11.6.1.4 Subtask - Verify each mapper clause preserves canonical hierarchy, styling, interaction bindings, and accessibility metadata.

    [ ] 11.6.2 Task - Update renderer completeness diagnostics
      Update inspection, validation, and run surfaces to report full IUR widget
      coverage instead of partial coverage.

      [ ] 11.6.2.1 Subtask - Update `DesktopUi.Sdl3.RenderPlan` presentation metadata to reflect complete widget coverage.
      [ ] 11.6.2.2 Subtask - Update `DesktopUi.Validate` to verify all 45 IUR widget kinds have dedicated draw kinds and render plan handling.
      [ ] 11.6.2.3 Subtask - Update `mix desktop_ui.validate --strict` to report canonical IUR renderer completeness as a release-readiness gate.

  [ ] 11.7 Section - Phase 11 Integration Tests
    Validate complete IUR widget coverage end to end with focused tests for
    each widget family.

    [ ] 11.7.1 Task - Foundational completeness scenarios
      Verify the new foundational widgets render correctly through both native
      and canonical paths.

      [ ] 11.7.1.1 Subtask - Verify badge, hero, link, separator, and spacer render with proper semantics and style resolution.
      [ ] 11.7.1.2 Subtask - Verify link widgets support keyboard navigation and hover states.
      [ ] 11.7.1.3 Subtask - Verify separator and spacer participate correctly in layout composition and overflow handling.

    [ ] 11.7.2 Task - Form input completeness scenarios
      Verify all form input widgets render and interact correctly through both
      native and canonical paths.

      [ ] 11.7.2.1 Subtask - Verify numeric_input, toggle, radio_group, select, pick_list render with proper focus and selection states.
      [ ] 11.7.2.2 Subtask - Verify slider, date_input, time_input render with proper value presentation and keyboard interaction.
      [ ] 11.7.2.3 Subtask - Verify file_input triggers platform file picker dialogs and reports selection state correctly.
      [ ] 11.7.2.4 Subtask - Verify all form input widgets preserve canonical data-binding semantics and validation state.

    [ ] 11.7.3 Task - Data display completeness scenarios
      Verify all data display widgets render correctly through both native and
      canonical paths.

      [ ] 11.7.3.1 Subtask - Verify tree_view renders hierarchical data with expand/collapse state and keyboard navigation.
      [ ] 11.7.3.2 Subtask - Verify stat, key_value, and info_list render structured data with proper alignment and typography.
      [ ] 11.7.3.3 Subtask - Verify data display widgets handle overflow, wrapping, and empty states correctly.

    [ ] 11.7.4 Task - Feedback and advanced widget scenarios
      Verify feedback and advanced widgets render correctly through both native
      and canonical paths.

      [ ] 11.7.4.1 Subtask - Verify status, progress, and inline_feedback render with semantic colors and proper placement.
      [ ] 11.7.4.2 Subtask - Verify progress widgets animate and report determinate versus indeterminate states correctly.
      [ ] 11.7.4.3 Subtask - Verify stream_widget, markdown_viewer, and supervision_tree_viewer render complex operational content with proper interaction.

    [ ] 11.7.5 Task - Mapper coverage and diagnostics scenarios
      Verify the canonical mapper and diagnostics surfaces report complete IUR
      widget coverage.

      [ ] 11.7.5.1 Subtask - Verify the canonical mapper handles all 45 IUR widget kinds without fallback to generic containers.
      [ ] 11.7.5.2 Subtask - Verify `DesktopUi.Sdl3.RenderPlan` diagnostics report draw kind counts matching the expected widget surface.
      [ ] 11.7.5.3 Subtask - Verify `mix desktop_ui.validate --strict` passes with full IUR widget coverage and reports completeness accurately.
