# Ownership Boundary and Contract Reference

## Purpose

Provide an operator-facing reference that links control-plane ownership boundaries to contract requirement families.

## Canonical Ownership Boundary Summary

| Control Plane | Canonical Authority | Non-Authority Guardrail | Primary Contracts |
|---|---|---|---|
| UI Plane | Elm runtime + deterministic UI model transitions | MUST NOT own domain state or policy persistence | `REQ-WGT-*`, `REQ-SUP-*`, `REQ-TRN-*`, `REQ-SCP-*` |
| Transport Plane | Endpoint/router/channel orchestration and CloudEvent framing | MUST NOT mutate product-domain state | `REQ-CP-*`, `REQ-SVC-*`, `REQ-OBS-*`, `REQ-PRM-*` |
| Runtime Authority Plane | Server-side runtime dispatch/reconciliation and recovery state | MUST remain typed/fail-closed and deterministic | `REQ-SVC-*`, `REQ-POL-*`, `REQ-TRN-*`, `REQ-SCP-*`, `REQ-RPL-*`, `REQ-EVL-*` |
| Product Plane | Host runtime/services and release governance decisions | MUST NOT leak direct domain authority into UI/transport layers | `REQ-SVC-*`, `REQ-EVL-*` |

## Contract Index by Operational Concern

| Operational Concern | Contract | Core Scenario Families |
|---|---|---|
| Transport and control-plane ownership | [control_plane_ownership_matrix.md](/Users/Pascal/code/unified/web_ui/specs/contracts/control_plane_ownership_matrix.md) | `SCN-001`, `SCN-002`, `SCN-019` |
| Runtime service and envelope continuity | [service_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/service_contract.md) | `SCN-003`, `SCN-004`, `SCN-005` |
| Observability and joinability | [observability_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/observability_contract.md) | `SCN-006`, `SCN-015` |
| Widget parity and lifecycle behavior | [widget_system_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/widget_system_contract.md) | `SCN-007`..`SCN-012` |
| Recovery and restart orchestration | [supervision_restart_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/supervision_restart_contract.md) | `SCN-013`, `SCN-014`, `SCN-016`, `SCN-020` |
| Policy dispatch guards | [policy_authorization_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/policy_authorization_contract.md) | `SCN-022` |
| Turn and scope continuity | [turn_execution_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/turn_execution_contract.md), [scope_resolution_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/scope_resolution_contract.md) | `SCN-023`, `SCN-024` |
| Replay persistence and eval calibration | [persistence_replay_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/persistence_replay_contract.md), [eval_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/eval_contract.md) | `SCN-025`..`SCN-031` |
| Prompt hygiene and asset boundaries | [prompt_asset_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/prompt_asset_contract.md) | `SCN-006`, `SCN-015`, `SCN-039` |

## Operator Usage

1. Start incident triage from contract family and scenario IDs in [spec_conformance_matrix.md](/Users/Pascal/code/unified/web_ui/specs/conformance/spec_conformance_matrix.md).
2. Confirm ownership boundary using [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md).
3. Select the matching runbook in `specs/operations/` and execute deterministic validation commands before rollout changes.
