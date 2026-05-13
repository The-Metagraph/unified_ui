# Portable Widgets Review Fixture

This maintained example fixture tracks the AshUi-originated widgets that have
been promoted into the canonical UnifiedUi and UnifiedIUR surface.

The authored example lives in `UnifiedUi.Examples.PortableWidgets`. Reviewers
can compare that authored DSL with the canonical IUR fixture
`portable_widgets--ash_ui_portability`, then use the runtime parity matrix to
check native and degraded runtime behavior across `live_ui`, `elm_ui`,
`desktop_ui`, and `terminal_ui`.

## Files

- `review-fixtures.json` records the deterministic authored, canonical, and
  runtime review paths for the portable widget example.

## Validate

From `packages/unified-ui`:

`mix test test/unified_ui/ash_ui_widget_portability_phase_5_examples_test.exs`
