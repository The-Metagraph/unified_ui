# Canonical Rendering And Transport

`terminal_ui` consumes canonical `UnifiedIUR` inside the package boundary and
realizes it through the same native runtime used for direct-native screens.

## Canonical Renderer Entry Point

- `TerminalUi.Renderer` accepts canonical `UnifiedIUR.Element`
- `TerminalUi.Renderer.Mapper` maps canonical widgets, layout, layering, and
  form composition into native `TerminalUi.Widget` structures
- renderer support is summarized through:
  - `TerminalUi.Renderer.supported_kinds/0`
  - `TerminalUi.Renderer.required_canonical_kinds/0`
  - `TerminalUi.Reference.package_reference/0`

The renderer is expected to preserve meaning while using explicit terminal
degradation where richer constructs cannot be realized directly.

## Shared Runtime Path

After canonical rendering, the output still mounts through `TerminalUi.Runtime`.
That means direct-native and canonical flows share:

- backend selection
- capability detection
- degradation policy
- style and theme realization
- focus and event routing
- transport translation and diagnostics

## Boundary Event Translation

`TerminalUi.Transport` keeps terminal inputs and boundary signals explicit:

- native terminal events normalize through one transport pipeline
- local-default and boundary-crossing families remain visible
- canonical boundary signals are translated without leaking terminal-specific
  payload details

Use:

- `TerminalUi.Transport.diagnostics/0`
- `TerminalUi.Validate.transport_validation/0`
- `mix terminal_ui.inspect transport_flow_review --format diagnostics`
- `mix terminal_ui.validate`

to review those guarantees while changing the renderer or runtime behavior.
