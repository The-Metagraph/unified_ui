# Runtime Backbone

`web_ui` uses one split runtime for both direct-native and canonical screens.

## Runtime Roles

- `WebUi.ServerRuntime`
  - owns authoritative Phoenix-side screen state
  - resolves canonical and native inputs into a server render model
  - routes local versus boundary events
- `WebUi.FrontendRuntime`
  - hydrates the server payload into bounded browser-facing state
  - realizes DOM-facing behavior and browser-local style state
  - keeps browser responsiveness bounded instead of redefining server meaning
- `WebUi.Runtime`
  - exposes the shared mount, hydrate, and event entrypoints
  - keeps native and canonical flows on the same package boundary

## Shared Flow

1. A native screen or canonical `UnifiedIUR.Element` enters through `WebUi.Runtime`.
2. `WebUi.ServerRuntime` builds the authoritative render model.
3. `WebUi.FrontendRuntime` hydrates the payload into browser-facing realization.
4. Local events stay local when allowed, or cross the boundary through `WebUi.Transport`.

## Review Surfaces

- `WebUi.Inspection.runtime_snapshot/2`
- `WebUi.Continuity.compare/3`
- `WebUi.Inspect.preview/1`
