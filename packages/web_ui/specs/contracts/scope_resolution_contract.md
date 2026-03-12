# Scope Resolution Contract

This contract defines deterministic scope resolution and scope-policy enforcement for runtime dispatch.

## Covered Runtime Modules

- `WebUi.Scope.Resolver`
- `WebUi.Ui.Runtime`

## Requirement Set

- `REQ-SCP-001`: Scope resolution MUST require valid widget-event payload shape (`type` + `data`) and fail closed on malformed payloads.
- `REQ-SCP-002`: Scope resolution precedence MUST be deterministic: event data -> runtime context -> session -> global default.
- `REQ-SCP-003`: Event-supplied scope IDs (`scope_id` or `scope`) MUST override runtime-context/session/default scope fallbacks.
- `REQ-SCP-004`: Scope metadata injected into outbound event data MUST include canonical keys `scope_id`, `scope_type`, and `scope_source`.
- `REQ-SCP-005`: Missing scope policy MUST normalize to empty allow/deny/require sets.
- `REQ-SCP-006`: Scope policy list fields MUST normalize to unique, non-empty string values.
- `REQ-SCP-007`: `deny_scope_ids` and `allow_scope_ids` policies MUST fail closed with typed authorization errors.
- `REQ-SCP-008`: `require_scope_for_event_types` policies MUST deny default/global scope sources for protected event types.
- `REQ-SCP-009`: Malformed scope policy documents MUST fail closed with typed validation errors.
- `REQ-SCP-010`: Equivalent scope inputs and scope-policy documents MUST produce equivalent resolution outcomes and typed errors.

## Types

### ResolvedScope

```text
ResolvedScope {
  scope_id: string,
  scope_type: string,
  scope_source: "event_data" | "runtime_context" | "session" | "default"
}
```

### ScopePolicy

```text
ScopePolicy {
  allow_scope_ids?: [string],
  deny_scope_ids?: [string],
  require_scope_for_event_types?: [string]
}
```

### ScopeResolutionInput

```text
ScopeResolutionInput {
  event_payload: {
    type: string,
    data: map
  },
  runtime_context: RuntimeContext & {
    session_id?: string,
    scope_id?: string,
    scope_type?: string,
    scope_policy?: ScopePolicy
  }
}
```

`RuntimeContext` and `TypedError` shapes are defined in [service_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/service_contract.md).

## Deterministic Scope Resolution Rules

1. Scope fallback resolution order MUST be:
   1. `event_payload.data.scope_id` or `event_payload.data.scope`
   2. `runtime_context.scope_id`
   3. `runtime_context.session_id`
   4. global default
2. Default scope payload MUST resolve to:
   - `scope_id: "global"`
   - `scope_type: "global"`
   - `scope_source: "default"`
3. Session fallback scope payload MUST resolve to:
   - `scope_id: runtime_context.session_id`
   - `scope_type: "session"`
   - `scope_source: "session"`

## Canonical Typed Error Codes

| Error Code | Category | Trigger |
|---|---|---|
| `scope.resolution.invalid_payload` | `validation` | Missing/invalid event payload, event type, or data map |
| `scope.resolution.invalid_scope_policy` | `validation` | Scope policy document/list shape invalid |
| `scope.resolution.scope_denied` | `authorization` | Scope blocked by `deny_scope_ids` |
| `scope.resolution.scope_not_allowed` | `authorization` | Scope excluded by non-empty `allow_scope_ids` |
| `scope.resolution.scope_required` | `authorization` | Protected event type resolved to default scope source |

## Conformance Mapping

- `SCN-024`: deterministic scope metadata injection, policy-deny fail-closed behavior, and repeated-flow scope trace parity.

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
