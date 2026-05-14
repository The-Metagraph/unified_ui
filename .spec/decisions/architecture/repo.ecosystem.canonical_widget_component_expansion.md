---
id: repo.ecosystem.canonical_widget_component_expansion
status: accepted
date: 2026-05-14
affects:
  - ecosystem.widget_component_behavior
  - unified_ui.widgets
  - unified_ui.widget_components
  - unified_iur.widgets
  - unified_iur.widget_components
  - live_ui.native_widgets
  - live_ui.iur_renderer
  - elm_ui.native_widgets
  - elm_ui.iur_renderer
  - desktop_ui.native_widgets
  - desktop_ui.iur_renderer
  - terminal_ui.native_widgets
  - terminal_ui.iur_renderer
---

# AshUi Widget Additions Become Canonical Widget Components

## Context

AshUi PRs 79 through 98 introduced a focused batch of reusable UI primitives
and one list-composition behavior. The batch covers editorial content, identity,
status, progress, forms, list rows, overlays, code and redline display, chat
composition, and row-repeat composition:

- `inline_rich_text_heading`
- `disclosure`
- `phoenix_form`
- `kicker`
- `avatar`
- `presence_dot`
- `segmented_button_group`
- `list_item_multi_column`
- `artifact_row`
- `sticky_frosted_header`
- `pipeline_stepper_horizontal`
- `segmented_progress_bar`
- `workflow_stage_list_vertical`
- `meter_thin`
- `slide_over_panel`
- `event_callout`
- `redline_inline`
- `code_block_syntax_highlighted`
- `chat_composer`
- `ui_relationship repeat`

Those additions were authored for AshUi, but their meaning is not specific to
AshUi. They are common application, document-workflow, and operational UI
patterns that belong in the UnifiedUi ecosystem as canonical authored widgets,
canonical IUR constructs, and native runtime components.

The ecosystem must avoid importing AshUi implementation details directly. In
particular, names and behaviors that are host-specific in AshUi, such as
`phoenix_form`, need portable canonical meaning in UnifiedUi and UnifiedIUR
while still allowing LiveUi to provide the Phoenix-specific realization.

## Decision

1. The AshUi PR 79-98 widget batch is adopted as a canonical widget-component
   expansion for the UnifiedUi ecosystem.
2. UnifiedUi shall expose authored equivalents for the batch through canonical
   DSL widgets and composition behavior rather than as AshUi compatibility
   shims.
3. UnifiedIUR shall represent the same widget-component meanings as canonical
   renderer-independent data.
4. Runtime packages shall provide native component equivalents and IUR renderer
   mappings for the expanded catalog while preserving their native runtime
   ownership.
5. Host-specific AshUi names may be accepted as aliases where useful, but the
   canonical contract shall use portable names when the AshUi name leaks a host
   runtime. The `phoenix_form` meaning becomes a runtime-owned form shell in the
   canonical contract; LiveUi may realize it through Phoenix and AshPhoenix
   form integration.
6. `ui_relationship repeat` becomes a canonical list-repeat composition
   behavior rather than a renderer-only widget. UnifiedUi authors the repeat
   relationship, UnifiedIUR preserves repeat metadata or expanded children, and
   renderers consume deterministic concrete child nodes.
7. Content safety, accessibility, and interaction meaning are part of the
   canonical contract. Pre-tokenized code and redline text remain plain-text
   inputs to be escaped by renderers, and selection, submit, change, send,
   row-activation, step-navigation, disclosure, and panel-state behavior remain
   canonical interaction descriptors.

## Consequences

- The ecosystem gains one portable widget-component catalog instead of leaving
  these primitives stranded in an AshUi-specific contribution.
- UnifiedUi and UnifiedIUR must move together for every adopted widget and for
  list-repeat composition behavior.
- LiveUi, ElmUi, DesktopUi, and TerminalUi each remain native widget libraries,
  but they need parity plans for this expanded catalog.
- TerminalUi may degrade visual affordances such as frost, slide motion,
  multi-column layout, and syntax color while preserving readable structure,
  state, and interaction meaning.
- The implementation plan should phase the work by canonical contracts first,
  then IUR/compiler behavior, then runtime component parity, and finally
  examples, documentation, tooling, and conformance.
