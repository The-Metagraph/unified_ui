# RFC-0001: RFC Governance And Spec Intake System

## Metadata

- RFC ID: `RFC-0001`
- Status: `Draft`
- Authors: `@web-ui`
- Created: `2026-03-07`
- Updated: `2026-03-07`
- Target Phase: `Phase-0`
- Supersedes: `none`
- Superseded By: `none`

## Summary

Establish an RFC subsystem that evaluates proposal governance against the current specs model and enables deterministic creation of new spec stubs from approved RFC plans.

## Motivation

The current specs system enforces governance after behavior is already encoded in contracts/specs. A proposal intake layer is needed so governance alignment is evaluated before implementation, and so new spec surfaces are created with compliant traceability from day one.

## Scope

In scope:

- RFC document format with machine-readable metadata
- governance mapping from RFC to existing `REQ-*`, contracts, and `SCN-*`
- governance validation script and CI gate
- deterministic scaffolding of new spec docs from RFC `Spec Creation Plan`

Out of scope:

- automatic mutation of contracts, conformance matrix, or ADRs
- automatic conformance scenario generation
- approval workflow semantics beyond status metadata

## Proposed Design

1. Introduce `rfcs/` as a sibling to `specs/` with index, getting-started guide, and RFC template.
2. Require each RFC to include governance mappings and a `Spec Creation Plan` table.
3. Validate RFCs by checking:
   - metadata correctness and index registration
   - known `REQ` family and `SCN` references
   - valid contracts and plan-row shape
4. Provide a generator that can create initial spec stubs from `create` rows in the RFC plan, including AC seeds and contract/ADR links.

## Governance Mapping

### Requirement Families (`REQ-*`)

- `REQ-CP-*`
- `REQ-OBS-*`

### Scenario Coverage (`SCN-*`)

- `SCN-001`
- `SCN-006`

### Contract References

- [control_plane_ownership_matrix.md](../specs/contracts/control_plane_ownership_matrix.md)
- [observability_contract.md](../specs/contracts/observability_contract.md)

### ADR Impact

- ADR update required: `no`
- ADR refs: `none`

### Lifecycle Impact

- Transition: `none`
- Index row updated: `yes`

## Spec Creation Plan

| Action | Spec Path | Component Title | Control Plane | Requirement Families | Scenario IDs | Initial AC IDs |
|---|---|---|---|---|---|---|
| create | specs/operations/rfc_intake_governance.md | RFC Intake Governance | Product Plane | REQ-CP-*, REQ-OBS-* | SCN-001, SCN-006 | AC-01, AC-02, AC-03 |

## Migration / Rollout

1. Land RFC docs, validator, generator, and CI workflow.
2. Use this RFC as the first governance-tracked RFC entry.
3. Start requiring RFCs for material architecture/spec changes.

## Risks

- RFC metadata drift if authors do not maintain index linkage.
- Overly strict linting may block early ideation drafts.
- Generated specs may create false confidence if not completed with contract/matrix updates.

## Open Questions

- Should `Accepted` RFCs require linked ADR IDs in metadata?
- Should we enforce a max age for `Draft` RFCs before status refresh?
