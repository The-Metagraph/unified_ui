# Canonical Widget Components Planning

This directory contains the phased implementation plan for the canonical
widget-component expansion derived from AshUi PRs 79 through 98.

## Originating AshUi PR Set

- PR 79: `inline_rich_text_heading`
- PR 80: `disclosure`
- PR 81: `phoenix_form`, represented canonically as a runtime-owned form shell
- PR 82: `kicker`
- PR 83: `avatar`
- PR 84: `presence_dot`
- PR 85: `segmented_button_group`
- PR 86: `list_item_multi_column`
- PR 87: `artifact_row`
- PR 88: `sticky_frosted_header`
- PR 89: `pipeline_stepper_horizontal`
- PR 90: `segmented_progress_bar`
- PR 91: `workflow_stage_list_vertical`
- PR 92: `meter_thin`
- PR 93: `slide_over_panel`
- PR 94: `event_callout`
- PR 95: `redline_inline`
- PR 96: `code_block_syntax_highlighted`
- PR 97: `chat_composer`
- PR 98: `ui_relationship repeat`, represented canonically as list-repeat composition behavior

## Phase Files

1. [Phase 1 - Canonical Catalog and UnifiedUi Authoring Surface](./phase-01-canonical-catalog-and-unified-ui-authoring-surface.md): define the portable catalog, canonical names, authored widget surface, and list-repeat DSL behavior.
2. [Phase 2 - UnifiedIUR Representation, Compiler, and Hydration Alignment](./phase-02-unified-iur-representation-compiler-and-hydration-alignment.md): represent the expanded catalog in UnifiedIUR and lower UnifiedUi declarations into deterministic canonical output.
3. [Phase 3 - LiveUi Native Components and IUR Renderer Alignment](./phase-03-live-ui-native-components-and-iur-renderer-alignment.md): implement the expanded catalog as LiveUi native widget components and map IUR input into the same components.
4. [Phase 4 - ElmUi, DesktopUi, and TerminalUi Runtime Parity](./phase-04-elm-ui-desktop-ui-and-terminal-ui-runtime-parity.md): add equivalent runtime support across the remaining runtime packages with explicit terminal degradation.
5. [Phase 5 - Examples, Documentation, Tooling, and Conformance](./phase-05-examples-documentation-tooling-and-conformance.md): add focused examples, guides, introspection, validation, traceability, and release-readiness checks.

## Numbering

- Phases: `N`
- Sections: `N.M`
- Tasks: `N.M.K`
- Subtasks: `N.M.K.L`

Every phase, section, task, and subtask uses Markdown checkboxes. Every phase,
section, and task starts with a short description paragraph. Each phase ends
with an integration-testing section. Sections are intended to be practical
commit units during implementation unless a package-local change needs a
smaller commit boundary.
