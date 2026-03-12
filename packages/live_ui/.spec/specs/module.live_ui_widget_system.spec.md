# LiveUi Widget System

The widget system subject defines the independent live_ui widget library.

It renders normalized render-tree nodes into HEEx through a registry of layout, widget, data-visualization, form, feedback, and extension implementations owned by live_ui, and it also exposes those same widgets as public components that can be used without `UnifiedIUR`.

```spec-meta
{
  "id": "module.live_ui_widget_system",
  "kind": "module",
  "status": "draft",
  "surface": ["LiveUi.Widgets", "LiveUi.WidgetRegistry", "LiveUi.Components.Layouts", "LiveUi.Components.BasicWidgets", "LiveUi.Components.DataViz", "LiveUi.Components.Navigation", "LiveUi.Components.Feedback", "LiveUi.Components.Forms", "LiveUi.Components.Extensions"],
  "relationships": [
    {"kind": "depends_on", "target": "package.live_ui"},
    {"kind": "depends_on", "target": "module.live_ui_iur_interpreter"},
    {"kind": "depends_on", "target": "module.live_ui_theme_system"},
    {"kind": "depends_on", "target": "module.live_ui_layer_system"},
    {"kind": "governed_by", "target": "policy.live_ui_governance"},
    {"kind": "governed_by", "target": "policy.live_ui_conformance"},
    {"kind": "relates_to", "target": "module.live_ui_signal_bridge"}
  ]
}
```

```spec-governance
{
  "owner": "team.live_ui",
  "criticality": "high",
  "primary_plane": "rendering",
  "change_rules": [
    {
      "id": "widget_system_changes_require_interpreter_theme_and_layer_alignment",
      "when": {
        "change_types": ["behavior_shape"]
      },
      "requires": [
        {"subject_ids": ["module.live_ui_iur_interpreter", "module.live_ui_theme_system", "module.live_ui_layer_system", "module.live_ui_signal_bridge"]},
        {"verification_kinds": ["test_file"]}
      ],
      "severity": "error"
    }
  ],
  "approval": {
    "required": true,
    "roles": ["maintainer"]
  },
  "gates": [
    {
      "id": "local_spec_check",
      "kind": "mix_task",
      "target": "mix live_ui.spec.check",
      "mode": "required"
    }
  ]
}
```

## Requirements

