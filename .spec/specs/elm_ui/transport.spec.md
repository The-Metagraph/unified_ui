# ElmUi Transport

This subject defines how `elm_ui` translates between canonical ecosystem event
meaning and its native Phoenix-and-Elm interaction model.

## Related General Specs

- [Signal Transport](../signal_transport.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [ElmUi Package](./package.spec.md)
- [ElmUi Server Runtime](./server_runtime.spec.md)
- [ElmUi Frontend Runtime](./frontend_runtime.spec.md)
- [ElmUi IUR Renderer](./iur_renderer.spec.md)

```spec-meta
id: elm_ui.transport
kind: integration
status: active
summary: Target boundary-translation contract for `elm_ui`, preserving canonical event meaning across the Phoenix-and-Elm web runtime.
surface:
  - packages/elm_ui
  - .spec/specs/elm_ui/transport.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.elm_ui_naming
```

## Requirements

```spec-requirements
- id: elm_ui.transport.canonical_boundary_events
  statement: The package shall translate canonical boundary events using `Jido.Signal` and CloudEvents-compatible semantics whenever interactions cross the ecosystem package boundary.
  priority: must
  stability: stable

- id: elm_ui.transport.native_web_event_model
  statement: The package may use its own native Phoenix-and-Elm interaction model internally, but that model shall translate to and from canonical boundary meaning without loss of event intent.
  priority: must
  stability: stable

- id: elm_ui.transport.server_frontend_bridge
  statement: Event translation shall preserve the runtime split between Phoenix server authority and Elm frontend rendering instead of collapsing canonical boundary behavior into one side of the web runtime.
  priority: must
  stability: stable

- id: elm_ui.transport.no_boundary_leakage
  statement: Renderer-local event names, frontend-local payload shapes, and package-local transport envelopes shall not leak out as the cross-package contract of `elm_ui`.
  priority: must
  stability: stable

- id: elm_ui.transport.direct_native_usage_allowed
  statement: Direct native `elm_ui` usage may handle interactions without crossing the canonical boundary, but crossing that boundary shall always preserve canonical event meaning.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: elm_ui.transport.translate_boundary_form_event
  given: A form submit, click, or navigation interaction on an `elm_ui` screen must cross the ecosystem package boundary
  when: The package emits or consumes that event
  then: It translates between native Phoenix-and-Elm interaction behavior and canonical `Jido.Signal` meaning without exposing renderer-local event details

- id: elm_ui.transport_keep_native_events_local
  given: A direct native `elm_ui` interaction remains inside the package runtime
  when: The interaction does not cross an ecosystem boundary
  then: The package may handle it through native runtime mechanics while retaining the ability to translate the same interaction family canonically when needed
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/elm_ui/transport.spec.md
  covers:
    - elm_ui.transport.canonical_boundary_events
    - elm_ui.transport.native_web_event_model
    - elm_ui.transport.server_frontend_bridge
    - elm_ui.transport.no_boundary_leakage
    - elm_ui.transport.direct_native_usage_allowed
    - elm_ui.transport.translate_boundary_form_event
    - elm_ui.transport_keep_native_events_local
```
