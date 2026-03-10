# Phase 40 - Frontend Event Payload Contract Parity and Required-Key Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/events/event_catalog.ex`
- `scripts/validate_frontend_event_payload_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.Events.EventCatalog` is the canonical authority for widget event payload required-key specs (`required_all_of`, `required_any_of`).
- Frontend harness CloudEvent `data` payloads must satisfy canonical required key constraints for emitted/validated widget event types.
- Payload parity checks must execute deterministically in local hooks and CI merge gates.

[x] 40 Phase 40 - Frontend Event Payload Contract Parity and Required-Key Guardrails
  Align frontend harness widget event payload-key handling with canonical event catalog contracts and enforce deterministic invalid-payload guardrails.

  [x] 40.1 Section - Elm Payload-Key Contract Modeling
    Model emitted widget event payload keys in Elm using explicit contract helpers for required key sets.

    [x] 40.1.1 Task - Implement deterministic Elm required payload-key helpers
      Replace ad hoc payload construction with explicit required key composition for emitted default widget event envelopes.

      [x] 40.1.1.1 Subtask - Implement canonical widget payload key declaration list in Elm harness.
      [x] 40.1.1.2 Subtask - Implement default emitted widget event required-key helper lists (`required_all_of`, `required_any_of`).
      [x] 40.1.1.3 Subtask - Implement payload builder composition through required-key helper functions.

  [x] 40.2 Section - JS Required-Key Validation Guardrails
    Enforce fail-closed required-key validation for CloudEvent `data` payloads in JS bridge paths.

    [x] 40.2.1 Task - Implement deterministic JS payload required-key enforcement
      Validate canonical widget event payload `data` against required key specs and emit typed invalid-payload failures.

      [x] 40.2.1.1 Subtask - Implement canonical widget event payload-key spec map in JS bridge runtime harness.
      [x] 40.2.1.2 Subtask - Implement payload required-key presence checks for `required_all_of` and `required_any_of` groups.
      [x] 40.2.1.3 Subtask - Implement typed `transport.invalid_widget_event_payload` fail-closed error path with stable diagnostics.

  [x] 40.3 Section - Payload Contract Validation Gates
    Add deterministic frontend event payload parity validation tooling and local/CI gate wiring.

    [x] 40.3.1 Task - Implement frontend payload contract validator and gate integration
      Validate Elm/JS payload key parity and guardrail wiring against `WebUi.Events.EventCatalog` in local and CI workflows.

      [x] 40.3.1.1 Subtask - Implement `validate_frontend_event_payload_contract.sh` with canonical required-key extraction from `WebUi.Events.EventCatalog`.
      [x] 40.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for frontend payload contract checks.
      [x] 40.3.1.3 Subtask - Implement frontend workflow and README updates for payload contract validation commands.

  [x] 40.4 Section - Phase 40 Integration Tests
    Validate payload contract parity and typed invalid-payload guardrails through conformance-tagged scenarios.

    [x] 40.4.1 Task - Frontend payload contract parity conformance scenarios
      Verify canonical payload-key parity checks, typed invalid-payload guardrails, and deterministic gate wiring continuity.

      [x] 40.4.1.1 Subtask - Verify `SCN-045` frontend payload contract validator passes on canonical harness state.
      [x] 40.4.1.2 Subtask - Verify `SCN-045` frontend harness references canonical payload keys and typed invalid-payload guardrails in Elm/JS.
      [x] 40.4.1.3 Subtask - Verify `SCN-045` local hooks and CI workflow include frontend payload contract validation commands.
