# LiveUi Screen Macro

The screen macro subject defines the public wrapper API used by host applications for optional source-module adapters.

This subject should keep the host-facing wrapper small and explicit while hiding the shared runtime engine behind a stable `use LiveUi.Screen, source: ...` contract.

```spec-meta
{
  "id": "module.live_ui_screen_macro",
  "kind": "module",
  "status": "draft",
  "surface": ["LiveUi.Screen"],
  "relationships": [
    {"kind": "depends_on", "target": "package.live_ui"},
    {"kind": "depends_on", "target": "module.live_ui_host_integration"},
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
  "criticality": "medium",
  "primary_plane": "integration",
  "change_rules": [
    {
      "id": "screen_macro_changes_require_host_and_runtime_alignment",
      "when": {
        "change_types": ["behavior_shape"]
      },
      "requires": [
        {"subject_ids": ["module.live_ui_host_integration", "module.live_ui_runtime"]},
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
    "id": "live_ui_screen.uses_explicit_source_option",
    "statement": "When a host defines a screen wrapper, the LiveUi.Screen macro shall accept an explicit source option that identifies a source module which emits canonical UnifiedIUR from view/1.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_screen.source_is_module_only",
    "statement": "When the source option is declared on LiveUi.Screen, the macro shall require a source-module reference and shall not overload the option with registry keys, strings, or runtime-selected source values.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_screen.keeps_wrapper_minimal",
    "statement": "When a host defines a source wrapper with LiveUi.Screen, the wrapper shall remain a tiny manually authored LiveView module rather than requiring code generation.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_screen.delegates_to_shared_engine",
    "statement": "When a wrapper module mounts or handles events, the LiveUi.Screen macro shall delegate runtime behavior to the shared internal engine rather than reimplementing the rendering loop per wrapper.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_screen.preserve_host_customization_points",
    "statement": "While a host wrapper uses LiveUi.Screen, the macro shall preserve normal Phoenix customization points such as routing, auth, layout selection, and host module naming.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_screen.supports_narrow_context_callbacks",
    "statement": "When a host wrapper needs small integration hooks, the macro shall support narrow optional callbacks for runtime context enrichment and source option derivation without exposing the core LiveView lifecycle.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_screen.disallows_core_lifecycle_overrides",
    "statement": "While a host wrapper uses LiveUi.Screen, the macro shall keep mount, render, and handle_event behavior owned by the shared engine rather than allowing wrapper-specific overrides of the core rendering loop.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_screen.rejects_invalid_source_configuration",
    "statement": "If the screen macro is declared without a valid source-module configuration, then the macro shall fail with an explicit configuration error rather than deferring the failure to runtime rendering.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_screen.manual_wrapper_definition",
    "given": ["a host module declared as use LiveUi.Screen, source: MyApp.CounterSource"],
    "when": ["the host compiles and mounts the wrapper"],
    "then": ["the wrapper remains tiny, names its source explicitly, and delegates runtime behavior to the shared engine"],
    "covers": [
      "live_ui_screen.uses_explicit_source_option",
      "live_ui_screen.source_is_module_only",
      "live_ui_screen.keeps_wrapper_minimal",
      "live_ui_screen.delegates_to_shared_engine",
      "live_ui_screen.disallows_core_lifecycle_overrides"
    ]
  },
  {
    "id": "live_ui_screen.narrow_callback_usage",
    "given": ["a wrapper module that defines liveui_context/3 and liveui_source_opts/3"],
    "when": ["the wrapper mounts through LiveUi.Screen"],
    "then": ["the callbacks enrich runtime context and source opts without replacing mount, render, or handle_event ownership"],
    "covers": [
      "live_ui_screen.supports_narrow_context_callbacks",
      "live_ui_screen.disallows_core_lifecycle_overrides",
      "live_ui_screen.delegates_to_shared_engine"
    ]
  },
  {
    "id": "live_ui_screen.host_customization",
    "given": ["a host router and wrapper module with host-specific auth or layout behavior"],
    "when": ["the wrapper is mounted through the host app"],
    "then": ["the wrapper continues to participate in normal host routing and Phoenix customization points"],
    "covers": ["live_ui_screen.preserve_host_customization_points"]
  },
  {
    "id": "live_ui_screen.invalid_source_option",
    "given": ["a wrapper declaration missing the source option or using an invalid source module"],
    "when": ["the host compiles or boots the wrapper"],
    "then": ["an explicit configuration error is raised before runtime rendering proceeds"],
    "covers": ["live_ui_screen.rejects_invalid_source_configuration", "live_ui_screen.source_is_module_only"]
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
      "live_ui_screen.uses_explicit_source_option",
      "live_ui_screen.source_is_module_only",
      "live_ui_screen.keeps_wrapper_minimal",
      "live_ui_screen.delegates_to_shared_engine",
      "live_ui_screen.preserve_host_customization_points",
      "live_ui_screen.supports_narrow_context_callbacks",
      "live_ui_screen.disallows_core_lifecycle_overrides",
      "live_ui_screen.rejects_invalid_source_configuration"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/screen/macro_test.exs",
    "covers": [
      "live_ui_screen.uses_explicit_source_option",
      "live_ui_screen.source_is_module_only",
      "live_ui_screen.keeps_wrapper_minimal",
      "live_ui_screen.delegates_to_shared_engine",
      "live_ui_screen.supports_narrow_context_callbacks",
      "live_ui_screen.disallows_core_lifecycle_overrides",
      "live_ui_screen.rejects_invalid_source_configuration"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/host/router_integration_test.exs",
    "covers": ["live_ui_screen.preserve_host_customization_points"]
  }
]
```
