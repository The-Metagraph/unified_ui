# Phase 3 - Advanced Category Galleries and Cross-Category Review Flow

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/demo`
- `examples/catalog.tsv`
- `UnifiedUi.Dsl`
- `UnifiedIUR`
- `LiveUi.Renderer`
- `LiveUi.Runtime.ScreenComponent`
- `Phoenix.LiveView`

## Relevant Assumptions / Defaults
- The tabbed shell and the first three category galleries already exist from Phase 2.
- The remaining categories should preserve the same shell and reviewer-facing gallery pattern rather than branching into category-specific page layouts.
- Cross-category reviewer cues should help users navigate the full control surface without losing the single-app browsing advantage.

[ ] 3 Phase 3 - Advanced Category Galleries and Cross-Category Review Flow
  Implement the remaining category tabs and the shared review cues that connect them, turning the aggregate demo into a full catalog browser for the current control families.

  [ ] 3.1 Section - Navigation and Selection Gallery
    Implement the navigation-and-selection tab so reviewers can compare controls whose purpose is to switch, choose, or focus content surfaces.

    [ ] 3.1.1 Task - Author the navigation and selection gallery fragment
      Populate the navigation tab with representative controls and presentation cues that explain active state and selection meaning.

      [ ] 3.1.1.1 Subtask - Add representative `menu`, `tabs`, `list`, and `command_palette` demonstrations.
      [ ] 3.1.1.2 Subtask - Add reviewer-facing descriptions explaining active, selected, or focused states for each control family.
      [ ] 3.1.1.3 Subtask - Add tests that verify the navigation gallery renders correctly and remains traceable to the example-suite catalog.

  [ ] 3.2 Section - Data and Feedback Gallery
    Implement the data-and-feedback tab so reviewers can inspect data presentation and feedback controls together in one shared category surface.

    [ ] 3.2.1 Task - Author the data and feedback gallery fragment
      Populate the data/feedback tab with representative controls and meaningful descriptive framing.

      [ ] 3.2.1.1 Subtask - Add representative `table`, `tree_view`, `markdown_viewer`, `log_viewer`, `status`, `progress`, `gauge`, `inline_feedback`, `sparkline`, `bar_chart`, and `line_chart` demonstrations.
      [ ] 3.2.1.2 Subtask - Add panel-level summaries that explain the review purpose of each data or feedback surface.
      [ ] 3.2.1.3 Subtask - Add tests that verify the gallery remains complete and visually consistent with the rest of the demo shell.

  [ ] 3.3 Section - Overlays and Operational Gallery
    Implement the overlays-and-operational tab so the aggregate demo covers the most context-sensitive and complex control families.

    [ ] 3.3.1 Task - Author the overlays and operational gallery fragment
      Populate the overlays/operational tab with representative controls and readable panel framing.

      [ ] 3.3.1.1 Subtask - Add representative `overlay`, `dialog`, `alert_dialog`, `context_menu`, `toast`, `stream_widget`, `process_monitor`, `supervision_tree_viewer`, and `cluster_dashboard` demonstrations.
      [ ] 3.3.1.2 Subtask - Add reviewer-facing descriptions that explain whether each panel highlights layered context or operational monitoring purpose.
      [ ] 3.3.1.3 Subtask - Add tests that verify these higher-complexity galleries remain stable inside the shared shell and category frame.

  [ ] 3.4 Section - Cross-Category Reviewer Cues and Shared Panel Composition
    Add the shared cues that help reviewers understand where they are, what is being demonstrated, and how the aggregate demo maps back to the per-widget example suite.

    [ ] 3.4.1 Task - Add cross-category review guidance and catalog traceability
      Strengthen the aggregate demo's information architecture so it remains useful after all category tabs are present.

      [ ] 3.4.1.1 Subtask - Add shared cues that identify the active category, the category purpose, and any linked per-widget example directories.
      [ ] 3.4.1.2 Subtask - Add consistent panel chrome for representative controls so galleries remain comparable across categories.
      [ ] 3.4.1.3 Subtask - Add tests that verify cross-category traceability and reviewer cues remain present on every non-signal tab.

  [ ] 3.5 Section - Phase 3 Integration Tests
    Validate that the full category gallery set now renders through the aggregate demo shell and that cross-category review cues keep the app understandable as the control surface grows.

    [ ] 3.5.1 Task - Full category-gallery integration scenarios
      Verify the advanced categories render cleanly and remain reviewable through one shared tabbed surface.

      [ ] 3.5.1.1 Subtask - Verify the navigation, data/feedback, and overlays/operational galleries render all required representative controls.
      [ ] 3.5.1.2 Subtask - Verify cross-category traceability links and shared panel composition remain present throughout the app.
      [ ] 3.5.1.3 Subtask - Verify the aggregate demo still presents a consistent shell and category framing across every implemented tab.
