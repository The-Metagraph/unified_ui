# Adapters

Current adapter contract for multi-platform rendering, event normalization, and renderer support utilities.

```spec-meta
id: unified_ui.adapters
kind: component
status: active
summary: Shared renderer behaviour plus terminal, desktop, and web adapters coordinated through common state, security, and routing helpers.
surface:
  - lib/unified_ui/adapters/protocol.ex
  - lib/unified_ui/adapters/coordinator.ex
  - lib/unified_ui/adapters/state.ex
  - lib/unified_ui/adapters/shared.ex
  - lib/unified_ui/adapters/security.ex
  - lib/unified_ui/adapters/terminal/*.ex
  - lib/unified_ui/adapters/desktop/*.ex
  - lib/unified_ui/adapters/web/*.ex
  - guides/platform-guides.md
  - guides/platforms/terminal.md
  - guides/platforms/desktop.md
  - guides/platforms/web.md
  - guides/signals-and-events.md
```

## Requirements

```spec-requirements
- id: unified_ui.adapters.renderer_contract
  statement: Terminal, desktop, and web renderers shall implement the shared renderer contract for render, update, and destroy operations using adapter state structures.
  priority: must
  stability: stable

- id: unified_ui.adapters.coordination
  statement: UnifiedUi.Adapters.Coordinator shall detect platforms, select renderers, render on one or many platforms, and coordinate state or signal routing across those platforms.
  priority: must
  stability: evolving

- id: unified_ui.adapters.event_normalization
  statement: Adapter event modules shall normalize native terminal, desktop, and web events into consistent Jido.Signal values and payload shapes.
  priority: must
  stability: stable

- id: unified_ui.adapters.security_pipeline
  statement: Adapter security helpers shall validate event actions, enforce payload limits, sanitize string inputs, and redact sensitive fields before signals are emitted.
  priority: must
  stability: stable

- id: unified_ui.adapters.shared_support
  statement: Adapter support modules shall provide reusable renderer state, tree traversal, element lookup, and style collection helpers for all platforms.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.adapters.multi_platform_render
  given:
    - a single IUR tree and the currently supported platforms
  when:
    - the coordinator renders on one, many, or all renderers
  then:
    - each selected platform returns renderer state according to the shared contract
  covers:
    - unified_ui.adapters.renderer_contract
    - unified_ui.adapters.coordination

- id: unified_ui.adapters.consistent_event_routing
  given:
    - platform-native input events from the terminal, desktop, and web adapters
  when:
    - the adapters normalize and route those events
  then:
    - the resulting signals share a consistent type and payload shape and pass through the security pipeline
  covers:
    - unified_ui.adapters.event_normalization
    - unified_ui.adapters.security_pipeline
```

## Verification

```spec-verification
- kind: source_file
  target: lib/unified_ui/adapters/protocol.ex
  covers:
    - unified_ui.adapters.renderer_contract

- kind: source_file
  target: lib/unified_ui/adapters/coordinator.ex
  covers:
    - unified_ui.adapters.coordination

- kind: source_file
  target: lib/unified_ui/adapters/state.ex
  covers:
    - unified_ui.adapters.shared_support

- kind: source_file
  target: lib/unified_ui/adapters/shared.ex
  covers:
    - unified_ui.adapters.shared_support

- kind: source_file
  target: lib/unified_ui/adapters/security.ex
  covers:
    - unified_ui.adapters.security_pipeline

- kind: guide_file
  target: guides/platform-guides.md
  covers:
    - unified_ui.adapters.renderer_contract
    - unified_ui.adapters.coordination

- kind: guide_file
  target: guides/platforms/terminal.md
  covers:
    - unified_ui.adapters.renderer_contract
    - unified_ui.adapters.event_normalization

- kind: guide_file
  target: guides/platforms/desktop.md
  covers:
    - unified_ui.adapters.renderer_contract
    - unified_ui.adapters.event_normalization

- kind: guide_file
  target: guides/platforms/web.md
  covers:
    - unified_ui.adapters.renderer_contract
    - unified_ui.adapters.event_normalization

- kind: guide_file
  target: guides/signals-and-events.md
  covers:
    - unified_ui.adapters.event_normalization

- kind: test_file
  target: test/unified_ui/adapters/coordinator_test.exs
  covers:
    - unified_ui.adapters.coordination

- kind: test_file
  target: test/unified_ui/adapters/security_test.exs
  covers:
    - unified_ui.adapters.security_pipeline

- kind: test_file
  target: test/unified_ui/adapters/state_test.exs
  covers:
    - unified_ui.adapters.shared_support

- kind: test_file
  target: test/unified_ui/adapters/terminal/events_test.exs
  covers:
    - unified_ui.adapters.event_normalization

- kind: test_file
  target: test/unified_ui/adapters/desktop/renderer_test.exs
  covers:
    - unified_ui.adapters.renderer_contract

- kind: test_file
  target: test/unified_ui/adapters/web/renderer_test.exs
  covers:
    - unified_ui.adapters.renderer_contract

- kind: test_file
  target: test/unified_ui/integration/phase_3_test.exs
  covers:
    - unified_ui.adapters.renderer_contract
    - unified_ui.adapters.coordination
    - unified_ui.adapters.event_normalization
    - unified_ui.adapters.shared_support

- kind: command
  target: mix test test/unified_ui/adapters test/unified_ui/integration/phase_3_test.exs
  execute: true
  covers:
    - unified_ui.adapters.renderer_contract
    - unified_ui.adapters.coordination
    - unified_ui.adapters.event_normalization
    - unified_ui.adapters.security_pipeline
    - unified_ui.adapters.shared_support
```
