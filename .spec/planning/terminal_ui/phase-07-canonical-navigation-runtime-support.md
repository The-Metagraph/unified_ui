# Phase 7 - Canonical Navigation Runtime Support

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `TerminalUi.Runtime`
- `TerminalUi.Runtime.State`
- `TerminalUi.Runtime.EventRouter`
- `TerminalUi.Transport`
- `UnifiedIUR.Interaction`
- `UnifiedIUR.Interactions.Transport`

## Relevant Assumptions / Defaults
- `terminal_ui` should extend the shared runtime and canonical boundary model
  it already uses rather than inventing a second navigation-specific runtime
  stack.
- Canonical navigation in `terminal_ui` should use symbolic screen
  identifiers, bounded terminal history semantics, and modal or section
  transitions instead of browser-style route syntax.
- Native and canonical entry paths must share the same terminal navigation
  state model so transition behavior stays reviewable across backend modes and
  capability profiles.

[ ] 7 Phase 7 - Canonical Navigation Runtime Support
  Implement canonical navigation transition handling inside the shared terminal
  runtime so native and canonical screens can resolve symbolic screen changes,
  bounded history traversal, and modal transitions without browser-route
  assumptions.

  [ ] 7.1 Section - Runtime Navigation State Backbone
    Implement the shared terminal navigation state and module seams required to
    handle canonical screen-transition intent inside `terminal_ui`.

    [ ] 7.1.1 Task - Implement shared navigation runtime modules and state surfaces
      Define the package-local runtime modules, state fields, and diagnostics
      needed to represent active terminal screens, bounded history, modal
      stack state, and last transition metadata.

      [ ] 7.1.1.1 Subtask - Add a package-local runtime navigation module that extends the shared `TerminalUi.Runtime` backbone without splitting native and canonical execution paths.
      [ ] 7.1.1.2 Subtask - Define runtime state fields for current symbolic screen id, replacement strategy, bounded back and forward history, modal stack state, and deterministic transition summaries.
      [ ] 7.1.1.3 Subtask - Add runtime diagnostics for unresolved symbolic targets, unsupported transition actions, invalid modal state, and navigation requests that exceed bounded terminal policies.

    [ ] 7.1.2 Task - Implement runtime snapshot and reference hooks for navigation state
      Keep the new navigation runtime behavior visible through package-local
      inspection and reference surfaces while it is being introduced.

      [ ] 7.1.2.1 Subtask - Extend runtime snapshot or inspection helpers to report current screen id, bounded history state, modal stack state, and last transition details.
      [ ] 7.1.2.2 Subtask - Expose navigation runtime capabilities through package-facing reference helpers and validation summaries.
      [ ] 7.1.2.3 Subtask - Keep navigation inspection output aligned with the shared runtime and terminal capability assumptions already surfaced by the package.

  [ ] 7.2 Section - Symbolic Screen Resolution and Transition Application
    Implement symbolic screen resolution and terminal-appropriate transition
    application for canonical `navigate_to` and `replace_with` actions.

    [ ] 7.2.1 Task - Implement symbolic screen registry and resolver support
      Resolve canonical screen-transition targets through terminal-local screen
      registries or resolver callbacks rather than browser-route semantics.

      [ ] 7.2.1.1 Subtask - Add runtime support for package-local screen registries and optional resolver callbacks keyed by symbolic screen identifiers.
      [ ] 7.2.1.2 Subtask - Resolve direct-native and canonical-rendered target screens through the same registry and resolver behavior.
      [ ] 7.2.1.3 Subtask - Reject URL-like or host-router-oriented target data at the terminal runtime boundary with deterministic diagnostics.

    [ ] 7.2.2 Task - Implement terminal screen replacement and replacement-history behavior
      Apply canonical navigation actions in a terminal-appropriate way that
      preserves one coherent runtime model.

      [ ] 7.2.2.1 Subtask - Implement `navigate_to` as terminal screen replacement with bounded history push behavior and shared runtime realization updates.
      [ ] 7.2.2.2 Subtask - Implement `replace_with` as terminal screen replacement without history growth while preserving canonical transition summaries.
      [ ] 7.2.2.3 Subtask - Keep runtime realization, focus, event-loop state, and canonical/native screen metadata aligned after each terminal screen transition.

  [ ] 7.3 Section - Bounded History and Modal Transition Semantics
    Implement canonical `go_back`, `go_forward`, `open_modal`, and
    `close_modal` handling using bounded terminal runtime policies.

    [ ] 7.3.1 Task - Implement bounded history traversal for terminal navigation
      Support canonical back and forward transitions without assuming browser
      history semantics or unbounded page stacks.

      [ ] 7.3.1.1 Subtask - Implement bounded `go_back` behavior that restores the previous symbolic terminal screen when history state is available.
      [ ] 7.3.1.2 Subtask - Implement bounded `go_forward` behavior that restores forward history state only when the runtime has preserved it explicitly.
      [ ] 7.3.1.3 Subtask - Add deterministic diagnostics for empty history, empty forward state, or invalid history restoration payloads.

    [ ] 7.3.2 Task - Implement modal transition handling for layered terminal flows
      Support canonical modal open and close transitions through the existing
      layered terminal runtime model rather than as browser-window concepts.

      [ ] 7.3.2.1 Subtask - Implement `open_modal` by pushing modal identifiers, params, and metadata onto a bounded terminal modal stack.
      [ ] 7.3.2.2 Subtask - Implement `close_modal` by closing the active or requested modal entry through deterministic terminal runtime rules.
      [ ] 7.3.2.3 Subtask - Keep layered terminal realization, focus behavior, and fallback-capability policies aligned when modal transitions occur.

  [ ] 7.4 Section - Canonical Boundary Integration, Examples, and Tooling Alignment
    Integrate canonical navigation transitions into the existing boundary
    translation flow and make the behavior reviewable through maintained
    examples and tooling.

    [ ] 7.4.1 Task - Route canonical navigation transitions through the shared runtime event flow
      Connect the current canonical-boundary transport layer to the new
      runtime navigation behavior so terminal transitions affect runtime state
      instead of stopping at transport translation.

      [ ] 7.4.1.1 Subtask - Extend boundary-signal and native-event routing so navigation-family translations can invoke runtime screen, history, and modal transition behavior.
      [ ] 7.4.1.2 Subtask - Preserve the distinction between local terminal navigation-like interactions and boundary-crossing canonical screen transitions.
      [ ] 7.4.1.3 Subtask - Keep canonical navigation transition handling shared between native and canonical-rendered screens without bypassing transport diagnostics.

    [ ] 7.4.2 Task - Implement maintained examples and validation coverage for terminal navigation
      Make canonical navigation behavior reviewable and repeatable through
      maintained package examples, inspection output, and validation workflows.

      [ ] 7.4.2.1 Subtask - Add maintained native and canonical terminal examples that exercise screen replacement, bounded history traversal, and modal transitions through symbolic screen ids.
      [ ] 7.4.2.2 Subtask - Extend inspection and preview tooling to summarize terminal navigation state, transition targets, and no-host-route assumptions.
      [ ] 7.4.2.3 Subtask - Extend package validation workflows to cover runtime navigation determinism, symbolic-target resolution, and rejection of browser-route leakage.

  [ ] 7.5 Section - Phase 7 Integration Tests
    Validate canonical terminal navigation transitions, bounded history and
    modal behavior, and tooling visibility end to end.

    [ ] 7.5.1 Task - Runtime navigation integration scenarios
      Verify direct-native and canonical-rendered terminal screens resolve the
      same canonical transition meaning through one shared runtime model.

      [ ] 7.5.1.1 Subtask - Verify `navigate_to` and `replace_with` resolve symbolic terminal screens and update shared runtime state deterministically across native and canonical entry paths.
      [ ] 7.5.1.2 Subtask - Verify `go_back` and `go_forward` honor bounded terminal history semantics without introducing browser-route assumptions.
      [ ] 7.5.1.3 Subtask - Verify `open_modal` and `close_modal` update layered terminal runtime state, focus behavior, and fallback-capability behavior deterministically.

    [ ] 7.5.2 Task - Contract hygiene and tooling integration scenarios
      Verify the new navigation runtime remains reviewable and rejects
      browser-route leakage cleanly.

      [ ] 7.5.2.1 Subtask - Verify URL-like targets, host-router syntax, or unresolved symbolic screen identifiers fail with deterministic diagnostics.
      [ ] 7.5.2.2 Subtask - Verify maintained examples and inspection tooling expose terminal navigation state, transition summaries, and no-host-route guarantees coherently.
      [ ] 7.5.2.3 Subtask - Verify validation workflows and traceability surfaces cover canonical navigation runtime support without breaking the existing shared terminal runtime model.
