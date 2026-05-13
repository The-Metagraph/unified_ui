# UnifiedUi Widgets

This subject defines the canonical authored surface categories that the
`unified_ui` package must expose and keep aligned with canonical IUR.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [UnifiedUi Package](./package.spec.md)
- [UnifiedUi DSL](./dsl.spec.md)
- [UnifiedUi Compiler](./compiler.spec.md)

```spec-meta
id: unified_ui.widgets
kind: subsystem
status: active
summary: Target canonical widget, layout, layer, style, and theme authoring surface for `unified_ui`.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/widgets.spec.md
  - .spec/specs/unified-iur/widgets.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.widget_portability_from_ash_ui
```

## Requirements

```spec-requirements
- id: unified_ui.widgets.foundational_visual_surface
  statement: The package shall author foundational visual elements such as text-bearing, image-bearing, icon-bearing, button-like, link-like, badge-like, hero-like, separator, spacer, and content container widgets as part of the canonical DSL surface.
  priority: must
  stability: stable

- id: unified_ui.widgets.input_surface
  statement: The package shall author canonical input and navigation controls including `text_input`, `menu`, `context_menu`, `command_palette`, `tabs`, `form_builder`, and `form_field`, while remaining extensible to additional canonical controls such as toggles, selects, sliders, and other form primitives.
  priority: must
  stability: stable

- id: unified_ui.widgets.layout_and_layer_surface
  statement: The package shall author canonical row, column, grid, stack, split, scroll, viewport, overlay, and layer-oriented composition primitives needed to express hierarchy and z-order, including `split_pane`, `viewport`, overlay-backed dialog constructs, and canvas-oriented composition support.
  priority: must
  stability: stable

- id: unified_ui.widgets.feedback_navigation_data_surface
  statement: The package shall author canonical navigation, feedback, and data-display constructs including `dialog`, `alert_dialog`, `toast`, `table`, `tree_view`, `stat`, `key_value`, `info_list`, `markdown_viewer`, `log_viewer`, `scroll_bar`, `gauge`, `sparkline`, `bar_chart`, `line_chart`, `stream_widget`, `process_monitor`, `supervision_tree_viewer`, and `cluster_dashboard`.
  priority: must
  stability: stable

- id: unified_ui.widgets.portable_semantic_micro_widgets
  statement: The package shall author portable semantic and micro-interaction widgets equivalent to AshUi-originated `disclosure`, `kicker`, `avatar`, `presence_dot`, `segmented_button_group`, `list_item_multi_column`, `artifact_row`, `sticky_header`, and host-owned form shell concepts without making AshUi or a specific renderer the canonical owner of those widgets.
  priority: must
  stability: stable

- id: unified_ui.widgets.portable_workflow_document_widgets
  statement: The package shall author portable workflow, document, and composer widgets equivalent to AshUi-originated `pipeline_stepper_horizontal`, `segmented_progress_bar`, `workflow_stage_list_vertical`, `meter_thin`, `slide_over_panel`, `event_callout`, `redline_inline`, `code_block_syntax_highlighted`, and `chat_composer` concepts as canonical DSL widgets.
  priority: must
  stability: stable

- id: unified_ui.widgets.style_attribute_surface
  statement: The package shall author canonical styling attributes for typography, color, spacing, sizing, alignment, borders, background treatment, visibility, state variants, and theme-driven design tokens.
  priority: must
  stability: stable

- id: unified_ui.widgets.canvas_surface
  statement: The package shall author a canonical `canvas` widget or equivalent drawing construct for direct visual composition beyond standard layout-driven widgets.
  priority: must
  stability: stable

- id: unified_ui.widgets.iur_surface_parity
  statement: Every canonical widget, layout, layering construct, styling attribute, and theme-level authored concept exposed by the package shall have a corresponding canonical IUR representation and shall not be package-local only.
  priority: must
  stability: stable

- id: unified_ui.widgets.repeated_collection_composition
  statement: The package shall author repeated collection composition that renders a child widget or layout template once per item in a list-oriented data binding while keeping row-scope data access renderer-independent and free of Ash resource relationship semantics.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.widgets.author_modal_flow
  covers:
    - unified_ui.widgets.foundational_visual_surface
    - unified_ui.widgets.input_surface
    - unified_ui.widgets.layout_and_layer_surface
    - unified_ui.widgets.feedback_navigation_data_surface
    - unified_ui.widgets.portable_semantic_micro_widgets
    - unified_ui.widgets.portable_workflow_document_widgets
    - unified_ui.widgets.style_attribute_surface
    - unified_ui.widgets.canvas_surface
    - unified_ui.widgets.iur_surface_parity
    - unified_ui.widgets.repeated_collection_composition
  given:
    - A developer needs a modal interaction flow with layered content, form inputs, button actions, and theme-aware styling
  when:
    - The flow is authored in `unified_ui`
  then:
    - The package provides canonical widgets, layer declarations, and styling declarations for the full flow without requiring runtime-library widgets

- id: unified_ui.widgets.author_data_experience
  covers:
    - unified_ui.widgets.foundational_visual_surface
    - unified_ui.widgets.input_surface
    - unified_ui.widgets.layout_and_layer_surface
    - unified_ui.widgets.feedback_navigation_data_surface
    - unified_ui.widgets.portable_semantic_micro_widgets
    - unified_ui.widgets.portable_workflow_document_widgets
    - unified_ui.widgets.style_attribute_surface
    - unified_ui.widgets.canvas_surface
    - unified_ui.widgets.iur_surface_parity
    - unified_ui.widgets.repeated_collection_composition
  given:
    - A developer needs to author a dashboard or data-heavy screen
  when:
    - The developer combines tables, lists, charts, progress or status widgets, and navigation elements
  then:
    - The package provides canonical authored constructs for the full experience as one coherent DSL surface
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-ui/widgets.spec.md
  covers:
    - unified_ui.widgets.foundational_visual_surface
    - unified_ui.widgets.input_surface
    - unified_ui.widgets.layout_and_layer_surface
    - unified_ui.widgets.feedback_navigation_data_surface
    - unified_ui.widgets.portable_semantic_micro_widgets
    - unified_ui.widgets.portable_workflow_document_widgets
    - unified_ui.widgets.style_attribute_surface
    - unified_ui.widgets.canvas_surface
    - unified_ui.widgets.iur_surface_parity
    - unified_ui.widgets.repeated_collection_composition
```
