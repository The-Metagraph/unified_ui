# Phase 51 - Frontend Route-Key Source-Keys and Parity Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/widget_registry.ex`
- `scripts/validate_frontend_event_route_key_source_keys_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.WidgetRegistry` route key requirements are the canonical source for required route-key source-key continuity by route family.
- Frontend widget payload `route_key_source_keys` for guarded route families SHOULD preserve canonical key membership and order continuity aligned with route-key source requirements.
- Route-key source-key parity checks MUST execute deterministically in local hooks and CI merge gates.

[x] 51 Phase 51 - Frontend Route-Key Source-Keys and Parity Guardrails
  Align frontend harness route-key source-key continuity with canonical route-key source conventions and enforce deterministic typed source-key mismatch guardrails.

  [x] 51.1 Section - Elm Route-Key Source-Key Modeling
    Model deterministic canonical route-key source-key continuity payload emission in Elm harness source composition.

    [x] 51.1.1 Task - Implement deterministic Elm canonical route-key source-key helpers
      Emit ordered source-key continuity metadata from canonical source entries for guarded route families.

      [x] 51.1.1.1 Subtask - Implement declared route-key source-entry helper in Elm harness source continuity paths.
      [x] 51.1.1.2 Subtask - Implement declared route-key source-key derivation helper from source entries.
      [x] 51.1.1.3 Subtask - Implement `route_key_source_keys` continuity payload wiring in emitted widget event data.

  [x] 51.2 Section - JS Route-Key Source-Key Guardrails
    Enforce deterministic route-key source-key continuity checks in JS route validation guardrails.

    [x] 51.2.1 Task - Implement typed JS required route-key source-key enforcement
      Validate payload route-key source-key shape, completeness, allowlist, order, and parity with `route_key_sources` entries.

      [x] 51.2.1.1 Subtask - Implement declared route-key source-key analysis helper in JS bridge route validation logic.
      [x] 51.2.1.2 Subtask - Implement typed route-key source-key fail-closed diagnostics (`expected_route_key_source_keys`, `actual_route_key_source_keys`, `duplicate_route_key_source_keys`).
      [x] 51.2.1.3 Subtask - Implement route-key source-key parity checks with `route_key_sources` entries before route-key order/allowlist checks.

  [x] 51.3 Section - Route-Key Source-Key Validation Gates
    Add deterministic frontend route-key source-key validation tooling and local/CI gate wiring.

    [x] 51.3.1 Task - Implement frontend route-key source-key validator and gate integration
      Validate Elm/JS route-key source-key parity against canonical route-key source conventions in local and CI workflows.

      [x] 51.3.1.1 Subtask - Implement `validate_frontend_event_route_key_source_keys_contract.sh` with canonical route-family/route-key extraction.
      [x] 51.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend route-key source-key checks.
      [x] 51.3.1.3 Subtask - Implement frontend workflow and README updates for route-key source-key validation commands.

  [x] 51.4 Section - Phase 51 Integration Tests
    Validate route-key source-key and parity guardrails through conformance-tagged scenarios.

    [x] 51.4.1 Task - Frontend route-key source-key conformance scenarios
      Verify canonical route-key source-key checks, typed source-key mismatch guardrails, and deterministic gate wiring continuity.

      [x] 51.4.1.1 Subtask - Verify `SCN-056` frontend route-key source-key validator passes on canonical harness state.
      [x] 51.4.1.2 Subtask - Verify `SCN-056` frontend harness references route-key source-key continuity helpers and typed source-key mismatch guardrails in Elm/JS.
      [x] 51.4.1.3 Subtask - Verify `SCN-056` local hooks and CI workflow include frontend route-key source-key validation commands.
