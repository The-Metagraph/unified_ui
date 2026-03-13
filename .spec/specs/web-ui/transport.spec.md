# WebUi Transport

This subject backfills the current transport and boundary-envelope contract for
`packages/web_ui`, based on its typed protocol helpers, channel orchestration,
and route bootstrap modules.

```spec-meta
id: web_ui.transport
kind: subsystem
status: active
summary: Current transport contract for `packages/web_ui`, including typed error and context envelopes, CloudEvent validation, canonical naming and routes, and channel ingress or egress orchestration.
surface:
  - packages/web_ui/lib/web_ui/typed_error.ex
  - packages/web_ui/lib/web_ui/runtime_context.ex
  - packages/web_ui/lib/web_ui/cloud_event.ex
  - packages/web_ui/lib/web_ui/service_request_envelope.ex
  - packages/web_ui/lib/web_ui/service_result_envelope.ex
  - packages/web_ui/lib/web_ui/transport/naming.ex
  - packages/web_ui/lib/web_ui/endpoint.ex
  - packages/web_ui/lib/web_ui/router.ex
  - packages/web_ui/lib/web_ui/channel.ex
  - packages/web_ui/test/web_ui
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: web_ui.transport.typed_boundaries
  statement: 'The package shall provide the current typed error, runtime-context, CloudEvent, service-request, and service-result envelope helpers used to normalize protocol and service outcomes at runtime boundaries.'
  priority: must
  stability: stable

- id: web_ui.transport.naming_and_routes
  statement: 'The package shall define the current canonical websocket topic and event naming policy together with the SPA, assets, and websocket route bootstrap contract.'
  priority: must
  stability: stable

- id: web_ui.transport.channel_flow
  statement: 'The channel boundary shall validate current ingress topics, client event names, and CloudEvent envelopes, preserve correlation or request continuity, support ping or pong handling, and emit the current deterministic recv or error envelopes.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/web_ui/lib/web_ui/typed_error.ex
  covers:
    - web_ui.transport.typed_boundaries

- kind: source_file
  target: packages/web_ui/lib/web_ui/runtime_context.ex
  covers:
    - web_ui.transport.typed_boundaries

- kind: source_file
  target: packages/web_ui/lib/web_ui/cloud_event.ex
  covers:
    - web_ui.transport.typed_boundaries
    - web_ui.transport.channel_flow

- kind: source_file
  target: packages/web_ui/lib/web_ui/service_request_envelope.ex
  covers:
    - web_ui.transport.typed_boundaries

- kind: source_file
  target: packages/web_ui/lib/web_ui/service_result_envelope.ex
  covers:
    - web_ui.transport.typed_boundaries

- kind: source_file
  target: packages/web_ui/lib/web_ui/transport/naming.ex
  covers:
    - web_ui.transport.naming_and_routes
    - web_ui.transport.channel_flow

- kind: source_file
  target: packages/web_ui/lib/web_ui/endpoint.ex
  covers:
    - web_ui.transport.naming_and_routes

- kind: source_file
  target: packages/web_ui/lib/web_ui/router.ex
  covers:
    - web_ui.transport.naming_and_routes

- kind: source_file
  target: packages/web_ui/lib/web_ui/channel.ex
  covers:
    - web_ui.transport.channel_flow

- kind: source_file
  target: packages/web_ui/test/web_ui/cloud_event_test.exs
  covers:
    - web_ui.transport.typed_boundaries

- kind: source_file
  target: packages/web_ui/test/web_ui/runtime_context_test.exs
  covers:
    - web_ui.transport.typed_boundaries

- kind: source_file
  target: packages/web_ui/test/web_ui/service_request_envelope_test.exs
  covers:
    - web_ui.transport.typed_boundaries

- kind: source_file
  target: packages/web_ui/test/web_ui/service_result_envelope_test.exs
  covers:
    - web_ui.transport.typed_boundaries

- kind: source_file
  target: packages/web_ui/test/web_ui/transport/naming_test.exs
  covers:
    - web_ui.transport.naming_and_routes

- kind: source_file
  target: packages/web_ui/test/web_ui/endpoint_test.exs
  covers:
    - web_ui.transport.naming_and_routes

- kind: source_file
  target: packages/web_ui/test/web_ui/router_test.exs
  covers:
    - web_ui.transport.naming_and_routes

- kind: source_file
  target: packages/web_ui/test/web_ui/channel_test.exs
  covers:
    - web_ui.transport.channel_flow

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_01_transport_test.exs
  covers:
    - web_ui.transport.channel_flow
    - web_ui.transport.naming_and_routes
```
