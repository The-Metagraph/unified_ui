# Canonical Rendering And Transport

`WebUi.Renderer` accepts canonical `UnifiedIUR.Element` values and maps them
into the same native widget surface used by direct-native screens.

## Canonical Rendering

- `WebUi.Renderer.render/2` is the canonical entrypoint.
- `WebUi.Renderer.supported_kinds/0` describes the current canonical coverage surface.
- Canonical rendering reuses `WebUi.Widget` values rather than inventing a
  second runtime model.

Canonical screens then flow through the same runtime path:

- `WebUi.Runtime.mount_iur_screen/2`
- `WebUi.Runtime.hydrate_frontend/1`

## Boundary Transport

`WebUi.Transport` keeps package-local event meaning and canonical boundary
translation aligned.

- local interactions remain package-local when allowed
- boundary interactions translate into `Jido.Signal`
- Phoenix stays authoritative for acknowledgement and state progression

## Comparison Workflows

Use the mixed example artifacts for review:

- `WebUi.Examples.foundational_comparison/0`
- `WebUi.Examples.advanced_comparison/0`
- `WebUi.Examples.mixed_transport_comparison/0`
- `WebUi.Examples.styling_comparison/0`
