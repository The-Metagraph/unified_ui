# WebUi

`WebUi` is the Phoenix-and-Elm web runtime library for the unified ecosystem.

The package has two equally important roles:

- it is a directly usable native web widget/runtime library
- it is the canonical `UnifiedIUR` renderer and boundary-transport layer for the web runtime

`WebUi` does not own the authored DSL or the canonical IUR data model. It owns
the split web runtime behavior that turns native screens and canonical IUR
values into one coherent Phoenix-and-Elm-facing runtime.

## What This Package Owns

`WebUi` owns:

- native web widget, layout, layer, and styling boundaries
- the Phoenix server-side runtime that remains authoritative for package-boundary meaning
- the Elm frontend runtime that realizes browser-facing rendering and bounded local state
- canonical `UnifiedIUR` rendering through native widget reuse instead of a second renderer stack
- canonical boundary transport via `Jido.Signal` and split-runtime translation helpers
- maintainer-facing reference, inspection, and validation surfaces

`WebUi` does not own:

- the authored `unified_ui` DSL
- the canonical `unified_iur` construct model
- Phoenix LiveView-native component ownership
- desktop-native process lifecycles

## Maintainer Workflows

During the scaffold phase, the package keeps the maintainer workflow small:

- `mix test`

Later phases will add preview, inspection, export, and validation commands once
the server runtime, frontend runtime, renderer, and transport surfaces exist in
more depth.

## Reference Guides

Use the package guides for the current package contract details:

- [Server Runtime Backbone](guides/server_runtime_backbone.md)
- [Frontend Runtime Backbone](guides/frontend_runtime_backbone.md)
- [Canonical Rendering and Transport](guides/canonical_rendering_and_transport.md)
- [Maintainer Workflows](guides/maintainer_workflows.md)
