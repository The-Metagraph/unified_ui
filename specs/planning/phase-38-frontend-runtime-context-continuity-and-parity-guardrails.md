# Phase 38 - Frontend Runtime-Context Continuity and Parity Guardrails

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `assets/src/Main.elm`
- `assets/js/app.js`
- `lib/web_ui/runtime_context.ex`
- `scripts/validate_frontend_runtime_context_contract.sh`
- `.github/workflows/frontend-toolchain.yml`

## Relevant Assumptions / Defaults
- `WebUi.RuntimeContext` is the canonical authority for required and optional runtime-context field sets.
- Frontend transport loops must preserve required runtime-context continuity (`correlation_id`, `request_id`) and propagate optional fields when available.
- Runtime-context parity checks must run deterministically in local git hooks and CI merge gates.

[x] 38 Phase 38 - Frontend Runtime-Context Continuity and Parity Guardrails
  Align frontend harness runtime-context propagation with canonical runtime-context contracts and enforce deterministic parity validation gates.

  [x] 38.1 Section - Elm Runtime-Context Field Modeling
    Model required and optional runtime-context fields explicitly in Elm command and envelope builders.

    [x] 38.1.1 Task - Implement Elm runtime-context helper composition
      Add reusable required/optional runtime-context field helpers and apply them in ping/event envelopes.

      [x] 38.1.1.1 Subtask - Implement optional runtime-context field support (`session_id`, `client_id`, `user_id`, `trace_id`) in Elm model.
      [x] 38.1.1.2 Subtask - Implement required/optional runtime-context field helper functions for envelope payload composition.
      [x] 38.1.1.3 Subtask - Implement ping and CloudEvent payload updates using shared runtime-context helper composition.

  [x] 38.2 Section - JS Runtime-Context Continuity Propagation
    Propagate and normalize runtime-context fields across JS bridge pong/recv/error payload paths.

    [x] 38.2.1 Task - Implement deterministic JS runtime-context normalization and continuity
      Normalize required/optional context fields and attach context payloads to loopback responses and typed failures.

      [x] 38.2.1.1 Subtask - Implement JS runtime-context normalization helper for required and optional context fields.
      [x] 38.2.1.2 Subtask - Implement pong and recv payload context propagation from inbound command/envelope inputs.
      [x] 38.2.1.3 Subtask - Implement typed invalid-envelope error details carrying normalized runtime-context continuity metadata.

  [x] 38.3 Section - Runtime-Context Contract Validation Gates
    Add runtime-context parity validation tooling and local/CI gate wiring.

    [x] 38.3.1 Task - Implement frontend runtime-context validator and gate integration
      Validate required/optional runtime-context parity against `WebUi.RuntimeContext` in local and CI checks.

      [x] 38.3.1.1 Subtask - Implement `validate_frontend_runtime_context_contract.sh` with required/optional field extraction from `WebUi.RuntimeContext`.
      [x] 38.3.1.2 Subtask - Implement pre-commit/pre-push and Makefile wiring for runtime-context parity checks.
      [x] 38.3.1.3 Subtask - Implement frontend workflow and README updates for runtime-context contract validation commands.

  [x] 38.4 Section - Phase 38 Integration Tests
    Validate runtime-context continuity and parity guardrails through conformance-tagged scenarios.

    [x] 38.4.1 Task - Frontend runtime-context continuity conformance scenarios
      Verify runtime-context parity checks and deterministic gate wiring across frontend harness paths.

      [x] 38.4.1.1 Subtask - Verify `SCN-043` frontend runtime-context validator passes on canonical harness state.
      [x] 38.4.1.2 Subtask - Verify `SCN-043` frontend harness references required and optional runtime-context fields in Elm/JS.
      [x] 38.4.1.3 Subtask - Verify `SCN-043` local hooks and CI workflow include runtime-context contract validation commands.
