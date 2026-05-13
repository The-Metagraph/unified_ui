---
id: repo.ecosystem.widget_portability_from_ash_ui
status: accepted
date: 2026-05-13
affects:
  - ecosystem.dsl_iur_symbiosis
  - ecosystem.platform_runtimes
  - unified_ui.dsl
  - unified_ui.widgets
  - unified_iur.constructs
  - unified_iur.interactions
  - unified_iur.widgets
  - live_ui.native_widgets
  - elm_ui.native_widgets
  - desktop_ui.native_widgets
  - terminal_ui.native_widgets
---

# AshUi-Originated Widgets Belong in the Canonical Ecosystem Surface

## Context

AshUi has proposed several generally useful widgets and one repeated-list
composition primitive while integrating with downstream application needs.
Those proposals are useful signals from a real consumer, but AshUi is an Ash
Framework integration package rather than the canonical widget, DSL, IUR, or
runtime-library owner for the unified UI ecosystem.

If those widgets remain AshUi-only, downstream applications must either bypass
UnifiedUi or duplicate equivalent runtime widgets in several places. That would
weaken the ecosystem boundary already established by the DSL/IUR symbiosis and
platform-runtime contracts.

## Decision

1. Generally useful AshUi-originated widget proposals shall be promoted into
   the canonical UnifiedUi and UnifiedIUR contract when their meaning is not
   Ash-specific.
2. The initial promoted surface includes canonical equivalents for:
   `disclosure`, `kicker`, `avatar`, `presence_dot`,
   `segmented_button_group`, `list_item_multi_column`, `artifact_row`,
   `sticky_header`, `pipeline_stepper_horizontal`,
   `segmented_progress_bar`, `workflow_stage_list_vertical`, `meter_thin`,
   `slide_over_panel`, `event_callout`, `redline_inline`,
   `code_block_syntax_highlighted`, and `chat_composer`.
3. AshUi's `phoenix_form` proposal shall be represented canonically as a
   host-owned form shell rather than as a Phoenix- or AshPhoenix-specific
   construct. Runtime packages may map that shell onto their own host-owned
   form lifecycle.
4. AshUi's repeated relationship rendering proposal shall be represented
   canonically as repeated collection composition over list data and a child
   template, without importing Ash resource relationship semantics into
   UnifiedUi or UnifiedIUR.
5. UnifiedUi shall own the authored DSL surface for these canonical equivalents
   and shall compile them into UnifiedIUR.
6. UnifiedIUR shall preserve the widget and repeated-composition meaning in a
   renderer-independent form.
7. Runtime packages shall provide native equivalents and IUR rendering support
   for the promoted surface, using explicit medium-appropriate degradation
   where a runtime cannot realize the richer visual treatment directly.

## Consequences

- AshUi remains an integration consumer and can retire local copies once the
  canonical surface and relevant runtime implementations exist.
- Portable widget meaning is reviewed once at the canonical DSL/IUR boundary
  instead of being reinterpreted independently by every integration package.
- Phoenix-specific and style-specific proposal names may be mapped to portable
  canonical concepts when the exact downstream name would leak runtime or
  medium assumptions.
- Runtime packages still own their native widget APIs, local lifecycle, host
  form integration, and degradation behavior.
