# DesktopUi

`desktop_ui` is the desktop-target runtime library for the unified ecosystem.
It supports both direct-native desktop screens and canonical `UnifiedIUR`
rendering through one shared SDL3-oriented runtime boundary.

## Main Surfaces

- `DesktopUi.Widgets` exposes the direct-native widget surface.
- `DesktopUi.Runtime` defines the shared desktop runtime boundary used by both
  native and canonical entry paths.
- `DesktopUi.Platform` and `DesktopUi.Artifacts` expose bounded target
  variation and explicit platform packaging workflows.
- `DesktopUi.Renderer` defines the canonical renderer entrypoint.
- `DesktopUi.Transport` defines normalized local input and canonical boundary
  translation.
- `DesktopUi.Style`, `DesktopUi.Theme`, `DesktopUi.Inspection`, and
  `DesktopUi.Continuity` expose style realization and review surfaces.
- `DesktopUi.Examples`, `DesktopUi.Inspect`, `DesktopUi.Validate`,
  `DesktopUi.Reference`, and `DesktopUi.Info` provide the maintained example,
  inspection, validation, and summary helpers maintainers use day to day.

## Shared Runtime Model

`desktop_ui` does not own the authored DSL or canonical IUR definitions.
Instead, it consumes canonical `UnifiedIUR`, realizes that meaning through
native desktop widgets, and translates cross-package event meaning at the
desktop runtime boundary.

Both entry paths stay inside one package:

- direct-native `DesktopUi.Widgets` screens mount through `DesktopUi.Runtime`
- canonical `UnifiedIUR` trees render through `DesktopUi.Renderer` and then
  mount through the same `DesktopUi.Runtime`
- style resolution, platform integration, artifact policy, transport
  translation, and continuity diagnostics stay shared across both paths

## Platform And Artifact Policy

`desktop_ui` treats Windows, macOS, and Linux as first-class targets, but keeps
their differences explicitly bounded:

- platform modules may vary in window chrome, menu shape, shortcut scope, and
  notification style
- shared runtime, widget, renderer, style, and transport semantics must remain
  common
- build and packaging workflows are explicit in `DesktopUi.Artifacts` and do
  not redefine runtime behavior

## Maintained Example Workflows

The package ships paired maintained examples for:

- foundational desktop flows
- advanced layered and multiwindow flows
- transport and normalized-input review
- styled review and style continuity

Use the example helpers directly:

- `DesktopUi.Examples.catalog/0`
- `DesktopUi.Examples.metadata/1`
- `DesktopUi.Examples.coverage_matrix/0`
- `DesktopUi.Reference.example_summary/0`

## Maintainer Workflow

Package-local checks:

- `mix deps.get`
- `mix compile`
- `mix test`
- `mix desktop_ui.inspect --format catalog`
- `mix desktop_ui.inspect native_styled_review --format diagnostics`
- `mix desktop_ui.run --format catalog`
- `mix desktop_ui.run native_foundational --format summary`
- `mix desktop_ui.validate`
- `mix desktop_ui.validate --format report`
- `mix desktop_ui.validate --strict`

Workspace checks:

- `mix spec.plancheck desktop_ui`
- `mix spec.traceability.generate desktop_ui`

## Host-Backed Execution Notes

The current SDL3 execution path runs through a host-backed Elixir process that
exercises the SDL3 adapter contract, frame protocol, resource requests, and
event round-trips.

- no external SDL3 installation is required for the current placeholder-backed
  host workflow
- `mix desktop_ui.run` is the maintainer entrypoint for exercising the
  executable host boundary
- text and image resource requests, host diagnostics, and event round-trips
  are visible through the run and inspect surfaces
- actual native SDL3 drawing remains intentionally bounded and placeholder-led
  until a later phase replaces the host skeleton with concrete SDL3 runtime
  integration

## Guides

- [Runtime Backbone](guides/runtime_backbone.md)
- [Native Runtime And Examples](guides/native_runtime_and_examples.md)
- [Canonical Rendering And Transport](guides/canonical_rendering_and_transport.md)
- [Styling, Platforms, And Artifacts](guides/styling_platforms_and_artifacts.md)
- [Maintainer Workflows](guides/maintainer_workflows.md)

## Release Readiness

Treat these as the normal release-readiness loop:

- `mix desktop_ui.validate --strict`
- `mix spec.traceability.generate desktop_ui`
- `mix spec.plancheck desktop_ui`

That loop keeps example coverage, shared runtime behavior, transport
translation, documentation, traceability, and artifact policy aligned before
the package evolves further.

`desktop_ui` does not own authored `UnifiedUi` contracts or canonical
`UnifiedIUR` definitions. When those upstream contracts change, the expected
follow-up here is to update `desktop_ui` planning, renderer/runtime behavior,
docs, and validation together rather than letting the runtime drift.
