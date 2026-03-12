# Phase 19 - Scope Resolution and Context Propagation

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/scope_resolution_contract.md`
- `specs/contracts/service_contract.md`
- `specs/contracts/policy_authorization_contract.md`
- `specs/conformance/spec_conformance_matrix.md`

## Relevant Assumptions / Defaults
- Scope metadata should be deterministic for equivalent event and runtime-context inputs.
- Scope checks must fail closed with typed errors before dispatch.
- Scope resolution is transport/runtime metadata and does not change server-side domain authority boundaries.

[x] 19 Phase 19 - Scope Resolution and Context Propagation
  Introduce deterministic scope resolution and propagation for runtime widget-event dispatch flows.

  [x] 19.1 Section - Scope Resolver Baseline
    Add a dedicated scope resolver module with deterministic precedence and policy checks.

    [x] 19.1.1 Task - Implement scope resolver primitives
      Provide deterministic scope selection and policy enforcement helpers with typed errors.

      [x] 19.1.1.1 Subtask - Implement `WebUi.Scope.Resolver.resolve_widget_scope/2` precedence rules.
      [x] 19.1.1.2 Subtask - Implement scope policy checks for allow/deny/require-scope semantics.
      [x] 19.1.1.3 Subtask - Implement scope resolver unit tests.

  [x] 19.2 Section - Runtime Dispatch Integration
    Integrate scope resolution into runtime dispatch prior to envelope encoding and command emission.

    [x] 19.2.1 Task - Implement scope propagation in widget-event dispatch
      Ensure resolved scope metadata is attached to outbound event payloads and denied scopes fail closed.

      [x] 19.2.1.1 Subtask - Implement runtime dispatch integration for scope resolution and metadata attachment.
      [x] 19.2.1.2 Subtask - Implement deterministic denial diagnostics for scope authorization failures.
      [x] 19.2.1.3 Subtask - Implement runtime unit tests for scope allow/deny and propagation behavior.

  [x] 19.3 Section - Scenario and Matrix Mapping
    Register scope-resolution behavior in conformance scenario coverage.

    [x] 19.3.1 Task - Implement scenario catalog and matrix entries for scope resolution
      Add canonical scope scenario coverage and link it to requirement families.

      [x] 19.3.1.1 Subtask - Implement `SCN-024` scenario-catalog entry for scope resolution continuity.
      [x] 19.3.1.2 Subtask - Implement matrix mapping updates linking `SCN-024` to service/scope requirement coverage.
      [x] 19.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 19.

  [x] 19.4 Section - Phase 19 Integration Tests
    Validate deterministic scope propagation and fail-closed behavior through runtime conformance tests.

    [x] 19.4.1 Task - Scope resolution conformance scenarios
      Verify deterministic scope metadata, policy-denial behavior, and repeated-flow consistency.

      [x] 19.4.1.1 Subtask - Verify `SCN-024` outbound dispatch includes deterministic scope metadata.
      [x] 19.4.1.2 Subtask - Verify `SCN-024` denied scopes do not dispatch and emit typed errors.
      [x] 19.4.1.3 Subtask - Verify `SCN-024` repeated equivalent scope flows produce equivalent traces.
