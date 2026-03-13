---
id: repo.live_ui.ecosystem_alignment
status: accepted
date: 2026-03-13
affects:
  - live_ui.package
  - live_ui.interpreter
  - live_ui.rendering
  - live_ui.runtime
  - live_ui.transport
  - repo.governance.live_ui_contract
---

# LiveUi Package Specs Follow the Ecosystem Contract

## Context

The first `live_ui` package subjects were backfilled from the current codebase.
That made them broader than the ecosystem contract in several places, including
module-backed screen sources, package-local governance tooling, and a looser
input boundary than canonical `UnifiedIUR`. We want the authored `live_ui`
package specs to describe the intended ecosystem role of the library rather
than inventorying every currently shipped implementation detail.

## Decision

1. The authored subjects under `.spec/specs/live-ui/` are the normative
   ecosystem-aligned package contract for `live_ui`, not a code-derived backfill
   inventory.
2. The cross-package rendering boundary for `live_ui` is canonical
   `UnifiedIUR`. Optional local adapters, experiments, or convenience entrypoints
   do not expand the authored package contract unless the ecosystem contract is
   updated first.
3. `live_ui` remains an independent Phoenix LiveView widget library with its own
   native widget surface, but it consumes canonical `UnifiedIUR` rather than
   acting as an authored DSL boundary.
4. Canonical widget events for `live_ui` use Phoenix-channel transport with
   `Jido.Signal` values and CloudEvents-compatible semantics while preserving
   server-authoritative UI behavior.
5. JavaScript hooks are part of the runtime only where they are necessary to
   bridge canonical signals and local widget behavior.
6. Package-local governance or compliance tooling inside `packages/live_ui` is
   not part of the authored `live_ui` package contract unless it is explicitly
   adopted into the root ecosystem or governance layer.

## Consequences

- The previous code-derived `live_ui` backfill subjects are replaced with
  ecosystem-aligned target-state subjects.
- The `live_ui` package contract no longer treats module-backed sources,
  non-canonical extension inputs, or package-local governance tooling as part
  of the authored cross-package boundary.
- Future implementation work in `packages/live_ui` should converge on these
  authored subjects, with conformance added later as a separate layer.
