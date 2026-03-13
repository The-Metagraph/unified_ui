# LiveUi Rendering

This subject backfills the current rendering and widget catalog surface for
`packages/live_ui`, based on its component modules, registry, and tests.

```spec-meta
id: live_ui.rendering
kind: subsystem
status: active
summary: Current rendering contract for `packages/live_ui`, including direct widget helpers, descriptor-driven rendering, stable HTML tokens, and hook-backed advanced widgets.
surface:
  - packages/live_ui/lib/live_ui/widgets.ex
  - packages/live_ui/lib/live_ui/widget_registry.ex
  - packages/live_ui/lib/live_ui/components
  - packages/live_ui/lib/live_ui/assets.ex
  - packages/live_ui/lib/live_ui/style/compiler.ex
  - packages/live_ui/test/live_ui/components
  - packages/live_ui/test/live_ui/widgets
  - packages/live_ui/test/live_ui/assets
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: live_ui.rendering.widget_surface
  statement: 'The package shall expose the current direct Phoenix component surface for its implemented widget and layout catalog across basic widgets, layouts, navigation, forms, feedback, data visualization, and extension widgets.'
  priority: must
  stability: stable

- id: live_ui.rendering.registry_catalog
  statement: 'The package shall normalize descriptor kinds through `LiveUi.WidgetRegistry` and dispatch rendering to the current renderer families for supported canonical and extension widget kinds.'
  priority: must
  stability: stable

- id: live_ui.rendering.stable_html_contract
  statement: 'The renderer components shall emit the current stable HTML contract, including CSS tokens and scoped LiveView payload attributes for stateless widgets, multi-event widgets, stateful composites, tables, and advanced hook-driven widgets.'
  priority: must
  stability: stable

- id: live_ui.rendering.asset_manifest
  statement: 'The package shall expose the current JavaScript hook manifest and style token compiler used by advanced widgets such as viewport, split pane, command palette, and canvas.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/live_ui/lib/live_ui/widgets.ex
  covers:
    - live_ui.rendering.widget_surface

- kind: source_file
  target: packages/live_ui/lib/live_ui/widget_registry.ex
  covers:
    - live_ui.rendering.registry_catalog

- kind: source_file
  target: packages/live_ui/test/live_ui/components/widget_rendering_test.exs
  covers:
    - live_ui.rendering.widget_surface
    - live_ui.rendering.registry_catalog
    - live_ui.rendering.stable_html_contract

- kind: source_file
  target: packages/live_ui/test/live_ui/components/canvas_and_chart_test.exs
  covers:
    - live_ui.rendering.stable_html_contract

- kind: source_file
  target: packages/live_ui/lib/live_ui/assets.ex
  covers:
    - live_ui.rendering.asset_manifest

- kind: source_file
  target: packages/live_ui/lib/live_ui/style/compiler.ex
  covers:
    - live_ui.rendering.asset_manifest

- kind: source_file
  target: packages/live_ui/test/live_ui/assets/hooks_test.exs
  covers:
    - live_ui.rendering.asset_manifest
```
