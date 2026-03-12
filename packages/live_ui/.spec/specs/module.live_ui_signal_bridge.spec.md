# LiveUi Signal Bridge

The signal bridge subject turns LiveView events into concrete `%Jido.Signal{}` values and keeps client payload normalization out of the screen modules.

This subject is also responsible for rejecting malformed or unauthorized event payloads before they become runtime signals.

```spec-meta
{
  "id": "module.live_ui_signal_bridge",
  "kind": "module",
  "status": "draft",
  "surface": ["LiveUi.Signals.Encoder", "LiveUi.Live.EventRouter", "LiveUi.WidgetState"],
  "relationships": [
    {"kind": "depends_on", "target": "package.live_ui"},
    {"kind": "depends_on", "target": "module.live_ui_iur_interpreter"},
    {"kind": "depends_on", "target": "module.live_ui_runtime"},
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
      "id": "signal_bridge_changes_require_runtime_alignment",
      "when": {
        "change_types": ["behavior_shape"]
      },
      "requires": [
        {"subject_ids": ["module.live_ui_runtime", "module.live_ui_iur_interpreter"]},
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
    "id": "live_ui_signals.liveview.events.normalize_to_unified",
    "statement": "When a LiveView event is accepted from a rendered widget, the signal bridge shall normalize the event into a concrete `%Jido.Signal{}` containing widget identity, widget kind, and event intent.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_signals.form_and_value_payloads.include_context",
    "statement": "When an input change or submit event is normalized, the signal bridge shall include the current value or form context needed by screen update handlers.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_signals.advanced_widgets.emit_stable_payloads",
    "statement": "When advanced widgets such as table, tabs, tree_view, pick_list, viewport, split_pane, command_palette, dialog, toast, or canvas emit events, the signal bridge shall normalize those events into stable `%Jido.Signal{}` payload shapes that do not leak raw browser event structure.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_signals.hook_events.share_validation_path",
    "statement": "When a JavaScript hook emits an interaction payload, the signal bridge shall normalize and validate that payload through the same dispatch path used for standard LiveView events.",
    "priority": "must",
    "stability": "stable"
  },
  {
    "id": "live_ui_signals.payloads.validated_before_dispatch",
    "statement": "If a client event payload is malformed or missing required descriptor metadata, then the signal bridge shall reject the payload before signal dispatch proceeds.",
    "priority": "must",
    "stability": "stable"
  }
]
```

## Scenarios

```spec-scenarios
[
  {
    "id": "live_ui_signals.button_click_roundtrip",
    "given": ["a rendered button descriptor with a click binding"],
    "when": ["the browser emits a phx-click event"],
    "then": ["the event is normalized into a concrete `%Jido.Signal{}` click signal and delivered to the runtime"],
    "covers": ["live_ui_signals.liveview.events.normalize_to_unified"]
  },
  {
    "id": "live_ui_signals.input_change_roundtrip",
    "given": ["a rendered text_input or form_builder field"],
    "when": ["the browser emits a change or submit event"],
    "then": ["the normalized signal includes the current value or form context required by the screen update handler"],
    "covers": ["live_ui_signals.form_and_value_payloads.include_context", "live_ui_signals.liveview.events.normalize_to_unified"]
  },
  {
    "id": "live_ui_signals.stateful_widget_payload",
    "given": ["a rendered table, tabs, tree_view, pick_list, viewport, split_pane, command_palette, dialog, toast, or canvas widget"],
    "when": ["the widget emits an interaction event"],
    "then": ["the event payload is normalized into a stable `%Jido.Signal{}` data shape without leaking raw browser event structure"],
    "covers": ["live_ui_signals.advanced_widgets.emit_stable_payloads"]
  },
  {
    "id": "live_ui_signals.hook_payload_roundtrip",
    "given": ["a rendered widget whose richer interaction is mediated by a JavaScript hook"],
    "when": ["the hook emits a payload toward the server"],
    "then": ["the payload is normalized and validated through the same dispatch path used for standard LiveView events"],
    "covers": ["live_ui_signals.hook_events.share_validation_path", "live_ui_signals.payloads.validated_before_dispatch"]
  },
  {
    "id": "live_ui_signals.rejects_malformed_payload",
    "given": ["a client event missing widget identity or required payload fields"],
    "when": ["the event router attempts normalization"],
    "then": ["the payload is rejected before signal dispatch proceeds"],
    "covers": ["live_ui_signals.payloads.validated_before_dispatch"]
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
      "live_ui_signals.liveview.events.normalize_to_unified",
      "live_ui_signals.form_and_value_payloads.include_context",
      "live_ui_signals.advanced_widgets.emit_stable_payloads",
      "live_ui_signals.hook_events.share_validation_path",
      "live_ui_signals.payloads.validated_before_dispatch"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/signals/encoder_test.exs",
    "covers": [
      "live_ui_signals.liveview.events.normalize_to_unified",
      "live_ui_signals.form_and_value_payloads.include_context",
      "live_ui_signals.advanced_widgets.emit_stable_payloads",
      "live_ui_signals.hook_events.share_validation_path"
    ]
  },
  {
    "kind": "test_file",
    "target": "test/live_ui/live/event_router_test.exs",
    "covers": ["live_ui_signals.payloads.validated_before_dispatch"]
  }
]
```
