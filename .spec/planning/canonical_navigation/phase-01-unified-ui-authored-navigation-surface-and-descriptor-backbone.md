# Phase 1 - UnifiedUi Authored Navigation Surface and Descriptor Backbone

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `UnifiedUi.Signal`
- `UnifiedUi.Dsl`
- `UnifiedUi.Dsl.Sections.Signals`
- `UnifiedUi.Compiler`
- `UnifiedUi.Tooling`

## Relevant Assumptions / Defaults
- Canonical navigation remains inside the `signals` authoring surface rather
  than becoming a new top-level `routing` section.
- Authored screen transitions use canonical actions such as `navigate_to`,
  `replace_with`, `go_back`, `go_forward`, `open_modal`, and `close_modal`.
- Top-level screen transitions target symbolic screen ids with optional params
  and metadata rather than URLs or host-router helpers.
- In-screen destination changes may remain authored as local navigation intent
  without being treated as host-style route changes.

[ ] 1 Phase 1 - UnifiedUi Authored Navigation Surface and Descriptor Backbone
  Implement the authored screen-transition model inside `unified_ui` so
  developers can declare cross-runtime navigation intent without leaking host
  routing syntax into the DSL.

  [x] 1.1 Section - Authored Navigation Action Vocabulary
    Implement the canonical navigation vocabulary and target-intent shape that
    developers use when declaring top-level screen transitions.

    [x] 1.1.1 Task - Define the canonical authored transition fields
      Establish the authored descriptor fields and allowed action set for
      top-level screen-transition intent.

      [x] 1.1.1.1 Subtask - Define how `action`, `screen`, `params`, `metadata`, and modal-oriented target fields appear in authored `target_intent` values.
      [x] 1.1.1.2 Subtask - Define which actions require a symbolic `screen` target and which actions, such as `go_back` or `close_modal`, are targetless.
      [x] 1.1.1.3 Subtask - Define how modal transitions and replacement transitions are distinguished from ordinary history-push transitions.

    [x] 1.1.2 Task - Distinguish screen transitions from in-screen navigation
      Keep local destination changes available without conflating them with
      cross-screen transition semantics.

      [x] 1.1.2.1 Subtask - Define the authored distinction between in-screen destination updates, such as tab or section changes, and top-level screen transitions.
      [x] 1.1.2.2 Subtask - Ensure canonical navigation examples demonstrate both local destination changes and top-level screen transitions without blurring their semantics.
      [x] 1.1.2.3 Subtask - Define how existing generic interaction descriptors continue to work when no top-level screen transition is intended.

  [x] 1.2 Section - Validation, Diagnostics, and Introspection
    Implement the validation and inspection surfaces that keep the authored
    navigation contract explicit, deterministic, and reviewable.

    [x] 1.2.1 Task - Validate authored screen-transition intent
      Reject malformed or host-specific navigation declarations at authoring
      time.

      [x] 1.2.1.1 Subtask - Reject URLs, Phoenix route helpers, browser-history instructions, and runtime-module identifiers in canonical screen-transition declarations.
      [x] 1.2.1.2 Subtask - Reject malformed action names, missing required screen targets, and invalid modal-target combinations.
      [x] 1.2.1.3 Subtask - Emit actionable diagnostics that explain whether the author attempted a top-level screen transition, a local destination change, or an unsupported host-specific route declaration.

    [x] 1.2.2 Task - Expose navigation inspection helpers
      Make authored navigation intent visible through package tooling before a
      runtime is involved.

      [x] 1.2.2.1 Subtask - Update inspection helpers to show canonical navigation actions, symbolic screen targets, params, and modal-oriented targets.
      [x] 1.2.2.2 Subtask - Expose helper surfaces that list the supported navigation actions and their required authored fields.
      [x] 1.2.2.3 Subtask - Ensure navigation descriptors remain deterministic in inspection and export output so diffs stay stable and review-friendly.

  [x] 1.3 Section - Author-Facing Examples and Guidance
    Implement maintained examples and guidance that teach developers how to use
    the new authored navigation contract correctly.

    [x] 1.3.1 Task - Add maintained navigation authoring examples
      Provide canonical examples that demonstrate the supported authored
      navigation patterns.

      [x] 1.3.1.1 Subtask - Add an example that shows an in-screen destination change, such as a tab switch, without using screen-transition fields.
      [x] 1.3.1.2 Subtask - Add an example that shows a top-level screen transition using a symbolic screen id and params.
      [x] 1.3.1.3 Subtask - Add an example that shows modal open and close transitions as canonical navigation actions.

    [x] 1.3.2 Task - Update foundational navigation guidance
      Document the authored mental model so developers understand what the DSL
      owns and what runtimes still own.

      [x] 1.3.2.1 Subtask - Explain that `UnifiedUi` owns screen-transition intent rather than router tables or URL semantics.
      [x] 1.3.2.2 Subtask - Explain the difference between `screen` targets, local destinations, and host-runtime route resolution.
      [x] 1.3.2.3 Subtask - Explain how authored canonical navigation remains portable across web, desktop, and terminal runtimes.

  [ ] 1.4 Section - Phase 1 Integration Tests
    Validate the authored navigation surface, diagnostics, and inspection
    output end to end inside `unified_ui`.

    [ ] 1.4.1 Task - Authored descriptor and validation scenarios
      Verify `unified_ui` accepts valid canonical transitions and rejects
      host-specific navigation leakage deterministically.

      [ ] 1.4.1.1 Subtask - Verify authored `navigate_to`, `replace_with`, `go_back`, `go_forward`, `open_modal`, and `close_modal` descriptors validate successfully with the expected field requirements.
      [ ] 1.4.1.2 Subtask - Verify screen-transition descriptors reject URLs, route helpers, browser-history directives, and runtime-module identifiers.
      [ ] 1.4.1.3 Subtask - Verify invalid action and target combinations fail with actionable diagnostics that distinguish malformed screen transitions from local destination changes.

    [ ] 1.4.2 Task - Inspection and example scenarios
      Verify maintained examples and tooling reflect canonical navigation
      intent clearly before runtime mapping begins.

      [ ] 1.4.2.1 Subtask - Verify inspection and export helpers report navigation action, symbolic screen target, params, and modal target fields deterministically.
      [ ] 1.4.2.2 Subtask - Verify the maintained examples cover in-screen destination changes, top-level screen transitions, and modal transitions.
      [ ] 1.4.2.3 Subtask - Verify foundational guidance stays aligned with the actual authored navigation surface and does not describe host-router semantics as part of the DSL.
