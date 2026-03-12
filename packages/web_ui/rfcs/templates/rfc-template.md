# RFC-XXXX: <Title>

## Metadata

- RFC ID: `RFC-XXXX`
- Status: `Draft`
- Authors: `@team-or-handle`
- Created: `YYYY-MM-DD`
- Updated: `YYYY-MM-DD` (optional, update on status changes)
- Target Phase: `Phase-N` (optional)
- Supersedes: `RFC-YYYY` (optional)
- Superseded By: `RFC-ZZZZ` (optional)

## Summary

Brief statement of the change and why it is needed.

## Motivation

Problem statement and impact if unchanged.

## Scope

In scope:

- ...

Out of scope:

- ...

## Proposed Design

Describe runtime behavior, boundaries, and failure semantics.

## Governance Mapping

### Requirement Families (`REQ-*`)

- `REQ-SVC-*`

### Scenario Coverage (`SCN-*`)

- `SCN-003`

### Contract References

- [service_contract.md](../../specs/contracts/service_contract.md)
- [observability_contract.md](../../specs/contracts/observability_contract.md)

### ADR Impact

- ADR update required: `yes|no`
- ADR refs: `ADR-0001` (if applicable)

### Lifecycle Impact

- Transition: `Draft -> Proposed` (or `none`)
- Index row updated: `yes|no`

## Spec Creation Plan

| Action | Spec Path | Component Title | Control Plane | Requirement Families | Scenario IDs | Initial AC IDs |
|---|---|---|---|---|---|---|
| create | specs/services/example_service.md | Example Service | Runtime Authority Plane | REQ-SVC-*, REQ-OBS-* | SCN-003, SCN-006 | AC-01, AC-02, AC-03 |

## Migration / Rollout

How the change is introduced, guarded, and rolled back.

## Risks

Known risks and mitigations.

## Open Questions

- ...
