# Phase 37 - Frontend CloudEvent Contract Parity and Envelope Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/cloud_event.ex`
- `scripts/validate_frontend_cloudevent_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.CloudEvent` remains the canonical authority for required CloudEvent fields and required extensions.
- Frontend harness CloudEvent payloads must preserve required envelope keys and context continuity fields.
- CloudEvent contract parity validation must run in local hooks and CI merge gates.

[x] 37 Phase 37 - Frontend CloudEvent Contract Parity and Envelope Guardrails
  Align frontend runtime harness CloudEvent behavior with canonical service contracts and enforce deterministic envelope validation gates.

  [x] 37.1 Section - Elm CloudEvent Envelope Normalization
    Normalize frontend CloudEvent payload construction in Elm runtime command flow.

    [x] 37.1.1 Task - Implement deterministic Elm CloudEvent envelope helpers
      Extract explicit CloudEvent and payload builders so required fields and required extensions stay stable and reviewable.

      [x] 37.1.1.1 Subtask - Implement dedicated CloudEvent envelope builder function for runtime send commands.
      [x] 37.1.1.2 Subtask - Implement dedicated widget-event `data` payload builder with deterministic field set.
      [x] 37.1.1.3 Subtask - Implement deterministic local event-id helper for emitted CloudEvent envelopes.

  [x] 37.2 Section - JS CloudEvent Envelope Validation Guardrails
    Add fail-closed JS bridge validation for outbound runtime send CloudEvent payloads.

    [x] 37.2.1 Task - Implement deterministic CloudEvent envelope validation in JS bridge
      Validate required fields/extensions and typed envelope constraints before loopback recv dispatch.

      [x] 37.2.1.1 Subtask - Implement required CloudEvent field and extension lists in JS bridge.
      [x] 37.2.1.2 Subtask - Implement envelope shape, required-key, and `specversion` validation checks.
      [x] 37.2.1.3 Subtask - Implement typed `transport.invalid_cloudevent_envelope` fail-closed error path.

  [x] 37.3 Section - CloudEvent Contract Validation Gates
    Add deterministic CloudEvent parity validation tooling and local/CI gate wiring.

    [x] 37.3.1 Task - Implement frontend CloudEvent contract validator and gate wiring
      Validate frontend harness parity against `WebUi.CloudEvent` required fields/extensions in local and CI workflows.

      [x] 37.3.1.1 Subtask - Implement `validate_frontend_cloudevent_contract.sh` with required field/extension extraction from `WebUi.CloudEvent`.
      [x] 37.3.1.2 Subtask - Implement pre-commit/pre-push + Makefile command wiring for CloudEvent contract checks.
      [x] 37.3.1.3 Subtask - Implement frontend workflow and README updates for CloudEvent contract parity gates.

  [x] 37.4 Section - Phase 37 Integration Tests
    Validate CloudEvent contract parity and gate coverage through conformance-tagged scenarios.

    [x] 37.4.1 Task - Frontend CloudEvent contract conformance scenarios
      Verify canonical CloudEvent parity checks and deterministic gate-wiring continuity for frontend harness paths.

      [x] 37.4.1.1 Subtask - Verify `SCN-042` frontend CloudEvent contract validator passes on canonical harness state.
      [x] 37.4.1.2 Subtask - Verify `SCN-042` frontend harness references required CloudEvent fields/extensions and typed invalid-envelope error code.
      [x] 37.4.1.3 Subtask - Verify `SCN-042` local hooks and CI workflow include CloudEvent contract validation commands.
