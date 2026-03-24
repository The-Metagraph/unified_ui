# DesktopUi

`desktop_ui` is the desktop-target runtime library for the unified ecosystem.
It is intended to support both direct-native desktop screens and canonical
`UnifiedIUR` rendering through one shared SDL2-oriented runtime boundary.

## Main Surfaces

- `DesktopUi.Widgets` will expose the direct-native widget surface.
- `DesktopUi.Runtime` defines the shared desktop runtime boundary.
- `DesktopUi.Platform` defines Windows, macOS, and Linux adapter seams.
- `DesktopUi.Renderer` defines the canonical renderer entrypoint.
- `DesktopUi.Transport`, `DesktopUi.Artifacts`, `DesktopUi.Tooling`,
  `DesktopUi.Reference`, and `DesktopUi.Info` expose package-facing helper
  surfaces for transport, packaging, maintainer workflows, and introspection.

## Shared Runtime Model

`desktop_ui` does not own the authored DSL or canonical IUR definitions.
Instead, it consumes canonical `UnifiedIUR`, realizes that meaning through
native desktop widgets, and translates cross-package event meaning at the
desktop runtime boundary.

The package keeps one architectural split from the beginning:

- shared desktop runtime coordination lives under `DesktopUi.Runtime`
- platform-specific behavior stays under `DesktopUi.Platform`
- canonical rendering stays under `DesktopUi.Renderer`
- packaging concerns stay under `DesktopUi.Artifacts`

## SDL2 Foundation

Phase 1 establishes SDL2 as the shared runtime foundation and treats platform
variation as an adapter concern. The actual native binding remains deferred
behind the package’s runtime policy until later phases harden the event loop,
renderer, and platform-specific artifact flows.

## Maintainer Workflow

Package-local checks:

- `mix deps.get`
- `mix compile`
- `mix test`

Workspace checks:

- `mix spec.plancheck desktop_ui`

## Guides

- `guides/runtime_backbone.md`
- `guides/maintainer_workflows.md`
