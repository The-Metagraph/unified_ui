# Phase 46 - Frontend Route-Key Allowlist and Parity Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/widget_registry.ex`
- `scripts/validate_frontend_event_route_key_allowlist_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.WidgetRegistry` route key requirements are the canonical source of route-family route-key allowlists.
- Frontend widget payload `route_keys` SHOULD include only canonical route keys allowed for the declared route family.
- Route-key allowlist parity checks MUST execute deterministically in local hooks and CI merge gates.

[x] 46 Phase 46 - Frontend Route-Key Allowlist and Parity Guardrails
  Align frontend harness route-key allowlist continuity with canonical route-key requirements and enforce deterministic typed unexpected-key guardrails.

  [x] 46.1 Section - Elm Route-Key Allowlist Modeling
    Model deterministic route-key allowlist continuity in Elm harness route-key derivation.

    [x] 46.1.1 Task - Implement deterministic Elm route-key allowlist derivation helpers
      Derive declared route keys from compatibility field composition and explicit route-family allowlist membership checks.

      [x] 46.1.1.1 Subtask - Implement Elm route-key compatibility key derivation helper from compatibility fields.
      [x] 46.1.1.2 Subtask - Implement explicit route-family allowlist membership helper for route-key filtering.
      [x] 46.1.1.3 Subtask - Implement declared route-key continuity wiring through compatibility-derived allowlist keys.

  [x] 46.2 Section - JS Route-Key Allowlist Guardrails
    Enforce deterministic non-canonical route-key fail-closed checks in JS route validation guardrails.

    [x] 46.2.1 Task - Implement typed JS unexpected route-key allowlist enforcement
      Validate declared payload route keys stay within canonical route-family allowlists and fail closed with typed unexpected-key diagnostics.

      [x] 46.2.1.1 Subtask - Implement unexpected route-key detection helper from declared route_keys against canonical route-family requirements.
      [x] 46.2.1.2 Subtask - Implement typed unexpected-route-key fail-closed diagnostics (`allowed_route_keys`, `unexpected_route_keys`).
      [x] 46.2.1.3 Subtask - Implement canonical route-key allowlist continuity reason metadata for invalid route-key payloads.

  [x] 46.3 Section - Route-Key Allowlist Validation Gates
    Add deterministic frontend route-key allowlist validation tooling and local/CI gate wiring.

    [x] 46.3.1 Task - Implement frontend route-key allowlist validator and gate integration
      Validate Elm/JS route-key allowlist parity against canonical route-key requirements in local and CI workflows.

      [x] 46.3.1.1 Subtask - Implement `validate_frontend_event_route_key_allowlist_contract.sh` with canonical route-family/route-key extraction.
      [x] 46.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend route-key allowlist checks.
      [x] 46.3.1.3 Subtask - Implement frontend workflow and README updates for route-key allowlist validation commands.

  [x] 46.4 Section - Phase 46 Integration Tests
    Validate route-key allowlist and parity guardrails through conformance-tagged scenarios.

    [x] 46.4.1 Task - Frontend route-key allowlist conformance scenarios
      Verify canonical route-key allowlist checks, typed unexpected-key guardrails, and deterministic gate wiring continuity.

      [x] 46.4.1.1 Subtask - Verify `SCN-051` frontend route-key allowlist validator passes on canonical harness state.
      [x] 46.4.1.2 Subtask - Verify `SCN-051` frontend harness references allowlist route-key continuity fields and typed unexpected-key guardrails in Elm/JS.
      [x] 46.4.1.3 Subtask - Verify `SCN-051` local hooks and CI workflow include frontend route-key allowlist validation commands.
