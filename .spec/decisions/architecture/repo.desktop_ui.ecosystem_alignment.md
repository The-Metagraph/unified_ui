---
id: repo.desktop_ui.ecosystem_alignment
status: accepted
date: 2026-03-13
affects:
  - desktop_ui.package
  - desktop_ui.architecture
  - desktop_ui.runtime
  - desktop_ui.transport
  - repo.governance.desktop_ui_contract
---

# DesktopUi Package Specs Follow the Ecosystem Contract

## Context

The first `desktop_ui` package subjects were backfilled from the current
scaffold, research notes, and proof-of-concept planning documents. That made
them narrower in implementation depth but broader in planning detail than the
ecosystem contract. We want the authored `desktop_ui` package specs to describe
the intended ecosystem role of the library rather than inventorying the current
prototype state or local planning backlog.

## Decision

1. The authored subjects under `.spec/specs/desktop-ui/` are the normative
   ecosystem-aligned package contract for `desktop_ui`, not a code-derived
   scaffold inventory or planning backfill.
2. `desktop_ui` remains an independent desktop widget library that consumes
   canonical `UnifiedIUR` rather than acting as an authored DSL boundary.
3. `desktop_ui` targets Windows, macOS, and Linux through an SDL2-based desktop
   runtime with its own native widget system.
4. Canonical widget events for `desktop_ui` use `Jido.Signal` values and
   CloudEvents-compatible semantics both when events cross package boundaries
   and inside the desktop runtime itself.
5. Native platform input is normalized into the canonical signal model before
   events cross package boundaries.
6. Package-local scaffold details, research notes, or proof-of-concept plans
   inside `packages/desktop_ui` are not part of the authored `desktop_ui`
   package contract unless they are explicitly adopted into the root ecosystem
   or governance layer.

## Consequences

- The previous code-derived and planning-derived `desktop_ui` backfill subjects
  are replaced with ecosystem-aligned target-state subjects.
- The `desktop_ui` package contract no longer treats current scaffold shape or
  local POC plans as part of the authored cross-package boundary.
- Future implementation work in `packages/desktop_ui` should converge on these
  authored subjects, with conformance added later as a separate layer.
