# Spec System

This subject defines the contract for the `.spec` workspace itself.

```spec-meta
id: spec.system
kind: policy
status: active
summary: Canonical workspace contract for authored specs, governance subjects, ADRs, and generated Spec Led state.
surface:
  - .spec/README.md
  - .spec/AGENTS.md
  - .spec/decisions/**/*.md
  - .spec/specs/**/*.spec.md
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: spec.workspace.readme_present
  statement: The repository shall include a .spec/README.md that explains purpose, layout, and workflow.
  priority: must
  stability: stable

- id: spec.workspace.agents_present
  statement: The repository shall include a .spec/AGENTS.md that gives local operating guidance for agents working inside the .spec workspace.
  priority: must
  stability: stable

- id: spec.workspace.decisions_readme_present
  statement: The repository shall include a .spec/decisions/README.md that explains when durable ADRs belong in the workspace.
  priority: must
  stability: stable

- id: spec.workspace.recursive_authored_subjects
  statement: The repository shall author subject specs under .spec/specs/**/*.spec.md so nested layers such as governance remain parser-compatible without custom rules.
  priority: must
  stability: stable

- id: spec.workspace.recursive_decisions
  statement: Durable ADRs may be organized under nested paths below .spec/decisions/ and shall remain valid Spec Led decision documents.
  priority: must
  stability: stable

- id: spec.workspace.governance_layer_present
  statement: The workspace shall define a governance layer under .spec/specs/governance/ for durable repository-wide contracts and policies.
  priority: must
  stability: stable

- id: spec.workspace.state_generated
  statement: When planning and verification run, the workspace shall generate .spec/state.json containing indexed subjects, indexed decisions, and verification state across the authored specs and ADR trees.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/README.md
  covers:
    - spec.workspace.readme_present

- kind: source_file
  target: .spec/AGENTS.md
  covers:
    - spec.workspace.agents_present

- kind: source_file
  target: .spec/decisions/README.md
  covers:
    - spec.workspace.decisions_readme_present

- kind: source_file
  target: .spec/specs/spec_system.spec.md
  covers:
    - spec.workspace.recursive_authored_subjects
    - spec.workspace.governance_layer_present

- kind: source_file
  target: .spec/specs/spec_system.spec.md
  covers:
    - spec.workspace.recursive_decisions

- kind: command
  target: mix spec.plan
  covers:
    - spec.workspace.state_generated

- kind: command
  target: mix spec.verify
  covers:
    - spec.workspace.state_generated
```
