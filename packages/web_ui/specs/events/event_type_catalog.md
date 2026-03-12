# Event Type Catalog

This catalog defines canonical widget interaction event types and payload requirements for application update handlers.

## Envelope Shape

Widget-originated events SHOULD normalize to this shape before runtime dispatch:

```text
WidgetUiEvent {
  type: string,
  widget_id: string,
  widget_kind: string,
  correlation_id: string,
  request_id: string,
  timestamp: string,
  data: map
}
```

When transported across websocket boundaries, this payload SHOULD remain inside the canonical CloudEvent envelope defined in [service_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/service_contract.md).

## Canonical Event Types

The six `unified-ui` standard signal names are the baseline compatibility set.

| Event Type | Baseline | Typical Elm Binding | Required `data` Keys |
|---|---|---|---|
| `unified.button.clicked` | Standard | `Html.Events.onClick` | `action` or `button_id` or `widget_id` |
| `unified.input.changed` | Standard | `Html.Events.onInput`, `Html.Events.onCheck` | `value` plus `input_id` or `widget_id` |
| `unified.form.submitted` | Standard | `Html.Events.onSubmit` | `form_id` or `widget_id`; optional `data` map |
| `unified.element.focused` | Standard | `Html.Events.onFocus` | `widget_id` |
| `unified.element.blurred` | Standard | `Html.Events.onBlur` | `widget_id` |
| `unified.item.selected` | Standard | `onClick` / keyboard selection handlers | `widget_id` and one of `item_id`, `index`, or `value` |

Extended event types follow the same naming convention and are used for complex widgets.

| Event Type | Typical Elm Binding | Required `data` Keys |
|---|---|---|
| `unified.item.toggled` | `onClick` / keyboard toggle handlers | `widget_id` and `item_id` or `index`; `selected` |
| `unified.menu.action_selected` | `onClick` | `widget_id`, `action_id` |
| `unified.table.row_selected` | row `onClick` / keyboard selection | `widget_id`, `row_index` |
| `unified.table.sorted` | header `onClick` | `widget_id`, `column`, `direction` |
| `unified.tab.changed` | `onClick` / keyboard nav | `widget_id`, `tab_id` |
| `unified.tab.closed` | close button `onClick` | `widget_id`, `tab_id` |
| `unified.tree.node_selected` | `onClick` / keyboard nav | `widget_id`, `node_id` |
| `unified.tree.node_toggled` | `onClick` / keyboard expand/collapse | `widget_id`, `node_id`, `expanded` |
| `unified.overlay.confirmed` | button `onClick`, Enter key | `widget_id`, `action_id` |
| `unified.overlay.closed` | Escape key, outside click, close button | `widget_id`, optional `reason` |
| `unified.scroll.changed` | `on "scroll"` / drag handlers | `widget_id`, `position`, optional `delta` |
| `unified.split.resized` | drag handlers (`mousemove`/`mouseup` subscriptions) | `widget_id`, `panes` |
| `unified.split.collapse_changed` | `onClick` | `widget_id`, `pane_id`, `collapsed` |
| `unified.command.executed` | `onClick`, Enter key | `widget_id`, `command_id` |
| `unified.action.requested` | keyboard shortcut or click handlers | `widget_id`, `action`, optional `target_id` |
| `unified.toast.dismissed` | `onClick`, Escape key, timer command | `widget_id`, `toast_id` |
| `unified.toast.cleared` | `onClick` | `widget_id` |
| `unified.chart.point_selected` | custom `on` with decoder | `widget_id`, `series`, `point` |
| `unified.chart.point_hovered` | custom `on` with decoder | `widget_id`, `series`, `point` |
| `unified.canvas.pointer.changed` | custom pointer/mouse handlers | `widget_id`, `x`, `y`, `phase` |
| `unified.link.clicked` | `onClick` on rendered links | `widget_id`, `href` |
| `unified.view.changed` | tab/menu/view switch handlers | `widget_id`, `view` |
| `unified.viewport.resized` | `Browser.Events.onResize` | `widget_id`, `width`, `height` |

## Elm Binding Notes

1. `Html.Events.onInput` reads `event.target.value` and internally uses `stopPropagationOn`.
2. `Html.Events.onCheck` reads `event.target.checked`.
3. `Html.Events.onSubmit` uses `preventDefaultOn` so default browser submit navigation is suppressed.
4. Keyboard/pointer details (`key`, `code`, coordinates, modifiers) require `Html.Events.on` with `Json.Decode`.
5. Global interactions (`onResize`, `onVisibilityChange`, drag subscriptions) should use `Browser.Events`.

## Route-Key Compatibility

For dispatch compatibility with existing `unified-ui` update routing, handlers SHOULD keep these keys populated when available:

- click path: `action`, `button_id`, `widget_id`, `id`
- change path: `input_id`, `widget_id`, `field`, `action`, `id`
- submit path: `form_id`, `action`, `id`
