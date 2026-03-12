# LiveUi Runtime

The runtime subject is the LiveView-owned execution loop that mounts screens, holds runtime state, and coordinates rebuilds from events back into rendered assigns.

This subject should remain deterministic. Client events may enrich the runtime with widget-local state, but the server remains authoritative for the rendered descriptor tree.

```spec-meta
{
  "id": "module.live_ui_runtime",
  "kind": "module",
  "status": "draft",
  "surface": ["LiveUi.Runtime", "LiveUi.Runtime.Model", "LiveUi.Live.Engine", "LiveUi.Live.DynamicLive"],
  "relationships": [
    {"kind": "depends_on", "target": "package.live_ui"},
    {"kind": "depends_on", "target": "module.live_ui_host_integration"},
    {"kind": "depends_on", "target": "module.live_ui_iur_interpreter"},
    {"kind": "depends_on", "target": "module.live_ui_signal_bridge"},
    {"kind": "governed_by", "target": "policy.live_ui_governance"},
    {"kind": "governed_by", "target": "policy.live_ui_conformance"}
  ]
}
```

```spec-governance
{
  "owner": "team.live_ui",
  "criticality": "high",
  "primary_plane": "execution",
  "change_rules": [
    {
      "id": "runtime_changes_require_signal_and_host_alignment",
      "when": {
        "change_types": ["behavior_shape"]
      },
      "requires": [
        {"subject_ids": ["module.live_ui_host_integration", "module.live_ui_signal_bridge"]},
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
    "id": "live_ui_runtime.mount.initializes_model",
    "statement": "When a screen is mounted, the runtime shall initialize a model containing source input, screen state, widget-local state, interpreted view state, and error metadata.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_runtime.engine.shared_across_entrypoints",
    "statement": "When screen-specific wrappers and the dynamic generic LiveView are used, the runtime shall execute both entry styles through one shared internal engine.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_runtime.update.atomic_rebuild",
    "statement": "When an accepted `%Jido.Signal{}` is processed, the runtime shall apply screen updates, rebuild the source IUR, reinterpret the descriptor tree, and assign the new view state atomically.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_runtime.widget_state.server_authority",
    "statement": "While interactive widgets are active, the runtime shall keep adapter-owned widget-local state on the server and merge that state deterministically into rebuilds.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_runtime.error.degrades_deterministically",
    "statement": "If interpretation, rendering, or event validation fails, then the runtime shall expose a deterministic error state instead of crashing the mounted LiveView.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_runtime.mounts_dsl_screen",
    "given": ["a DSL-backed screen module and mount options"],
    "when": ["a screen-specific wrapper delegates mount to the shared engine"],
    "then": ["the runtime initializes screen state, builds the first IUR tree, interprets it, and stores the resulting descriptor tree in assigns"],
    "covers": ["live_ui_runtime.mount.initializes_model", "live_ui_runtime.engine.shared_across_entrypoints"]
  },
  {
    "id": "live_ui_runtime.mounts_dynamic_source",
    "given": ["a canonical UnifiedIUR source or validated runtime-selected source"],
    "when": ["the dynamic generic LiveView delegates mount to the shared engine"],
    "then": ["the runtime initializes through the same shared engine used by screen-specific wrappers"],
    "covers": ["live_ui_runtime.mount.initializes_model", "live_ui_runtime.engine.shared_across_entrypoints"]
  },
  {
    "id": "live_ui_runtime.processes_click_signal",
    "given": ["a mounted screen with a clickable widget"],
    "when": ["a click event is accepted and encoded as a concrete `%Jido.Signal{}`"],
    "then": ["the runtime updates screen state and publishes one atomically rebuilt descriptor tree"],
    "covers": ["live_ui_runtime.update.atomic_rebuild", "live_ui_runtime.widget_state.server_authority"]
  },
  {
    "id": "live_ui_runtime_handles_interpreter_failure",
    "given": ["a mounted screen whose interpreted node set contains an invalid widget payload"],
    "when": ["the runtime attempts to rebuild the descriptor tree"],
    "then": ["the runtime stores a deterministic error view instead of terminating the socket process"],
    "covers": ["live_ui_runtime.error.degrades_deterministically"]
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
      "live_ui_runtime.mount.initializes_model",
      "live_ui_runtime.engine.shared_across_entrypoints",
      "live_ui_runtime.update.atomic_rebuild",
      "live_ui_runtime.widget_state.server_authority",
      "live_ui_runtime.error.degrades_deterministically"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/runtime/runtime_test.exs",
    "covers": [
      "live_ui_runtime.mount.initializes_model",
      "live_ui_runtime.engine.shared_across_entrypoints",
      "live_ui_runtime.update.atomic_rebuild",
      "live_ui_runtime.widget_state.server_authority"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/live/engine_test.exs",
    "covers": [
      "live_ui_runtime.mount.initializes_model",
      "live_ui_runtime.engine.shared_across_entrypoints",
      "live_ui_runtime.update.atomic_rebuild",
      "live_ui_runtime.error.degrades_deterministically"
    ]
  }
]
```
