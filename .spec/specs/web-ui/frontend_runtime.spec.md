# WebUi Frontend Runtime

This subject backfills the current frontend runtime and Elm or JS bridge
contract implemented by `packages/web_ui`.

```spec-meta
id: web_ui.frontend_runtime
kind: runtime
status: active
summary: Current frontend runtime contract for `packages/web_ui`, including the UI model and message baseline, update flow, widget-event catalog or Elm bindings, JS interop policy, and the local Elm or JS harness bridge.
surface:
  - packages/web_ui/lib/web_ui/events/event_catalog.ex
  - packages/web_ui/lib/web_ui/events/elm_bindings.ex
  - packages/web_ui/lib/web_ui/ui/model.ex
  - packages/web_ui/lib/web_ui/ui/message.ex
  - packages/web_ui/lib/web_ui/ui/interop.ex
  - packages/web_ui/lib/web_ui/ui/runtime.ex
  - packages/web_ui/assets/js/app.js
  - packages/web_ui/assets/src/Main.elm
  - packages/web_ui/test/web_ui/events
  - packages/web_ui/test/web_ui/ui
  - packages/web_ui/test/web_ui/integration
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: web_ui.frontend_runtime.model_and_messages
  statement: 'The package shall define the current deterministic frontend model and typed message baseline for connection state, runtime context, view state, slice state, recovery state, websocket lifecycle, widget events, port events, and replay-control requests.'
  priority: must
  stability: stable

- id: web_ui.frontend_runtime.update_flow
  statement: 'The frontend runtime shall implement the current init and update flow for join or ping bootstrap, widget-event dispatch, websocket recv or error handling, retry and cancel paths, replay controls, and fail-closed UI error handling.'
  priority: must
  stability: stable

- id: web_ui.frontend_runtime.event_catalog_and_bindings
  statement: 'The package shall maintain the current canonical widget event catalog, payload-key requirements, route-family conventions, and Elm binding helpers used to construct supported widget events.'
  priority: must
  stability: stable

- id: web_ui.frontend_runtime.interop_and_harness
  statement: 'The JS interop bridge and local Elm or JS harness shall expose the current ports, canonical runtime transport event names, blocked interop actions, and loopback guardrails used by the frontend runtime scaffold.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/web_ui/lib/web_ui/ui/model.ex
  covers:
    - web_ui.frontend_runtime.model_and_messages

- kind: source_file
  target: packages/web_ui/lib/web_ui/ui/message.ex
  covers:
    - web_ui.frontend_runtime.model_and_messages

- kind: source_file
  target: packages/web_ui/lib/web_ui/ui/runtime.ex
  covers:
    - web_ui.frontend_runtime.update_flow

- kind: source_file
  target: packages/web_ui/lib/web_ui/events/event_catalog.ex
  covers:
    - web_ui.frontend_runtime.event_catalog_and_bindings

- kind: source_file
  target: packages/web_ui/lib/web_ui/events/elm_bindings.ex
  covers:
    - web_ui.frontend_runtime.event_catalog_and_bindings

- kind: source_file
  target: packages/web_ui/lib/web_ui/ui/interop.ex
  covers:
    - web_ui.frontend_runtime.interop_and_harness

- kind: source_file
  target: packages/web_ui/assets/js/app.js
  covers:
    - web_ui.frontend_runtime.interop_and_harness

- kind: source_file
  target: packages/web_ui/assets/src/Main.elm
  covers:
    - web_ui.frontend_runtime.interop_and_harness

- kind: source_file
  target: packages/web_ui/test/web_ui/ui/model_test.exs
  covers:
    - web_ui.frontend_runtime.model_and_messages

- kind: source_file
  target: packages/web_ui/test/web_ui/ui/message_test.exs
  covers:
    - web_ui.frontend_runtime.model_and_messages

- kind: source_file
  target: packages/web_ui/test/web_ui/ui/runtime_bootstrap_test.exs
  covers:
    - web_ui.frontend_runtime.update_flow

- kind: source_file
  target: packages/web_ui/test/web_ui/ui/runtime_update_test.exs
  covers:
    - web_ui.frontend_runtime.update_flow

- kind: source_file
  target: packages/web_ui/test/web_ui/ui/runtime_recovery_test.exs
  covers:
    - web_ui.frontend_runtime.update_flow

- kind: source_file
  target: packages/web_ui/test/web_ui/ui/runtime_replay_control_test.exs
  covers:
    - web_ui.frontend_runtime.update_flow

- kind: source_file
  target: packages/web_ui/test/web_ui/ui/runtime_interop_test.exs
  covers:
    - web_ui.frontend_runtime.interop_and_harness

- kind: source_file
  target: packages/web_ui/test/web_ui/ui/interop_test.exs
  covers:
    - web_ui.frontend_runtime.interop_and_harness

- kind: source_file
  target: packages/web_ui/test/web_ui/events/event_catalog_test.exs
  covers:
    - web_ui.frontend_runtime.event_catalog_and_bindings

- kind: source_file
  target: packages/web_ui/test/web_ui/events/elm_bindings_test.exs
  covers:
    - web_ui.frontend_runtime.event_catalog_and_bindings

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_02_elm_runtime_test.exs
  covers:
    - web_ui.frontend_runtime.update_flow

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_35_elm_runtime_transport_bridge_test.exs
  covers:
    - web_ui.frontend_runtime.interop_and_harness
```
