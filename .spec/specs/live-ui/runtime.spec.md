# LiveUi Runtime

This subject backfills the current host/runtime execution model for
`packages/live_ui`, based on its source validation, shared runtime model,
signal encoding, wrapper macro, and LiveView engine.

```spec-meta
id: live_ui.runtime
kind: runtime
status: active
summary: Current runtime and host integration contract for `packages/live_ui`, including source validation, deterministic runtime state, event encoding, widget-state overlaying, and wrapper or dynamic entrypoints.
surface:
  - packages/live_ui/lib/live_ui/configuration_error.ex
  - packages/live_ui/lib/live_ui/source.ex
  - packages/live_ui/lib/live_ui/runtime.ex
  - packages/live_ui/lib/live_ui/runtime
  - packages/live_ui/lib/live_ui/widget_state.ex
  - packages/live_ui/lib/live_ui/signals
  - packages/live_ui/lib/live_ui/live
  - packages/live_ui/lib/live_ui/screen.ex
  - packages/live_ui/lib/live_ui/router.ex
  - packages/live_ui/lib/live_ui/session.ex
  - packages/live_ui/test/live_ui/runtime
  - packages/live_ui/test/live_ui/host
  - packages/live_ui/test/live_ui/live
  - packages/live_ui/test/live_ui/screen
  - packages/live_ui/test/live_ui/signals
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: live_ui.runtime.source_validation
  statement: 'The package shall validate the current two source modes for runtime execution: module-backed screen sources with required callbacks and raw IUR sources represented as maps or UnifiedIUR protocol structs.'
  priority: must
  stability: stable

- id: live_ui.runtime.shared_model
  statement: 'The runtime shall build and update the current deterministic `LiveUi.Runtime.Model` shape, including runtime context, source metadata, screen state, IUR tree, descriptor tree, signal bindings, render metadata, and event bookkeeping.'
  priority: must
  stability: stable

- id: live_ui.runtime.event_encoding
  statement: 'The package shall encode current LiveView and hook payloads into concrete `Jido.Signal` values with normalized type, subject, source, intent, and scoped payload fields.'
  priority: must
  stability: stable

- id: live_ui.runtime.widget_state_overlay
  statement: 'The runtime shall maintain the current server-authoritative widget-local state overlay for advanced widgets and apply that overlay back onto the normalized descriptor tree after interpretation.'
  priority: must
  stability: stable

- id: live_ui.runtime.host_entrypoints
  statement: 'The package shall keep the current host integration model in which wrapper LiveViews, dynamic LiveViews, route helpers, session normalization, and the shared engine all converge on the same runtime model shape and rendering path.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/live_ui/lib/live_ui/source.ex
  covers:
    - live_ui.runtime.source_validation

- kind: source_file
  target: packages/live_ui/lib/live_ui/runtime.ex
  covers:
    - live_ui.runtime.shared_model

- kind: source_file
  target: packages/live_ui/lib/live_ui/signals/encoder.ex
  covers:
    - live_ui.runtime.event_encoding

- kind: source_file
  target: packages/live_ui/lib/live_ui/widget_state.ex
  covers:
    - live_ui.runtime.widget_state_overlay

- kind: source_file
  target: packages/live_ui/test/live_ui/runtime/runtime_test.exs
  covers:
    - live_ui.runtime.shared_model
    - live_ui.runtime.event_encoding
    - live_ui.runtime.widget_state_overlay

- kind: source_file
  target: packages/live_ui/test/live_ui/live/engine_test.exs
  covers:
    - live_ui.runtime.host_entrypoints
    - live_ui.runtime.shared_model

- kind: source_file
  target: packages/live_ui/test/live_ui/host/entrypoint_parity_test.exs
  covers:
    - live_ui.runtime.host_entrypoints

- kind: source_file
  target: packages/live_ui/test/live_ui/host/router_integration_test.exs
  covers:
    - live_ui.runtime.host_entrypoints

- kind: source_file
  target: packages/live_ui/test/live_ui/screen/macro_test.exs
  covers:
    - live_ui.runtime.host_entrypoints

- kind: source_file
  target: packages/live_ui/test/live_ui/signals/encoder_test.exs
  covers:
    - live_ui.runtime.event_encoding
```
