# TerminalUi Transport

This subject defines how `terminal_ui` translates between canonical ecosystem
event meaning and its native terminal interaction model.

## Related General Specs

- [Application Authority](../application_authority.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [TerminalUi Package](./package.spec.md)
- [TerminalUi Runtime](./runtime.spec.md)
- [TerminalUi Capabilities](./capabilities.spec.md)
- [TerminalUi IUR Renderer](./iur_renderer.spec.md)

```spec-meta
id: terminal_ui.transport
kind: integration
status: active
summary: Target boundary-translation contract for `terminal_ui`, preserving canonical event meaning and application-authoritative behavior across terminal-native interactions and capability-aware fallback modes.
surface:
  - packages/terminal_ui
  - .spec/specs/terminal_ui/transport.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: terminal_ui.transport.canonical_boundary_events
  statement: The package shall translate canonical boundary events using `Jido.Signal` and CloudEvents-compatible semantics whenever interactions cross the ecosystem package boundary.
  priority: must
  stability: stable

- id: terminal_ui.transport.native_terminal_event_model
  statement: The package may use its own native terminal interaction model internally, but that model shall translate to and from canonical boundary meaning without loss of event intent.
  priority: must
  stability: stable

- id: terminal_ui.transport.application_authority_preserved
  statement: Event translation shall preserve the application-authoritative behavior required by the `terminal_ui` runtime instead of moving canonical decision-making into backend-local input handling.
  priority: must
  stability: stable

- id: terminal_ui.transport.backend_input_normalization
  statement: Raw-mode and TTY-compatible keyboard, mouse, paste, resize, and focus inputs shall be normalized through the shared `terminal_ui` interaction model before they cross the canonical boundary.
  priority: must
  stability: stable

- id: terminal_ui.transport.no_boundary_leakage
  statement: Renderer-local event names, terminal escape-sequence details, backend-local input envelopes, and capability-probing internals shall not leak out as the cross-package contract of `terminal_ui`.
  priority: must
  stability: stable

- id: terminal_ui.transport.direct_native_usage_allowed
  statement: Direct native `terminal_ui` usage may handle interactions without crossing the canonical boundary, but crossing that boundary shall always preserve canonical event meaning.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: terminal_ui.transport.translate_boundary_input
  given: A keyboard shortcut, paste action, mouse gesture, or resize event on a `terminal_ui` screen must cross the ecosystem package boundary
  when: The package emits or consumes that event
  then: It translates between native terminal interaction behavior and canonical `Jido.Signal` meaning without exposing backend-local details

- id: terminal_ui.transport_keep_native_events_local
  given: A direct native `terminal_ui` interaction remains inside the package runtime
  when: The interaction does not cross an ecosystem boundary
  then: The package may handle it through native terminal runtime mechanics while retaining the ability to translate the same interaction family canonically when needed
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/terminal_ui/transport.spec.md
  covers:
    - terminal_ui.transport.canonical_boundary_events
    - terminal_ui.transport.native_terminal_event_model
    - terminal_ui.transport.application_authority_preserved
    - terminal_ui.transport.backend_input_normalization
    - terminal_ui.transport.no_boundary_leakage
    - terminal_ui.transport.direct_native_usage_allowed
    - terminal_ui.transport.translate_boundary_input
    - terminal_ui.transport_keep_native_events_local
```
