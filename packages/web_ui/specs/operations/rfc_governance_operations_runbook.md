# RFC Governance Operations Runbook

## Purpose

Define the operational workflow for authors and reviewers using the RFC + specs governance system.

## Reviewer Checklist

1. Confirm RFC metadata is complete and machine-readable (`RFC ID`, `Status`, `Authors`, `Created`).
2. Confirm governance mappings only reference known `REQ-*` families and `SCN-*` IDs.
3. Confirm contract references resolve to existing files under `specs/contracts/`.
4. Confirm `Spec Creation Plan` rows use valid actions (`create`, `update`, `deprecate`) and valid `specs/*.md` paths.
5. If status changed, confirm `rfcs/index.md` is updated in the same PR.
6. If status changed to `Accepted` or `Implemented`, confirm there is at least one `specs/*.md` change in the same PR.

## Author Checklist

1. Start from `rfcs/templates/rfc-template.md`.
2. Register the RFC in `rfcs/index.md` with matching `RFC ID` and status.
3. Ensure governance mappings are aligned with:
- `specs/conformance/spec_conformance_matrix.md`
- `specs/conformance/scenario_catalog.md`
- `specs/contracts/*.md`
4. Ensure every plan row includes action, control plane, REQ mappings, SCN mappings, and AC seeds.
5. Run `./scripts/validate_rfc_governance.sh` before opening a PR.
6. If using generation, run `./scripts/gen_specs_from_rfc.sh --rfc <path> --dry-run` first.

## Validator Incident Guidance

When validator output appears incorrect:

1. Re-run locally and capture output:
- `./scripts/validate_rfc_governance.sh`
- `./scripts/validate_specs_governance.sh`
2. Confirm repo is up to date (`git fetch`, compare with `origin/main`) and rerun.
3. Verify whether failures are due to stale matrix/catalog references rather than script behavior.
4. If a validator rule is genuinely incorrect, open a governance-debt issue using `.github/ISSUE_TEMPLATE/rfc-governance-debt.md` with:
- failing command and output
- expected behavior
- minimal reproduction diff/files

## Governance Debt Triage

Run periodic scan:

```bash
./scripts/scan_rfc_governance_debt.sh
```

Strict mode for CI or scheduled checks:

```bash
./scripts/scan_rfc_governance_debt.sh --strict
```

## Cadence

Recommended cadence:

1. Weekly: run debt scan and triage findings.
2. Per PR touching `rfcs/` or `specs/`: run both governance validators.
3. Per release cutoff: review all `Draft`/`Proposed` RFCs for staleness and ownership.
