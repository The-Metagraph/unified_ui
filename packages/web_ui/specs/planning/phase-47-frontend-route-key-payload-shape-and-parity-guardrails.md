# Phase 47 - Frontend Route-Key Payload-Shape and Parity Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/widget_registry.ex`
- `scripts/validate_frontend_event_route_key_shape_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.WidgetRegistry` route key requirements are the canonical source for route-family route-key payload shape.
- Frontend widget payload `route_keys` SHOULD preserve canonical list payload shape (`array<non-empty string>`) for guarded route families.
- Route-key payload-shape parity checks MUST execute deterministically in local hooks and CI merge gates.

[x] 47 Phase 47 - Frontend Route-Key Payload-Shape and Parity Guardrails
  Align frontend harness route-key payload-shape continuity with canonical route-key requirements and enforce deterministic typed invalid-value guardrails.

  [x] 47.1 Section - Elm Route-Key Payload-Shape Modeling
    Model deterministic canonical route-key payload-shape filtering in Elm harness route-key continuity derivation.

    [x] 47.1.1 Task - Implement deterministic Elm canonical route-key payload-shape helpers
      Derive declared route keys through canonical non-empty, allowed, and unique route-key shaping helpers.

      [x] 47.1.1.1 Subtask - Implement canonical route-key shape helper for non-empty route-key filtering in Elm harness.
      [x] 47.1.1.2 Subtask - Implement route-key uniqueness helper to keep deterministic declared-route-key payload shape.
      [x] 47.1.1.3 Subtask - Implement declared route-key continuity wiring through canonical route-key shape helper.

  [x] 47.2 Section - JS Route-Key Payload-Shape Guardrails
    Enforce deterministic route-key payload-value shape checks in JS route validation guardrails.

    [x] 47.2.1 Task - Implement typed JS route-key payload-shape enforcement
      Validate declared payload route-key values are list-shaped non-empty strings and fail closed with typed invalid-value diagnostics.

      [x] 47.2.1.1 Subtask - Implement route-key value-type helper and declared route-key payload analysis helper in JS bridge.
      [x] 47.2.1.2 Subtask - Implement typed invalid route-key value fail-closed diagnostics (`expected_value_shape`, `actual_value_shape`, `invalid_route_keys`).
      [x] 47.2.1.3 Subtask - Implement route-key payload-shape validation ordering before completeness/order/allowlist parity checks.

  [x] 47.3 Section - Route-Key Payload-Shape Validation Gates
    Add deterministic frontend route-key payload-shape validation tooling and local/CI gate wiring.

    [x] 47.3.1 Task - Implement frontend route-key payload-shape validator and gate integration
      Validate Elm/JS route-key payload-shape parity against canonical route-key requirements in local and CI workflows.

      [x] 47.3.1.1 Subtask - Implement `validate_frontend_event_route_key_shape_contract.sh` with canonical route-family/route-key extraction.
      [x] 47.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend route-key payload-shape checks.
      [x] 47.3.1.3 Subtask - Implement frontend workflow and README updates for route-key payload-shape validation commands.

  [x] 47.4 Section - Phase 47 Integration Tests
    Validate route-key payload-shape and parity guardrails through conformance-tagged scenarios.

    [x] 47.4.1 Task - Frontend route-key payload-shape conformance scenarios
      Verify canonical route-key payload-shape checks, typed invalid-value guardrails, and deterministic gate wiring continuity.

      [x] 47.4.1.1 Subtask - Verify `SCN-052` frontend route-key payload-shape validator passes on canonical harness state.
      [x] 47.4.1.2 Subtask - Verify `SCN-052` frontend harness references route-key payload-shape continuity fields and typed invalid-value guardrails in Elm/JS.
      [x] 47.4.1.3 Subtask - Verify `SCN-052` local hooks and CI workflow include frontend route-key payload-shape validation commands.
