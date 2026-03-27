# LiveUi Transport

This subject defines how `live_ui` translates between canonical ecosystem event
meaning and its native LiveView interaction model.

## Related General Specs

- [Signal Transport](../signal_transport.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [LiveUi Package](./package.spec.md)
- [LiveUi Runtime](./runtime.spec.md)
- [LiveUi IUR Renderer](./iur_renderer.spec.md)

```spec-meta
id: live_ui.transport
kind: integration
status: active
summary: Target boundary-translation contract for `live_ui`, preserving canonical event meaning across LiveView-native interactions.
surface:
  - packages/live_ui
  - .spec/specs/live_ui/transport.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: live_ui.transport.canonical_boundary_events
  statement: The package shall translate canonical boundary events using `Jido.Signal` and CloudEvents-compatible semantics whenever interactions cross the ecosystem package boundary.
  priority: must
  stability: stable

- id: live_ui.transport.native_liveview_event_model
  statement: The package may use its own native LiveView interaction model internally, but that model shall translate to and from canonical boundary meaning without loss of event intent.
  priority: must
  stability: stable

- id: live_ui.transport.server_authority_preserved
  statement: Event translation shall preserve the server-authoritative behavior required by the `live_ui` runtime instead of moving canonical decision-making into browser-only event handling.
  priority: must
  stability: stable

- id: live_ui.transport.no_boundary_leakage
  statement: Renderer-local event names, hook-local payload shapes, and renderer-local transport envelopes shall not leak out as the cross-package contract of `live_ui`.
  priority: must
  stability: stable

- id: live_ui.transport.direct_native_usage_allowed
  statement: Direct native `live_ui` usage may handle interactions without crossing the canonical boundary, but crossing that boundary shall always preserve canonical event meaning.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: live_ui.transport.translate_boundary_click
  given: A click or submit interaction on a `live_ui` screen must cross the ecosystem package boundary
  when: The package emits or consumes that event
  then: It translates between native LiveView interaction behavior and canonical `Jido.Signal` meaning without exposing renderer-local event details

- id: live_ui.transport_keep_native_events_local
  given: A direct native `live_ui` interaction remains inside the package runtime
  when: The interaction does not cross an ecosystem boundary
  then: The package may handle it through native LiveView mechanics while retaining the ability to translate the same interaction family canonically when needed
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live_ui/transport.spec.md
  covers:
    - live_ui.transport.canonical_boundary_events
    - live_ui.transport.native_liveview_event_model
    - live_ui.transport.server_authority_preserved
    - live_ui.transport.no_boundary_leakage
    - live_ui.transport.direct_native_usage_allowed
    - live_ui.transport.translate_boundary_click
    - live_ui.transport_keep_native_events_local
```
