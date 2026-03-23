# Runtime Backbone

`elm_ui` uses one split runtime for both direct-native and canonical screens.

## Runtime Roles

- `ElmUi.ServerRuntime`
  - owns authoritative Phoenix-side screen state
  - resolves canonical and native inputs into a server render model
  - routes local versus boundary events
- `ElmUi.FrontendRuntime`
  - hydrates the server payload into bounded browser-facing state
  - realizes DOM-facing behavior and browser-local style state
  - keeps browser responsiveness bounded instead of redefining server meaning
- `ElmUi.Runtime`
  - exposes the shared mount, hydrate, and event entrypoints
  - keeps native and canonical flows on the same package boundary

## Shared Flow

1. A native screen or canonical `UnifiedIUR.Element` enters through `ElmUi.Runtime`.
2. `ElmUi.ServerRuntime` builds the authoritative render model.
3. `ElmUi.FrontendRuntime` hydrates the payload into browser-facing realization.
4. Local events stay local when allowed, or cross the boundary through `ElmUi.Transport`.

## Review Surfaces

- `mix elm_ui.inspect native_styling`
- `mix elm_ui.export styling_continuity --format comparison`
- `mix elm_ui.validate --strict`
- `ElmUi.Inspection.runtime_snapshot/2`
- `ElmUi.Continuity.compare/3`
- `ElmUi.Inspect.preview/1`
