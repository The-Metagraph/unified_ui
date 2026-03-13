# UnifiedIUR Structures

This subject backfills the current structural element surface of
`packages/unified_iur`, covering the implemented widget and layout families.

```spec-meta
id: unified_iur.structures
kind: subsystem
status: active
summary: Current struct surface for foundational widgets, charts, tables, navigation, and layouts in `packages/unified_iur`.
surface:
  - packages/unified_iur/lib/unified_iur/widgets.ex
  - packages/unified_iur/lib/unified_iur/layouts.ex
  - packages/unified_iur/lib/unified_iur/element.ex
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: unified_iur.structures.foundational_widgets
  statement: The package shall define the current foundational widget structs for text, button, label, and text_input, with metadata exposed through the element protocol.
  priority: must
  stability: stable

- id: unified_iur.structures.data_and_tables
  statement: The package shall define the current data-visualization and tabular structs for gauge, sparkline, bar_chart, line_chart, column, and table, with metadata exposed through the element protocol.
  priority: must
  stability: stable

- id: unified_iur.structures.navigation
  statement: The package shall define the current navigation and hierarchy structs for menu_item, menu, context_menu, tab, tabs, tree_node, and tree_view, with metadata and nested-child traversal exposed through the element protocol where applicable.
  priority: must
  stability: stable

- id: unified_iur.structures.layouts
  statement: The package shall define the current `VBox` and `HBox` layout structs with child lists, spacing/alignment fields, and element-protocol traversal of nested children.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified_iur/lib/unified_iur/widgets.ex
  covers:
    - unified_iur.structures.foundational_widgets
    - unified_iur.structures.data_and_tables
    - unified_iur.structures.navigation

- kind: source_file
  target: packages/unified_iur/lib/unified_iur/layouts.ex
  covers:
    - unified_iur.structures.layouts

- kind: source_file
  target: packages/unified_iur/lib/unified_iur/element.ex
  covers:
    - unified_iur.structures.foundational_widgets
    - unified_iur.structures.data_and_tables
    - unified_iur.structures.navigation
    - unified_iur.structures.layouts
```
