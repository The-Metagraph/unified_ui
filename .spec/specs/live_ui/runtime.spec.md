# LiveUi Runtime

This subject defines the target runtime behavior of `live_ui` as a server-led
Phoenix LiveView library.

## Related General Specs

- [Application Authority](../application_authority.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [LiveUi Package](./package.spec.md)
- [LiveUi Native Widgets](./native_widgets.spec.md)
- [LiveUi Transport](./transport.spec.md)

```spec-meta
id: live_ui.runtime
kind: runtime
status: active
summary: Target LiveView runtime contract for `live_ui`, including server-authoritative state, LiveView composition, and bounded browser-bridge behavior.
surface:
  - packages/live_ui
  - .spec/specs/live_ui/runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: live_ui.runtime.server_authoritative_model
  statement: The `live_ui` runtime shall remain server-authoritative, with canonical boundary event meaning resolved on the server side and browser-side behavior kept subordinate to the LiveView runtime model.
  priority: must
  stability: stable

- id: live_ui.runtime.liveview_component_execution
  statement: The runtime shall realize native widgets and IUR-rendered widgets through Phoenix LiveView components and assigns-driven rendering rather than through a separate client-side runtime authority.
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
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live_ui/runtime.spec.md
  covers:
    - live_ui.runtime.server_authoritative_model
    - live_ui.runtime.liveview_component_execution
    - live_ui.runtime.hooks_only_where_necessary
    - live_ui.runtime.native_and_iur_entrypoints_share_runtime
    - live_ui.runtime.state_and_render_continuity
    - live_ui.runtime.handle_canonical_event_server_side
    - live_ui.runtime_handle_direct_native_event
```
