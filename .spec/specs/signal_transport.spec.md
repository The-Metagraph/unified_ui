# Signal Transport

This subject defines the canonical event and transport semantics across the ecosystem.

```spec-meta
id: ecosystem.signal_transport
kind: integration
status: active
summary: Shared Jido.Signal and CloudEvents-compatible transport contract across the DSL, IUR consumers, and renderer runtimes.
surface:
  - packages/unified-ui
  - packages/live_ui
  - packages/web_ui
  - packages/desktop_ui
  - .spec/specs/signal_transport.spec.md
decisions:
  - repo.ecosystem.contract_model
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

- id: ecosystem.signal_transport.web_bridge
  statement: `web_ui` shall bridge canonical widget events between Phoenix and Elm through CloudEvents-shaped envelopes while preserving canonical event meaning across the boundary.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.live_bridge
  statement: `live_ui` shall bridge canonical widget events over Phoenix channels using Jido.Signal and CloudEvents semantics while preserving server-authoritative UI behavior.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.desktop_translation
  statement: `desktop_ui` shall translate native platform input into the same canonical signal contract before events cross package boundaries.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.desktop_internal_standard
  statement: `desktop_ui` shall use the same canonical `Jido.Signal` and CloudEvents-compatible semantics for internal runtime and widget communication, not only for external package boundaries.
  priority: must
  stability: stable

- id: ecosystem.signal_transport.local_state_not_contract
  statement: Renderer-specific local state may vary by library, but cross-package event meanings shall remain canonical at the signal contract boundary.
  priority: must
  stability: stable
```

## Exceptions

```spec-exceptions
- id: ecosystem.signal_transport.desktop_bridge_evolving
  covers:
    - ecosystem.signal_transport.desktop_translation
    - ecosystem.signal_transport.desktop_internal_standard
  reason: The desktop runtime is expected to normalize native input into canonical signals, but the SDL2 event bridge is still evolving.
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/signal_transport.spec.md
  covers:
    - ecosystem.signal_transport.jido_signal_canonical
    - ecosystem.signal_transport.dsl_event_bindings
    - ecosystem.signal_transport.web_bridge
    - ecosystem.signal_transport.live_bridge
    - ecosystem.signal_transport.desktop_translation
    - ecosystem.signal_transport.desktop_internal_standard
    - ecosystem.signal_transport.local_state_not_contract
```
