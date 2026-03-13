# DesktopUi Architecture

This subject backfills the current documented architecture for
`packages/desktop_ui`, based on the local research notes and project guidance
that exist today.

```spec-meta
id: desktop_ui.architecture
kind: subsystem
status: active
summary: Current documentation-level architecture for `packages/desktop_ui`, including its cross-platform desktop positioning, layered Elm-style runtime model, SDL2 graphics bridge strategy, and planned Jido-oriented evolution.
surface:
  - packages/desktop_ui/CLAUDE.md
  - packages/desktop_ui/notes/research/1.01-foundation/1.01.1-original-concept.md
  - packages/desktop_ui/notes/research/1.01-foundation/1.01.2-architecture.md
  - packages/desktop_ui/notes/research/1.01-foundation/1.01.3-graphics-engine.md
  - packages/desktop_ui/notes/research/1.01-foundation/1.01.4-component-architecture.md
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: desktop_ui.architecture.framework_positioning
  statement: 'The current research set shall position DesktopUI as an Elixir-based cross-platform desktop UI framework that follows Elm-style state management and pursues direct desktop graphics rather than wrapping an existing GUI toolkit.'
  priority: must
  stability: stable

- id: desktop_ui.architecture.layered_runtime_model
  statement: 'The documented architecture shall define the current layered runtime model with a `DesktopUI.Elm` behaviour, a central runtime process, declarative widget trees, a rendering and layout layer, and a `DesktopUI.Graphics` bridge over SDL2-backed native functions.'
  priority: must
  stability: stable

- id: desktop_ui.architecture.future_jido_evolution
  statement: 'The current design docs shall describe Jido integration as a planned future evolution for agent-based components, signal-driven communication, and structured side-effect execution rather than as implemented package behavior today.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/desktop_ui/CLAUDE.md
  covers:
    - desktop_ui.architecture.framework_positioning
    - desktop_ui.architecture.layered_runtime_model
    - desktop_ui.architecture.future_jido_evolution

- kind: source_file
  target: packages/desktop_ui/notes/research/1.01-foundation/1.01.1-original-concept.md
  covers:
    - desktop_ui.architecture.framework_positioning
    - desktop_ui.architecture.layered_runtime_model

- kind: source_file
  target: packages/desktop_ui/notes/research/1.01-foundation/1.01.2-architecture.md
  covers:
    - desktop_ui.architecture.layered_runtime_model

- kind: source_file
  target: packages/desktop_ui/notes/research/1.01-foundation/1.01.3-graphics-engine.md
  covers:
    - desktop_ui.architecture.layered_runtime_model

- kind: source_file
  target: packages/desktop_ui/notes/research/1.01-foundation/1.01.4-component-architecture.md
  covers:
    - desktop_ui.architecture.future_jido_evolution
```
