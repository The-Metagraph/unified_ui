# Phase 49 - Frontend Route-Key Value-Source and Parity Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/widget_registry.ex`
- `scripts/validate_frontend_event_route_key_source_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.WidgetRegistry` route key requirements are the canonical source for required route-key source expectations by route family.
- Frontend widget payload route-key values for guarded route families SHOULD preserve canonical value-source continuity (`route_key_contract` vs `widget_event_contract`).
- Route-key value-source parity checks MUST execute deterministically in local hooks and CI merge gates.

[x] 49 Phase 49 - Frontend Route-Key Value-Source and Parity Guardrails
  Align frontend harness route-key value-source continuity with canonical route-key source conventions and enforce deterministic typed invalid-source guardrails.

  [x] 49.1 Section - Elm Route-Key Value-Source Modeling
    Model deterministic canonical route-key value-source helpers in Elm harness route-key compatibility composition.

    [x] 49.1.1 Task - Implement deterministic Elm canonical route-key source helpers
      Resolve route-key compatibility values through explicit canonical source-resolution helpers and emit source continuity metadata.

      [x] 49.1.1.1 Subtask - Implement canonical route-key source resolution helper in Elm harness compatibility paths.
      [x] 49.1.1.2 Subtask - Implement route-key source helper split between route-key contract and widget-event fallback resolution.
      [x] 49.1.1.3 Subtask - Implement route-key source continuity payload wiring through `route_key_sources`.

  [x] 49.2 Section - JS Route-Key Value-Source Guardrails
    Enforce deterministic route-key value-source checks in JS route validation guardrails.

    [x] 49.2.1 Task - Implement typed JS required route-key source enforcement
      Validate required canonical route-key sources against route-family source requirements and fail closed with typed invalid-source diagnostics.

      [x] 49.2.1.1 Subtask - Implement declared route-key source analysis helper in JS bridge route validation logic.
      [x] 49.2.1.2 Subtask - Implement typed invalid route-key source fail-closed diagnostics (`expected_route_key_sources`, `source_mismatches`).
      [x] 49.2.1.3 Subtask - Implement route-key source validation ordering before duplicate/allowlist/order parity checks.

  [x] 49.3 Section - Route-Key Value-Source Validation Gates
    Add deterministic frontend route-key value-source validation tooling and local/CI gate wiring.

    [x] 49.3.1 Task - Implement frontend route-key value-source validator and gate integration
      Validate Elm/JS route-key value-source parity against canonical route-key source conventions in local and CI workflows.

      [x] 49.3.1.1 Subtask - Implement `validate_frontend_event_route_key_source_contract.sh` with canonical route-family/route-key extraction.
      [x] 49.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend route-key value-source checks.
      [x] 49.3.1.3 Subtask - Implement frontend workflow and README updates for route-key value-source validation commands.

  [x] 49.4 Section - Phase 49 Integration Tests
    Validate route-key value-source and parity guardrails through conformance-tagged scenarios.

    [x] 49.4.1 Task - Frontend route-key value-source conformance scenarios
      Verify canonical route-key value-source checks, typed invalid-source guardrails, and deterministic gate wiring continuity.

      [x] 49.4.1.1 Subtask - Verify `SCN-054` frontend route-key value-source validator passes on canonical harness state.
      [x] 49.4.1.2 Subtask - Verify `SCN-054` frontend harness references route-key value-source continuity helpers and typed invalid-source guardrails in Elm/JS.
      [x] 49.4.1.3 Subtask - Verify `SCN-054` local hooks and CI workflow include frontend route-key value-source validation commands.
