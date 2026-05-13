# Unified IUR Widget Catalog

This subject defines the canonical widget families that `unified_iur` shall be able to represent for ecosystem interchange.

## Related General Specs

- [Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)

```spec-meta
id: unified_iur.widgets
kind: capability
status: proposed
summary: Canonical widget families representable in `unified_iur`.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/widgets.spec.md
  - .spec/specs/unified-ui/widgets.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.widget_portability_from_ash_ui
```

## Requirements

```spec-requirements
- id: unified_iur.widgets.input_and_navigation
  statement: `unified_iur` shall be able to represent `text_input`, `menu`, `context_menu`, `command_palette`, `tabs`, and `form_builder` as canonical interchange widgets.
  priority: must
  stability: stable

- id: unified_iur.widgets.overlay_and_feedback
  statement: `unified_iur` shall be able to represent `dialog`, `alert_dialog`, and `toast` as canonical interchange widgets with enough structure to preserve overlay semantics.
  priority: must
  stability: stable

- id: unified_iur.widgets.data_and_document_views
  statement: `unified_iur` shall be able to represent `table`, `tree_view`, `stat`, `key_value`, `info_list`, `markdown_viewer`, `log_viewer`, `viewport`, `split_pane`, and `scroll_bar` as canonical interchange widgets or display nodes.
  priority: must
  stability: stable

- id: unified_iur.widgets.semantic_surface
  statement: `unified_iur` shall be able to represent `badge`, `hero`, and `form_field` as canonical semantic display or form constructs without reducing them to generic text, container, or field placeholders.
  priority: must
  stability: stable

- id: unified_iur.widgets.portable_semantic_micro_widgets
  statement: `unified_iur` shall be able to represent portable semantic and micro-interaction widgets equivalent to AshUi-originated `disclosure`, `kicker`, `avatar`, `presence_dot`, `segmented_button_group`, `list_item_multi_column`, `artifact_row`, `sticky_header`, and host-owned form shell concepts.
  priority: must
  stability: stable

- id: unified_iur.widgets.visualization
  statement: `unified_iur` shall be able to represent `gauge`, `sparkline`, `bar_chart`, `line_chart`, and `canvas` as canonical interchange widgets or drawing surfaces.
  priority: must
  stability: stable

- id: unified_iur.widgets.workflow_document_widgets
  statement: `unified_iur` shall be able to represent portable workflow, document, and composer widgets equivalent to AshUi-originated `pipeline_stepper_horizontal`, `segmented_progress_bar`, `workflow_stage_list_vertical`, `meter_thin`, `slide_over_panel`, `event_callout`, `redline_inline`, `code_block_syntax_highlighted`, and `chat_composer` concepts.
  priority: must
  stability: stable

- id: unified_iur.widgets.operational_views
  statement: `unified_iur` shall be able to represent `stream_widget`, `process_monitor`, `supervision_tree_viewer`, and `cluster_dashboard` as canonical interchange widgets for operational or diagnostic rendering.
  priority: must
  stability: evolving

- id: unified_iur.widgets.widget_semantics_preserved
  statement: Each canonical `unified_iur` widget representation shall preserve the content model, local interaction semantics, child composition semantics, and styling hooks required for renderer parity.
  priority: must
  stability: stable

- id: unified_iur.widgets.no_integration_package_widget_escape_hatches
  statement: Widgets promoted from AshUi or another integration package shall be represented as canonical `unified_iur` widgets or constructs rather than as opaque integration-package escape hatches.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-iur/widgets.spec.md
  covers:
    - unified_iur.widgets.input_and_navigation
    - unified_iur.widgets.overlay_and_feedback
    - unified_iur.widgets.data_and_document_views
    - unified_iur.widgets.semantic_surface
    - unified_iur.widgets.portable_semantic_micro_widgets
    - unified_iur.widgets.visualization
    - unified_iur.widgets.workflow_document_widgets
    - unified_iur.widgets.operational_views
    - unified_iur.widgets.widget_semantics_preserved
    - unified_iur.widgets.no_integration_package_widget_escape_hatches
```
