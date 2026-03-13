# UnifiedUi Widgets

This subject backfills the current widget, layout, and builder surface of
`packages/unified-ui` from the implemented DSL entities and builder logic.

```spec-meta
id: unified_ui.widgets
kind: subsystem
status: active
summary: Current supported widget, layout, and builder surface for `packages/unified-ui`, derived from the package implementation.
surface:
  - packages/unified-ui/lib/unified_ui/dsl/entities
  - packages/unified-ui/lib/unified_ui/dsl/sections
  - packages/unified-ui/lib/unified_ui/iur/builder.ex
  - packages/unified-ui/test/unified_ui/dsl/entities
  - packages/unified-ui/test/unified_ui/iur
  - packages/unified-ui/test/unified_ui/integration
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: unified_ui.widgets.basic_layouts
  statement: The current package shall support foundational authored widgets and layouts including text, button, label, text_input, vbox, hbox, grid, stack, and zbox.
  priority: must
  stability: stable

- id: unified_ui.widgets.data_and_tables
  statement: The current package shall support data visualization and tabular authored entities including gauge, sparkline, bar_chart, line_chart, table, and column.
  priority: must
  stability: stable

- id: unified_ui.widgets.navigation_and_feedback
  statement: The current package shall support navigation and feedback authored entities including menu, context_menu, tabs, tree_view, dialog, alert_dialog, toast, and their related child entities.
  priority: must
  stability: stable

- id: unified_ui.widgets.advanced_surface
  statement: The current package shall support the implemented higher-level input, container, specialized, and monitoring entities including pick lists, form builders, viewports, split panes, canvas, command palettes, log viewers, stream widgets, and process monitors.
  priority: must
  stability: stable

- id: unified_ui.widgets.builder_translation
  statement: The current IUR builder shall translate supported DSL entities into `UnifiedIUR` or package-defined element structs while resolving styles and runtime state references.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/entities/widgets.ex
  covers:
    - unified_ui.widgets.basic_layouts

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/entities/layouts.ex
  covers:
    - unified_ui.widgets.basic_layouts

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/entities/data_viz.ex
  covers:
    - unified_ui.widgets.data_and_tables

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/entities/tables.ex
  covers:
    - unified_ui.widgets.data_and_tables

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/entities/navigation.ex
  covers:
    - unified_ui.widgets.navigation_and_feedback

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/entities/dialog_feedback.ex
  covers:
    - unified_ui.widgets.navigation_and_feedback

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/entities/input_widgets.ex
  covers:
    - unified_ui.widgets.advanced_surface

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/entities/containers.ex
  covers:
    - unified_ui.widgets.advanced_surface

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/entities/specialized.ex
  covers:
    - unified_ui.widgets.advanced_surface

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/entities/monitoring.ex
  covers:
    - unified_ui.widgets.advanced_surface

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/iur/builder.ex
  covers:
    - unified_ui.widgets.basic_layouts
    - unified_ui.widgets.data_and_tables
    - unified_ui.widgets.navigation_and_feedback
    - unified_ui.widgets.advanced_surface
    - unified_ui.widgets.builder_translation

- kind: source_file
  target: packages/unified-ui/test/unified_ui/integration/phase_2_test.exs
  covers:
    - unified_ui.widgets.basic_layouts
    - unified_ui.widgets.builder_translation

- kind: source_file
  target: packages/unified-ui/test/unified_ui/integration/phase_4_test.exs
  covers:
    - unified_ui.widgets.navigation_and_feedback
    - unified_ui.widgets.advanced_surface

- kind: source_file
  target: packages/unified-ui/test/unified_ui/iur/dsl_golden_build_test.exs
  covers:
    - unified_ui.widgets.basic_layouts
    - unified_ui.widgets.data_and_tables
    - unified_ui.widgets.navigation_and_feedback
    - unified_ui.widgets.builder_translation
```
