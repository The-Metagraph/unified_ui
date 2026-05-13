# AshUi Widget Portability Implementation Plan Index

This directory contains a phased implementation plan for promoting the
AshUi-originated widget and repeated-collection concepts into the canonical
UnifiedUi, UnifiedIUR, and runtime package surfaces.

The plan aligns to:
- [AshUi-Originated Widget Portability ADR](../../decisions/architecture/repo.ecosystem.widget_portability_from_ash_ui.md)
- [DSL and IUR Symbiosis](../../specs/dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](../../specs/platform_runtimes.spec.md)
- [UnifiedUi DSL](../../specs/unified-ui/dsl.spec.md)
- [UnifiedUi Widgets](../../specs/unified-ui/widgets.spec.md)
- [UnifiedIUR Widgets](../../specs/unified-iur/widgets.spec.md)
- [UnifiedIUR Constructs](../../specs/unified-iur/constructs.spec.md)
- [UnifiedIUR Interactions](../../specs/unified-iur/interactions.spec.md)
- [LiveUi Native Widgets](../../specs/live_ui/native_widgets.spec.md)
- [ElmUi Native Widgets](../../specs/elm_ui/native_widgets.spec.md)
- [DesktopUi Native Widgets](../../specs/desktop_ui/native_widgets.spec.md)
- [TerminalUi Native Widgets](../../specs/terminal_ui/native_widgets.spec.md)

## Phase Files
1. [Phase 1 - Canonical Widget Taxonomy and UnifiedUi Authoring Surface](./phase-01-canonical-widget-taxonomy-and-unified-ui-authoring-surface.md): define canonical widget names, authored DSL declarations, host-owned form shell semantics, and repeated collection authoring.
2. [Phase 2 - UnifiedIUR Model and Compiler Lowering](./phase-02-unified-iur-model-and-compiler-lowering.md): implement renderer-independent widget and repeated-composition representations, compiler lowering, row-scope bindings, fixtures, and validation.
3. [Phase 3 - LiveUi and ElmUi Runtime Equivalents](./phase-03-live-ui-and-elm-ui-runtime-equivalents.md): implement web-runtime native equivalents and IUR rendering support for the promoted widgets and repeated collection model.
4. [Phase 4 - DesktopUi and TerminalUi Runtime Equivalents](./phase-04-desktop-ui-and-terminal-ui-runtime-equivalents.md): implement desktop and terminal equivalents with explicit capability-aware degradation where needed.
5. [Phase 5 - Examples, Tooling, Documentation, and Conformance](./phase-05-examples-tooling-documentation-and-conformance.md): finish the rollout with examples, inspection and validation tooling, documentation, traceability, and conformance evidence.

## Shared Conventions
- Numbering:
  - Phases: `N`
  - Sections: `N.M`
  - Tasks: `N.M.K`
  - Subtasks: `N.M.K.L`
- Tracking:
  - Every phase, section, task, and subtask uses Markdown checkboxes (`[ ]`).
- Description requirement:
  - Every phase, section, and task starts with a short description paragraph.
- Integration-test requirement:
  - Each phase ends with a final integration-testing section.

## Shared Assumptions and Defaults
- AshUi is treated as the originating consumer signal, not as the canonical
  owner of the promoted surface.
- Canonical widget names may differ from the exact AshUi proposal names when
  the original name leaks Phoenix, Ash, or medium-specific assumptions.
- `phoenix_form` maps to a portable host-owned form shell concept rather than
  to a Phoenix-specific canonical widget.
- Relationship-repeat authoring maps to repeated collection composition over
  list-oriented data and a child template rather than to Ash resource
  relationship semantics.
- `unified_ui` owns the authored DSL surface and validation; `unified_iur`
  owns the canonical renderer-independent interchange representation.
- Runtime packages own native widget APIs, local lifecycle, host form
  integration, renderer details, and medium-appropriate degradation.
- Runtimes should preserve canonical interaction and row-scope binding meaning
  even when the visual rendering necessarily differs by medium.
