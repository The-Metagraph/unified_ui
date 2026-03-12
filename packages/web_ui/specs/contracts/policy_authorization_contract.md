# Policy Authorization Contract

This contract defines deterministic policy authorization checks for runtime widget-event dispatch.

## Covered Runtime Modules

- `WebUi.Policy.Authorizer`
- `WebUi.Ui.Runtime`

## Requirement Set

- `REQ-POL-001`: Widget-event authorization MUST execute before outbound dispatch command construction.
- `REQ-POL-002`: Missing policy documents MUST normalize to an allow-by-default policy with empty deny/allow/user-requirement sets.
- `REQ-POL-003`: Authorization inputs MUST fail closed with typed validation errors when event payload shape is invalid.
- `REQ-POL-004`: `deny_event_types` policy membership MUST produce typed authorization denials.
- `REQ-POL-005`: `deny_widget_ids` policy membership MUST produce typed authorization denials.
- `REQ-POL-006`: Non-empty `allow_event_types` policies MUST behave as strict allowlists and deny unknown event types.
- `REQ-POL-007`: `require_user_for_event_types` policies MUST require non-empty `user_id` runtime context for protected event types.
- `REQ-POL-008`: Malformed policy documents or malformed policy list fields MUST fail closed with typed validation errors.
- `REQ-POL-009`: All authorization failures MUST include stable `error_code`, `category`, and `correlation_id` metadata.
- `REQ-POL-010`: Authorization denials in runtime dispatch MUST emit deterministic policy-deny UI notices and MUST NOT enqueue outbound websocket commands.

## Types

### PolicyDocument

```text
PolicyDocument {
  deny_event_types?: [string],
  deny_widget_ids?: [string],
  allow_event_types?: [string],
  require_user_for_event_types?: [string]
}
```

### AuthorizationInput

```text
AuthorizationInput {
  event_payload: {
    type: string,
    widget_id: string,
    widget_kind?: string,
    data?: map
  },
  runtime_context: RuntimeContext & {
    policy?: PolicyDocument,
    user_id?: string
  }
}
```

### AuthorizationResult

```text
AuthorizationResult {
  outcome: "ok" | "error",
  error?: TypedError
}
```

`RuntimeContext` and `TypedError` shapes are defined in [service_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/service_contract.md).

## Evaluation Order

1. Normalize policy document and list fields.
2. Validate required event payload keys (`type`, `widget_id`).
3. Enforce `deny_event_types`.
4. Enforce `deny_widget_ids`.
5. Enforce `allow_event_types`.
6. Enforce `require_user_for_event_types`.

Equivalent inputs MUST produce equivalent outcomes and typed errors.

## Canonical Typed Error Codes

| Error Code | Category | Trigger |
|---|---|---|
| `policy.authorization.invalid_payload` | `validation` | Missing/invalid payload or required payload key fields |
| `policy.authorization.invalid_policy` | `validation` | Policy document is not a map or policy list fields are invalid |
| `policy.authorization.event_type_denied` | `authorization` | Event type blocked by `deny_event_types` |
| `policy.authorization.widget_id_denied` | `authorization` | Widget ID blocked by `deny_widget_ids` |
| `policy.authorization.event_type_not_allowed` | `authorization` | Event type excluded by `allow_event_types` allowlist |
| `policy.authorization.user_required` | `authorization` | Missing `user_id` for protected event type |

## Conformance Mapping

- `SCN-022`: policy deny/allow/user-requirement paths, malformed policy fail-closed behavior, and deterministic denial notice continuity.

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
