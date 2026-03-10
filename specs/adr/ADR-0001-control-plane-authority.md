# ADR-0001: Control-Plane Authority for WebUi Runtime Boundaries

## Status

Accepted

## Context

`web_ui` integrates multiple execution surfaces (Elm, Phoenix channels, optional JS interop, and host runtime services).
Without explicit authority boundaries, runtime behavior can drift and create split ownership for state and policy decisions.

## Decision

1. Browser UI state authority is Elm runtime only.
2. Domain/runtime state authority is server-side host runtime services (Jido agents/actions).
3. `web_ui` transport modules are orchestration boundaries and MUST NOT become domain-state owners.
4. JS interop is an extension seam and MUST remain non-authoritative.
5. All client/server boundary payloads MUST use the canonical CloudEvents-shaped envelope.
6. Canonical runtime module namespace root is `WebUi.*`.
7. Built-in widget catalog parity MUST track the public widget set from `term_ui`; custom widgets are extension-only and namespaced.

## Consequences

- Ownership boundaries are explicit and reviewable.
- Transport and interop layers remain decoupled from product-domain authority.
- Architecture, contract, and conformance docs can enforce the same control-plane model.
- Policy, turn, scope, and replay continuity contracts can extend control-plane governance into deterministic runtime execution paths.
- Supervision-restart, prompt-hygiene, and eval-calibration contracts can extend control-plane governance into recovery, observability, and release-evaluation operations.

## Related Requirements

- `REQ-CP-001` through `REQ-CP-010`
- `REQ-SVC-001` through `REQ-SVC-010`
- `REQ-OBS-001` through `REQ-OBS-010`
- `REQ-WGT-001` through `REQ-WGT-010`
- `REQ-POL-001` through `REQ-POL-010`
- `REQ-SUP-001` through `REQ-SUP-010`
- `REQ-TRN-001` through `REQ-TRN-010`
- `REQ-SCP-001` through `REQ-SCP-010`
- `REQ-RPL-001` through `REQ-RPL-010`
- `REQ-EVL-001` through `REQ-EVL-010`
- `REQ-PRM-001` through `REQ-PRM-010`
