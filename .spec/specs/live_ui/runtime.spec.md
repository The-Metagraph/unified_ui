# LiveUi Runtime

This subject defines the target runtime behavior of `live_ui` as a server-led
Phoenix LiveView library.

## Related General Specs

- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [LiveUi Package](./package.spec.md)
- [LiveUi Native Widgets](./native_widgets.spec.md)
- [LiveUi Transport](./transport.spec.md)

```spec-meta
id: live_ui.runtime
kind: runtime
status: active
summary: Target LiveView runtime contract for `live_ui`, including server-authoritative state, screen composition through widget LiveComponents, and bounded browser-bridge behavior.
surface:
  - packages/live_ui
  - .spec/specs/live_ui/runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.canonical_navigation_boundary
  - live_ui.runtime.widget_livecomponents
```

## Requirements

```spec-requirements
- id: live_ui.runtime.server_authoritative_model
  statement: The `live_ui` runtime shall remain server-authoritative, with canonical boundary event meaning resolved on the server side and browser-side behavior kept subordinate to the LiveView runtime model.
  priority: must
  stability: stable

- id: live_ui.runtime.liveview_component_execution
  statement: The runtime shall realize native widgets and IUR-rendered widgets through Phoenix LiveComponent-backed widget boundaries composed inside the server-led screen runtime rather than through plain helper-only widget surfaces or a separate client-side runtime authority.
  priority: must
  stability: stable

- id: live_ui.runtime.widget_component_local_state
  statement: Widget components may own bounded local UI lifecycle and ephemeral state, but that state shall remain subordinate to server-authoritative screen or application state and to canonical boundary meaning.
  priority: must
  stability: stable

- id: live_ui.runtime.hooks_only_where_necessary
  statement: JavaScript hooks shall be used only where necessary for browser capabilities or interaction behaviors that cannot be expressed adequately through pure LiveView composition.
  priority: must
  stability: stable

- id: live_ui.runtime.native_and_iur_entrypoints_share_runtime
  statement: The same runtime architecture shall support both direct native `live_ui` usage and canonical IUR rendering so the package does not split into unrelated runtime models.
  priority: must
  stability: stable

- id: live_ui.runtime.state_and_render_continuity
  statement: Runtime state, assigns, and rendered widget structure shall preserve canonical UI meaning across updates whether the source is direct native usage or canonical IUR interpretation.
  priority: must
  stability: stable

- id: live_ui.runtime.canonical_navigation_transition_mapping
  statement: When canonical navigation interactions are emitted or consumed, the runtime shall map canonical screen-transition actions onto LiveView-appropriate screen or page transitions while preserving server-authoritative UI meaning.
  priority: must
  stability: stable

- id: live_ui.runtime.host_route_resolution_boundary
  statement: Phoenix router lookup, URL generation, and host-specific route matching may be used by applications, but they shall remain host or runtime concerns rather than part of the authored `UnifiedUi` contract.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: live_ui.runtime.handle_canonical_event_server_side
  given: A user interacts with a `live_ui` screen rendered from canonical IUR
  when: The interaction crosses the package boundary as canonical event meaning
  then: The `live_ui` runtime resolves the interaction through its server-authoritative LiveView model and updates rendered output accordingly

- id: live_ui.runtime_handle_direct_native_event
  given: A user interacts with a screen built directly with native `live_ui` widgets
  when: The widget interaction stays inside the package
  then: The package handles the native event through its LiveView runtime model without requiring canonical IUR as an intermediate step

- id: live_ui.runtime.screen_composes_widget_components
  given: A Phoenix LiveView screen is built directly with `live_ui`
  when: The screen renders buttons, inputs, overlays, or data widgets
  then: The screen composes mountable widget component boundaries inside the shared runtime instead of bypassing them with ad hoc HTML fragments
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live_ui/runtime.spec.md
  covers:
    - live_ui.runtime.server_authoritative_model
    - live_ui.runtime.liveview_component_execution
    - live_ui.runtime.widget_component_local_state
    - live_ui.runtime.hooks_only_where_necessary
    - live_ui.runtime.native_and_iur_entrypoints_share_runtime
    - live_ui.runtime.state_and_render_continuity
    - live_ui.runtime.canonical_navigation_transition_mapping
    - live_ui.runtime.host_route_resolution_boundary
    - live_ui.runtime.handle_canonical_event_server_side
    - live_ui.runtime_handle_direct_native_event
    - live_ui.runtime.screen_composes_widget_components
```
