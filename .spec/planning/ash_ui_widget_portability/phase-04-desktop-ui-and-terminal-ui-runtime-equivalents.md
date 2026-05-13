# Phase 4 - DesktopUi and TerminalUi Runtime Equivalents

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `DesktopUi`
- `DesktopUi.Renderer`
- `DesktopUi.Runtime`
- SDL3-oriented native widget and layout modules
- `TerminalUi`
- terminal capability and degradation modules
- shared `UnifiedIUR` promoted widget fixtures

## Relevant Assumptions / Defaults
- DesktopUi should provide rich native equivalents where SDL3 rendering can
  express the canonical meaning directly.
- TerminalUi should preserve canonical meaning with capability-aware fallback
  when visual richness, overlays, syntax color, or interaction affordances are
  constrained by terminal capabilities.
- Both runtimes must preserve canonical row-scope and interaction semantics at
  the boundary even when visual rendering degrades.

[ ] 4 Phase 4 - DesktopUi and TerminalUi Runtime Equivalents
  Implement desktop and terminal native equivalents, IUR renderer support, and
  explicit degradation behavior for the promoted widget surface.

  [x] 4.1 Section - DesktopUi Native and IUR Runtime Support
    Add SDL3-oriented native widgets and canonical rendering paths for the
    promoted surface.

    [x] 4.1.1 Task - Implement DesktopUi promoted widget equivalents
      Provide desktop-native widgets that preserve canonical semantics with
      desktop-appropriate interaction and rendering behavior.

      [x] 4.1.1.1 Subtask - Add desktop-native equivalents for semantic micro widgets, workflow/document widgets, slide-over panels, syntax-highlighted code blocks, and chat composers.
      [x] 4.1.1.2 Subtask - Implement focus, keyboard, pointer, layout, z-order, overlay, and text-rendering behavior needed by the promoted widgets.
      [x] 4.1.1.3 Subtask - Add desktop runtime tests for widget layout, input routing, overlay stacking, state changes, and style-token application.

    [x] 4.1.2 Task - Implement DesktopUi IUR rendering and repeated collection support
      Make canonical promoted widgets and repeated templates render through the
      desktop IUR renderer.

      [x] 4.1.2.1 Subtask - Extend the desktop IUR renderer to consume every promoted canonical widget node, host-owned form shell, and repeated collection construct.
      [x] 4.1.2.2 Subtask - Map row-scope bindings to desktop event routing and native selection state without leaking renderer structs into canonical values.
      [x] 4.1.2.3 Subtask - Add renderer tests using shared IUR fixtures for promoted widgets, repeated collections, and row-scope events.

  [ ] 4.2 Section - TerminalUi Native and IUR Runtime Support
    Add terminal-native equivalents and explicit degradation behavior for the
    promoted surface.

    [ ] 4.2.1 Task - Implement TerminalUi promoted widget equivalents and degradation policy
      Provide terminal-native widgets that preserve semantic meaning even when
      visual treatment must degrade.

      [ ] 4.2.1.1 Subtask - Add terminal equivalents for semantic micro widgets, workflow/document widgets, slide-over panels, syntax-highlighted code blocks, and chat composers.
      [ ] 4.2.1.2 Subtask - Define degradation for avatars, presence indicators, sticky headers, slide-over panels, inline redlines, syntax highlighting, progress visuals, and composer attachments.
      [ ] 4.2.1.3 Subtask - Add terminal capability tests for color, width, keyboard navigation, focus behavior, overlays, and no-color or narrow-viewport fallback.

    [ ] 4.2.2 Task - Implement TerminalUi IUR rendering and repeated collection support
      Make canonical promoted widgets and repeated templates render through the
      terminal IUR renderer with explicit fallback metadata.

      [ ] 4.2.2.1 Subtask - Extend the terminal IUR renderer to consume every promoted canonical widget node, host-owned form shell, and repeated collection construct.
      [ ] 4.2.2.2 Subtask - Preserve row-scope payload mapping and item identity across terminal selection, activation, and command input flows.
      [ ] 4.2.2.3 Subtask - Add renderer tests that verify fallback output remains semantically equivalent to the shared IUR fixtures.

  [ ] 4.3 Section - Cross-Runtime Degradation and Parity Matrix
    Make desktop and terminal runtime differences explicit and reviewable
    rather than hidden in renderer implementations.

    [ ] 4.3.1 Task - Define promoted widget runtime parity expectations
      Establish a cross-runtime matrix for direct support, fallback support,
      unsupported states, and required diagnostics.

      [ ] 4.3.1.1 Subtask - Create a parity matrix that lists every promoted widget, required canonical semantics, desktop support status, terminal support status, and fallback behavior.
      [ ] 4.3.1.2 Subtask - Define the minimum acceptable degradation for terminal and constrained desktop environments.
      [ ] 4.3.1.3 Subtask - Add validation that fails when a runtime silently drops required canonical widget or row-scope meaning.

    [ ] 4.3.2 Task - Align runtime interaction and row-scope behavior
      Ensure desktop and terminal interaction events preserve the same
      canonical meaning as web runtimes.

      [ ] 4.3.2.1 Subtask - Map disclosure, segmented controls, slide-over panels, chat composer actions, and repeated-row interactions onto desktop native events.
      [ ] 4.3.2.2 Subtask - Map the same interaction families onto terminal key and command events with explicit fallback where direct interaction is impossible.
      [ ] 4.3.2.3 Subtask - Add shared interaction fixtures proving row-scope payloads and widget actions survive runtime translation.

  [ ] 4.4 Section - Phase 4 Integration Tests
    Validate desktop and terminal runtime equivalents, IUR rendering, fallback,
    and interaction behavior end to end.

    [ ] 4.4.1 Task - Desktop and terminal promoted widget scenarios
      Verify both non-web runtimes realize the promoted canonical widgets
      through native and IUR entrypoints.

      [ ] 4.4.1.1 Subtask - Verify each promoted widget renders through native `desktop_ui`, native `terminal_ui`, and each runtime's IUR renderer.
      [ ] 4.4.1.2 Subtask - Verify desktop rich behavior and terminal fallback behavior both preserve required canonical semantics.
      [ ] 4.4.1.3 Subtask - Verify unsupported visual treatments emit explicit degradation diagnostics rather than silently dropping meaning.

    [ ] 4.4.2 Task - Desktop and terminal repeated collection scenarios
      Verify repeated collection rendering and row-scope events behave
      correctly in non-web runtimes.

      [ ] 4.4.2.1 Subtask - Verify repeated collection fixtures render stable rows, empty states, nested promoted widgets, and updates in both runtimes.
      [ ] 4.4.2.2 Subtask - Verify row-level interactions emit canonical payloads through desktop and terminal event models.
      [ ] 4.4.2.3 Subtask - Verify the cross-runtime parity matrix matches observed renderer behavior.
