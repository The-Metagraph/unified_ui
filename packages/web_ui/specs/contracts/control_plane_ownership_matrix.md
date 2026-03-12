# Control Plane Ownership Matrix

This document is the canonical source for `primary_plane` ownership assignments for `web_ui` runtime modules.

## Requirement Set

- `REQ-CP-001`: Every covered runtime module MUST map to exactly one primary plane.
- `REQ-CP-002`: [services-and-libraries.md](/Users/Pascal/code/unified/web_ui/specs/services-and-libraries.md) MUST defer to this matrix for ownership summaries.
- `REQ-CP-003`: If docs conflict on ownership, this matrix and ADR-0001 MUST win.
- `REQ-CP-004`: Ownership changes MUST update this matrix in the same change set.
- `REQ-CP-005`: Transport modules MUST NOT own product-domain state.
- `REQ-CP-006`: UI runtime modules MUST NOT bypass transport contract boundaries.
- `REQ-CP-007`: Runtime authority modules MUST be explicit and auditable.
- `REQ-CP-008`: Extension seams MUST remain non-authoritative unless reclassified by ADR.
- `REQ-CP-009`: New modules MUST be assigned before merge.
- `REQ-CP-010`: Conformance mappings MUST reference ownership families where behavior is AC-bearing.

## Planes

`Product Plane`, `UI Runtime Plane`, `Transport Plane`, `Runtime Authority Plane`, `Data Plane`, `Extension Plane`.

## Ownership Table

| Module | Primary Plane |
|---|---|
| `WebUi.Endpoint` | `Transport Plane` |
| `WebUi.Router` | `Transport Plane` |
| `WebUi.Channel` | `Transport Plane` |
| `WebUi.CloudEvent` | `Transport Plane` |
| `WebUi.Agent` | `Runtime Authority Plane` |
| `WebUi.Component` | `UI Runtime Plane` |
| `WebUi.WidgetRegistry` | `Runtime Authority Plane` |
| `WebUi.Widget` | `UI Runtime Plane` |

## ADR References

- [ADR-0001-control-plane-authority.md](/Users/Pascal/code/unified/web_ui/specs/adr/ADR-0001-control-plane-authority.md)
