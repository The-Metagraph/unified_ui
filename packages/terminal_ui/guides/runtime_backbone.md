# Runtime Backbone

`terminal_ui` is structured around one terminal runtime boundary for both
direct-native and canonical rendering flows.

## Runtime Roles

- `TerminalUi.Runtime`
  - defines the shared runtime entrypoint and state boundary
  - keeps native and canonical flows inside one package runtime model
- `TerminalUi.Backend`
  - defines richer and limited backend adapter seams
  - keeps backend selection explicit instead of implicit
- `TerminalUi.Capabilities`
  - defines capability summaries and degradation assumptions
  - keeps terminal variation inspectable

## Phase 1 Scope

Phase 1 establishes the package scaffold, runtime adapter seams, and reference
surfaces. Full canonical rendering, transport translation, and capability-aware
degradation arrive in later phases.

## Shared Boundary Principles

- `TerminalUi.Runtime` is the only runtime entrypoint for both direct-native
  and canonical mounting flows.
- `TerminalUi.Renderer` consumes canonical `UnifiedIUR` and reuses the same
  native widget, styling, degradation, and transport model rather than
  introducing a second rendering stack.
- `TerminalUi.Backend`, `TerminalUi.Capabilities`, and `TerminalUi.Degradation`
  make capability assumptions inspectable before terminal realization depends on
  them.
- `TerminalUi.Transport` keeps local terminal inputs and canonical boundary
  signal translation explicit under one package boundary.

## Modal Stack Navigation

Canonical modal transitions preserve stack meaning even when terminal
presentation degrades. `open_modal` records symbolic modal entries with params,
metadata, and backend-specific degradation metadata. Targetless `close_modal`
removes the topmost modal and restores the previous modal or underlying screen
state without requiring browser routes, runtime-local stack ids, or structural
modal containment.

Rich backends report overlay presentation, while TTY-compatible backends report
bounded inline overlay presentation. Both paths expose the same canonical stack
state through runtime inspection.

Use the additional guides for task-oriented detail:

- `guides/native_runtime_and_examples.md`
- `guides/canonical_rendering_and_transport.md`
- `guides/styling_capabilities_and_inspection.md`
