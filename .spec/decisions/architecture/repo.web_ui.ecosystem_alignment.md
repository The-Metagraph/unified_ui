---
id: repo.web_ui.ecosystem_alignment
status: accepted
date: 2026-03-13
affects:
  - web_ui.package
  - web_ui.iur
  - web_ui.widget_system
  - web_ui.server_runtime
  - web_ui.frontend_runtime
  - web_ui.transport
  - repo.governance.web_ui_contract
---

# WebUi Package Specs Follow the Ecosystem Contract

## Context

The first `web_ui` package subjects were backfilled from the current codebase.
That made them broader than the ecosystem contract in several places,
especially around package-local tooling, persistence, observability, and other
implementation details that are not part of the intended cross-package
boundary. We want the authored `web_ui` package specs to describe the intended
ecosystem role of the library rather than inventorying every currently shipped
subsystem.

## Decision

1. The authored subjects under `.spec/specs/web-ui/` are the normative
   ecosystem-aligned package contract for `web_ui`, not a code-derived backfill
   inventory.
2. The cross-package rendering boundary for `web_ui` is canonical `UnifiedIUR`.
   Optional local adapters, implementation details, or package workflows do not
   expand the authored package contract unless the ecosystem contract is updated
   first.
3. `web_ui` remains an independent widget library with its own native widget
   system, using Phoenix for server-side runtime representation and Elm for
   client-side rendering and local state.
4. Canonical widget events for `web_ui` bridge between Phoenix and Elm through
   CloudEvents-shaped envelopes and canonical `Jido.Signal` semantics while
   preserving canonical event meaning across the boundary.
5. Renderer-local frontend state may exist, but it remains subordinate to the
   canonical IUR and signal contract rather than redefining cross-package UI
   meaning.
6. Package-local tooling, observability, persistence, or release automation
   inside `packages/web_ui` is not part of the authored `web_ui` package
   contract unless it is explicitly adopted into the root ecosystem or
   governance layer.

## Consequences

- The previous code-derived `web_ui` backfill subjects are replaced with
  ecosystem-aligned target-state subjects.
- The `web_ui` package contract no longer treats package-local tooling,
  observability, persistence, or other implementation-specific subsystems as
  part of the authored cross-package boundary.
- Future implementation work in `packages/web_ui` should converge on these
  authored subjects, with conformance added later as a separate layer.
