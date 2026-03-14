# WebUi Server Runtime

This subject defines the target Phoenix server-side runtime behavior of
`web_ui`.

## Related General Specs

- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [WebUi Package](./package.spec.md)
- [WebUi Native Widgets](./native_widgets.spec.md)
- [WebUi Transport](./transport.spec.md)

```spec-meta
id: web_ui.server_runtime
kind: runtime
status: active
summary: Target Phoenix server-side runtime contract for `web_ui`, including authoritative UI representation, coordination, and boundary-event handling.
surface:
  - packages/web_ui
  - .spec/specs/web_ui/server_runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: web_ui.server_runtime.authoritative_server_representation
  statement: The Phoenix side of `web_ui` shall hold the authoritative server-side representation of web UI meaning, canonical event translation, and runtime coordination at the ecosystem boundary.
  priority: must
  stability: stable

- id: web_ui.server_runtime.coordinate_frontend_rendering
  statement: The server runtime shall coordinate what the Elm frontend runtime renders and how canonical IUR or direct native widget intent becomes frontend-view state.
  priority: must
  stability: stable

- id: web_ui.server_runtime.handle_boundary_events
  statement: The server runtime shall receive and emit canonical boundary events using `Jido.Signal` and CloudEvents-compatible semantics whenever interactions cross the ecosystem package boundary.
  priority: must
  stability: stable

- id: web_ui.server_runtime.direct_and_iur_entrypoints_share_runtime
  statement: The same Phoenix runtime architecture shall support both direct native `web_ui` usage and canonical IUR rendering so the package does not split into unrelated server models.
  priority: must
  stability: stable

- id: web_ui.server_runtime.browser_state_is_bounded
  statement: Browser-local state may exist on the frontend, but authoritative server-side UI meaning and package-boundary event translation shall remain anchored in the Phoenix runtime.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: web_ui.server_runtime_handle_canonical_event
  given: A user interacts with a `web_ui` screen rendered from canonical IUR
  when: The interaction crosses the ecosystem package boundary
  then: The Phoenix runtime resolves canonical event meaning and updates the authoritative UI representation that the frontend runtime reflects
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/web_ui/server_runtime.spec.md
  covers:
    - web_ui.server_runtime.authoritative_server_representation
    - web_ui.server_runtime.coordinate_frontend_rendering
    - web_ui.server_runtime.handle_boundary_events
    - web_ui.server_runtime.direct_and_iur_entrypoints_share_runtime
    - web_ui.server_runtime.browser_state_is_bounded
    - web_ui.server_runtime_handle_canonical_event
```
