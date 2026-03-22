# WebUi

`web_ui` is the web-target runtime library for the unified ecosystem. It
supports both direct-native authored screens and canonical `UnifiedIUR`
rendering through the same Phoenix-authoritative and Elm-realized runtime
boundary.

## Main Surfaces

- `WebUi.Widgets`, `WebUi.Layout`, and `WebUi.Layer` expose the direct-native
  widget and composition surface.
- `WebUi.Renderer` maps canonical `UnifiedIUR.Element` values into the same
  native widget model.
- `WebUi.Runtime`, `WebUi.ServerRuntime`, and `WebUi.FrontendRuntime` provide
  the shared split-runtime path for native and canonical screens.
- `WebUi.Style` and `WebUi.Theme` define portable styling, theme tokens, and
  cross-runtime style continuity.
- `WebUi.Inspect`, `WebUi.Export`, `WebUi.Validate`, `WebUi.Reference`, and
  `WebUi.Info` provide the maintainer tooling surface.

## Maintained Example Suites

`WebUi.Examples` includes maintained:

- direct-native examples through `WebUi.Examples.native_examples/0`
- canonical-rendered examples through `WebUi.Examples.canonical_examples/0`
- mixed comparison and continuity artifacts through `WebUi.Examples.mixed_examples/0`

Each example carries stable metadata, artifact names, parity obligations, and
coverage tags through `WebUi.Examples.catalog/0`, `WebUi.Examples.metadata/1`,
and `WebUi.Examples.coverage_matrix/0`.

## Maintainer Workflow

Package-local checks:

- `mix deps.get`
- `mix compile`
- `mix test`
- `mix docs`

Workspace checks:

- `mix spec.plancheck web_ui`
- `mix spec.compliance web_ui`

Maintainer helper modules:

- `WebUi.Inspect.preview/1`
- `WebUi.Export.artifact/1`
- `WebUi.Validate.release_readiness/1`
- `WebUi.Reference.package_reference/0`
- `WebUi.Info.package_summary/0`

## Guides

- `guides/runtime_backbone.md`
- `guides/native_runtime_and_examples.md`
- `guides/canonical_rendering_and_transport.md`
- `guides/styling_and_inspection.md`
- `guides/maintainer_workflows.md`
