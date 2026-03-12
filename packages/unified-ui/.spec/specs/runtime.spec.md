# Runtime

Current runtime contract for Elm-style components, signals, and supervised component processes.

```spec-meta
id: unified_ui.runtime
kind: component
status: active
summary: ElmArchitecture behaviour, component runtime, signal helpers, and PubSub-backed signal delivery.
surface:
  - lib/unified_ui/elm_architecture.ex
  - lib/unified_ui/agent.ex
  - lib/unified_ui/signal_bus.ex
  - lib/unified_ui/signals.ex
  - guides/getting-started.md
  - guides/signals-and-events.md
```

## Requirements

```spec-requirements
- id: unified_ui.runtime.elm_behaviour
  statement: UnifiedUi.ElmArchitecture shall define init, update, and view callbacks for atom-key state maps and IUR output.
  priority: must
  stability: stable

- id: unified_ui.runtime.component_lifecycle
  statement: UnifiedUi.Agent shall start components under supervision, address them by component id, stop them, and expose current state, IUR, and render results.
  priority: must
  stability: evolving

- id: unified_ui.runtime.signal_delivery
  statement: UnifiedUi.Signals and UnifiedUi.SignalBus shall create standard signals, validate signal types, and deliver signals through component topics or PubSub topics.
  priority: must
  stability: stable

- id: unified_ui.runtime.batching_and_dirty_tracking
  statement: The component runtime shall batch burst signals in order and avoid rebuild work when updates leave component state unchanged.
  priority: should
  stability: evolving

- id: unified_ui.runtime.recovery_patterns
  statement: The runtime shall support persisted-state startup and the production-readiness recovery patterns currently covered by integration tests, including hot reload and runtime extension lifecycle flows.
  priority: should
  stability: evolving
```

## Scenarios

```spec-scenarios
- id: unified_ui.runtime.component_update_cycle
  given:
    - a component implementing UnifiedUi.ElmArchitecture
    - a supervised runtime component process
  when:
    - a signal is delivered to the component
  then:
    - the model state updates
    - the current IUR and render results can be queried by component id
  covers:
    - unified_ui.runtime.elm_behaviour
    - unified_ui.runtime.component_lifecycle
    - unified_ui.runtime.signal_delivery

- id: unified_ui.runtime.persisted_state_recovery
  given:
    - persisted or upgraded component state and runtime-managed component code
  when:
    - the component restarts or code is reloaded
  then:
    - the runtime preserves the recovered state shape and continues processing signals
  covers:
    - unified_ui.runtime.recovery_patterns
```

## Verification

```spec-verification
- kind: source_file
  target: lib/unified_ui/elm_architecture.ex
  covers:
    - unified_ui.runtime.elm_behaviour

- kind: source_file
  target: lib/unified_ui/agent.ex
  covers:
    - unified_ui.runtime.component_lifecycle
    - unified_ui.runtime.batching_and_dirty_tracking
    - unified_ui.runtime.recovery_patterns

- kind: source_file
  target: lib/unified_ui/signal_bus.ex
  covers:
    - unified_ui.runtime.signal_delivery

- kind: source_file
  target: lib/unified_ui/signals.ex
  covers:
    - unified_ui.runtime.signal_delivery

- kind: guide_file
  target: guides/getting-started.md
  covers:
    - unified_ui.runtime.elm_behaviour
    - unified_ui.runtime.component_lifecycle

- kind: guide_file
  target: guides/signals-and-events.md
  covers:
    - unified_ui.runtime.signal_delivery

- kind: test_file
  target: test/unified_ui/agent_test.exs
  covers:
    - unified_ui.runtime.component_lifecycle
    - unified_ui.runtime.batching_and_dirty_tracking
    - unified_ui.runtime.signal_delivery

- kind: test_file
  target: test/unified_ui/signal_bus_test.exs
  covers:
    - unified_ui.runtime.signal_delivery

- kind: test_file
  target: test/unified_ui/signals/signals_test.exs
  covers:
    - unified_ui.runtime.signal_delivery

- kind: test_file
  target: test/unified_ui/integration/phase_5_test.exs
  covers:
    - unified_ui.runtime.component_lifecycle
    - unified_ui.runtime.recovery_patterns

- kind: command
  target: mix test test/unified_ui/agent_test.exs test/unified_ui/signal_bus_test.exs test/unified_ui/signals/signals_test.exs test/unified_ui/integration/phase_5_test.exs
  execute: true
  covers:
    - unified_ui.runtime.elm_behaviour
    - unified_ui.runtime.component_lifecycle
    - unified_ui.runtime.signal_delivery
    - unified_ui.runtime.batching_and_dirty_tracking
    - unified_ui.runtime.recovery_patterns
```
