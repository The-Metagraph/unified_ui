# Phase 3 - Runtime Modal Stack Navigation Alignment

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Runtime.Navigation`
- `ElmUi.ServerRuntime.Navigation`
- `DesktopUi.Navigation.Controller`
- `DesktopUi.Navigation.State`
- `TerminalUi.Runtime`
- `TerminalUi.Transport`
- `UnifiedIUR.Interaction`
- `UnifiedIUR.Interactions.Transport`

## Relevant Assumptions / Defaults
- Runtime packages consume the same canonical modal stack meaning: `open_modal`
  pushes a symbolic modal target, targetless `close_modal` closes the topmost
  modal, and targeted `close_modal` refers to a named open modal when supported.
- Modal stack behavior remains independent from main screen navigation history.
- Runtime visual behavior may differ, but host-specific focus traps, backdrops,
  route integration, and terminal degradation must not become canonical IUR or
  `UnifiedUi` authored fields.
- Terminal implementations may degrade stacked modal presentation into panels,
  inline overlays, or bounded screen sections while preserving stack meaning.

[x] 3 Phase 3 - Runtime Modal Stack Navigation Alignment
  Implement and verify modal stack navigation behavior in each runtime package
  that consumes canonical navigation transitions, keeping stack meaning
  portable while allowing each runtime to realize the experience through its
  native host model.

  [x] 3.1 Section - Shared Modal Stack Fixtures and Boundary Expectations
    Extend shared canonical fixtures, validation, and review output so every
    runtime can consume the same stacked modal transition scenarios.

    [x] 3.1.1 Task - Add shared modal stack transition fixtures
      Define the canonical fixture set that represents the new stack
      requirements without making any runtime the source of truth.

      [x] 3.1.1.1 Subtask - Add an `open_modal` fixture for a first symbolic modal target with params and metadata.
      [x] 3.1.1.2 Subtask - Add a second `open_modal` fixture that represents opening another modal while one is already active.
      [x] 3.1.1.3 Subtask - Add targetless and targeted `close_modal` fixtures that prove topmost close and named-modal close semantics stay portable.

    [x] 3.1.2 Task - Add shared validation and inspection for modal stacks
      Make modal stack behavior visible and deterministic before runtime
      package-specific handling begins.

      [x] 3.1.2.1 Subtask - Extend shared fixture validation so modal stack descriptors reject host-router fields, runtime-local stack ids, and structural modal containment assumptions.
      [x] 3.1.2.2 Subtask - Extend fixture summaries to show modal stack action, symbolic modal target, params, metadata, and whether a close is topmost or targeted.
      [x] 3.1.2.3 Subtask - Keep fixture serialization deterministic so stacked modal review output remains diff-friendly.

  [x] 3.2 Section - Web Runtime Modal Stack Handling
    Align the web runtimes with the shared canonical modal stack contract while
    preserving each runtime's existing server-authoritative model.

    [x] 3.2.1 Task - Implement LiveUi server-authoritative modal stack handling
      Ensure `live_ui` resolves canonical modal transitions through server
      state and exposes the current modal stack predictably to rendering and
      inspection surfaces.

      [x] 3.2.1.1 Subtask - Verify or implement `open_modal` appends symbolic modal entries with params and metadata to the server-authoritative modal stack.
      [x] 3.2.1.2 Subtask - Verify or implement targetless `close_modal` closes the topmost modal and targeted `close_modal` closes the matching open modal without mutating screen history.
      [x] 3.2.1.3 Subtask - Expose current modal and modal stack summaries through assigns, inspection, and runtime navigation summaries without leaking Phoenix route details.

    [x] 3.2.2 Task - Implement ElmUi server and frontend modal stack reflection
      Ensure `elm_ui` keeps the Phoenix server runtime authoritative while the
      frontend runtime reflects the resulting modal stack state.

      [x] 3.2.2.1 Subtask - Verify or implement server-side modal stack push and close semantics for canonical `open_modal` and `close_modal` transitions.
      [x] 3.2.2.2 Subtask - Update authoritative screen payloads and frontend acknowledgements so current modal and modal stack state are reflected after each transition.
      [x] 3.2.2.3 Subtask - Add diagnostics for missing modal targets, invalid targeted close, and frontend/server modal stack divergence.

  [x] 3.3 Section - Desktop and Terminal Runtime Modal Stack Handling
    Align desktop and terminal runtimes with the shared stack contract while
    respecting their native presentation and capability constraints.

    [x] 3.3.1 Task - Implement DesktopUi modal stack navigation behavior
      Keep desktop modal navigation as an independent stack managed by the
      navigation controller and rendered through desktop-native overlay
      behavior.

      [x] 3.3.1.1 Subtask - Verify or implement controller state transitions where each `open_modal` pushes and targetless `close_modal` pops the top modal while preserving history and forward stacks.
      [x] 3.3.1.2 Subtask - Verify or implement current/top modal helpers, modal depth reporting, and targeted close diagnostics for named symbolic modal targets.
      [x] 3.3.1.3 Subtask - Align modal overlay rendering, focus behavior, and navigation events with the controller stack without requiring canonical structural containment.

    [x] 3.3.2 Task - Implement TerminalUi modal stack degradation behavior
      Preserve canonical modal stack meaning in terminal runtime state even
      when visual presentation must degrade for terminal capabilities.

      [x] 3.3.2.1 Subtask - Add terminal runtime navigation state for modal stack entries, current modal, transition summaries, and bounded fallback metadata.
      [x] 3.3.2.2 Subtask - Implement `open_modal`, targetless `close_modal`, and targeted `close_modal` using terminal-appropriate panels, inline overlays, or bounded section transitions.
      [x] 3.3.2.3 Subtask - Add diagnostics and inspection output that show degradation decisions while preserving canonical stack meaning.

  [x] 3.4 Section - Examples, Documentation, and Traceability
    Update maintainer-facing examples and planning evidence so the new modal
    stack behavior can be reviewed package by package.

    [x] 3.4.1 Task - Add focused runtime examples for stacked modal navigation
      Provide small examples that prove each runtime maps the same canonical
      stack semantics into its own host model.

      [x] 3.4.1.1 Subtask - Add or update focused examples for `live_ui` and `elm_ui` that open a second modal, close the topmost modal, and expose server-authoritative modal stack state.
      [x] 3.4.1.2 Subtask - Add or update focused examples for `desktop_ui` that demonstrate independent modal stack behavior over a stable screen history.
      [x] 3.4.1.3 Subtask - Add or update focused examples for `terminal_ui` that demonstrate modal stack semantics with explicit terminal degradation output.

    [x] 3.4.2 Task - Update documentation and traceability surfaces
      Keep package plans, generated mirrors, and documentation aligned with the
      new modal stack requirements.

      [x] 3.4.2.1 Subtask - Update runtime package documentation to describe stack-based modal navigation without adding authored DSL router semantics.
      [x] 3.4.2.2 Subtask - Update package planning traceability for the new modal stack requirements where package-local manifests are maintained.
      [x] 3.4.2.3 Subtask - Regenerate generated traceability mirrors through the owning Mix tasks rather than hand-editing generated review output.

  [x] 3.5 Section - Phase 3 Integration Tests
    Validate that each runtime consumes canonical modal stack transitions
    consistently and keeps host-specific details outside the canonical
    boundary.

    [x] 3.5.1 Task - Cross-package modal stack transition scenarios
      Verify shared fixtures produce the same stack meaning in each runtime
      package even when host realization differs.

      [x] 3.5.1.1 Subtask - Verify shared modal stack fixtures validate through `UnifiedIUR` and signal transport before runtime package tests consume them.
      [x] 3.5.1.2 Subtask - Verify `live_ui`, `elm_ui`, and `desktop_ui` preserve open/open/top-close state transitions without changing screen history.
      [x] 3.5.1.3 Subtask - Verify `terminal_ui` preserves stack meaning and reports bounded degradation without requiring browser routes or runtime-local stack ids.

    [x] 3.5.2 Task - Contract hygiene and regression scenarios
      Verify modal stack support does not reopen router leakage or accidental
      structural containment assumptions.

      [x] 3.5.2.1 Subtask - Verify URL-like targets, host-router names, runtime module references, and modal containment metadata are rejected or ignored according to the canonical contract.
      [x] 3.5.2.2 Subtask - Verify targetless `close_modal` remains topmost close in every runtime and targeted `close_modal` remains symbolic where supported.
      [x] 3.5.2.3 Subtask - Verify examples, inspection output, and validation workflows expose modal stack state clearly enough for review.
