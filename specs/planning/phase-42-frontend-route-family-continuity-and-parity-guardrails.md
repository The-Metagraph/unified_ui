# Phase 42 - Frontend Route-Family Continuity and Parity Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/events/event_catalog.ex`
- `scripts/validate_frontend_event_route_family_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.Events.EventCatalog` is the canonical authority for event-type to route-family mappings.
- Frontend CloudEvent widget payloads MUST preserve a `route_family` field that matches canonical route-family mapping for the emitted widget event type.
- Route-family continuity parity checks MUST execute deterministically in local hooks and CI merge gates.

[x] 42 Phase 42 - Frontend Route-Family Continuity and Parity Guardrails
  Align frontend harness route-family payload continuity with canonical event route mappings and enforce deterministic typed mismatch guardrails.

  [x] 42.1 Section - Elm Route-Family Continuity Modeling
    Model canonical event-type to route-family mapping in Elm and propagate route-family payload continuity fields for emitted widget events.

    [x] 42.1.1 Task - Implement deterministic Elm route-family continuity helpers
      Ensure emitted payloads carry canonical `route_family` values derived from event-type mapping helpers.

      [x] 42.1.1.1 Subtask - Implement canonical event-type to route-family tuple mapping in Elm harness.
      [x] 42.1.1.2 Subtask - Implement default route-family derivation from emitted default widget event type.
      [x] 42.1.1.3 Subtask - Implement `route_family` continuity payload field wiring in emitted widget event data.

  [x] 42.2 Section - JS Route-Family Continuity Guardrails
    Enforce canonical route-family continuity validation in JS CloudEvent envelope guardrails.

    [x] 42.2.1 Task - Implement deterministic JS route-family continuity checks
      Validate declared payload `route_family` values against canonical event-type route-family mappings and fail closed on mismatch.

      [x] 42.2.1.1 Subtask - Implement declared payload `route_family` extraction in JS bridge route validation helper.
      [x] 42.2.1.2 Subtask - Implement typed missing/mismatch route-family fail-closed checks against canonical mapping.
      [x] 42.2.1.3 Subtask - Implement stable route-family diagnostics (`expected_route_family`, `actual_route_family`) for typed failures.

  [x] 42.3 Section - Route-Family Contract Validation Gates
    Add deterministic frontend route-family continuity validation tooling and local/CI gate wiring.

    [x] 42.3.1 Task - Implement frontend route-family continuity validator and gate integration
      Validate Elm/JS route-family continuity parity against canonical event route mappings in local and CI workflows.

      [x] 42.3.1.1 Subtask - Implement `validate_frontend_event_route_family_contract.sh` with canonical event-route mapping extraction.
      [x] 42.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend route-family continuity checks.
      [x] 42.3.1.3 Subtask - Implement frontend workflow and README updates for route-family continuity validation commands.

  [x] 42.4 Section - Phase 42 Integration Tests
    Validate route-family continuity and parity guardrails through conformance-tagged scenarios.

    [x] 42.4.1 Task - Frontend route-family continuity conformance scenarios
      Verify canonical route-family continuity checks, typed mismatch guardrails, and deterministic gate wiring continuity.

      [x] 42.4.1.1 Subtask - Verify `SCN-047` frontend route-family continuity validator passes on canonical harness state.
      [x] 42.4.1.2 Subtask - Verify `SCN-047` frontend harness references canonical route-family mappings and typed mismatch guardrails in Elm/JS.
      [x] 42.4.1.3 Subtask - Verify `SCN-047` local hooks and CI workflow include frontend route-family continuity validation commands.
