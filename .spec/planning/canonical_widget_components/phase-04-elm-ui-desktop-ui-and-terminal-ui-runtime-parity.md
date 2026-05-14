# Phase 4 - ElmUi, DesktopUi, and TerminalUi Runtime Parity

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `ElmUi.Renderer`
- `ElmUi.ServerRuntime`
- `ElmUi.FrontendRuntime`
- `DesktopUi.Renderer`
- `DesktopUi.Runtime`
- `TerminalUi.Renderer`
- `TerminalUi.Capabilities`
- `UnifiedIUR.Element`
- `UnifiedIUR.Interaction`

## Relevant Assumptions / Defaults
- Runtime packages own their native widget APIs and do not become IUR-only
  shells.
- Runtime renderers consume the shared UnifiedIUR fixtures created in Phase 2.
- TerminalUi preserves meaning through explicit degradation where visual effects
  cannot be represented directly.
- All work in this phase is done.

[x] 4 Phase 4 - ElmUi, DesktopUi, and TerminalUi Runtime Parity
  Implement native and IUR-rendered equivalents for the expanded catalog in
  ElmUi, DesktopUi, and TerminalUi with runtime-appropriate interaction and
  degradation behavior.

  [x] 4.1 Section - Shared Runtime Parity Fixtures
    Establish shared fixture coverage and expected behavior summaries before
    implementing runtime-specific widgets.

    [x] 4.1.1 Task - Create runtime parity fixture suite
      Provide common inputs that every runtime package can render and validate.

      [x] 4.1.1.1 Subtask - Add fixture groups for content, identity, form, control, row, progress, layer, callout, redline, code, composer, and repeated rows.
      [x] 4.1.1.2 Subtask - Add expected semantic summaries for state, labels, interactions, and child structure.
      [x] 4.1.1.3 Subtask - Add malicious text fixtures for redline and code output safety across host runtimes.

    [x] 4.1.2 Task - Define runtime parity acceptance criteria
      Make clear when a runtime has native support, degraded support, or a
      missing implementation.

      [x] 4.1.2.1 Subtask - Define full, degraded, and unsupported statuses for every expanded widget family.
      [x] 4.1.2.2 Subtask - Define minimum interaction and accessibility behavior required even under degraded rendering.
      [x] 4.1.2.3 Subtask - Add parity reports that compare runtime coverage against the canonical fixture set.

  [x] 4.2 Section - ElmUi Runtime Support
    Implement the expanded catalog in the Phoenix-and-Elm runtime split while
    preserving canonical IUR and signal meaning.

    [x] 4.2.1 Task - Implement ElmUi native widget models
      Add server-side and Elm frontend representations for the expanded widget
      catalog.

      [x] 4.2.1.1 Subtask - Add server-side widget records and validation for expanded catalog props, children, and interactions.
      [x] 4.2.1.2 Subtask - Add Elm frontend rendering and update messages for interactive widgets.
      [x] 4.2.1.3 Subtask - Add safe text output for redline and code token content.

    [x] 4.2.2 Task - Implement ElmUi IUR renderer mappings
      Map canonical IUR into ElmUi's native server and frontend runtime model.

      [x] 4.2.2.1 Subtask - Add renderer mappings for every expanded widget family.
      [x] 4.2.2.2 Subtask - Translate canonical interactions into ElmUi message and Phoenix boundary events.
      [x] 4.2.2.3 Subtask - Verify repeated rows render as deterministic frontend children.

  [x] 4.3 Section - DesktopUi Runtime Support
    Implement desktop-native equivalents and IUR mappings with pointer,
    keyboard, and platform behavior appropriate for SDL3-oriented rendering.

    [x] 4.3.1 Task - Implement DesktopUi native widget models
      Add desktop-native structures for the expanded widget catalog.

      [x] 4.3.1.1 Subtask - Add native widget structs and style hooks for content, identity, controls, rows, progress, layers, callouts, redline, code, and composer surfaces.
      [x] 4.3.1.2 Subtask - Add keyboard and pointer handling for selection, row activation, step navigation, disclosure, slide-over, form, and composer widgets.
      [x] 4.3.1.3 Subtask - Add safe text layout and token rendering for redline and code widgets.

    [x] 4.3.2 Task - Implement DesktopUi IUR renderer mappings
      Map canonical IUR into DesktopUi native widgets and desktop signal
      translation.

      [x] 4.3.2.1 Subtask - Add renderer mappings for every expanded widget family.
      [x] 4.3.2.2 Subtask - Translate canonical interactions into desktop input and signal behavior.
      [x] 4.3.2.3 Subtask - Verify repeated rows produce stable widget identity across desktop rerenders.

  [x] 4.4 Section - TerminalUi Runtime Support and Degradation
    Implement terminal-native equivalents and explicit fallback behavior for
    visual affordances that terminals cannot always render directly.

    [x] 4.4.1 Task - Implement TerminalUi native widget models
      Add terminal widgets and capability-aware rendering for the expanded
      catalog.

      [x] 4.4.1.1 Subtask - Add terminal-native models for content, identity, controls, rows, progress, layers, callouts, redline, code, and composer widgets.
      [x] 4.4.1.2 Subtask - Add keyboard-first behavior for selection, row activation, step navigation, disclosure, slide-over, form, and composer widgets.
      [x] 4.4.1.3 Subtask - Add terminal-safe redline and code rendering with color-depth and ASCII fallbacks.

    [x] 4.4.2 Task - Implement TerminalUi IUR mappings and degradation reports
      Map canonical IUR into terminal widgets and expose any degraded behavior
      clearly.

      [x] 4.4.2.1 Subtask - Add renderer mappings for every expanded widget family.
      [x] 4.4.2.2 Subtask - Define degradation for frost, slide animation, dense multi-column rows, color-rich progress, avatars, and syntax colors.
      [x] 4.4.2.3 Subtask - Add inspectable degradation summaries for runtime parity reports.

  [x] 4.5 Section - Phase 4 Integration Tests
    Validate runtime parity across ElmUi, DesktopUi, and TerminalUi using the
    shared canonical fixtures and runtime-specific behavior checks.

    [x] 4.5.1 Task - Runtime fixture parity scenarios
      Verify every runtime consumes the shared expanded catalog fixtures.

      [x] 4.5.1.1 Subtask - Verify ElmUi renders and updates fixture widgets through server and frontend runtime paths.
      [x] 4.5.1.2 Subtask - Verify DesktopUi renders fixture widgets with deterministic native widget identity and event translation.
      [x] 4.5.1.3 Subtask - Verify TerminalUi renders or degrades fixture widgets with explicit capability summaries.

    [x] 4.5.2 Task - Cross-runtime behavior scenarios
      Verify canonical meaning remains stable across runtime differences.

      [x] 4.5.2.1 Subtask - Compare selection, submit, change, send, row activation, and step navigation signal meaning across runtimes.
      [x] 4.5.2.2 Subtask - Compare repeated row identity and row-scoped values across runtimes.
      [x] 4.5.2.3 Subtask - Compare redline and code safety fixtures across runtimes.
