# LiveUi

`LiveUi` is the Phoenix LiveView runtime library for the unified ecosystem.

The package has two equally important roles:

- it is a directly usable native LiveView widget/runtime library
- it is the canonical `UnifiedIUR` renderer and boundary-transport layer for the LiveView runtime
- it exposes a package-local demo workbench for maintained example review

`LiveUi` does not own the authored DSL or the canonical IUR data model. It owns
the server-authoritative runtime behavior that turns native screens and
canonical IUR values into one coherent LiveView-facing runtime.

## What This Package Owns

`LiveUi` owns:

- native widget, form, layout, overlay, display, and operational component families
- the shared server-authoritative runtime used for both native screens and canonical IUR rendering
- canonical `UnifiedIUR` rendering through native widget reuse instead of a second renderer stack
- canonical boundary transport via `Jido.Signal` and channel-safe translation helpers
- maintained native, canonical, and mixed comparison examples
- maintainer-facing preview, inspection, export, and validation workflows

`LiveUi` does not own:

- the authored `unified_ui` DSL
- the canonical `unified_iur` construct model
- client-side Elm state management
- desktop-native process lifecycles

## Maintainer Workflows

The package includes five maintainer-facing Mix tasks:

- `mix live_ui.demo [home|EXAMPLE_ID] [--format summary|html|report|catalog]`
- `mix live_ui.preview [EXAMPLE_ID] [--format report|html|metadata]`
- `mix live_ui.inspect [EXAMPLE_ID] [--format report|metadata|comparison|diagnostics|catalog]`
- `mix live_ui.export [EXAMPLE_ID] [--format metadata|report|html|comparison|diagnostics|catalog]`
- `mix live_ui.validate [--format summary|report] [--strict]`

Use these commands to:

- render the package-local demo workbench around maintained example lanes
- launch the same demo as a real browser-hosted LiveView with `mix live_ui.demo --serve`
- preview maintained native and canonical examples
- inspect how native and canonical flows map onto the same runtime
- export review-friendly metadata, snapshots, comparisons, and diagnostics
- validate continuity, transport, runtime authority, and documentation readiness

To run the browser demo locally:

```bash
cd /Users/Pascal/code/unified/packages/live_ui
mix deps.get
mix live_ui.demo --serve
```

By default the demo listens on [http://127.0.0.1:4040](http://127.0.0.1:4040). You can deep-link to a maintained example and change the port too:

```bash
mix live_ui.demo native_styled_profile --serve --port 4050
```

## Reference Guides

Use the package guides for the package contract details:

- [Runtime Backbone](guides/runtime_backbone.md)
- [Native Runtime and Examples](guides/native_runtime_and_examples.md)
- [Canonical Rendering and Transport](guides/canonical_rendering_and_transport.md)
- [Maintainer Workflows](guides/maintainer_workflows.md)

## Release Readiness

`LiveUi` treats maintained example health, styled continuity alignment, boundary
transport soundness, server-authoritative runtime behavior, and maintainer
documentation as release-readiness criteria. Run `mix live_ui.validate --strict`
before promoting runtime-boundary changes.
