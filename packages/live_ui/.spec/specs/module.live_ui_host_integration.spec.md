# LiveUi Host Integration

The host integration subject defines how `live_ui` is mounted inside another Phoenix application.

This subject is the public library boundary for routing, session/context propagation, direct widget composition, and asset registration for the independent widget library. It should make `live_ui` easy to adopt without requiring a standalone Phoenix app shell.

```spec-meta
{
  "id": "module.live_ui_host_integration",
  "kind": "module",
  "status": "draft",
  "surface": ["LiveUi", "LiveUi.Router", "LiveUi.Assets", "LiveUi.Session", "LiveUi.Widgets"],
  "relationships": [
    {"kind": "depends_on", "target": "package.live_ui"},
    {"kind": "governed_by", "target": "policy.live_ui_governance"},
    {"kind": "governed_by", "target": "policy.live_ui_conformance"},
    {"kind": "relates_to", "target": "module.live_ui_screen_macro"},
    {"kind": "relates_to", "target": "module.live_ui_runtime"},
    {"kind": "relates_to", "target": "module.live_ui_theme_system"},
    {"kind": "relates_to", "target": "module.live_ui_signal_bridge"}
  ]
}
```

```spec-governance
{
  "owner": "team.live_ui",
  "criticality": "high",
  "primary_plane": "integration",
  "change_rules": [
    {
      "id": "host_integration_changes_require_runtime_and_docs_alignment",
      "when": {
        "change_types": ["behavior_shape"]
      },
      "requires": [
        {"artifacts": ["docs/architecture.md"]},
        {"subject_ids": ["module.live_ui_runtime", "module.live_ui_theme_system"]}
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
    "id": "live_ui_host.mounts_in_host_router",
    "statement": "When a host Phoenix application integrates live_ui, the library shall expose mount helpers or route conventions that allow canonical UnifiedIUR views to be mounted from the host router without requiring a standalone endpoint.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_host.exposes_public_widgets",
    "statement": "When a host wants to compose screens directly, the integration layer shall expose live_ui widgets and layouts as public Phoenix components that can be used without UnifiedIUR input.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_host.supports_iur_primary_entrypoint",
    "statement": "When a host renders live_ui, the integration layer shall support a generic canonical UnifiedIUR entrypoint as the primary host-facing rendering path.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_host.supports_source_wrappers",
    "statement": "When a host wants a small wrapper around a source module that emits UnifiedIUR, the integration layer shall support tiny manually authored screen-specific LiveView wrappers declared with use LiveUi.Screen, source: <source module>.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_host.accepts_host_session_context",
    "statement": "When a mounted UI starts, the host integration layer shall normalize host session data, route params, and assigns into runtime context for the LiveUi runtime.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_host.exposes_widget_assets",
    "statement": "When the host integrates the widget library, the library shall expose hook registration and theme or styling asset entrypoints that the host application can import into its own bundle.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_host.respects_host_shell",
    "statement": "While a UI is mounted inside a host application, the integration layer shall preserve host ownership of layouts, authentication, endpoint configuration, and release topology.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_host.shared_engine_across_entrypoints",
    "statement": "When direct widget composition, source-module wrappers, and the generic canonical IUR entrypoint are used together, the integration layer shall keep them aligned to the same internal rendering contract.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_host.router_mount",
    "given": ["a host Phoenix router that wants to expose a live_ui route"],
    "when": ["the host mounts the library"],
    "then": ["a canonical UnifiedIUR view is reachable through the host router without a separate live_ui endpoint"],
    "covers": ["live_ui_host.mounts_in_host_router", "live_ui_host.supports_iur_primary_entrypoint", "live_ui_host.respects_host_shell"]
  },
  {
    "id": "live_ui_host.direct_widget_usage",
    "given": ["a host LiveView that wants to compose screens directly from live_ui widgets"],
    "when": ["the host imports and renders the public widget components"],
    "then": ["the host can build screens directly without requiring UnifiedIUR input"],
    "covers": ["live_ui_host.exposes_public_widgets", "live_ui_host.shared_engine_across_entrypoints"]
  },
  {
    "id": "live_ui_host.session_normalization",
    "given": ["host session data, route params, and assigns"],
    "when": ["a live_ui screen mounts"],
    "then": ["the data is normalized into runtime context before the runtime initializes the UI"],
    "covers": ["live_ui_host.accepts_host_session_context"]
  },
  {
    "id": "live_ui_host.source_wrapper_mount",
    "given": ["a host module that wraps a source module emitting UnifiedIUR"],
    "when": ["the host mounts the wrapper"],
    "then": ["the route renders through the wrapper without replacing the canonical IUR entrypoint as the primary path"],
    "covers": ["live_ui_host.supports_source_wrappers", "live_ui_host.mounts_in_host_router"]
  },
  {
    "id": "live_ui_host.asset_registration",
    "given": ["a host application rendering interactive and themed live_ui widgets"],
    "when": ["the host imports live_ui assets"],
    "then": ["the host can register the library's hooks and styling entrypoints in its own bundle and keep the widgets interactive and themed"],
    "covers": ["live_ui_host.exposes_widget_assets", "live_ui_host.respects_host_shell"]
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
      "live_ui_host.mounts_in_host_router",
      "live_ui_host.exposes_public_widgets",
      "live_ui_host.supports_iur_primary_entrypoint",
      "live_ui_host.supports_source_wrappers",
      "live_ui_host.accepts_host_session_context",
      "live_ui_host.exposes_widget_assets",
      "live_ui_host.respects_host_shell",
      "live_ui_host.shared_engine_across_entrypoints"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/host/router_integration_test.exs",
    "covers": ["live_ui_host.mounts_in_host_router", "live_ui_host.supports_source_wrappers", "live_ui_host.supports_iur_primary_entrypoint", "live_ui_host.respects_host_shell"]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/components/widget_rendering_test.exs",
    "covers": ["live_ui_host.exposes_public_widgets"]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/host/session_test.exs",
    "covers": ["live_ui_host.accepts_host_session_context"]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/assets/hooks_test.exs",
    "covers": ["live_ui_host.exposes_widget_assets"]
  }
]
```
