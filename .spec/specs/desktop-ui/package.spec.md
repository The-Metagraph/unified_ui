# DesktopUi Package

This subject backfills the current package-level contract for
`packages/desktop_ui` from the code and package docs that exist today.

```spec-meta
id: desktop_ui.package
kind: package
status: active
summary: Current codebase-derived contract for the `packages/desktop_ui` library, including its Mix scaffold, placeholder public module, and explicitly documented research-phase status.
surface:
  - packages/desktop_ui/mix.exs
  - packages/desktop_ui/README.md
  - packages/desktop_ui/lib/desktop_ui.ex
  - packages/desktop_ui/test/desktop_ui_test.exs
  - packages/desktop_ui/CLAUDE.md
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: desktop_ui.package.mix_scaffold
  statement: '`packages/desktop_ui` shall currently remain a minimal Mix project published as `:desktop_ui`, targeting Elixir `~> 1.18`, starting only `:logger`, and declaring no active package dependencies.'
  priority: must
  stability: stable

- id: desktop_ui.package.placeholder_module
  statement: 'The current public code surface shall remain the placeholder `DesktopUi` module that exposes `hello/0` returning `:world`, with matching doctest and unit-test coverage.'
  priority: must
  stability: stable

- id: desktop_ui.package.research_phase_status
  statement: 'The package documentation shall state that `desktop_ui` is still in an early research or prototype phase, with the runtime, graphics bridge, and widget system planned but not yet implemented in the shipped code.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/desktop_ui/mix.exs
  covers:
    - desktop_ui.package.mix_scaffold

- kind: source_file
  target: packages/desktop_ui/README.md
  covers:
    - desktop_ui.package.mix_scaffold

- kind: source_file
  target: packages/desktop_ui/lib/desktop_ui.ex
  covers:
    - desktop_ui.package.placeholder_module

- kind: source_file
  target: packages/desktop_ui/test/desktop_ui_test.exs
  covers:
    - desktop_ui.package.placeholder_module

- kind: source_file
  target: packages/desktop_ui/CLAUDE.md
  covers:
    - desktop_ui.package.research_phase_status
```
