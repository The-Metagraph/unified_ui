# RFC System Index

This directory defines the RFC system that is a sibling to `specs/`.

The RFC system has two goals:

1. Evaluate proposed changes against the current specs governance model.
2. Generate new spec stubs from approved RFC plans.

Normative language in this directory uses RFC-2119 terms: **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY**.

## Directory Layout

- [index.md](index.md): RFC registry and lifecycle tracking.
- [getting-started.md](getting-started.md): author and reviewer workflow.
- [lifecycle.md](lifecycle.md): status transitions, supersede semantics, and review checklists.
- [templates/rfc-template.md](templates/rfc-template.md): canonical RFC authoring template.

## Governance Model

Every RFC document (`rfcs/RFC-XXXX-*.md`) MUST include:

1. machine-readable metadata (`RFC ID`, `Status`, `Authors`, `Created`)
2. governance mapping to existing `REQ-*` families
3. governance mapping to existing `SCN-*` scenarios
4. references to owning contracts under `specs/contracts/`
5. a `Spec Creation Plan` table with target paths under `specs/`

This creates one traceability chain:

`RFC -> REQ family -> contract -> SCN coverage -> generated/new spec path`

## Lifecycle

Allowed RFC status values:

- `Draft`
- `Proposed`
- `Accepted`
- `Rejected`
- `Implemented`
- `Superseded`

Lifecycle transition rules and supersede/deprecation conventions are defined in:

- [lifecycle.md](lifecycle.md)

## Commands

Validate RFC governance:

```bash
./scripts/validate_rfc_governance.sh
# or
make rfc-governance
```

Generate spec stubs from an RFC:

```bash
./scripts/gen_specs_from_rfc.sh --rfc rfcs/RFC-0001-my-change.md
```

Dry-run generation:

```bash
./scripts/gen_specs_from_rfc.sh --rfc rfcs/RFC-0001-my-change.md --dry-run
# or
make rfc-specs-dry-run RFC=rfcs/RFC-0001-my-change.md
```

Generate (with optional overwrite):

```bash
make rfc-specs-generate RFC=rfcs/RFC-0001-my-change.md
make rfc-specs-generate RFC=rfcs/RFC-0001-my-change.md OVERWRITE=1
```

Scan for governance debt:

```bash
./scripts/scan_rfc_governance_debt.sh
# or
make rfc-governance-debt-scan
```

## CI Gate

RFC governance is enforced in CI by:

- `.github/workflows/rfc-governance.yml`

This gate is complementary to:

- `.github/workflows/specs-governance.yml`
- `.github/workflows/conformance.yml`
