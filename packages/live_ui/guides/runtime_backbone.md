# Runtime Backbone

`LiveUi` is designed as a server-authoritative LiveView runtime library.

The package exposes native widget boundaries, runtime helpers, canonical
renderer entry points, and transport translation modules without taking over
application startup.

## Core Runtime Model

The package uses one shared runtime for:

- directly authored native `LiveUi.Screen` modules
- canonical `UnifiedIUR` values rendered through `LiveUi.Renderer`

That shared runtime is intentionally server-authoritative:

- the server owns runtime state
- boundary events are translated into canonical `Jido.Signal` values
- browser hooks are normalized before entering runtime event handling
- canonical rendering reuses the same runtime host instead of introducing a second renderer stack

## Boundary Expectations

`LiveUi` is allowed to keep renderer-local behavior inside the direct native
path, but canonical boundary translation must remain CloudEvents-compatible and
must not leak renderer-local payload semantics into boundary signals.

Use the maintained mixed examples and `mix live_ui.validate` to review these
transport expectations when the runtime boundary changes.
