# Spec Conformance Matrix

This matrix maps requirement families to owning contracts and canonical baseline scenarios.

| Requirement Family | Owning Contract | Primary Runtime Modules | Scenario Coverage |
|---|---|---|---|
| `REQ-CP-001`..`REQ-CP-010` | [control_plane_ownership_matrix.md](/Users/Pascal/code/unified/web_ui/specs/contracts/control_plane_ownership_matrix.md) | `WebUi.Endpoint`, `WebUi.Router`, `WebUi.Channel`, `WebUi.CloudEvent`, `WebUi.Agent`, `WebUi.Component`, `WebUi.WidgetRegistry`, `WebUi.Widget` | `SCN-001`, `SCN-002`, `SCN-019`, `SCN-022` |
| `REQ-SVC-001`..`REQ-SVC-010` | [service_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/service_contract.md) | `WebUi.Endpoint`, `WebUi.Router`, `WebUi.Channel`, `WebUi.CloudEvent`, `WebUi.Agent`, `WebUi.Component`, `WebUi.WidgetRegistry`, `WebUi.Widget` | `SCN-003`, `SCN-004`, `SCN-005`, `SCN-013`, `SCN-014`, `SCN-016`, `SCN-017`, `SCN-018`, `SCN-020`, `SCN-021`, `SCN-022`, `SCN-023`, `SCN-024`, `SCN-025`, `SCN-032`, `SCN-033`, `SCN-034`, `SCN-035`, `SCN-036`, `SCN-037`, `SCN-038`, `SCN-039`, `SCN-040` |
| `REQ-OBS-001`..`REQ-OBS-010` | [observability_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/observability_contract.md) | `WebUi.Channel`, `WebUi.CloudEvent`, `WebUi.Agent` | `SCN-004`, `SCN-006`, `SCN-015` |
| `REQ-WGT-001`..`REQ-WGT-010` | [widget_system_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/widget_system_contract.md) | `WebUi.WidgetRegistry`, `WebUi.Widget`, `WebUi.Component`, `WebUi.Channel` | `SCN-007`, `SCN-008`, `SCN-009`, `SCN-010`, `SCN-011`, `SCN-012`, `SCN-017`, `SCN-021`, `SCN-032`, `SCN-033`, `SCN-034`, `SCN-035`, `SCN-036`, `SCN-037`, `SCN-038` |
| `REQ-TRN-001`..`REQ-TRN-010` | [turn_execution_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/turn_execution_contract.md) | `WebUi.Ui.Runtime`, `WebUi.Turn.Execution` | `SCN-023` |
| `REQ-SCP-001`..`REQ-SCP-010` | [scope_resolution_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/scope_resolution_contract.md) | `WebUi.Ui.Runtime`, `WebUi.Scope.Resolver` | `SCN-024` |
| `REQ-RPL-001`..`REQ-RPL-010` | [persistence_replay_contract.md](/Users/Pascal/code/unified/web_ui/specs/contracts/persistence_replay_contract.md) | `WebUi.Ui.Runtime`, `WebUi.Persistence.ReplayLog`, `WebUi.Persistence.ReplayBaselineRegistry` | `SCN-025`, `SCN-026`, `SCN-027`, `SCN-028`, `SCN-029`, `SCN-030`, `SCN-031` |

## Acceptance Mapping Rule

Every future AC-bearing component spec MUST map to at least one `REQ-*` family and one `SCN-*` scenario.

## Bootstrap Note

Current implementation is in architecture-contract bootstrap mode (no AC-bearing component specs yet).
This matrix establishes initial requirement-family and scenario-family alignment for early conformance planning.

## Component AC Coverage

| Component Spec | AC Scope | Requirement Families | Scenario Coverage |
|---|---|---|---|
| `specs/operations/rfc_intake_governance.md` | `AC-*` | `REQ-CP-*`, `REQ-OBS-*` | `SCN-001`, `SCN-006` |
