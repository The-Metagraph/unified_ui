# Widget Reference

UnifiedUi widgets are grouped by capability and compiled to `UnifiedIUR` structs.

## Basic Widgets

- `text`: Static text content.
- `button`: Action trigger with `on_click`.
- `label`: Label associated with an input via `for`.
- `text_input`: Input field with `type`, `placeholder`, `on_change`, and `on_submit`.

## Data Visualization

- `gauge`: Range-based value display.
- `sparkline`: Compact trend chart.
- `bar_chart`: Horizontal or vertical categorical bars.
- `line_chart`: Sequential trend line with optional dots/area.

## Table

- `table`: Tabular rows with sorting and row selection support.
- `column` (nested in `table`): Declares header, key, width, alignment, formatter, and sorting.

## Navigation

- `menu` and nested `menu_item`
- `context_menu` and nested `menu_item`
- `tabs` and nested `tab`
- `tree_view` and nested `tree_node`

## Layouts

- `vbox`: Vertical container for children.
- `hbox`: Horizontal container for children.

Layouts accept shared container options like `spacing`, `padding`, `align_items`, `justify_content`, and `style`.

## Shared Options

Most entities support:

- `id`: Unique element identifier.
- `style`: Inline style keyword list.
- `visible`: Runtime visibility flag.

## Signals

Event handlers accept:

- atom: `:submit`
- tuple with payload: `{:submit, %{form: :login}}`
- MFA tuple: `{MyModule, :handle_submit, []}`

## Notes

- Widget declarations are validated at compile time by Spark verifiers.
- DSL entities are converted to `UnifiedIUR` and then to adapter-specific render trees.
