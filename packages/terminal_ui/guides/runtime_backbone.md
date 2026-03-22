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
