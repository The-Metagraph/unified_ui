# Widget System Contract

This contract defines the built-in widget catalog and custom-widget extension model for `web_ui`.

## Requirement Set

- `REQ-WGT-001`: `web_ui` MUST expose a deterministic built-in widget catalog that matches the public widget set from `../term_ui`.
- `REQ-WGT-002`: Built-in widget IDs and categories MUST be stable across minor/patch releases.
- `REQ-WGT-003`: Every built-in widget MUST publish a `WidgetDescriptor` with props schema and event schema metadata.
- `REQ-WGT-004`: Widget rendering MUST be deterministic for equivalent descriptor + props + state inputs.
- `REQ-WGT-005`: Runtime MUST support custom widget registration through `WidgetRegistrationRequest`.
- `REQ-WGT-006`: Custom widget IDs MUST use `custom.<namespace>.<name>` and MUST NOT use reserved built-in IDs.
- `REQ-WGT-007`: Registration MUST fail closed for duplicate IDs, invalid schemas, or unsupported capabilities.
- `REQ-WGT-008`: Custom widgets MUST interoperate with canonical websocket event naming and preserve correlation metadata.
- `REQ-WGT-009`: Built-in widget override/replacement MUST be prohibited by default.
- `REQ-WGT-010`: Widget registry and render operations MUST emit observability events required by [observability_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/observability_contract.md).

## Canonical Built-In Widget Catalog (TermUI Parity Baseline)

The built-in catalog MUST include these public `term_ui` widget modules.

### Primitive / Base Widgets (`TermUI.Widget.*`)

| Widget ID | TermUI Module |
|---|---|
| `block` | `TermUI.Widget.Block` |
| `button` | `TermUI.Widget.Button` |
| `label` | `TermUI.Widget.Label` |
| `list` | `TermUI.Widget.List` |
| `pick_list` | `TermUI.Widget.PickList` |
| `progress` | `TermUI.Widget.Progress` |
| `text_input_primitive` | `TermUI.Widget.TextInput` |

### Composite / Advanced Widgets (`TermUI.Widgets.*`)

| Widget ID | TermUI Module |
|---|---|
| `alert_dialog` | `TermUI.Widgets.AlertDialog` |
| `bar_chart` | `TermUI.Widgets.BarChart` |
| `canvas` | `TermUI.Widgets.Canvas` |
| `cluster_dashboard` | `TermUI.Widgets.ClusterDashboard` |
| `command_palette` | `TermUI.Widgets.CommandPalette` |
| `context_menu` | `TermUI.Widgets.ContextMenu` |
| `dialog` | `TermUI.Widgets.Dialog` |
| `form_builder` | `TermUI.Widgets.FormBuilder` |
| `gauge` | `TermUI.Widgets.Gauge` |
| `line_chart` | `TermUI.Widgets.LineChart` |
| `log_viewer` | `TermUI.Widgets.LogViewer` |
| `markdown_viewer` | `TermUI.Widgets.MarkdownViewer` |
| `menu` | `TermUI.Widgets.Menu` |
| `process_monitor` | `TermUI.Widgets.ProcessMonitor` |
| `scroll_bar` | `TermUI.Widgets.ScrollBar` |
| `sparkline` | `TermUI.Widgets.Sparkline` |
| `split_pane` | `TermUI.Widgets.SplitPane` |
| `stream_widget` | `TermUI.Widgets.StreamWidget` |
| `supervision_tree_viewer` | `TermUI.Widgets.SupervisionTreeViewer` |
| `table` | `TermUI.Widgets.Table` |
| `tabs` | `TermUI.Widgets.Tabs` |
| `text_input` | `TermUI.Widgets.TextInput` |
| `toast` | `TermUI.Widgets.Toast` |
| `toast_manager` | `TermUI.Widgets.ToastManager` |
| `tree_view` | `TermUI.Widgets.TreeView` |
| `viewport` | `TermUI.Widgets.Viewport` |

The parity baseline excludes internal helper/variant modules (for example `*.Behavior`, `*.Factory`, `*.Consumer`, nested helper modules) unless explicitly promoted through ADR.

## Types

### WidgetDescriptor

```text
WidgetDescriptor {
  widget_id: string,
  origin: "builtin" | "custom",
  category: "primitive" | "navigation" | "overlay" | "visualization" | "data" | "runtime" | "utility",
  state_model: "stateless" | "stateful",
  props_schema: map,
  event_schema: map,
  version: string,
  capabilities?: string[]
}
```

### WidgetRegistrationRequest

```text
WidgetRegistrationRequest {
  descriptor: WidgetDescriptor,
  implementation_ref: string,
  requested_by: string,
  context: RuntimeContext
}
```

### WidgetRenderRequest

```text
WidgetRenderRequest {
  widget_id: string,
  props: map,
  state?: map,
  context: RuntimeContext
}
```

### WidgetRenderResult

```text
WidgetRenderResult {
  widget_id: string,
  outcome: "ok" | "error",
  node?: map,
  error?: TypedError,
  events: RuntimeEventEnvelope[]
}
```

## Custom Widget Extension Rules

1. Custom widgets MUST declare a full `WidgetDescriptor` before first render.
2. Custom widgets MUST use ID format `custom.<namespace>.<name>`.
3. Reserved built-in IDs MUST be rejected for custom registration.
4. Descriptor schema validation MUST occur before runtime activation.
5. Registration failures MUST emit typed protocol/validation errors.

## Required Widget Lifecycle Events

Implementations MUST emit:

- `runtime.widget.registered.v1`
- `runtime.widget.registration_failed.v1`
- `runtime.widget.rendered.v1`
- `runtime.widget.render_failed.v1`

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
