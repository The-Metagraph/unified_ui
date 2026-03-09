# Phase 39 - Frontend Event Catalog Parity and Typed Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/events/event_catalog.ex`
- `scripts/validate_frontend_event_catalog_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.Events.EventCatalog` is the canonical authority for allowed widget event `type` values.
- Frontend harness command envelopes must use canonical widget event types only and fail closed for unknown types.
- Event catalog parity checks must execute deterministically in local hooks and CI merge gates.

[x] 39 Phase 39 - Frontend Event Catalog Parity and Typed Guardrails
  Align frontend harness widget event-type handling with canonical event catalog contracts and enforce deterministic invalid-type guardrails.

  [x] 39.1 Section - Elm Canonical Event-Type Modeling
    Model frontend CloudEvent `type` emission from an explicit canonical widget event-type list in Elm.

    [x] 39.1.1 Task - Implement deterministic Elm canonical widget event-type helpers
      Replace single hardcoded widget event type usage with explicit canonical catalog-backed helper composition.

      [x] 39.1.1.1 Subtask - Implement canonical widget event-type list in Elm runtime harness.
      [x] 39.1.1.2 Subtask - Implement deterministic default event-type helper derived from canonical list.
      [x] 39.1.1.3 Subtask - Implement CloudEvent envelope `type` wiring through canonical event-type helper.

  [x] 39.2 Section - JS Typed Invalid-Event Guardrails
    Enforce fail-closed widget event-type membership checks in JS CloudEvent validation paths.

    [x] 39.2.1 Task - Implement deterministic JS canonical event-type membership enforcement
      Validate outbound CloudEvent `type` against canonical widget event set and emit typed protocol failures on unknown values.

      [x] 39.2.1.1 Subtask - Implement canonical widget event-type list in JS bridge runtime transport harness.
      [x] 39.2.1.2 Subtask - Implement CloudEvent `type` membership validation against canonical widget event type set.
      [x] 39.2.1.3 Subtask - Implement typed `transport.invalid_widget_event_type` fail-closed error path with context continuity metadata.

  [x] 39.3 Section - Event Catalog Contract Validation Gates
    Add deterministic frontend event catalog parity validation tooling and local/CI gate wiring.

    [x] 39.3.1 Task - Implement frontend event catalog validator and gate integration
      Validate Elm/JS harness canonical widget event-type parity against `WebUi.Events.EventCatalog` in local and CI workflows.

      [x] 39.3.1.1 Subtask - Implement `validate_frontend_event_catalog_contract.sh` with canonical event-type extraction from `WebUi.Events.EventCatalog`.
      [x] 39.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend event catalog parity checks.
      [x] 39.3.1.3 Subtask - Implement frontend workflow and README updates for event catalog contract validation commands.

  [x] 39.4 Section - Phase 39 Integration Tests
    Validate event catalog parity and typed invalid-event guardrails through conformance-tagged scenarios.

    [x] 39.4.1 Task - Frontend event catalog parity conformance scenarios
      Verify canonical event-type parity checks, typed invalid-event guardrails, and deterministic gate wiring continuity.

      [x] 39.4.1.1 Subtask - Verify `SCN-044` frontend event catalog validator passes on canonical harness state.
      [x] 39.4.1.2 Subtask - Verify `SCN-044` frontend harness references canonical widget event types and typed invalid-event guardrails in Elm/JS.
      [x] 39.4.1.3 Subtask - Verify `SCN-044` local hooks and CI workflow include frontend event catalog contract validation commands.
