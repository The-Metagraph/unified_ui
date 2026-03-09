# Phase 36 - Frontend Transport Contract Parity and Canonical Event Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/transport/naming.ex`
- `scripts/validate_frontend_transport_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.Transport.Naming` is the canonical authority for websocket topic and client/server event names.
- Frontend harness assets MUST NOT introduce transport event names outside the canonical naming set.
- Contract-parity validation must run in local git hooks and CI merge gates.

[x] 36 Phase 36 - Frontend Transport Contract Parity and Canonical Event Guardrails
  Align frontend runtime harness transport naming with canonical service contracts and enforce deterministic validation guardrails.

  [x] 36.1 Section - Elm Transport Contract Alignment
    Align Elm runtime command payloads with canonical transport naming rules.

    [x] 36.1.1 Task - Implement Elm command/event naming parity
      Remove non-canonical transport event names and ensure outbound bootstrap metadata matches canonical expectations.

      [x] 36.1.1.1 Subtask - Implement canonical server-event expectation list in Elm join command payload.
      [x] 36.1.1.2 Subtask - Implement canonical pong-driven connection promotion behavior.
      [x] 36.1.1.3 Subtask - Remove non-canonical join/joined transport event-name usage from Elm runtime flow.

  [x] 36.2 Section - JS Bridge Guardrail Enforcement
    Enforce canonical topic and client-event handling in the local JS transport bridge.

    [x] 36.2.1 Task - Implement deterministic bridge validation behavior
      Validate topic and client event names against canonical allowed sets and fail closed with typed transport errors.

      [x] 36.2.1.1 Subtask - Implement canonical topic validation for `ws_join` commands.
      [x] 36.2.1.2 Subtask - Implement expected-server-event validation for join bootstrap payloads.
      [x] 36.2.1.3 Subtask - Implement fail-closed handling for unknown client event names and pre-join push commands.

  [x] 36.3 Section - Contract Parity Validation Gates
    Add deterministic validation tooling and merge-gate wiring for frontend transport contract parity.

    [x] 36.3.1 Task - Implement frontend transport parity validation script and gate wiring
      Validate parity between frontend harness files and `WebUi.Transport.Naming` in local and CI paths.

      [x] 36.3.1.1 Subtask - Implement `validate_frontend_transport_contract.sh` for canonical topic/event parity checks.
      [x] 36.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for transport parity validation.
      [x] 36.3.1.3 Subtask - Implement frontend workflow and README updates for transport contract parity gates.

  [x] 36.4 Section - Phase 36 Integration Tests
    Validate canonical transport naming parity and gate coverage through conformance-tagged scenarios.

    [x] 36.4.1 Task - Frontend transport contract parity conformance scenarios
      Verify frontend assets reference only canonical transport names and validation gates remain operational.

      [x] 36.4.1.1 Subtask - Verify `SCN-041` frontend transport contract validator passes on canonical harness state.
      [x] 36.4.1.2 Subtask - Verify `SCN-041` Elm and JS harness files do not reference non-canonical join event names.
      [x] 36.4.1.3 Subtask - Verify `SCN-041` CI/frontend hooks include transport contract validation commands.
