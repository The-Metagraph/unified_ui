# Phase 48 - Frontend Route-Key Value-Shape and Parity Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/widget_registry.ex`
- `scripts/validate_frontend_event_route_key_value_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.WidgetRegistry` route key requirements are the canonical source for required route-key value-shape expectations by route family.
- Frontend widget payload route-key values for guarded route families SHOULD preserve canonical non-empty string value shape.
- Route-key value-shape parity checks MUST execute deterministically in local hooks and CI merge gates.

[x] 48 Phase 48 - Frontend Route-Key Value-Shape and Parity Guardrails
  Align frontend harness route-key value-shape continuity with canonical route-key requirements and enforce deterministic typed invalid-value guardrails.

  [x] 48.1 Section - Elm Route-Key Value-Shape Modeling
    Model deterministic canonical route-key value-shape helpers in Elm harness route-key compatibility composition.

    [x] 48.1.1 Task - Implement deterministic Elm canonical route-key string-value helpers
      Resolve route-key compatibility values through explicit canonical string-shape helpers with non-empty filtering.

      [x] 48.1.1.1 Subtask - Implement canonical route-key value helper in Elm harness compatibility paths.
      [x] 48.1.1.2 Subtask - Implement route-key string-value helper split between route-key contracts and widget route-key fallbacks.
      [x] 48.1.1.3 Subtask - Implement non-empty route-key string helper wiring for canonical route-key compatibility values.

  [x] 48.2 Section - JS Route-Key Value-Shape Guardrails
    Enforce deterministic route-key value-shape checks in JS route validation guardrails.

    [x] 48.2.1 Task - Implement typed JS required route-key value-shape enforcement
      Validate required canonical route-key values are non-empty strings and fail closed with typed invalid-value diagnostics.

      [x] 48.2.1.1 Subtask - Implement required route-key value-shape analysis helper in JS bridge route validation logic.
      [x] 48.2.1.2 Subtask - Implement typed invalid route-key value fail-closed diagnostics (`expected_route_key_value_shape`, `invalid_route_key_values`).
      [x] 48.2.1.3 Subtask - Implement route-key value-shape validation ordering before duplicate/allowlist/order parity checks.

  [x] 48.3 Section - Route-Key Value-Shape Validation Gates
    Add deterministic frontend route-key value-shape validation tooling and local/CI gate wiring.

    [x] 48.3.1 Task - Implement frontend route-key value-shape validator and gate integration
      Validate Elm/JS route-key value-shape parity against canonical route-key requirements in local and CI workflows.

      [x] 48.3.1.1 Subtask - Implement `validate_frontend_event_route_key_value_contract.sh` with canonical route-family/route-key extraction.
      [x] 48.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend route-key value-shape checks.
      [x] 48.3.1.3 Subtask - Implement frontend workflow and README updates for route-key value-shape validation commands.

  [x] 48.4 Section - Phase 48 Integration Tests
    Validate route-key value-shape and parity guardrails through conformance-tagged scenarios.

    [x] 48.4.1 Task - Frontend route-key value-shape conformance scenarios
      Verify canonical route-key value-shape checks, typed invalid-value guardrails, and deterministic gate wiring continuity.

      [x] 48.4.1.1 Subtask - Verify `SCN-053` frontend route-key value-shape validator passes on canonical harness state.
      [x] 48.4.1.2 Subtask - Verify `SCN-053` frontend harness references route-key value-shape continuity helpers and typed invalid-value guardrails in Elm/JS.
      [x] 48.4.1.3 Subtask - Verify `SCN-053` local hooks and CI workflow include frontend route-key value-shape validation commands.
