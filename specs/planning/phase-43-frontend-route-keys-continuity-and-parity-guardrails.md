# Phase 43 - Frontend Route-Keys Continuity and Parity Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/widget_registry.ex`
- `scripts/validate_frontend_event_route_keys_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.WidgetRegistry` route key requirements are the canonical source for route dispatch-key families (`click`, `change`, `submit`).
- Frontend widget payloads SHOULD preserve a `route_keys` continuity field representing populated canonical route keys for guarded route families.
- Route-keys continuity parity checks MUST execute deterministically in local hooks and CI merge gates.

[x] 43 Phase 43 - Frontend Route-Keys Continuity and Parity Guardrails
  Align frontend harness route-keys payload continuity with canonical route-key requirements and enforce deterministic typed mismatch guardrails.

  [x] 43.1 Section - Elm Route-Keys Continuity Modeling
    Model deterministic route-keys continuity payload emission in Elm harness event data composition.

    [x] 43.1.1 Task - Implement deterministic Elm declared route-keys helpers
      Emit canonical route-keys continuity fields derived from route family requirement keys and populated payload fields.

      [x] 43.1.1.1 Subtask - Implement `route_keys` payload key declarations in Elm canonical payload-key list.
      [x] 43.1.1.2 Subtask - Implement declared route-keys derivation helper based on route-family requirement keys.
      [x] 43.1.1.3 Subtask - Implement `route_keys` continuity payload field wiring in emitted widget event data.

  [x] 43.2 Section - JS Route-Keys Continuity Guardrails
    Enforce deterministic route-keys continuity parity checks in JS route validation guardrails.

    [x] 43.2.1 Task - Implement typed JS route-keys continuity mismatch enforcement
      Validate declared payload route-keys against canonical observed route keys and fail closed on missing/mismatched continuity fields.

      [x] 43.2.1.1 Subtask - Implement declared route-keys normalization helper in JS bridge.
      [x] 43.2.1.2 Subtask - Implement typed missing route-keys continuity error path for guarded route families.
      [x] 43.2.1.3 Subtask - Implement typed mismatch diagnostics (`expected_route_keys`, `actual_route_keys`) for route-keys continuity failures.

  [x] 43.3 Section - Route-Keys Contract Validation Gates
    Add deterministic frontend route-keys continuity validation tooling and local/CI gate wiring.

    [x] 43.3.1 Task - Implement frontend route-keys continuity validator and gate integration
      Validate Elm/JS route-keys continuity parity against canonical route-key requirements in local and CI workflows.

      [x] 43.3.1.1 Subtask - Implement `validate_frontend_event_route_keys_contract.sh` with canonical route-family/route-key extraction.
      [x] 43.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend route-keys continuity checks.
      [x] 43.3.1.3 Subtask - Implement frontend workflow and README updates for route-keys continuity validation commands.

  [x] 43.4 Section - Phase 43 Integration Tests
    Validate route-keys continuity and parity guardrails through conformance-tagged scenarios.

    [x] 43.4.1 Task - Frontend route-keys continuity conformance scenarios
      Verify canonical route-keys continuity checks, typed mismatch guardrails, and deterministic gate wiring continuity.

      [x] 43.4.1.1 Subtask - Verify `SCN-048` frontend route-keys continuity validator passes on canonical harness state.
      [x] 43.4.1.2 Subtask - Verify `SCN-048` frontend harness references canonical route-keys continuity fields and typed mismatch guardrails in Elm/JS.
      [x] 43.4.1.3 Subtask - Verify `SCN-048` local hooks and CI workflow include frontend route-keys continuity validation commands.
