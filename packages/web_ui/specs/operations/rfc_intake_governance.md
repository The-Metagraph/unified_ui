# RFC Intake Governance

## Purpose

`RFC Intake Governance` is introduced by [RFC-0001](../../rfcs/RFC-0001-rfc-governance-and-spec-intake.md) and defines governance behavior for RFC proposal intake and compliance validation.

## Control Plane

Primary control-plane ownership: **Product Plane**.

## Topology Context

- [Topology](../topology.md)

## Governance Mapping

### Requirement Families

- `REQ-CP-*`
- `REQ-OBS-*`

### Scenario Coverage

- `SCN-001`
- `SCN-006`

### Source RFC

- [RFC-0001](../../rfcs/RFC-0001-rfc-governance-and-spec-intake.md)

## Acceptance Criteria

| Acceptance ID (AC-XX) | Criterion | Verification |
|---|---|---|
| `AC-01` | Every RFC under `rfcs/RFC-XXXX-*.md` MUST include machine-readable metadata (`RFC ID`, `Status`, `Authors`, `Created`) plus required sections (`## Metadata`, `## Governance Mapping`, `## Spec Creation Plan`). | Run `./scripts/validate_rfc_governance.sh`; missing metadata/sections MUST fail with explicit file-scoped diagnostics, and valid RFCs MUST pass. |
| `AC-02` | RFC governance mappings MUST fail closed against canonical specs sources: all `REQ-*` references MUST resolve to known requirement families from `specs/conformance/spec_conformance_matrix.md`, all `SCN-*` references MUST resolve to `specs/conformance/scenario_catalog.md`, and all contract references MUST resolve to existing files in `specs/contracts/`. | Introduce one unknown `REQ-*`, one unknown `SCN-*`, and one missing contract reference in a test RFC; each mutation MUST produce deterministic validator failure. Remove mutations and confirm pass. |
| `AC-03` | RFC status transitions to `Accepted` or `Implemented` MUST be coupled with concrete spec-surface changes in the same change set, and governance outcomes MUST be deterministic and auditable in CI logs. | Validate with `DIFF_BASE`/`DIFF_HEAD` (or local staged diff): an `Accepted`/`Implemented` RFC change without any `specs/*.md` delta MUST fail; adding corresponding spec changes MUST pass and emit stable pass/fail output. |

## Normative Contracts

- [control_plane_ownership_matrix.md](../contracts/control_plane_ownership_matrix.md)
- [observability_contract.md](../contracts/observability_contract.md)

## Control Plane ADR

- [ADR-0001-control-plane-authority.md](../adr/ADR-0001-control-plane-authority.md)
