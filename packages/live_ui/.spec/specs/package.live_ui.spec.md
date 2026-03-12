# LiveUi Package Contract

`live_ui` is the Phoenix LiveView widget library and rendering runtime for canonical `UnifiedIUR` trees.

The package owns interpretation, widget rendering, theming, layering, event bridging, and host integration. Upstream tools may produce `UnifiedIUR`, but `live_ui` should not depend on their widget implementations once the IUR boundary is crossed.

Optional source modules may adapt into the same pipeline by emitting canonical `UnifiedIUR` from `view/1`, but the package's primary rendering contract is the canonical IUR itself.

```spec-meta
{
  "id": "package.live_ui",
  "kind": "package",
  "status": "draft",
  "surface": ["LiveUi", "LiveUi.Widgets"],
  "relationships": [
    {"kind": "depends_on", "target": "package.unified_iur"},
    {"kind": "governed_by", "target": "policy.live_ui_governance"},
    {"kind": "governed_by", "target": "policy.live_ui_conformance"},
    {"kind": "relates_to", "target": "module.live_ui_host_integration"},
    {"kind": "relates_to", "target": "module.live_ui_screen_macro"},
    {"kind": "relates_to", "target": "module.live_ui_runtime"},
    {"kind": "relates_to", "target": "module.live_ui_iur_interpreter"},
    {"kind": "relates_to", "target": "module.live_ui_widget_system"},
    {"kind": "relates_to", "target": "module.live_ui_theme_system"},
    {"kind": "relates_to", "target": "module.live_ui_layer_system"},
    {"kind": "relates_to", "target": "module.live_ui_signal_bridge"}
  ]
}
```

```spec-governance
{
  "owner": "team.live_ui",
  "criticality": "high",
  "primary_plane": "package",
  "change_rules": [
    {
      "id": "package_contract_changes_require_architecture_alignment",
      "when": {
        "change_types": ["behavior_shape"]
      },
      "requires": [
        {"artifacts": ["docs/architecture.md"]},
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
    "id": "live_ui.input.iur_primary_contract",
    "statement": "When the package renders a UI, the package shall treat canonical UnifiedIUR as the primary rendering contract and shall allow optional source modules only as adapters that emit the same canonical IUR.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui.widget_library.owns_rendering_contract",
    "statement": "When the package renders a UnifiedIUR tree, the package shall use an independent widget library, layout system, layer system, and theme system owned by live_ui rather than depending on upstream renderer implementations.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui.widget_library.public_components",
    "statement": "When a host application composes screens directly, the package shall expose live_ui widgets and layouts as public components that can be used without going through the UnifiedIUR interpreter.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui.render.normalization_boundary",
    "statement": "When a UI source is rendered, the package shall preserve a boundary in which upstream producers stop at canonical UnifiedIUR and live_ui owns interpretation and rendering after that boundary.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui.integration.host_mounted_library",
    "statement": "When the package is integrated into Phoenix, the package shall behave as a reusable library mounted inside a host application rather than requiring a standalone live_ui endpoint or app shell.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui.integration.hybrid_entrypoints",
    "statement": "When the package exposes host-facing rendering entrypoints, the package shall provide a canonical UnifiedIUR entrypoint as the primary path, a direct widget composition path for public components, and may provide thin source-module wrappers through use LiveUi.Screen as an adapter path, while sharing one internal rendering contract.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui.widget.catalog.parity",
    "statement": "When the package renders the supported catalog, the package shall support all canonical UnifiedIUR widgets and every explicitly adopted extension kind in the live_ui widget library contract.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui.event.loop.rebuild",
    "statement": "When a user interaction is accepted, the package shall encode the interaction as a concrete `%Jido.Signal{}`, rebuild the interpreted render tree, and rely on LiveView diffing for DOM reconciliation.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui.state.separation",
    "statement": "While a UI is mounted, the package shall keep source domain state, widget-local state, layer-local state, and render metadata separate and make those domains available during rebuilds.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui.canonical_iur_mount",
    "given": ["a canonical UnifiedIUR tree produced outside the library"],
    "when": ["the tree is mounted for rendering"],
    "then": ["the tree is interpreted, themed, layered, and rendered through the independent live_ui widget library without requiring any upstream widget implementation"],
    "covers": ["live_ui.input.iur_primary_contract", "live_ui.widget_library.owns_rendering_contract", "live_ui.render.normalization_boundary"]
  },
  {
    "id": "live_ui.direct_widget_composition",
    "given": ["a host LiveView composing a screen directly from public live_ui widgets and layouts"],
    "when": ["the screen is rendered"],
    "then": ["the same library-owned widget semantics, theme system, and layer system are used without requiring UnifiedIUR input"],
    "covers": ["live_ui.widget_library.public_components", "live_ui.widget_library.owns_rendering_contract", "live_ui.integration.hybrid_entrypoints"]
  },
  {
    "id": "live_ui.source_module_mount",
    "given": ["a source module that emits canonical UnifiedIUR from view/1"],
    "when": ["the source is mounted in LiveView"],
    "then": ["the source is initialized, emits canonical IUR, and enters the same interpretation and rendering pipeline used for raw IUR"],
    "covers": ["live_ui.input.iur_primary_contract", "live_ui.render.normalization_boundary", "live_ui.event.loop.rebuild"]
  },
  {
    "id": "live_ui.host_app_mount",
    "given": ["a Phoenix application that wants to embed live_ui under its own router and layout"],
    "when": ["the host mounts the library"],
    "then": ["the library runs inside the host application shell without requiring a standalone live_ui endpoint"],
    "covers": ["live_ui.integration.host_mounted_library"]
  },
  {
    "id": "live_ui.layered_widget_roundtrip",
    "given": ["a UnifiedIUR tree containing overlay, navigation, data visualization, and advanced interaction widgets"],
    "when": ["the tree is rendered and interacted with"],
    "then": ["the live_ui widget library, theme system, and layer system remain first-class participants in rendering and event handling"],
    "covers": ["live_ui.widget_library.owns_rendering_contract", "live_ui.widget.catalog.parity", "live_ui.event.loop.rebuild", "live_ui.state.separation"]
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
      "live_ui.input.iur_primary_contract",
      "live_ui.widget_library.owns_rendering_contract",
      "live_ui.widget_library.public_components",
      "live_ui.render.normalization_boundary",
      "live_ui.integration.host_mounted_library",
      "live_ui.integration.hybrid_entrypoints",
      "live_ui.widget.catalog.parity",
      "live_ui.event.loop.rebuild",
      "live_ui.state.separation"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/architecture/package_contract_test.exs",
    "covers": [
      "live_ui.input.iur_primary_contract",
      "live_ui.integration.host_mounted_library",
      "live_ui.integration.hybrid_entrypoints",
      "live_ui.widget.catalog.parity",
      "live_ui.event.loop.rebuild"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/architecture/golden_parity_test.exs",
    "covers": [
      "live_ui.input.iur_primary_contract",
      "live_ui.render.normalization_boundary",
      "live_ui.widget_library.owns_rendering_contract",
      "live_ui.widget.catalog.parity"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/components/widget_rendering_test.exs",
    "covers": ["live_ui.widget_library.public_components"]
  },
  {
    "kind": "command",
    "target": "mix test test/live_ui/**/*_test.exs",
    "covers": [
      "live_ui.input.iur_primary_contract",
      "live_ui.integration.host_mounted_library",
      "live_ui.integration.hybrid_entrypoints",
      "live_ui.widget.catalog.parity",
      "live_ui.event.loop.rebuild",
      "live_ui.state.separation"
    ]
  }
]
```
