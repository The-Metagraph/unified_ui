# Phase 1 - Transport Backbone and CloudEvent Boundary

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `WebUi.Endpoint`
- `WebUi.Router`
- `WebUi.Channel`
- `WebUi.CloudEvent`

## Relevant Assumptions / Defaults
- Transport Plane is stateless orchestration, not domain authority.
- Canonical websocket topics and event names are enforced by contract.
- Envelope validation is required before runtime dispatch.

[x] 1 Phase 1 - Transport Backbone and CloudEvent Boundary
  Implement the baseline endpoint/router/channel and CloudEvent validation path so all client-server traffic is contract-governed.

  [x] 1.1 Section - Endpoint and Router Bootstrap
    Implement deterministic endpoint and router boundaries for SPA delivery and websocket transport admission.

    [x] 1.1.1 Task - Implement canonical HTTP and websocket route surfaces
      Define stable route boundaries and channel mount points required by transport contracts.

      [x] 1.1.1.1 Subtask - Implement endpoint configuration for static Elm/Tailwind assets.
      [x] 1.1.1.2 Subtask - Implement router entries for SPA shell and websocket channel handshake.
      [x] 1.1.1.3 Subtask - Implement startup checks that fail closed on missing transport configuration.

    [x] 1.1.2 Task - Implement deterministic websocket naming contracts
      Enforce canonical topic and event-name contracts from `service_contract.md`.

      [x] 1.1.2.1 Subtask - Implement topic validation for `webui:runtime:v1` and session-scoped variants.
      [x] 1.1.2.2 Subtask - Implement known event-name validation for send/ping and recv/error/pong flows.
      [x] 1.1.2.3 Subtask - Implement typed protocol errors for unknown event names.

  [x] 1.2 Section - Channel Ingress and Egress Orchestration
    Implement channel behavior for validated ingress, normalized dispatch requests, and typed egress outcomes.

    [x] 1.2.1 Task - Implement ingress envelope validation and normalization
      Validate required CloudEvent fields and normalize request context before dispatch.

      [x] 1.2.1.1 Subtask - Implement required envelope-key checks (`specversion`, `id`, `source`, `type`, `data`).
      [x] 1.2.1.2 Subtask - Implement fail-closed typed errors for malformed envelopes.
      [x] 1.2.1.3 Subtask - Implement context extraction with `correlation_id` and `request_id` continuity.

    [x] 1.2.2 Task - Implement egress outcome envelope normalization
      Emit only typed success/error runtime responses on server-to-client flows.

      [x] 1.2.2.1 Subtask - Implement `runtime.event.recv.v1` envelope shaping for accepted outcomes.
      [x] 1.2.2.2 Subtask - Implement `runtime.event.error.v1` shaping for protocol and runtime failures.
      [x] 1.2.2.3 Subtask - Implement keepalive `runtime.event.pong.v1` behavior for ping probes.

  [x] 1.3 Section - CloudEvent Codec and Error Semantics
    Implement reusable CloudEvent encode/decode helpers and typed transport error semantics.

    [x] 1.3.1 Task - Implement canonical CloudEvent codec helpers
      Provide consistent encode/decode operations used by channel ingress and egress paths.

      [x] 1.3.1.1 Subtask - Implement decode helpers with explicit schema validation failures.
      [x] 1.3.1.2 Subtask - Implement encode helpers preserving envelope identity and metadata.
      [x] 1.3.1.3 Subtask - Implement shared validation helpers for required extension fields.

    [x] 1.3.2 Task - Implement transport typed-error mapping
      Normalize transport and protocol failures into `TypedError` without leaking internal exceptions.

      [x] 1.3.2.1 Subtask - Implement protocol category errors for schema and event-name violations.
      [x] 1.3.2.2 Subtask - Implement timeout/dependency category errors for runtime dispatch failures.
      [x] 1.3.2.3 Subtask - Implement internal category fallback with stable error codes.

  [x] 1.4 Section - Phase 1 Integration Tests
    Validate endpoint/router/channel behavior and contract-level transport guarantees end-to-end.

    [x] 1.4.1 Task - Transport admission and envelope scenarios
      Verify routing, topic naming, and ingress validation behavior across allowed and denied inputs.

      [x] 1.4.1.1 Subtask - Verify canonical websocket topic admission and non-canonical rejection.
      [x] 1.4.1.2 Subtask - Verify malformed CloudEvents fail with typed protocol errors.
      [x] 1.4.1.3 Subtask - Verify unknown websocket event names produce deterministic error envelopes.

    [x] 1.4.2 Task - Egress and continuity scenarios
      Verify response-shape normalization and metadata continuity across round trips.

      [x] 1.4.2.1 Subtask - Verify accepted ingress emits `runtime.event.recv.v1` with valid envelope shape.
      [x] 1.4.2.2 Subtask - Verify failures emit `runtime.event.error.v1` with stable typed-error fields.
      [x] 1.4.2.3 Subtask - Verify `correlation_id` and `request_id` continuity ingress to egress.
