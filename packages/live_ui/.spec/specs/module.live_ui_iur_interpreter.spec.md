# LiveUi IUR Interpreter

The interpreter subject converts canonical `UnifiedIUR` input and compatible extension nodes into one normalized render tree that the independent live_ui widget library can consume.

It is the adapter contract between platform-agnostic UI data and live_ui-owned rendering semantics.

```spec-meta
{
  "id": "module.live_ui_iur_interpreter",
  "kind": "module",
  "status": "draft",
  "surface": ["LiveUi.IUR.Interpreter", "LiveUi.IUR.Dependency", "LiveUi.IUR.ValueNormalizer"],
  "relationships": [
    {"kind": "depends_on", "target": "package.live_ui"},
    {"kind": "depends_on", "target": "package.unified_iur"},
    {"kind": "governed_by", "target": "policy.live_ui_governance"},
    {"kind": "governed_by", "target": "policy.live_ui_conformance"},
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
  "primary_plane": "rendering",
  "change_rules": [
    {
      "id": "interpreter_changes_require_widget_theme_layer_alignment",
      "when": {
        "change_types": ["behavior_shape"]
      },
      "requires": [
        {"subject_ids": ["module.live_ui_widget_system", "module.live_ui_theme_system", "module.live_ui_layer_system", "module.live_ui_signal_bridge"]},
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
    "id": "live_ui_iur.accepts.canonical_and_compatible_inputs",
    "statement": "When the interpreter receives canonical UnifiedIUR structs, canonical map payloads, or compatible extension nodes implementing UnifiedIUR.Element, the interpreter shall normalize them through one traversal path.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_iur.normalizes.render_tree",
    "statement": "When a node is interpreted, the interpreter shall emit a render tree containing stable ids, widget or layout kinds, normalized props, and ordered children.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_iur.validates.schema_markers",
    "statement": "If canonical schema markers are present on a map payload, then the interpreter shall validate the declared schema, source, and version before rendering proceeds.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_iur.extracts.signal_bindings",
    "statement": "When an interpreted node exposes signal-bearing fields, the interpreter shall emit normalized signal bindings containing widget identity, source field, and normalized signal payload.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_iur.emits.theme_and_layer_traits",
    "statement": "When an interpreted node carries style, layout, or overlay semantics, the interpreter shall emit normalized render traits needed by the widget, theme, and layer systems.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_iur.rejects.unsupported_nodes",
    "statement": "If an interpreted node kind is unsupported, then the interpreter shall return an explicit validation error and shall not silently drop the node.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_iur.interprets_canonical_tree",
    "given": ["a canonical UnifiedIUR tree containing layout, widget, and extension nodes adopted by the library"],
    "when": ["the tree is interpreted"],
    "then": ["canonical and compatible extension nodes are emitted into one normalized render tree"],
    "covers": ["live_ui_iur.accepts.canonical_and_compatible_inputs", "live_ui_iur.normalizes.render_tree"]
  },
  {
    "id": "live_ui_iur.validates_schema_markers",
    "given": ["a canonical map payload with schema markers"],
    "when": ["the payload is interpreted"],
    "then": ["schema name, source, and version are validated before render-tree generation"],
    "covers": ["live_ui_iur.validates.schema_markers"]
  },
  {
    "id": "live_ui_iur.extracts_button_binding",
    "given": ["a button node with an on_click signal"],
    "when": ["the node is interpreted"],
    "then": ["a normalized signal binding is emitted alongside the render-tree node"],
    "covers": ["live_ui_iur.extracts.signal_bindings", "live_ui_iur.normalizes.render_tree"]
  },
  {
    "id": "live_ui_iur.emits_overlay_traits",
    "given": ["a node carrying style, geometry, or overlay semantics"],
    "when": ["the node is interpreted"],
    "then": ["normalized traits needed by the widget, theme, and layer systems are emitted"],
    "covers": ["live_ui_iur.emits.theme_and_layer_traits", "live_ui_iur.normalizes.render_tree"]
  },
  {
    "id": "live_ui_iur_rejects_unknown_kind",
    "given": ["a payload whose interpreted node kind has no supported renderer contract"],
    "when": ["the payload is interpreted"],
    "then": ["the interpreter returns a validation error rather than dropping the node"],
    "covers": ["live_ui_iur.rejects.unsupported_nodes"]
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
      "live_ui_iur.accepts.canonical_and_compatible_inputs",
      "live_ui_iur.normalizes.render_tree",
      "live_ui_iur.validates.schema_markers",
      "live_ui_iur.extracts.signal_bindings",
      "live_ui_iur.emits.theme_and_layer_traits",
      "live_ui_iur.rejects.unsupported_nodes"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/iur/interpreter_test.exs",
    "covers": [
      "live_ui_iur.accepts.canonical_and_compatible_inputs",
      "live_ui_iur.normalizes.render_tree",
      "live_ui_iur.extracts.signal_bindings",
      "live_ui_iur.emits.theme_and_layer_traits",
      "live_ui_iur.rejects.unsupported_nodes"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/iur/dependency_test.exs",
    "covers": ["live_ui_iur.validates.schema_markers"]
  }
]
```
