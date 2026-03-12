# Observability Contract

This contract defines required runtime event-envelope fields and baseline metric coverage.

## Requirement Set

- `REQ-OBS-001`: Runtime events MUST use `RuntimeEventEnvelope`.
- `REQ-OBS-002`: Event names MUST be versioned and stable.
- `REQ-OBS-003`: Event envelopes MUST include `correlation_id` and `request_id`.
- `REQ-OBS-004`: Operation success and failure paths MUST emit terminal events.
- `REQ-OBS-005`: Envelope validation failures MUST emit typed observability error events.
- `REQ-OBS-006`: Metrics in this contract are mandatory for runtime deployments.
- `REQ-OBS-007`: Metric labels MUST include bounded, joinable identifiers only.
- `REQ-OBS-008`: High-cardinality fields MUST NOT be used as unbounded labels.
- `REQ-OBS-009`: Event and metric streams MUST be joinable by correlation identifiers.
- `REQ-OBS-010`: Missing required observability fields MUST fail conformance validation.

## RuntimeEventEnvelope

```text
RuntimeEventEnvelope {
  event_name: string,
  event_version: string,
  timestamp: string,
  service: string,
  source: string,
  correlation_id: string,
  request_id: string,
  session_id?: string,
  client_id?: string,
  outcome: "ok" | "error" | "cancelled" | "timeout",
  payload: map
}
```

## Mandatory Metrics

| Metric | Type | Unit | Required Labels |
|---|---|---|---|
| `webui_ws_connection_total` | counter | count | `endpoint`, `outcome` |
| `webui_ws_disconnect_total` | counter | count | `endpoint`, `reason` |
| `webui_event_ingress_total` | counter | count | `service`, `event_type`, `outcome` |
| `webui_event_egress_total` | counter | count | `service`, `event_type`, `outcome` |
| `webui_event_decode_error_total` | counter | count | `service`, `error_code` |
| `webui_event_encode_error_total` | counter | count | `service`, `error_code` |
| `webui_service_operation_latency` | histogram | milliseconds | `service`, `operation`, `outcome` |
| `webui_js_interop_error_total` | counter | count | `bridge`, `error_code` |

## Label Policy

- Labels MUST be bounded and policy-safe.
- Raw payload data, free-form prompts, and arbitrary user text MUST NOT be metric labels.
- Correlation joinability SHOULD use event envelope fields rather than high-cardinality metric labels.

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
