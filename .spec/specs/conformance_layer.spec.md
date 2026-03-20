# Conformance Layer

This subject defines the repository-wide conformance layer for package-scoped
plan coverage and implementation evidence.

```spec-meta
id: repo.conformance
kind: policy
status: active
summary: Separate package-scoped conformance layer for machine-readable plan coverage and implementation evidence.
surface:
  - .spec/conformance/README.md
  - .spec/conformance/**/*.json
  - .spec/planning/**/spec-traceability.json
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: repo.conformance.separate_from_governance
  statement: Package-scoped conformance shall remain separate from governance contracts and authored current-truth specs.
  priority: must
  stability: stable

- id: repo.conformance.package_manifests
  statement: Package implementation evidence shall be authored as machine-readable manifests under .spec/conformance/<package>/manifest.json.
  priority: must
  stability: stable

- id: repo.conformance.plan_coverage_manifests
  statement: Package plan coverage shall be authored as machine-readable manifests under .spec/planning/<package>/spec-traceability.json.
  priority: must
  stability: stable

- id: repo.conformance.requirement_id_join
  statement: Implementation conformance manifests shall reference indexed requirement ids and join to planning coverage by requirement id rather than duplicating plan refs.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/conformance_layer.spec.md
  covers:
    - repo.conformance.separate_from_governance
    - repo.conformance.requirement_id_join

- kind: source_file
  target: .spec/conformance/README.md
  covers:
    - repo.conformance.package_manifests
    - repo.conformance.separate_from_governance

- kind: source_file
  target: .spec/planning/web_ui/spec-traceability.json
  covers:
    - repo.conformance.plan_coverage_manifests

- kind: source_file
  target: .spec/conformance/web_ui/manifest.json
  covers:
    - repo.conformance.package_manifests
    - repo.conformance.requirement_id_join
```
