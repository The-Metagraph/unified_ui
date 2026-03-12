# LiveUi Layer System

The layer system subject defines how live_ui manages overlays, floating surfaces, z-order, and transient interaction semantics across the widget library.

It should treat layering as a first-class library concern rather than as incidental markup owned by individual widgets, and those rules should apply consistently to both direct widget use and IUR-driven rendering.

```spec-meta
{
  "id": "module.live_ui_layer_system",
  "kind": "module",
  "status": "draft",
  "surface": ["LiveUi.Layers", "LiveUi.WidgetState", "LiveUi.Components.Feedback", "LiveUi.Components.Navigation", "LiveUi.Components.Extensions"],
  "relationships": [
    {"kind": "depends_on", "target": "package.live_ui"},
    {"kind": "depends_on", "target": "module.live_ui_iur_interpreter"},
    {"kind": "depends_on", "target": "module.live_ui_widget_system"},
    {"kind": "depends_on", "target": "module.live_ui_runtime"},
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
      "id": "layer_system_changes_require_runtime_and_widget_alignment",
      "when": {
        "change_types": ["behavior_shape"]
      },
      "requires": [
        {"subject_ids": ["module.live_ui_runtime", "module.live_ui_widget_system", "module.live_ui_signal_bridge"]},
        {"verification_kinds": ["doc", "test_file"]}
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
    "id": "live_ui_layers.coordinates_overlay_order",
    "statement": "When multiple overlays or floating surfaces are active, the layer system shall coordinate stable stacking order, precedence, and backdrop semantics across the widget library.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_layers.keeps_transient_state_server_authoritative",
    "statement": "While overlay and floating widgets are active, the layer system shall keep transient layer state server-authoritative and merge that state deterministically into rebuilds.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_layers.coordinates_focus_and_dismissal",
    "statement": "When dialogs, menus, palettes, or other transient surfaces are shown, the layer system shall coordinate focus, escape handling, and dismissal semantics consistently across the library.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_layers.supports_direct_widget_usage",
    "statement": "When a host composes overlays or floating surfaces directly from live_ui widgets, the layer system shall apply the same stacking, dismissal, and focus rules used by IUR-driven rendering.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_layers.provides_shared_mount_surfaces",
    "statement": "When widgets require overlay or floating presentation, the layer system shall provide shared mounting and composition surfaces instead of leaving each widget family to invent its own stacking contract.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_layers.dialog_and_toast_coordination",
    "given": ["a UI showing dialogs, toasts, and other feedback surfaces at the same time"],
    "when": ["the layer system renders the scene"],
    "then": ["stacking order and backdrop semantics remain stable and consistent"],
    "covers": ["live_ui_layers.coordinates_overlay_order", "live_ui_layers.provides_shared_mount_surfaces"]
  },
  {
    "id": "live_ui_layers.direct_overlay_usage",
    "given": ["a host LiveView rendering dialogs or floating widgets directly from live_ui components"],
    "when": ["the user opens, navigates, and dismisses those surfaces"],
    "then": ["the same layering and dismissal semantics used by IUR-driven rendering are preserved"],
    "covers": ["live_ui_layers.supports_direct_widget_usage", "live_ui_layers.coordinates_focus_and_dismissal"]
  },
  {
    "id": "live_ui_layers.palette_and_menu_interaction",
    "given": ["a command palette, menu, or other transient navigation surface"],
    "when": ["the user opens, navigates, and dismisses the surface"],
    "then": ["focus and dismissal behavior remain consistent and server-authoritative"],
    "covers": ["live_ui_layers.keeps_transient_state_server_authoritative", "live_ui_layers.coordinates_focus_and_dismissal"]
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
      "live_ui_layers.coordinates_overlay_order",
      "live_ui_layers.keeps_transient_state_server_authoritative",
      "live_ui_layers.coordinates_focus_and_dismissal",
      "live_ui_layers.supports_direct_widget_usage",
      "live_ui_layers.provides_shared_mount_surfaces"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/runtime/runtime_test.exs",
    "covers": ["live_ui_layers.keeps_transient_state_server_authoritative"]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/components/widget_rendering_test.exs",
    "covers": [
      "live_ui_layers.coordinates_overlay_order",
      "live_ui_layers.coordinates_focus_and_dismissal",
      "live_ui_layers.supports_direct_widget_usage",
      "live_ui_layers.provides_shared_mount_surfaces"
    ]
  }
]
```
