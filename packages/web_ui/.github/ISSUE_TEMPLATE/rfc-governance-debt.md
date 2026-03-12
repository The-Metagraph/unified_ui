---
name: RFC governance debt
about: Track governance debt findings for RFC/spec alignment
labels: governance-debt, specs, rfc
assignees: ''
---

## Debt Type

- [ ] Unindexed RFC file
- [ ] Orphaned index row
- [ ] Stale Draft RFC
- [ ] Broken RFC reference in specs
- [ ] Validator false positive
- [ ] Validator false negative

## Ownership

- Owner handle:
- Owning area (`rfcs`, `specs/contracts`, `specs/conformance`, `scripts`):

## Detection Source

- [ ] `./scripts/scan_rfc_governance_debt.sh`
- [ ] `./scripts/validate_rfc_governance.sh`
- [ ] CI workflow (`RFC Governance`)
- [ ] Manual review

## Findings

Describe the finding and include exact file paths/IDs.

## Reproduction

Commands and expected vs actual output:

```bash
# add commands here
```

## Remediation Plan

- [ ] Fix identified
- [ ] Validator/rule updates required
- [ ] Docs/runbook updates required
- [ ] Follow-up RFC required

## Target Milestone

Describe planned remediation phase or release target.
