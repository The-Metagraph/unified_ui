# Examples Demo Application Interface

This subject defines the tabbed interface, category coverage, and control
presentation contract for the aggregate demo application.

## Related General Specs

- [Examples Demo Application](./package.spec.md)
- [Examples Demo Application Structure](./structure.spec.md)
- [Examples Demo Application Theming](./theming.spec.md)
- [Example Apps Catalog](../examples/catalog.spec.md)
- [Example Apps DSL Template](../examples/dsl_template.spec.md)
- [LiveUi Native Widgets](../live_ui/native_widgets.spec.md)

```spec-meta
id: repo.examples_demo.interface
kind: subsystem
status: active
summary: Tabbed interface and category-coverage contract for the aggregate `examples/demo/` application.
surface:
  - examples/demo/**
  - .spec/specs/examples_demo/interface.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples_demo.interface.tabbed_shell
  statement: The aggregate demo application shall present its review surface through one tabbed interface where each top-level tab represents a control category or the dedicated signal-reactivity lab.
  priority: must
  stability: stable

- id: repo.examples_demo.interface.required_tabs
  statement: The tabbed interface shall include at minimum `foundational_content`, `forms_and_input`, `layout_and_display`, `navigation_and_selection`, `data_and_feedback`, `overlays_and_operational`, and `signal_lab` tabs.
  priority: must
  stability: stable

- id: repo.examples_demo.interface.category_representation
  statement: Each non-signal tab shall display a representative set of controls from its category with the same shared shell, default theme, default style baseline, and short per-control descriptive copy used by the current `examples/button/` application so maintainers can compare controls in one consistent view.
  priority: must
  stability: stable

- id: repo.examples_demo.interface.catalog_traceability
  statement: The category tabs shall be traceable to the existing example-suite catalog so every control family represented in the aggregate demo can be mapped back to the per-widget example applications.
  priority: must
  stability: stable

- id: repo.examples_demo.interface.visible_state_feedback
  statement: Each tab shall provide visible state or labeling that makes the currently selected category, the category purpose, and the active demonstration panel clear to a reviewer without inspecting the source code.
  priority: must
  stability: stable

- id: repo.examples_demo.interface.no_raw_debug_primary_surface
  statement: The aggregate demo application shall present controls and outcomes through reviewer-friendly labels, panels, and summaries rather than relying on raw inspection dumps as the primary interface.
  priority: must
  stability: stable
```

## Category Contract

The aggregate demo application shall organize controls into these review tabs:

- `foundational_content`: `text`, `label`, `icon`, `image`, `button`, `link`, `separator`, `spacer`, `content`
- `forms_and_input`: `form_builder`, `field_group`, `field`, `text_input`, `numeric_input`, `checkbox`, `radio_group`, `select`, `pick_list`, `date_input`, `time_input`, `file_input`, `toggle`
- `layout_and_display`: `box`, `row`, `column`, `grid`, `viewport`, `scroll_bar`, `split_pane`, `canvas`
- `navigation_and_selection`: `menu`, `tabs`, `list`, `command_palette`
- `data_and_feedback`: `table`, `tree_view`, `markdown_viewer`, `log_viewer`, `status`, `progress`, `gauge`, `inline_feedback`, `sparkline`, `bar_chart`, `line_chart`
- `overlays_and_operational`: `overlay`, `dialog`, `alert_dialog`, `context_menu`, `toast`, `stream_widget`, `process_monitor`, `supervision_tree_viewer`, `cluster_dashboard`
- `signal_lab`: cross-control interaction stories authored through canonical signals and visible runtime reactions

## Scenarios

```spec-scenarios
- id: repo.examples_demo.interface.review_input_family
  given: A reviewer wants to compare the current input controls without opening separate per-widget apps
  when: The reviewer switches to the `forms_and_input` tab
  then: The reviewer sees the current input controls presented together through the shared theme and descriptive panel structure
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples_demo/interface.spec.md
  covers:
    - repo.examples_demo.interface.tabbed_shell
    - repo.examples_demo.interface.required_tabs
    - repo.examples_demo.interface.category_representation
    - repo.examples_demo.interface.catalog_traceability
    - repo.examples_demo.interface.visible_state_feedback
    - repo.examples_demo.interface.no_raw_debug_primary_surface
    - repo.examples_demo.interface.review_input_family
```
