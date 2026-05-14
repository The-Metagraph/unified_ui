# Phase 2 - Compiler, UnifiedIUR, and Signal Transport Alignment

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `UnifiedUi.Compiler`
- `UnifiedUi.Compiler.Pipeline`
- `UnifiedIUR`
- `Jido.Signal`
- package inspection and export surfaces

## Relevant Assumptions / Defaults
- `unified_ui` remains the authored source of canonical navigation intent and
  `unified_iur` remains the renderer-independent interchange boundary.
- Navigation lowering must preserve transition action, symbolic screen target,
  modal target, params, and source-context meaning without introducing
  host-specific route syntax.
- Modal stack lowering must preserve ordered `open_modal` and `close_modal`
  descriptors, topmost close semantics, symbolic modal targets, params, and
  metadata without synthesizing renderer-specific containment behavior.
- The shared signal transport contract continues to use `Jido.Signal` with
  CloudEvents-compatible semantics at package boundaries.

[ ] 2 Phase 2 - Compiler, UnifiedIUR, and Signal Transport Alignment
  Implement the canonical lowering, interchange representation, and transport
  semantics that carry screen-transition intent from authored `UnifiedUi`
  modules to runtime libraries.

  [x] 2.1 Section - UnifiedUi Compiler Navigation Lowering
    Implement compiler support that lowers authored navigation transitions into
    stable canonical descriptors.

    [x] 2.1.1 Task - Lower authored navigation into canonical descriptors
      Extend the compiler pipeline so authored screen transitions become
      portable canonical interaction data.

      [x] 2.1.1.1 Subtask - Lower navigation actions, symbolic screen targets, modal targets, params, and source-context fields into canonical interaction descriptors.
      [x] 2.1.1.2 Subtask - Preserve payload mapping and binding references for navigation transitions without introducing renderer-local callback logic.
      [x] 2.1.1.3 Subtask - Ensure canonical lowering stays deterministic across equivalent authored modules so navigation diffs remain review-friendly.
      [x] 2.1.1.4 Subtask - Preserve modal stack transition ordering, targetless top-modal `close_modal`, targeted symbolic modal close, params, and metadata without adding renderer-local modal hierarchy.

    [x] 2.1.2 Task - Preserve compatibility for non-transition interactions
      Keep existing canonical interaction lowering intact while introducing the
      new screen-transition model.

      [x] 2.1.2.1 Subtask - Ensure non-navigation interaction families continue to compile without depending on the new transition fields.
      [x] 2.1.2.2 Subtask - Ensure local navigation-like descriptors that do not change the top-level screen remain representable without being forced into the screen-transition shape.
      [x] 2.1.2.3 Subtask - Add normalization rules that keep older generic target-intent usage reviewable while preserving the newer canonical transition contract.

  [x] 2.2 Section - UnifiedIUR Interaction Representation
    Implement the canonical `unified_iur` representation needed for runtimes to
    consume screen-transition meaning without host-router assumptions.

    [x] 2.2.1 Task - Extend canonical interaction descriptors
      Add the renderer-independent fields and invariants needed for canonical
      screen transitions.

      [x] 2.2.1.1 Subtask - Extend the canonical interaction model to represent transition action, symbolic screen target, modal target, params, and related metadata.
      [x] 2.2.1.2 Subtask - Keep canonical interaction storage renderer-independent and free from browser path syntax, host-router names, or runtime-module references.
      [x] 2.2.1.3 Subtask - Define how targetless navigation actions, such as `go_back` or `close_modal`, are represented without inventing fake screen ids.
      [x] 2.2.1.4 Subtask - Define ordered modal stack transition representation for repeated `open_modal`, targetless top-modal close, and targeted symbolic modal close without structural modal nesting.

    [x] 2.2.2 Task - Update canonical inspection, export, and fixture support
      Make the new canonical navigation representation visible and testable
      through package tooling.

      [x] 2.2.2.1 Subtask - Update inspect and export surfaces so canonical navigation descriptors print their transition fields clearly.
      [x] 2.2.2.2 Subtask - Add canonical fixtures that exercise ordinary transitions, replacement transitions, history traversal, and modal transitions.
      [x] 2.2.2.3 Subtask - Ensure serialized or review-friendly output stays stable enough for diff-oriented tooling and conformance snapshots.
      [x] 2.2.2.4 Subtask - Add canonical fixtures and review summaries for stacked modal open/open/close sequences and named modal close behavior.

  [x] 2.3 Section - Shared Signal Transport Alignment
    Implement the shared transport semantics that move canonical screen
    transitions across runtime package boundaries.

    [x] 2.3.1 Task - Define canonical boundary signal shape for transitions
      Establish how canonical screen transitions are represented when they cross
      package boundaries as `Jido.Signal` values.

      [x] 2.3.1.1 Subtask - Define the event-family and payload expectations for transition actions, symbolic screen targets, modal targets, and params.
      [x] 2.3.1.2 Subtask - Define how targetless actions, such as `go_back`, `go_forward`, and `close_modal`, are encoded without host-specific routing assumptions.
      [x] 2.3.1.3 Subtask - Define how runtimes receive canonical transition data while keeping their local native signal models free to differ internally.
      [x] 2.3.1.4 Subtask - Define boundary preservation rules for modal stack push behavior, targetless top-modal close, symbolic targeted close, params, and metadata without runtime-local stack identifiers.

    [x] 2.3.2 Task - Add shared transport validation and fixtures
      Provide the shared validation and reference fixtures that runtime
      implementers can consume consistently.

      [x] 2.3.2.1 Subtask - Add validation for malformed transition payloads, leaked router syntax, and missing required canonical fields.
      [x] 2.3.2.2 Subtask - Add shared transport fixtures that web, desktop, and terminal runtimes can use to prove canonical transition fidelity.
      [x] 2.3.2.3 Subtask - Add review-oriented transport summaries that make it obvious which transition action and symbolic screen target crossed the package boundary.
      [x] 2.3.2.4 Subtask - Add shared transport fixtures and validation cases for stacked modal flows so runtimes can prove topmost close semantics consistently.

  [ ] 2.4 Section - Phase 2 Integration Tests
    Validate canonical lowering, `unified_iur` representation, and boundary
    transport behavior end to end before runtime-specific mapping begins.

    [ ] 2.4.1 Task - Compiler and canonical descriptor scenarios
      Verify authored transitions compile into stable canonical descriptors that
      carry the required cross-runtime meaning.

      [ ] 2.4.1.1 Subtask - Verify authored screen transitions lower into canonical interaction descriptors with action, symbolic screen target, modal target, params, and payload mapping preserved.
      [ ] 2.4.1.2 Subtask - Verify targetless transitions compile without fake screen ids or host-router placeholders.
      [ ] 2.4.1.3 Subtask - Verify canonical descriptor output remains deterministic across equivalent authored modules and review exports.
      [ ] 2.4.1.4 Subtask - Verify stacked modal transitions lower into ordered canonical descriptors without structural containment fields or renderer-local modal stack ids.

    [ ] 2.4.2 Task - Shared transport boundary scenarios
      Verify canonical transition meaning survives the package-boundary signal
      contract without route leakage.

      [ ] 2.4.2.1 Subtask - Verify `Jido.Signal` boundary fixtures preserve transition action, symbolic screen target, and params where applicable.
      [ ] 2.4.2.2 Subtask - Verify malformed transition envelopes and leaked route syntax fail with shared validation diagnostics.
      [ ] 2.4.2.3 Subtask - Verify runtimes can consume the shared transition fixtures without requiring browser-only fields or runtime-module identifiers.
      [ ] 2.4.2.4 Subtask - Verify modal stack fixtures preserve `open_modal` push, targetless top-modal close, symbolic targeted close, params, and metadata across the shared boundary.
