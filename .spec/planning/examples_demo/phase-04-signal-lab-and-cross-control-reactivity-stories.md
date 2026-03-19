# Phase 4 - Signal Lab and Cross-Control Reactivity Stories

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/demo`
- `UnifiedUi` signal and binding sections
- `UnifiedIUR.Interaction`
- `UnifiedIUR` input and binding constructs
- `LiveUi.Renderer`
- `LiveUi.Runtime.ScreenComponent`
- `Phoenix.LiveView`

## Relevant Assumptions / Defaults
- The aggregate demo now renders all category galleries and already provides a stable tabbed review shell.
- The signal lab must use authored `unified_ui` interactions compiled to canonical `UnifiedIUR` and translated through `live_ui`, not ad hoc runtime-only event handlers.
- Signal-driven stories should be reviewer-friendly first, with clear visible outcomes and readable explanations, while still exposing canonical interaction meaning.

[x] 4 Phase 4 - Signal Lab and Cross-Control Reactivity Stories
  Implement the dedicated signal-lab tab so the aggregate demo app proves authored canonical signal flows through visible cross-control reactivity rather than only static showcase rendering.

  [ ] 4.1 Section - Signal Lab Authored Backbone
    Define the root structure of the signal lab so interaction stories can be authored, rendered, and reviewed consistently.

    [ ] 4.1.1 Task - Implement the signal-lab screen and story registry
      Create the authored fragment or screen that owns the signal-lab layout, the list of interaction stories, and the shared story-panel framing.

      [ ] 4.1.1.1 Subtask - Define the signal-lab fragment identity, title, summary, and reviewer notes inside the aggregate demo app.
      [ ] 4.1.1.2 Subtask - Define a story registry for the required interaction story shapes `action_to_feedback`, `input_to_preview`, `selection_to_filter`, and `toggle_to_visibility_or_enabled_state`.
      [ ] 4.1.1.3 Subtask - Add tests that prove the signal-lab tab mounts with all required story panels before story logic is populated.

    [ ] 4.1.2 Task - Define the shared story-panel contract
      Establish one consistent layout for source controls, reactive targets, explanatory copy, and runtime feedback.

      [ ] 4.1.2.1 Subtask - Define the source-control, outcome-panel, and latest-interaction summary regions for every story.
      [ ] 4.1.2.2 Subtask - Define how each story explains the source control, the intended emitted signal family or intent, and the expected visible outcome.
      [ ] 4.1.2.3 Subtask - Add tests that fail when signal stories regress into raw debug panels without a reviewer-friendly story structure.

  [ ] 4.2 Section - Required Cross-Control Story Inventory
    Implement the minimum interaction stories required by the demo-app specs so the signal lab demonstrates multiple canonical signal families.

    [ ] 4.2.1 Task - Implement action and input driven stories
      Add the click and change stories that demonstrate the two most common signal flows through visible target-state changes.

      [ ] 4.2.1.1 Subtask - Implement `action_to_feedback` so a button or action control emits a canonical click signal that updates a feedback, status, or callout region.
      [ ] 4.2.1.2 Subtask - Implement `input_to_preview` so a text or numeric control emits a canonical change signal that updates a preview or bound content panel.
      [ ] 4.2.1.3 Subtask - Add tests that verify these stories update both visible target state and latest-interaction summaries.

    [ ] 4.2.2 Task - Implement selection and toggle driven stories
      Add the selection and toggle stories that prove cross-control filtering, visibility, or enabled-state changes.

      [ ] 4.2.2.1 Subtask - Implement `selection_to_filter` so a select, tabs, menu, or pick-list interaction changes the visible state of another content region.
      [ ] 4.2.2.2 Subtask - Implement `toggle_to_visibility_or_enabled_state` so a toggle or checkbox changes whether another control or panel is enabled, visible, or emphasized.
      [ ] 4.2.2.3 Subtask - Add tests that verify these stories preserve readable source/target semantics and visible state transitions.

  [ ] 4.3 Section - Meaningful Runtime Feedback and Canonical Signal Presentation
    Make the signal lab show canonical interaction meaning in a readable form without turning the tab into a raw debug console.

    [ ] 4.3.1 Task - Implement reviewer-friendly runtime feedback surfaces
      Surface the latest interaction meaning in a way that helps reviewers understand what happened and why it matters.

      [ ] 4.3.1.1 Subtask - Add a latest-interaction summary that names the signal family or intent in human-readable language.
      [ ] 4.3.1.2 Subtask - Add a canonical detail surface that exposes the translated interaction meaning and selected payload details without making raw serialization the only feedback.
      [ ] 4.3.1.3 Subtask - Add tests that fail when visible outcome panels update but canonical interaction meaning disappears from the story surface.

    [ ] 4.3.2 Task - Preserve the shared styling contract inside the signal lab
      Ensure the signal-lab presentation still looks like part of the same example suite and current button example family.

      [ ] 4.3.2.1 Subtask - Reuse the same shared button-example accent treatment for story triggers and active story cues.
      [ ] 4.3.2.2 Subtask - Reuse the same shell, panel, and input treatment inside signal-lab story panels.
      [ ] 4.3.2.3 Subtask - Add regression coverage that proves the signal lab remains visually continuous with the rest of the aggregate demo.

  [ ] 4.4 Section - Signal Lab Diagnostics and Regression Guards
    Add the specific checks that keep the signal lab honest as the runtime and authored interaction surfaces evolve.

    [ ] 4.4.1 Task - Add validation for story completeness and runtime behavior
      Make the signal lab fail clearly when a story stops emitting a canonical interaction or stops producing a visible target-state change.

      [ ] 4.4.1.1 Subtask - Add validation for missing source controls, missing target panels, or missing reviewer-visible outcome descriptions.
      [ ] 4.4.1.2 Subtask - Add validation for signal-family drift when a story no longer demonstrates the intended interaction type.
      [ ] 4.4.1.3 Subtask - Add tests that prove regressions in signal meaning or target reactivity are caught before release workflows pass.

  [ ] 4.5 Section - Phase 4 Integration Tests
    Validate that the signal-lab tab now demonstrates multiple authored canonical signal families through visible cross-control reactivity and readable runtime feedback.

    [ ] 4.5.1 Task - Cross-control interaction integration scenarios
      Verify the required signal stories execute through the full authored DSL to canonical runtime path.

      [ ] 4.5.1.1 Subtask - Verify click and change stories update both visible target state and readable latest-interaction summaries.
      [ ] 4.5.1.2 Subtask - Verify selection and toggle stories change another control or panel rather than only logging signal metadata.
      [ ] 4.5.1.3 Subtask - Verify the signal-lab presentation remains styled and structured like the rest of the aggregate demo app.
