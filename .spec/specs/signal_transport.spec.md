# Signal Transport

This subject defines the canonical event and transport semantics across the ecosystem.

```spec-meta
id: ecosystem.signal_transport
kind: integration
status: active
summary: Shared Jido.Signal and CloudEvents-compatible boundary contract across the DSL, IUR consumers, and runtime libraries with native signal translation.
surface:
  - packages/unified-ui
  - packages/unified_iur
  - packages/live_ui
  - packages/elm_ui
  - packages/desktop_ui
  - packages/terminal_ui
  - .spec/specs/signal_transport.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.canonical_navigation_boundary
  - repo.ecosystem.elm_ui_naming
```

## Requirements

```spec-requirements
- id: ecosystem.signal_transport.jido_signal_canonical
  statement: Ecosystem UI events shall be expressed as `Jido.Signal` values using CloudEvents-compatible semantics.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.dsl_event_bindings
  statement: `unified_ui` authored widget interaction bindings shall compile to signal descriptors that can be transported as the canonical event contract.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.elm_ui_bridge
  statement: `elm_ui` shall translate between canonical widget events at the ecosystem boundary and its native Phoenix-and-Elm interaction model while preserving canonical event meaning.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.live_bridge
  statement: `live_ui` shall translate between canonical widget events at the ecosystem boundary and its native LiveView interaction model while preserving canonical event meaning and server-authoritative UI behavior.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.desktop_translation
  statement: `desktop_ui` shall translate between native desktop input and the canonical signal contract before events cross package boundaries.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.terminal_bridge
  statement: `terminal_ui` shall translate between canonical widget events at the ecosystem boundary and its native terminal interaction model for keyboard, mouse, paste, resize, and focus events while preserving canonical event meaning across capability-aware degradation.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.native_signal_models_allowed
  statement: Renderer-specific native signal models may vary by library, but translation to or from the canonical event contract shall preserve canonical event meaning.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.local_state_not_contract
  statement: Renderer-specific local state and native signal mechanics may vary by library, but cross-package event meanings shall remain canonical at the signal contract boundary.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.navigation_transition_meaning
  statement: Navigation interactions that cross ecosystem package boundaries shall preserve canonical screen-transition meaning, including transition action, symbolic screen target when applicable, and params, without requiring browser-route syntax or runtime-specific identifiers.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.shared_transition_validation_and_fixtures
  statement: The ecosystem shall expose shared canonical transition fixtures, validation rules, and review summaries that runtime packages can consume consistently when transporting screen transitions across package boundaries.
  priority: must
  stability: stable
```

## Exceptions

```spec-exceptions
- id: ecosystem.signal_transport.desktop_bridge_evolving
  covers:
    - ecosystem.signal_transport.desktop_translation
  reason: The desktop runtime is expected to normalize native input into canonical signals, but the SDL2 event bridge is still evolving.

- id: ecosystem.signal_transport.terminal_bridge_evolving
  covers:
    - ecosystem.signal_transport.terminal_bridge
  reason: The terminal runtime is expected to normalize terminal-native events into canonical signals, but backend fallback behavior and degradation-aware translation are still evolving.
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/signal_transport.spec.md
  covers:
    - ecosystem.signal_transport.jido_signal_canonical
    - ecosystem.signal_transport.dsl_event_bindings
    - ecosystem.signal_transport.elm_ui_bridge
    - ecosystem.signal_transport.live_bridge
    - ecosystem.signal_transport.desktop_translation
    - ecosystem.signal_transport.terminal_bridge
    - ecosystem.signal_transport.native_signal_models_allowed
    - ecosystem.signal_transport.local_state_not_contract
    - ecosystem.signal_transport.navigation_transition_meaning
    - ecosystem.signal_transport.shared_transition_validation_and_fixtures
```
