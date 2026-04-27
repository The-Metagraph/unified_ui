---
id: live_ui.tooling.focused_example_alignment
status: accepted
date: 2026-04-26
affects:
  - live_ui.package
  - live_ui.tooling
---

# Focused Example Alignment for LiveUi

## Context

The repository now treats the root `examples/` directory as the authoritative
widget-focused example suite. Each example is a standalone application with one
clear widget or construct focus, one repeatable review workflow, and one shared
runtime-target story across `live_ui`, `desktop_ui`, `elm_ui`, and
`terminal_ui`.

`live_ui` still carries a different maintainer surface:

- a package-local demo workbench
- a small package-owned maintained example catalog organized as native,
  canonical, and mixed lanes
- a widget preview inventory whose ids and coverage do not match the
  repository example inventory one-for-one

That creates three kinds of drift:

1. **Inventory Drift** - maintainers have to reason about a repository example
   inventory and a separate `live_ui` package inventory with different ids and
   coverage rules.
2. **Workflow Drift** - the root suite has moved toward focused standalone app
   review, while `live_ui` still centers a package-local demo/workbench and
   comparison-oriented package examples.
3. **Meaning Drift** - package examples can become abstractions about
   categories, continuity lanes, or demo states instead of concrete widget
   examples that match what the ecosystem already exposes publicly.

The package still needs strong maintainer review for native rendering,
canonical rendering, transport behavior, and runtime authority. The question is
what example surface should carry that burden.

## Decision

`live_ui` shall retire its current package-local demo/workbench and divergent
package-owned example catalog in favor of the same focused example inventory
used by the repository example suite, specialized for direct native `live_ui`
widgets and runtime entrypoints.

1. **One Focused Inventory** - The package shall align its maintained example
   identities one-for-one with the repository widget-focused example inventory
   instead of keeping a second package-specific catalog with unrelated names.
2. **Native Package Specialization** - Each aligned `live_ui` example shall use
   the package's own native widgets and runtime entrypoints directly rather than
   re-authoring the package example surface through `unified_ui`.
3. **No Aggregate Demo Workbench** - The package shall not keep a package-local
   demo/workbench as the primary review entry point once the aligned focused
   examples exist.
4. **Canonical Review on the Same Ids** - When package validation still needs
   canonical `UnifiedIUR` rendering, transport inspection, or continuity
   comparison, those workflows shall attach to the same focused example ids
   rather than introducing separate example families or demo-only artifacts.
5. **Package Tooling Follows the Inventory** - `mix live_ui.preview`,
   `mix live_ui.inspect`, `mix live_ui.export`, and `mix live_ui.validate`
   shall operate on the aligned focused example inventory and its package
   specializations.
6. **Repository Examples Stay Authoritative** - The repository `examples/`
   inventory remains the authoritative cross-runtime example catalog; `live_ui`
   specializes that inventory for native runtime review rather than replacing
   or forking it.

## Consequences

- Maintainers review the same widget-focused example identities across the root
  suite and the `live_ui` package.
- The package loses a separate demo/workbench concept and the extra cognitive
  layer that goes with it.
- Example coverage gaps become easier to spot because missing package examples
  map directly to missing repository example ids.
- Native `live_ui` review becomes more concrete because examples are anchored to
  real widget-focused application stories instead of category-level demo lanes.
- Canonical rendering and transport diagnostics still remain available, but
  they become inspection modes on the same example ids rather than a separate
  maintained example taxonomy.
