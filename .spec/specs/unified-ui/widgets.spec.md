# UnifiedUi Widgets

This subject defines the canonical authored surface categories that the
`unified_ui` package must expose and keep aligned with canonical IUR.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [UnifiedUi Package](./package.spec.md)
- [UnifiedUi DSL](./dsl.spec.md)
- [UnifiedUi Compiler](./compiler.spec.md)
- [UnifiedUi Widget Components](./widget_components.spec.md)

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
  - repo.ecosystem.canonical_widget_component_expansion
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

- id: unified_ui.widgets.expanded_widget_component_surface
  statement: The package shall author the expanded canonical widget-component catalog and list-repeat composition behavior defined by `unified_ui.widget_components` so AshUi PR 79-98 equivalents are available through the canonical DSL.
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
```

## Scenarios

```spec-scenarios
- id: unified_ui.widgets.author_modal_flow
  covers:
    - unified_ui.widgets.foundational_visual_surface
    - unified_ui.widgets.input_surface
    - unified_ui.widgets.layout_and_layer_surface
    - unified_ui.widgets.feedback_navigation_data_surface
    - unified_ui.widgets.expanded_widget_component_surface
    - unified_ui.widgets.style_attribute_surface
    - unified_ui.widgets.canvas_surface
    - unified_ui.widgets.iur_surface_parity
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
    - unified_ui.widgets.expanded_widget_component_surface
    - unified_ui.widgets.style_attribute_surface
    - unified_ui.widgets.canvas_surface
    - unified_ui.widgets.iur_surface_parity
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
    - unified_ui.widgets.expanded_widget_component_surface
    - unified_ui.widgets.style_attribute_surface
    - unified_ui.widgets.canvas_surface
    - unified_ui.widgets.iur_surface_parity
    - unified_ui.widgets.author_modal_flow
    - unified_ui.widgets.author_data_experience
```
