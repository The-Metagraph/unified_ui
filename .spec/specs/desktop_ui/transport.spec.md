# DesktopUi Transport

This subject defines how `desktop_ui` translates between canonical ecosystem
event meaning and its native desktop interaction model.

## Related General Specs

- [Signal Transport](../signal_transport.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [DesktopUi Package](./package.spec.md)
- [DesktopUi Runtime](./runtime.spec.md)
- [DesktopUi IUR Renderer](./iur_renderer.spec.md)

```spec-meta
id: desktop_ui.transport
kind: integration
status: active
summary: Target boundary-translation contract for `desktop_ui`, preserving canonical event meaning across native desktop interactions.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop_ui/transport.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: desktop_ui.transport.canonical_boundary_events
  statement: The package shall translate canonical boundary events using `Jido.Signal` and CloudEvents-compatible semantics whenever interactions cross the ecosystem package boundary.
  priority: must
  stability: stable

- id: desktop_ui.transport.native_desktop_event_model
  statement: The package may use its own native desktop interaction model internally, but that model shall translate to and from canonical boundary meaning without loss of event intent.
  priority: must
  stability: stable

- id: desktop_ui.transport.platform_input_normalization
  statement: Native Windows, macOS, and Linux input events shall be normalized through the shared `desktop_ui` interaction model before they cross the canonical boundary.
  priority: must
  stability: stable

- id: desktop_ui.transport.no_boundary_leakage
  statement: Renderer-local event names, SDL2 callback details, and platform-local input envelopes shall not leak out as the cross-package contract of `desktop_ui`.
  priority: must
  stability: stable

- id: desktop_ui.transport.direct_native_usage_allowed
  statement: Direct native `desktop_ui` usage may handle interactions without crossing the canonical boundary, but crossing that boundary shall always preserve canonical event meaning.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: desktop_ui.transport.translate_boundary_input
  given: A click, keyboard shortcut, or focus change on a `desktop_ui` screen must cross the ecosystem package boundary
  when: The package emits or consumes that event
  then: It translates between native desktop interaction behavior and canonical `Jido.Signal` meaning without exposing renderer-local or platform-local event details

- id: desktop_ui.transport_keep_native_events_local
  given: A direct native `desktop_ui` interaction remains inside the package runtime
  when: The interaction does not cross an ecosystem boundary
  then: The package may handle it through native desktop runtime mechanics while retaining the ability to translate the same interaction family canonically when needed
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop_ui/transport.spec.md
  covers:
    - desktop_ui.transport.canonical_boundary_events
    - desktop_ui.transport.native_desktop_event_model
    - desktop_ui.transport.platform_input_normalization
    - desktop_ui.transport.no_boundary_leakage
    - desktop_ui.transport.direct_native_usage_allowed
    - desktop_ui.transport.translate_boundary_input
    - desktop_ui.transport_keep_native_events_local
```
