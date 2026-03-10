# Prompt Asset Contract

This contract defines deterministic prompt-data hygiene and frontend asset boundary behavior.

## Covered Runtime Modules

- `WebUi.Endpoint`
- `WebUi.Router`
- `WebUi.Observability.Diagnostics`
- `WebUi.Observability.Metrics`

## Requirement Set

- `REQ-PRM-001`: Endpoint configuration MUST expose canonical static asset path boundaries and fail closed for invalid path shape.
- `REQ-PRM-002`: Router route tables MUST include deterministic wildcard asset route resolution for canonical asset serving.
- `REQ-PRM-003`: Prompt-like sensitive payload keys MUST be redacted in observability denied-path diagnostics.
- `REQ-PRM-004`: Redaction behavior MUST recursively preserve payload structure while replacing sensitive values with canonical redaction markers.
- `REQ-PRM-005`: Metrics label validation MUST reject high-cardinality/sensitive keys, including prompt-like fields.
- `REQ-PRM-006`: Metrics records MUST remain joinable via correlation/request identifiers without exposing prompt payload content.
- `REQ-PRM-007`: Prompt and payload raw text MUST NOT be accepted as metric-label dimensions.
- `REQ-PRM-008`: Equivalent prompt/payload redaction inputs MUST produce equivalent redacted diagnostics.
- `REQ-PRM-009`: Equivalent metric-label validation inputs MUST produce equivalent accepted/rejected outcomes and typed errors.
- `REQ-PRM-010`: Frontend asset toolchain and contract checks MUST run deterministically in local hooks and CI before merge.

## Types

### PromptAssetBoundary

```text
PromptAssetBoundary {
  spa_path: string,
  assets_path: string,
  websocket_path: string
}
```

### RedactedDiagnosticPayload

```text
RedactedDiagnosticPayload {
  details: map,
  denied_payload: map
}
```

### MetricRecord

```text
MetricRecord {
  metric_name: string,
  metric_type: "counter" | "histogram",
  value: number,
  labels: map<string, string>,
  correlation_id?: string,
  request_id?: string,
  timestamp: string
}
```

## Canonical Sensitive Keys

Sensitive keys that MUST be redacted include:

- `prompt`
- `payload`
- `raw_payload`
- `input_data`
- `user_text`
- `password`
- `token`
- `secret`
- `authorization`
- `cookie`
- `set_cookie`

## Conformance Mapping

- `SCN-006`: observability baseline envelope and metrics continuity.
- `SCN-015`: metric rejection joinability resilience.
- `SCN-039`: frontend asset toolchain enforcement continuity.

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
