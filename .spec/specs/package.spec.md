# Unified Repository

High-level repository contract.

```spec-meta
id: repo.package
kind: package
status: active
summary: Repository-level specification for the unified monorepo and its centralized spec workspace.
surface:
  - mix.exs
  - packages/*
  - .spec/**
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: repo.package.root_spec_workspace
  statement: The repository shall keep a single canonical .spec/ workspace at the repository root for repository-wide governance and package-level intent.
  priority: must
  stability: stable

- id: repo.package.packages_layout
  statement: The repository shall keep implementation packages under packages/ while repository-wide governance remains centralized in the root .spec workspace.
  priority: must
  stability: stable

- id: repo.package.governance_scope
  statement: Repository-wide governance contracts and ADRs shall apply across all packages unless a subject spec explicitly narrows scope.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/package.spec.md
  covers:
    - repo.package.root_spec_workspace
    - repo.package.packages_layout
    - repo.package.governance_scope
```
