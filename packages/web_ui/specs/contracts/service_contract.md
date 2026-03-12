# Service Contract

This contract is mandatory for core runtime modules listed in [services-and-libraries.md](/Users/Pascal/code/unified/web_ui/specs/services-and-libraries.md).

## Namespace Convention

All runtime module references in contracts and component docs MUST use the canonical namespace root `WebUi.*`.

## Covered Runtime Modules

- `WebUi.Endpoint`
- `WebUi.Router`
- `WebUi.Channel`
- `WebUi.CloudEvent`
- `WebUi.Agent`
- `WebUi.Component`
- `WebUi.WidgetRegistry`
- `WebUi.Widget`

## Requirement Set

- `REQ-SVC-001`: Covered runtime modules MUST expose explicit public responsibilities and stable API surfaces.
- `REQ-SVC-002`: Transport ingress/egress operations MUST preserve `correlation_id` and `request_id` continuity.
- `REQ-SVC-003`: `WebUi.Channel` ingress MUST validate CloudEvent envelope shape before dispatch.
- `REQ-SVC-004`: `WebUi.Channel` egress MUST emit typed success/error outcomes with normalized envelopes.
- `REQ-SVC-005`: `WebUi.Endpoint` and `WebUi.Router` MUST expose deterministic SPA and websocket routing boundaries, including canonical topic and event naming.
- `REQ-SVC-006`: `WebUi.Agent` integrations MUST use typed handler outcomes and MUST NOT become alternate state authorities.
- `REQ-SVC-007`: `WebUi.Component` abstractions MUST remain deterministic and side-effect minimal.
- `REQ-SVC-008`: Runtime service failures MUST return `TypedError` and MUST NOT leak untyped exceptions across boundaries.
- `REQ-SVC-009`: Missing required runtime context MUST fail closed with typed validation errors.
- `REQ-SVC-010`: Runtime service operations MUST emit observability events required by [observability_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/observability_contract.md).

## Types

### RuntimeContext

```text
RuntimeContext {
  client_id: string,
  session_id?: string,
  user_id?: string,
  correlation_id: string,
  request_id: string,
  trace_id?: string
}
```

### ServiceRequestEnvelope

```text
ServiceRequestEnvelope {
  service: string,
  operation: string,
  context: RuntimeContext,
  headers?: map,
  payload: map,
  metadata?: map
}
```

### ServiceResultEnvelope

```text
ServiceResultEnvelope {
  service: string,
  operation: string,
  context: RuntimeContext,
  outcome: "ok" | "error",
  payload?: map,
  error?: TypedError,
  events: RuntimeEventEnvelope[]
}
```

### TypedError

```text
TypedError {
  error_code: string,
  category: "validation" | "authorization" | "dependency" | "timeout" | "conflict" | "protocol" | "internal",
  retryable: boolean,
  details?: map,
  correlation_id: string
}
```

## CloudEvent Envelope Interop Rules

1. Channel ingress MUST reject envelopes missing `specversion`, `id`, `source`, `type`, or `data`.
2. Channel egress MUST preserve envelope identity and correlation fields from originating context.
3. Unknown event types SHOULD return typed protocol errors and SHOULD emit an audit event.

## Canonical WebSocket Naming

### Canonical Topics

- `webui:runtime:v1` for default runtime event exchange.
- `webui:runtime:session:<session_id>:v1` for session-scoped exchange when session isolation is required.

### Canonical Event Names

Client -> Server:

- `runtime.event.send.v1`: carries one CloudEvent envelope in `payload.event`.
- `runtime.event.ping.v1`: keepalive probe with optional correlation metadata.

Server -> Client:

- `runtime.event.recv.v1`: accepted/dispatched CloudEvent envelope in `payload.event`.
- `runtime.event.error.v1`: typed protocol/transport failure in `payload.error`.
- `runtime.event.pong.v1`: keepalive response.

### Naming and Validation Rules

1. Implementations MUST use the canonical topic and event names above unless a versioned ADR defines an exception.
2. Unknown websocket event names MUST return `runtime.event.error.v1` with a typed protocol error code.
3. `runtime.event.send.v1` and `runtime.event.recv.v1` payloads MUST preserve CloudEvent envelope shape and context continuity.

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
