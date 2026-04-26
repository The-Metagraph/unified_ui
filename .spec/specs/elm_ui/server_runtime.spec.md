# ElmUi Server Runtime

This subject defines the target Phoenix server-side runtime behavior of
`elm_ui`.

## Related General Specs

- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [ElmUi Package](./package.spec.md)
- [ElmUi Native Widgets](./native_widgets.spec.md)
- [ElmUi Transport](./transport.spec.md)

```spec-meta
id: elm_ui.server_runtime
kind: runtime
status: active
summary: Target Phoenix server-side runtime contract for `elm_ui`, including authoritative UI representation, coordination, and boundary-event handling.
surface:
  - packages/elm_ui
  - .spec/specs/elm_ui/server_runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.canonical_navigation_boundary
  - repo.ecosystem.elm_ui_naming
```

## Requirements

```spec-requirements
- id: elm_ui.server_runtime.authoritative_server_representation
  statement: The Phoenix side of `elm_ui` shall hold the authoritative server-side representation of web UI meaning, canonical event translation, and runtime coordination at the ecosystem boundary.
  priority: must
  stability: stable

- id: elm_ui.server_runtime.coordinate_frontend_rendering
  statement: The server runtime shall coordinate what the Elm frontend runtime renders and how canonical IUR or direct native widget intent becomes frontend-view state.
  priority: must
  stability: stable

- id: elm_ui.server_runtime.handle_boundary_events
  statement: The server runtime shall receive and emit canonical boundary events using `Jido.Signal` and CloudEvents-compatible semantics whenever interactions cross the ecosystem package boundary.
  priority: must
  stability: stable

- id: elm_ui.server_runtime.direct_and_iur_entrypoints_share_runtime
  statement: The same Phoenix runtime architecture shall support both direct native `elm_ui` usage and canonical IUR rendering so the package does not split into unrelated server models.
  priority: must
  stability: stable

- id: elm_ui.server_runtime.browser_state_is_bounded
  statement: Browser-local state may exist on the frontend, but authoritative server-side UI meaning and package-boundary event translation shall remain anchored in the Phoenix runtime.
  priority: must
  stability: stable

- id: elm_ui.server_runtime.canonical_navigation_transition_mapping
  statement: When canonical navigation interactions are emitted or consumed, the server runtime shall map canonical screen-transition actions onto Phoenix-and-Elm-appropriate screen or page transitions while preserving authoritative server-side UI meaning.
  priority: must
  stability: stable

- id: elm_ui.server_runtime.host_route_resolution_boundary
  statement: Host router lookup, URL generation, and frontend route-matching details may be used by applications, but they shall remain host or runtime concerns rather than part of the authored `UnifiedUi` contract.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: elm_ui.server_runtime_handle_canonical_event
  given: A user interacts with an `elm_ui` screen rendered from canonical IUR
  when: The interaction crosses the ecosystem package boundary
  then: The Phoenix runtime resolves canonical event meaning and updates the authoritative UI representation that the frontend runtime reflects
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/elm_ui/server_runtime.spec.md
  covers:
    - elm_ui.server_runtime.authoritative_server_representation
    - elm_ui.server_runtime.coordinate_frontend_rendering
    - elm_ui.server_runtime.handle_boundary_events
    - elm_ui.server_runtime.direct_and_iur_entrypoints_share_runtime
    - elm_ui.server_runtime.browser_state_is_bounded
    - elm_ui.server_runtime.canonical_navigation_transition_mapping
    - elm_ui.server_runtime.host_route_resolution_boundary
    - elm_ui.server_runtime_handle_canonical_event
```
