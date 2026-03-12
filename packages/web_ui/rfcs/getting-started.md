# RFC Getting Started

Use this guide to propose architecture/runtime/spec changes through RFCs.

## 1) Create A New RFC File

Create a file in `rfcs/`:

- `rfcs/RFC-XXXX-short-kebab-title.md`

Start from:

- [templates/rfc-template.md](templates/rfc-template.md)

`XXXX` MUST be a four-digit RFC number.

## 2) Map To Existing Governance

In `## Governance Mapping`, map your proposal to:

- requirement families (`REQ-*`) already defined in `specs/conformance/spec_conformance_matrix.md`
- canonical scenarios (`SCN-*`) in `specs/conformance/scenario_catalog.md`
- relevant contracts in `specs/contracts/*.md`

Unknown `REQ` families and unknown `SCN` IDs fail validation.

## 3) Define Spec Creation Plan

In `## Spec Creation Plan`, add one row per target spec.

Each row MUST define:

- action (`create`, `update`, `deprecate`)
- spec path (`specs/.../*.md`)
- control plane assignment
- requirement families
- scenario IDs
- initial AC seeds

## 4) Register The RFC

Add/update a row in:

- [index.md](index.md)

The RFC ID in `index.md` MUST match the RFC file metadata and filename.
The index row SHOULD include:

- current status
- primary owner(s)
- explicit spec plan coverage
- supersedes/superseded-by links when applicable

## 5) Validate Governance

Run:

```bash
./scripts/validate_rfc_governance.sh
```

## 6) Generate Spec Stubs (Optional)

Generate stubs for all `create` rows:

```bash
./scripts/gen_specs_from_rfc.sh --rfc rfcs/RFC-XXXX-short-kebab-title.md
```

Use `--dry-run` to preview changes.

## 7) Complete Spec + Contract + Conformance Updates

The generated stubs are starting points. You still MUST complete:

- contract updates in `specs/contracts/` (if behavior changed)
- matrix updates in `specs/conformance/spec_conformance_matrix.md`
- scenario coverage updates in conformance packs
- ADR updates when architecture/control-plane baseline changes

## 8) Run Status Transition Checklist

Before opening a PR that changes RFC status (for example `Draft -> Proposed` or `Accepted -> Implemented`), apply:

- [lifecycle.md](lifecycle.md)

For transitions to `Accepted` or `Implemented`, ensure specs deltas are present in the same change set or governance validation will fail.
