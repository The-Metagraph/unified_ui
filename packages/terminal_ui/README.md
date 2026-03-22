# TerminalUi

`terminal_ui` is the terminal-target runtime library for the unified
ecosystem. It is intended to support both direct-native terminal screens and
canonical `UnifiedIUR` rendering through the same `term_ui`-backed runtime
boundary.

## Main Surfaces

- `TerminalUi.Widgets` exposes the direct-native widget surface.
- `TerminalUi.Runtime` defines the shared terminal runtime boundary.
- `TerminalUi.Backend` and `TerminalUi.Capabilities` expose backend selection
  and capability seams.
- `TerminalUi.Renderer` defines the canonical renderer entrypoint that later
  phases will expand.
- `TerminalUi.Transport`, `TerminalUi.Tooling`, `TerminalUi.Reference`, and
  `TerminalUi.Info` provide package boundaries for transport, maintainer
  workflows, and package introspection.

## Maintainer Workflow

Package-local checks:

- `mix deps.get`
- `mix compile`
- `mix test`
- `mix docs`

Workspace checks:

- `mix spec.plancheck terminal_ui`

## Guides

- `guides/runtime_backbone.md`
- `guides/maintainer_workflows.md`
