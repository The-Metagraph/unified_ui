# UnifiedUi Runtime

This subject backfills the current runtime model for `packages/unified-ui`,
including the Elm-style behaviour, signal delivery, and supervised component
agent processes.

```spec-meta
id: unified_ui.runtime
kind: runtime
status: active
summary: Current runtime contract for `packages/unified-ui`, derived from the implemented Elm behaviour, signal helpers, bus, and agent runtime.
surface:
  - packages/unified-ui/lib/unified_ui/elm_architecture.ex
  - packages/unified-ui/lib/unified_ui/signals.ex
  - packages/unified-ui/lib/unified_ui/signal_bus.ex
  - packages/unified-ui/lib/unified_ui/agent.ex
  - packages/unified-ui/test/unified_ui/agent_test.exs
  - packages/unified-ui/test/unified_ui/signal_bus_test.exs
  - packages/unified-ui/test/unified_ui/signals
  - packages/unified-ui/test/unified_ui/integration/phase_5_test.exs
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: unified_ui.runtime.elm_behaviour
  statement: The package shall define an Elm-style component behaviour with `init/1`, `update/2`, and `view/1` callbacks over map-shaped model state, canonical `Jido.Signal` inputs, and IUR outputs.
  priority: must
  stability: stable

- id: unified_ui.runtime.signal_delivery
  statement: The package shall provide standard signal creation and validation helpers together with a PubSub-backed signal bus for broadcasting normalized `Jido.Signal` values.
  priority: must
  stability: stable

- id: unified_ui.runtime.component_lifecycle
  statement: The runtime shall support starting, locating, querying, signaling, rendering, and stopping supervised component processes by component id.
  priority: must
  stability: stable

- id: unified_ui.runtime.batching_and_dirty_tracking
  statement: The component server runtime shall batch pending signals, flush them into model updates, and rebuild current IUR and render results on demand.
  priority: must
  stability: stable

- id: unified_ui.runtime.recovery_patterns
  statement: The runtime shall degrade safely when initialization, update, topic subscription, or process lifecycle operations fail by returning fallback state or explicit runtime errors rather than crashing callers.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified-ui/lib/unified_ui/elm_architecture.ex
  covers:
    - unified_ui.runtime.elm_behaviour

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/signals.ex
  covers:
    - unified_ui.runtime.signal_delivery

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/signal_bus.ex
  covers:
    - unified_ui.runtime.signal_delivery

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/agent.ex
  covers:
    - unified_ui.runtime.component_lifecycle
    - unified_ui.runtime.batching_and_dirty_tracking
    - unified_ui.runtime.recovery_patterns

- kind: source_file
  target: packages/unified-ui/test/unified_ui/signals/signals_test.exs
  covers:
    - unified_ui.runtime.signal_delivery

- kind: source_file
  target: packages/unified-ui/test/unified_ui/signal_bus_test.exs
  covers:
    - unified_ui.runtime.signal_delivery

- kind: source_file
  target: packages/unified-ui/test/unified_ui/agent_test.exs
  covers:
    - unified_ui.runtime.component_lifecycle
    - unified_ui.runtime.batching_and_dirty_tracking
    - unified_ui.runtime.signal_delivery

- kind: source_file
  target: packages/unified-ui/test/unified_ui/integration/phase_5_test.exs
  covers:
    - unified_ui.runtime.component_lifecycle
    - unified_ui.runtime.recovery_patterns
```
