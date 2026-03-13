# WebUi Authority Runtime

This subject backfills the current runtime-authority contract implemented by
`packages/web_ui`, including dispatch routing, policy and scope controls, and
the first shipped workflow slice.

```spec-meta
id: web_ui.authority_runtime
kind: runtime
status: active
summary: Current runtime-authority contract for `packages/web_ui`, including route dispatch, policy or scope enforcement, deterministic turn metadata, and the first-slice save-preferences workflow.
surface:
  - packages/web_ui/lib/web_ui/agent.ex
  - packages/web_ui/lib/web_ui/policy/authorizer.ex
  - packages/web_ui/lib/web_ui/scope/resolver.ex
  - packages/web_ui/lib/web_ui/turn/execution.ex
  - packages/web_ui/lib/web_ui/first_slice/workflow.ex
  - packages/web_ui/test/web_ui
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: web_ui.authority_runtime.route_dispatch
  statement: 'The runtime-authority layer shall validate the current route table shape, preserve context integrity, dispatch current widget events into handler functions with timeout and error normalization, and return normalized service outcomes.'
  priority: must
  stability: stable

- id: web_ui.authority_runtime.policy_and_scope_controls
  statement: 'The package shall enforce the current widget-event policy and scope controls, including deny or allow lists, required-user rules, scope resolution precedence, scope-policy guardrails, and scoped outbound metadata.'
  priority: must
  stability: stable

- id: web_ui.authority_runtime.turns_and_first_slice
  statement: 'The deterministic turn helper and first-slice workflow shall assign the current turn metadata, preserve retry continuity, and implement the shipped save-preferences success, cancellation, and retryable-failure outcome model.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/web_ui/lib/web_ui/agent.ex
  covers:
    - web_ui.authority_runtime.route_dispatch

- kind: source_file
  target: packages/web_ui/lib/web_ui/policy/authorizer.ex
  covers:
    - web_ui.authority_runtime.policy_and_scope_controls

- kind: source_file
  target: packages/web_ui/lib/web_ui/scope/resolver.ex
  covers:
    - web_ui.authority_runtime.policy_and_scope_controls

- kind: source_file
  target: packages/web_ui/lib/web_ui/turn/execution.ex
  covers:
    - web_ui.authority_runtime.turns_and_first_slice

- kind: source_file
  target: packages/web_ui/lib/web_ui/first_slice/workflow.ex
  covers:
    - web_ui.authority_runtime.turns_and_first_slice

- kind: source_file
  target: packages/web_ui/test/web_ui/agent_test.exs
  covers:
    - web_ui.authority_runtime.route_dispatch

- kind: source_file
  target: packages/web_ui/test/web_ui/agent_result_test.exs
  covers:
    - web_ui.authority_runtime.route_dispatch

- kind: source_file
  target: packages/web_ui/test/web_ui/agent_context_continuity_test.exs
  covers:
    - web_ui.authority_runtime.route_dispatch

- kind: source_file
  target: packages/web_ui/test/web_ui/policy/authorizer_test.exs
  covers:
    - web_ui.authority_runtime.policy_and_scope_controls

- kind: source_file
  target: packages/web_ui/test/web_ui/scope/resolver_test.exs
  covers:
    - web_ui.authority_runtime.policy_and_scope_controls

- kind: source_file
  target: packages/web_ui/test/web_ui/turn/execution_test.exs
  covers:
    - web_ui.authority_runtime.turns_and_first_slice

- kind: source_file
  target: packages/web_ui/test/web_ui/first_slice/workflow_test.exs
  covers:
    - web_ui.authority_runtime.turns_and_first_slice

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_10_first_slice_release_readiness_test.exs
  covers:
    - web_ui.authority_runtime.turns_and_first_slice

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_17_policy_authorization_test.exs
  covers:
    - web_ui.authority_runtime.policy_and_scope_controls

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_18_turn_execution_test.exs
  covers:
    - web_ui.authority_runtime.turns_and_first_slice

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_19_scope_resolution_test.exs
  covers:
    - web_ui.authority_runtime.policy_and_scope_controls
```