```spec-requirements
[
  {
    "id": "live_ui_widgets.registry.covers_all_kinds",
    "statement": "When a normalized render-tree kind is emitted by the interpreter, the widget system shall resolve that kind through a registry that covers every canonical UnifiedIUR widget and every explicitly adopted extension kind.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_widgets.own_independent_widget_contract",
    "statement": "When a UnifiedIUR tree is rendered, the widget system shall use widget and layout implementations owned by live_ui rather than delegating rendering semantics to upstream producers.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_widgets.public_components.usable_without_iur",
    "statement": "When a host composes a screen directly, the widget system shall expose a stable public component API whose widgets and layouts can be used without going through the UnifiedIUR interpreter.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_widgets.public_and_iur_paths.share_one_contract",
    "statement": "When the same conceptual widget is rendered directly or through UnifiedIUR interpretation, the widget system shall use the same underlying widget semantics, theming rules, and layer behavior.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_widgets.render.stateless_vs_stateful",
    "statement": "When a widget is rendered, the widget system shall use pure function components for stateless widgets and shall reserve LiveComponents or hooks for widgets whose interaction model requires local lifecycle or measurement support.",
    "priority": "should",
    "stability": "stable"
  },
  {
    "id": "live_ui_widgets.hooks.first_class_for_advanced_interactions",
    "statement": "When widget interactions require measurement, drag, pointer capture, keyboard coordination, scroll synchronization, or rich drawing support, the widget system shall support JavaScript hooks as a first-class library tool while keeping server state authoritative.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_widgets.layouts_and_primitives.compose_consistently",
    "statement": "When layout containers, basic widgets, forms, navigation widgets, feedback widgets, and adopted extension widgets are composed in one tree, the widget system shall preserve consistent DOM, accessibility, and interaction semantics across the library.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_widgets.charts.and_canvas.server_correctness",
    "statement": "When chart or canvas widgets are rendered, the widget system shall provide a server-correct rendering path that remains functional without client-side JavaScript.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_widgets.overlay.and_composite.behavior",
    "statement": "When composite or overlay widgets such as tables, tabs, tree views, dialogs, toasts, viewports, split panes, and command palettes are rendered, the widget system shall preserve their server-authoritative state and expose the interactions needed by the signal bridge and layer system.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_widgets.renders_basic_catalog",
    "given": ["render-tree nodes for text, button, label, text_input, vbox, and hbox"],
    "when": ["the widget registry resolves the nodes"],
    "then": ["each node is rendered through the mapped independent layout or widget implementation"],
    "covers": ["live_ui_widgets.registry.covers_all_kinds", "live_ui_widgets.own_independent_widget_contract", "live_ui_widgets.layouts_and_primitives.compose_consistently"]
  },
  {
    "id": "live_ui_widgets.direct_component_usage",
    "given": ["a host LiveView composing a screen from public live_ui widgets and layouts"],
    "when": ["the host renders the screen without UnifiedIUR input"],
    "then": ["the same widget library contract is available through a stable public component API"],
    "covers": ["live_ui_widgets.public_components.usable_without_iur", "live_ui_widgets.public_and_iur_paths.share_one_contract", "live_ui_widgets.layouts_and_primitives.compose_consistently"]
  },
  {
    "id": "live_ui_widgets.renders_server_correct_canvas",
    "given": ["a canvas node with recorded drawing operations"],
    "when": ["the canvas implementation emits markup"],
    "then": ["the output remains correct without relying on client-side JavaScript for baseline rendering and may layer hooks on top for richer interaction"],
    "covers": ["live_ui_widgets.charts.and_canvas.server_correctness", "live_ui_widgets.hooks.first_class_for_advanced_interactions", "live_ui_widgets.registry.covers_all_kinds"]
  },
  {
    "id": "live_ui_widgets.renders_stateful_composites",
    "given": ["render-tree nodes for table, tabs, tree_view, viewport, split_pane, dialog, toast, or command_palette"],
    "when": ["the nodes are rendered and interacted with"],
    "then": ["the implementations preserve server-authoritative state and expose stable interaction hooks where richer behavior is needed"],
    "covers": ["live_ui_widgets.overlay.and_composite.behavior", "live_ui_widgets.render.stateless_vs_stateful", "live_ui_widgets.hooks.first_class_for_advanced_interactions"]
  },
  {
    "id": "live_ui_widgets.compose_mixed_library_tree",
    "given": ["a render tree that mixes layouts, forms, navigation, overlays, and extension widgets"],
    "when": ["the tree is rendered by the widget system"],
    "then": ["the library preserves coherent composition semantics across all widget families"],
    "covers": ["live_ui_widgets.own_independent_widget_contract", "live_ui_widgets.public_and_iur_paths.share_one_contract", "live_ui_widgets.layouts_and_primitives.compose_consistently", "live_ui_widgets.overlay.and_composite.behavior"]
  }
]
```

## Verification

```spec-verification
[
  {
    "kind": "doc",
    "target": "docs/architecture.md",
    "covers": [
      "live_ui_widgets.registry.covers_all_kinds",
      "live_ui_widgets.own_independent_widget_contract",
      "live_ui_widgets.public_components.usable_without_iur",
      "live_ui_widgets.public_and_iur_paths.share_one_contract",
      "live_ui_widgets.render.stateless_vs_stateful",
      "live_ui_widgets.hooks.first_class_for_advanced_interactions",
      "live_ui_widgets.layouts_and_primitives.compose_consistently",
      "live_ui_widgets.charts.and_canvas.server_correctness",
      "live_ui_widgets.overlay.and_composite.behavior"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/widgets/widget_registry_test.exs",
    "covers": ["live_ui_widgets.registry.covers_all_kinds"]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/components/widget_rendering_test.exs",
    "covers": [
      "live_ui_widgets.own_independent_widget_contract",
      "live_ui_widgets.public_components.usable_without_iur",
      "live_ui_widgets.public_and_iur_paths.share_one_contract",
      "live_ui_widgets.render.stateless_vs_stateful",
      "live_ui_widgets.hooks.first_class_for_advanced_interactions",
      "live_ui_widgets.layouts_and_primitives.compose_consistently",
      "live_ui_widgets.overlay.and_composite.behavior"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/components/canvas_and_chart_test.exs",
    "covers": ["live_ui_widgets.charts.and_canvas.server_correctness"]
  }
]
```
