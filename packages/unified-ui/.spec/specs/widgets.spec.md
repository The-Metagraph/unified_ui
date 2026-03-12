# Widgets And IUR

Current widget, layout, and DSL-to-IUR translation contract.

```spec-meta
id: unified_ui.widgets
kind: component
status: active
summary: Implemented widget/layout surface and the builder that translates authored DSL into UnifiedIUR trees.
surface:
  - lib/unified_ui/iur/builder.ex
  - lib/unified_ui/dsl/entities/widgets.ex
  - lib/unified_ui/dsl/entities/data_viz.ex
  - lib/unified_ui/dsl/entities/tables.ex
  - lib/unified_ui/dsl/entities/navigation.ex
  - lib/unified_ui/dsl/entities/dialog_feedback.ex
  - lib/unified_ui/dsl/entities/input_widgets.ex
  - lib/unified_ui/dsl/entities/containers.ex
  - lib/unified_ui/dsl/entities/specialized.ex
  - lib/unified_ui/dsl/entities/monitoring.ex
  - lib/unified_ui/dsl/entities/layouts.ex
  - guides/widget-reference.md
  - guides/layout-system.md
  - guides/dashboard-tutorial.md
```

## Requirements

```spec-requirements
- id: unified_ui.widgets.basic_layouts
  statement: The current implementation shall support basic widgets and core layouts, preserving nested tree structure and metadata through IUR translation.
  priority: must
  stability: stable

- id: unified_ui.widgets.data_and_tables
  statement: The current implementation shall support data visualization widgets and tabular widgets with their current value, sorting, and selection metadata.
  priority: must
  stability: evolving

- id: unified_ui.widgets.navigation_and_feedback
  statement: The current implementation shall support navigation and feedback widgets including menus, tabs, tree views, dialogs, alerts, and toasts.
  priority: must
  stability: evolving

- id: unified_ui.widgets.advanced_surface
  statement: The current implementation shall include advanced input, container, specialized, monitoring, and advanced layout widgets that compile and render across adapters.
  priority: must
  stability: evolving

- id: unified_ui.widgets.builder_translation
  statement: UnifiedUi.IUR.Builder shall translate authored DSL entities into the corresponding UnifiedIUR or UnifiedUi widget structs while skipping non-render entities.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.widgets.dashboard_build
  given:
    - authored DSL containing nested layouts, text, buttons, data visualization widgets, and tables
  when:
    - the DSL is built into IUR
  then:
    - the resulting tree preserves hierarchy, ids, styles, and widget metadata
  covers:
    - unified_ui.widgets.basic_layouts
    - unified_ui.widgets.data_and_tables
    - unified_ui.widgets.builder_translation

- id: unified_ui.widgets.advanced_widgets_render
  given:
    - authored UI using navigation, feedback, input, container, specialized, monitoring, and advanced layout widgets
  when:
    - the UI is rendered across the current adapters
  then:
    - the widgets retain their current metadata and render successfully on the supported platforms
  covers:
    - unified_ui.widgets.navigation_and_feedback
    - unified_ui.widgets.advanced_surface
```

## Verification

```spec-verification
- kind: source_file
  target: lib/unified_ui/iur/builder.ex
  covers:
    - unified_ui.widgets.builder_translation
    - unified_ui.widgets.basic_layouts
    - unified_ui.widgets.data_and_tables
    - unified_ui.widgets.navigation_and_feedback
    - unified_ui.widgets.advanced_surface

- kind: guide_file
  target: guides/widget-reference.md
  covers:
    - unified_ui.widgets.basic_layouts
    - unified_ui.widgets.data_and_tables
    - unified_ui.widgets.navigation_and_feedback

- kind: guide_file
  target: guides/layout-system.md
  covers:
    - unified_ui.widgets.basic_layouts

- kind: guide_file
  target: guides/dashboard-tutorial.md
  covers:
    - unified_ui.widgets.data_and_tables

- kind: test_file
  target: test/unified_ui/iur/dsl_golden_build_test.exs
  covers:
    - unified_ui.widgets.basic_layouts
    - unified_ui.widgets.data_and_tables
    - unified_ui.widgets.navigation_and_feedback
    - unified_ui.widgets.builder_translation

- kind: test_file
  target: test/unified_ui/integration/phase_2_test.exs
  covers:
    - unified_ui.widgets.basic_layouts
    - unified_ui.widgets.builder_translation

- kind: test_file
  target: test/unified_ui/integration/phase_4_test.exs
  covers:
    - unified_ui.widgets.navigation_and_feedback
    - unified_ui.widgets.advanced_surface

- kind: command
  target: mix test test/unified_ui/iur/dsl_golden_build_test.exs test/unified_ui/integration/phase_2_test.exs test/unified_ui/integration/phase_4_test.exs
  execute: true
  covers:
    - unified_ui.widgets.basic_layouts
    - unified_ui.widgets.data_and_tables
    - unified_ui.widgets.navigation_and_feedback
    - unified_ui.widgets.advanced_surface
    - unified_ui.widgets.builder_translation
```
