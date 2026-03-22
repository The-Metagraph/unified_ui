# Maintainer Workflows

`terminal_ui` treats runtime scaffolding, capability seams, and package
reference surfaces as release-shaping work from the beginning.

## Package Commands

- `mix deps.get`
- `mix compile`
- `mix test`
- `mix docs`

## Workspace Commands

- `mix spec.plancheck terminal_ui`

## Helper Modules

- `TerminalUi.Reference`
  - inspect the package-facing capability and module surface
- `TerminalUi.Info`
  - inspect the lightweight package summary
- `TerminalUi.Tooling`
  - inspect current package workflows and docs surfaces
