# Widget Event Matrix

This matrix maps each built-in widget ID from [widget_system_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/widget_system_contract.md) to standard events expected in code handlers.

`None` means no user-originated interaction events are expected by default for that widget.

| Widget ID | Standard Event Types | Payload Focus |
|---|---|---|
| `block` | None | N/A |
| `button` | `unified.button.clicked`, `unified.element.focused`, `unified.element.blurred` | `action`, `button_id` / `widget_id` |
| `label` | None | N/A |
| `list` | `unified.item.selected`, `unified.item.toggled` | `index`, `item_id`, `selected` |
| `pick_list` | `unified.item.selected`, `unified.overlay.closed` | `index` / `value`, optional `reason` |
| `progress` | None | N/A |
| `text_input_primitive` | `unified.input.changed`, `unified.form.submitted`, `unified.element.focused`, `unified.element.blurred` | `input_id`, `value`, `form_id` |
| `alert_dialog` | `unified.overlay.confirmed`, `unified.overlay.closed`, `unified.button.clicked` | `action_id`, optional `reason` |
| `bar_chart` | `unified.chart.point_selected` (optional), `unified.chart.point_hovered` (optional) | `series`, `point` |
| `canvas` | `unified.canvas.pointer.changed`, `unified.button.clicked` (optional) | `x`, `y`, `phase` |
| `cluster_dashboard` | `unified.item.selected`, `unified.view.changed`, `unified.action.requested` | `item_id` / `index`, `view`, `action` |
| `command_palette` | `unified.input.changed`, `unified.item.selected`, `unified.command.executed`, `unified.overlay.closed` | `query`, `command_id`, optional `reason` |
| `context_menu` | `unified.menu.action_selected`, `unified.item.selected`, `unified.overlay.closed` | `action_id`, `item_id`, optional `reason` |
| `dialog` | `unified.overlay.confirmed`, `unified.overlay.closed`, `unified.button.clicked` | `action_id`, optional `reason` |
| `form_builder` | `unified.input.changed`, `unified.form.submitted`, `unified.item.toggled`, `unified.element.focused`, `unified.element.blurred` | `field`, `value`, `data`, `selected` |
| `gauge` | None | N/A |
| `line_chart` | `unified.chart.point_selected` (optional), `unified.chart.point_hovered` (optional) | `series`, `point` |
| `log_viewer` | `unified.scroll.changed`, `unified.item.selected`, `unified.input.changed` (optional) | `position`, `index`, `query` |
| `markdown_viewer` | `unified.link.clicked` (optional) | `href` |
| `menu` | `unified.menu.action_selected`, `unified.item.selected` | `action_id`, `item_id` |
| `process_monitor` | `unified.item.selected`, `unified.action.requested` | `item_id`, `action`, `target_id` |
| `scroll_bar` | `unified.scroll.changed` | `position`, `delta` |
| `sparkline` | `unified.chart.point_selected` (optional), `unified.chart.point_hovered` (optional) | `series`, `point` |
| `split_pane` | `unified.split.resized`, `unified.split.collapse_changed` | `panes`, `pane_id`, `collapsed` |
| `stream_widget` | `unified.item.selected` (optional), `unified.scroll.changed` (optional) | `index`, `position` |
| `supervision_tree_viewer` | `unified.tree.node_selected`, `unified.tree.node_toggled`, `unified.action.requested` | `node_id`, `expanded`, `action` |
| `table` | `unified.table.row_selected`, `unified.table.sorted`, `unified.item.toggled` (optional) | `row_index`, `column`, `direction`, `selected` |
| `tabs` | `unified.tab.changed`, `unified.tab.closed` (optional) | `tab_id` |
| `text_input` | `unified.input.changed`, `unified.form.submitted`, `unified.element.focused`, `unified.element.blurred` | `input_id`, `value`, `form_id` |
| `toast` | `unified.toast.dismissed` | `toast_id`, optional `reason` |
| `toast_manager` | `unified.toast.dismissed`, `unified.toast.cleared` (optional) | `toast_id` |
| `tree_view` | `unified.tree.node_selected`, `unified.tree.node_toggled` | `node_id`, `expanded` |
| `viewport` | `unified.scroll.changed`, `unified.viewport.resized` (optional) | `position`, `width`, `height` |

## Custom Widgets

Custom widgets (`custom.<namespace>.<name>`) MUST declare event schemas that either:

1. Reuse one or more event types from [event_type_catalog.md](/Users/Pascal/code/unified/web_ui/specs/events/event_type_catalog.md), or
2. Define namespaced custom types that preserve the same envelope and route-key conventions.
