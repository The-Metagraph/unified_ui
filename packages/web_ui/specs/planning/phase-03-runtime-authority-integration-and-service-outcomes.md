# Phase 3 - Runtime Authority Integration and Service Outcomes

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `WebUi.Agent`
- `ServiceRequestEnvelope`
- `ServiceResultEnvelope`
- `RuntimeContext`
- `TypedError`

## Relevant Assumptions / Defaults
- Runtime Authority Plane remains server-side and host-owned.
- Channel and adapter logic only orchestrate; they do not own domain state.
- Service outcomes are always typed and envelope-normalized.

[x] 3 Phase 3 - Runtime Authority Integration and Service Outcomes
  Implement runtime dispatch and response normalization so backend authority integration is deterministic and contract-safe.

  [x] 3.1 Section - Runtime Dispatch Boundary
    Implement deterministic routing from channel ingress events into host runtime handlers.

    [x] 3.1.1 Task - Implement service-operation routing from event type to handler
      Translate canonical runtime events into explicit service/operation requests.

      [x] 3.1.1.1 Subtask - Implement mapping rules from CloudEvent type to service operation keys.
      [x] 3.1.1.2 Subtask - Implement handler lookup and missing-handler typed-error behavior.
      [x] 3.1.1.3 Subtask - Implement dispatch admission checks for required runtime context fields.

    [x] 3.1.2 Task - Implement timeout and dependency failure semantics
      Normalize external or runtime timeouts/dependency failures through typed categories.

      [x] 3.1.2.1 Subtask - Implement configurable dispatch timeout enforcement.
      [x] 3.1.2.2 Subtask - Implement dependency-failure normalization and retryability flags.
      [x] 3.1.2.3 Subtask - Implement guarded internal fallback for unexpected runtime exceptions.

  [x] 3.2 Section - Service Result Envelope Normalization
    Implement typed result shaping for all runtime outcomes before egress to browser clients.

    [x] 3.2.1 Task - Implement success envelope shaping
      Ensure successful handler outcomes produce canonical `ServiceResultEnvelope` responses.

      [x] 3.2.1.1 Subtask - Implement payload normalization for success responses.
      [x] 3.2.1.2 Subtask - Implement attached runtime event emission list handling.
      [x] 3.2.1.3 Subtask - Implement service and operation identity propagation in response envelopes.

    [x] 3.2.2 Task - Implement error envelope shaping
      Ensure all failure outcomes return canonical typed-error envelopes.

      [x] 3.2.2.1 Subtask - Implement validation, authorization, and conflict error mappings.
      [x] 3.2.2.2 Subtask - Implement timeout and dependency error mappings.
      [x] 3.2.2.3 Subtask - Implement correlation-preserving fallback internal error mapping.

  [x] 3.3 Section - Runtime Context and Continuity Guarantees
    Implement context propagation guarantees across ingress, dispatch, and egress boundaries.

    [x] 3.3.1 Task - Implement context propagation across request lifecycle
      Preserve mandatory context identifiers in all request and response surfaces.

      [x] 3.3.1.1 Subtask - Implement `correlation_id` and `request_id` pass-through invariants.
      [x] 3.3.1.2 Subtask - Implement optional `session_id`, `user_id`, and `trace_id` propagation rules.
      [x] 3.3.1.3 Subtask - Implement context integrity checks at each boundary.

    [x] 3.3.2 Task - Implement denied-path and missing-context behavior
      Fail closed when required runtime context is missing or malformed.

      [x] 3.3.2.1 Subtask - Implement missing-context typed validation errors.
      [x] 3.3.2.2 Subtask - Implement denied dispatch telemetry for policy and context failures.
      [x] 3.3.2.3 Subtask - Implement non-dispatch guarantee for invalid context requests.

  [x] 3.4 Section - Phase 3 Integration Tests
    Validate runtime dispatch, result normalization, and context continuity behaviors end-to-end.

    [x] 3.4.1 Task - Runtime dispatch and outcome scenarios
      Verify handler routing behavior and typed outcome guarantees under success and failure paths.

      [x] 3.4.1.1 Subtask - Verify valid requests route to expected service/operation handlers.
      [x] 3.4.1.2 Subtask - Verify unknown handlers fail with typed protocol/runtime errors.
      [x] 3.4.1.3 Subtask - Verify timeout/dependency failures map to stable typed categories.

    [x] 3.4.2 Task - Context continuity scenarios
      Verify context fields are preserved and enforced throughout the lifecycle.

      [x] 3.4.2.1 Subtask - Verify mandatory identifiers survive ingress through egress unchanged.
      [x] 3.4.2.2 Subtask - Verify missing-context requests fail before runtime dispatch.
      [x] 3.4.2.3 Subtask - Verify all error outcomes include correlation-preserving metadata.
