# Phase 17 - Policy Authorization and Dispatch Guards

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `specs/contracts/service_contract.md`
- `specs/contracts/control_plane_ownership_matrix.md`
- `specs/conformance/spec_conformance_matrix.md`
- `specs/operations/post_release_hardening_backlog.md`

## Relevant Assumptions / Defaults
- Runtime authority remains server-side; authorization checks gate outbound dispatch but do not become domain state authority.
- Policy decisions must fail closed with typed errors.
- Authorization outcomes must be deterministic for equivalent event and context inputs.

[x] 17 Phase 17 - Policy Authorization and Dispatch Guards
  Add deterministic policy authorization checks before runtime event dispatch and register conformance coverage.

  [x] 17.1 Section - Authorization Baseline Module
    Introduce a dedicated policy authorizer for runtime widget events.

    [x] 17.1.1 Task - Implement policy authorizer core checks
      Provide fail-closed deny/allow and user-requirement checks with typed errors.

      [x] 17.1.1.1 Subtask - Implement `WebUi.Policy.Authorizer.authorize_widget_event/2`.
      [x] 17.1.1.2 Subtask - Implement policy normalization for deny/allow/require-user lists.
      [x] 17.1.1.3 Subtask - Implement dedicated authorizer unit tests.

  [x] 17.2 Section - Runtime Dispatch Integration
    Enforce policy authorization in runtime dispatch flow before websocket command emission.

    [x] 17.2.1 Task - Integrate authorization checks into widget-event dispatch
      Ensure denied events fail closed and do not enqueue outbound commands.

      [x] 17.2.1.1 Subtask - Implement runtime dispatch authorization gate.
      [x] 17.2.1.2 Subtask - Implement deterministic denial notices for operator diagnostics.
      [x] 17.2.1.3 Subtask - Implement runtime unit tests for deny and allow behavior.

  [x] 17.3 Section - Scenario and Matrix Mapping
    Register policy authorization behavior in conformance scenario coverage.

    [x] 17.3.1 Task - Implement scenario catalog and matrix entries for authorization guards
      Add canonical scenario and map it to requirement families.

      [x] 17.3.1.1 Subtask - Implement `SCN-022` scenario-catalog entry for policy authorization continuity.
      [x] 17.3.1.2 Subtask - Implement matrix mapping updates linking `SCN-022` to service/control-plane coverage.
      [x] 17.3.1.3 Subtask - Implement phase-specific conformance scenario document for phase 17.

  [x] 17.4 Section - Phase 17 Integration Tests
    Validate authorization guard behavior end-to-end in conformance tests.

    [x] 17.4.1 Task - Policy authorization conformance scenarios
      Verify deterministic deny/allow decisions and fail-closed malformed policy behavior.

      [x] 17.4.1.1 Subtask - Verify `SCN-022` denied events do not dispatch and surface typed authorization errors.
      [x] 17.4.1.2 Subtask - Verify `SCN-022` allowed events dispatch when policy requirements are satisfied.
      [x] 17.4.1.3 Subtask - Verify `SCN-022` malformed policy shapes fail closed deterministically.
