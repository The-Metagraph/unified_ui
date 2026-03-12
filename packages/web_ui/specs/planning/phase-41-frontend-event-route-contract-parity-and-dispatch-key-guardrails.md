# Phase 41 - Frontend Event Route Contract Parity and Dispatch-Key Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/events/event_catalog.ex`
- `lib/web_ui/widget_registry.ex`
- `scripts/validate_frontend_event_route_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.Events.EventCatalog` is the canonical authority for event-type `route_family` assignments.
- `WebUi.WidgetRegistry` route key conventions are canonical for dispatch-key compatibility (`click`, `change`, `submit`).
- Frontend harness payloads MUST preserve route-key compatibility and fail closed on invalid route-key conditions.

[x] 41 Phase 41 - Frontend Event Route Contract Parity and Dispatch-Key Guardrails
  Align frontend harness route-family mapping and dispatch-key compatibility with canonical route contracts and enforce deterministic invalid-route guardrails.

  [x] 41.1 Section - Elm Route-Key Compatibility Modeling
    Model canonical route-family key conventions in Elm payload composition helpers.

    [x] 41.1.1 Task - Implement deterministic Elm route-family compatibility helpers
      Compose route-family compatibility keys through explicit canonical route key requirement helpers.

      [x] 41.1.1.1 Subtask - Implement canonical route key requirement declarations for `click`, `change`, and `submit` families in Elm harness.
      [x] 41.1.1.2 Subtask - Implement default emitted widget event route-family helper in Elm harness.
      [x] 41.1.1.3 Subtask - Implement route-family compatibility field composition in emitted widget event payload builders.

  [x] 41.2 Section - JS Route-Family Guardrails
    Enforce route-family mapping and dispatch-key presence guardrails in JS CloudEvent validation paths.

    [x] 41.2.1 Task - Implement deterministic JS route-family and dispatch-key enforcement
      Validate canonical event-type to route-family mappings and require route-key compatibility for guarded families.

      [x] 41.2.1.1 Subtask - Implement canonical event-type route-family mapping map in JS bridge runtime harness.
      [x] 41.2.1.2 Subtask - Implement canonical route-key requirement map for guarded route families in JS bridge.
      [x] 41.2.1.3 Subtask - Implement typed `transport.invalid_widget_event_route` fail-closed path for missing dispatch-key compatibility.

  [x] 41.3 Section - Route Contract Validation Gates
    Add deterministic frontend route parity validation tooling and local/CI gate wiring.

    [x] 41.3.1 Task - Implement frontend route contract validator and gate integration
      Validate Elm/JS route-family and dispatch-key parity against canonical route contracts in local and CI workflows.

      [x] 41.3.1.1 Subtask - Implement `validate_frontend_event_route_contract.sh` with canonical route-family and route-key extraction.
      [x] 41.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend route contract checks.
      [x] 41.3.1.3 Subtask - Implement frontend workflow and README updates for route contract validation commands.

  [x] 41.4 Section - Phase 41 Integration Tests
    Validate route-family parity and typed invalid-route guardrails through conformance-tagged scenarios.

    [x] 41.4.1 Task - Frontend route contract parity conformance scenarios
      Verify canonical route-family/dispatch-key parity checks, typed invalid-route guardrails, and deterministic gate wiring continuity.

      [x] 41.4.1.1 Subtask - Verify `SCN-046` frontend route contract validator passes on canonical harness state.
      [x] 41.4.1.2 Subtask - Verify `SCN-046` frontend harness references canonical route families/dispatch keys and typed invalid-route guardrails in Elm/JS.
      [x] 41.4.1.3 Subtask - Verify `SCN-046` local hooks and CI workflow include frontend route contract validation commands.
