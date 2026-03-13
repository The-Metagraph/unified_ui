# DesktopUi POC Plan

This subject backfills the current proof-of-concept implementation plan for
`packages/desktop_ui`, based on the local planning notes that exist today.

```spec-meta
id: desktop_ui.poc_plan
kind: tooling
status: active
summary: Current proof-of-concept plan for `packages/desktop_ui`, including its three-phase delivery structure, pure-Elixir architecture-validation slice, SDL2 graphics bridge phase, and final layout or widget-completion phase.
surface:
  - packages/desktop_ui/notes/planning/poc/README.md
  - packages/desktop_ui/notes/planning/poc/phase-1-architecture-validation.md
  - packages/desktop_ui/notes/planning/poc/phase-2-graphics-bridge.md
  - packages/desktop_ui/notes/planning/poc/phase-3-first-real-widget.md
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: desktop_ui.poc_plan.phase_structure
  statement: 'The current POC plan shall remain organized as three sequential phases: architecture validation in pure Elixir, an SDL2 graphics bridge phase, and a first-real-widget phase that completes layout and interaction basics.'
  priority: must
  stability: stable

- id: desktop_ui.poc_plan.phase1_validation_scope
  statement: 'Phase 1 planning shall cover the current pure-Elixir validation slice for the Elm behaviour, widget-construction DSL, runtime loop, mock renderer, example counter component, and integration-test coverage.'
  priority: must
  stability: stable

- id: desktop_ui.poc_plan.phase2_and_phase3_scope
  statement: 'Phase 2 and Phase 3 planning shall cover the current SDL2 NIF or graphics API bridge, event polling, SDL2-backed renderer integration, layout calculation, hit testing, and the enhanced interactive counter demonstration.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/desktop_ui/notes/planning/poc/README.md
  covers:
    - desktop_ui.poc_plan.phase_structure

- kind: source_file
  target: packages/desktop_ui/notes/planning/poc/phase-1-architecture-validation.md
  covers:
    - desktop_ui.poc_plan.phase1_validation_scope

- kind: source_file
  target: packages/desktop_ui/notes/planning/poc/phase-2-graphics-bridge.md
  covers:
    - desktop_ui.poc_plan.phase2_and_phase3_scope

- kind: source_file
  target: packages/desktop_ui/notes/planning/poc/phase-3-first-real-widget.md
  covers:
    - desktop_ui.poc_plan.phase2_and_phase3_scope
```
