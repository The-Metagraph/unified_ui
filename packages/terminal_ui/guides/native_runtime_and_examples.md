# Native Runtime And Examples

`terminal_ui` is usable directly through its own native terminal widget surface.
That direct-native path is not a demo-only layer; it is one of the package's
core contracts.

## Direct-Native Surface

Use `TerminalUi.Widgets` for the native terminal surface:

- foundational content and action widgets
- input and navigation widgets
- advanced data, feedback, visualization, and operational widgets
- grouped form composition through `TerminalUi.Widgets.Forms`
- display and layering constructs through `TerminalUi.Layout` and
  `TerminalUi.Layer`

The direct-native path still uses the same backend, capability, style,
degradation, and transport seams as canonical rendering.

## Maintained Example Catalog

The maintained examples are intentionally paired:

- native examples show direct-native authoring through `TerminalUi.Widgets`
- canonical examples show `UnifiedIUR` flowing through `TerminalUi.Renderer`
- mixed examples compare parity, transport, styling, and degradation behavior

Use these helpers to inspect the catalog without reading the source directly:

- `TerminalUi.Examples.catalog/0`
- `TerminalUi.Examples.metadata/1`
- `TerminalUi.Reference.example_summary/0`
- `mix terminal_ui.inspect --format catalog`

## Example Workflows

The maintained examples cover:

- foundational workspace review
- advanced operations review
- transport and normalized input review
- styled continuity review
- degradation review across rich and fallback terminals

Those examples are meant to stay useful for package inspection, CI-oriented
validation, and release-readiness review.
