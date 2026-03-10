# Phase 52 - Frontend Route-Key Source-Key and Route-Key Parity Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/widget_registry.ex`
- `scripts/validate_frontend_event_route_key_source_key_parity_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.WidgetRegistry` route key requirements are the canonical source for required route-key source-key and route-key continuity relationships by route family.
- Frontend widget payload `route_key_source_keys` SHOULD preserve deterministic parity with emitted `route_keys` continuity for guarded route families.
- Route-key source-key to route-key parity checks MUST execute deterministically in local hooks and CI merge gates.

[x] 52 Phase 52 - Frontend Route-Key Source-Key and Route-Key Parity Guardrails
  Align frontend harness route-key source-key continuity with emitted route-key continuity fields and enforce deterministic typed source-key-to-route-key mismatch guardrails.

  [x] 52.1 Section - Elm Route-Key Source-Key Parity Modeling
    Model deterministic route-key source-key and route-key parity helpers in Elm harness continuity composition.

    [x] 52.1.1 Task - Implement deterministic Elm route-key source-key parity helper wiring
      Emit route-key source entries and source-key continuity from parity-aligned helper paths that track emitted route keys.

      [x] 52.1.1.1 Subtask - Implement declared route-key source-key parity helper in Elm harness source continuity paths.
      [x] 52.1.1.2 Subtask - Implement route-key source entry derivation from parity helper outputs.
      [x] 52.1.1.3 Subtask - Implement route-key source-key payload wiring from parity helper outputs.

  [x] 52.2 Section - JS Route-Key Source-Key and Route-Key Parity Guardrails
    Enforce deterministic route-key source-key to route-key parity checks in JS route validation guardrails.

    [x] 52.2.1 Task - Implement typed JS route-key source-key to route-key parity enforcement
      Validate payload route-key source-key ordering and membership remain parity-aligned with emitted route-key continuity lists.

      [x] 52.2.1.1 Subtask - Implement route-key source-key parity analysis helper between `route_key_source_keys` and `route_keys`.
      [x] 52.2.1.2 Subtask - Implement typed source-key parity fail-closed diagnostics (`source_key_parity_mismatches`).
      [x] 52.2.1.3 Subtask - Implement source-key to route-key parity validation ordering before route validation success.

  [x] 52.3 Section - Route-Key Source-Key Parity Validation Gates
    Add deterministic frontend route-key source-key parity validation tooling and local/CI gate wiring.

    [x] 52.3.1 Task - Implement frontend route-key source-key parity validator and gate integration
      Validate Elm/JS route-key source-key to route-key parity against canonical route-key continuity conventions in local and CI workflows.

      [x] 52.3.1.1 Subtask - Implement `validate_frontend_event_route_key_source_key_parity_contract.sh` with canonical route-family/route-key extraction.
      [x] 52.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend route-key source-key parity checks.
      [x] 52.3.1.3 Subtask - Implement frontend workflow and README updates for route-key source-key parity validation commands.

  [x] 52.4 Section - Phase 52 Integration Tests
    Validate route-key source-key to route-key parity guardrails through conformance-tagged scenarios.

    [x] 52.4.1 Task - Frontend route-key source-key to route-key parity conformance scenarios
      Verify canonical route-key source-key to route-key parity checks, typed mismatch guardrails, and deterministic gate wiring continuity.

      [x] 52.4.1.1 Subtask - Verify `SCN-057` frontend route-key source-key parity validator passes on canonical harness state.
      [x] 52.4.1.2 Subtask - Verify `SCN-057` frontend harness references source-key parity helpers and typed mismatch guardrails in Elm/JS.
      [x] 52.4.1.3 Subtask - Verify `SCN-057` local hooks and CI workflow include frontend route-key source-key parity validation commands.
