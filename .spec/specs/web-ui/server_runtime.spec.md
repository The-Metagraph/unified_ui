# WebUi Server Runtime

This subject defines the intended ecosystem-aligned server runtime contract for
`packages/web_ui`.

```spec-meta
id: web_ui.server_runtime
kind: runtime
status: active
summary: Ecosystem-aligned server runtime contract for `packages/web_ui`, using Phoenix for server-side runtime representation while preserving canonical IUR and event semantics across the frontend boundary.
surface:
  - packages/web_ui
  - .spec/specs/web-ui/server_runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.web_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: web_ui.server_runtime.phoenix_authority
  statement: '`web_ui` shall use Phoenix as its server-side runtime representation and authority boundary for browser-connected UI execution.'
  priority: must
  stability: stable

- id: web_ui.server_runtime.canonical_runtime_boundary
  statement: 'The server runtime shall preserve canonical IUR and event semantics across the Phoenix-to-frontend boundary rather than introducing an alternate authored server contract.'
  priority: must
  stability: stable

- id: web_ui.server_runtime.server_state_subordinate_to_contract
  statement: 'Server-side coordination, workflow, or service state may exist for runtime execution, but it shall remain subordinate to the canonical rendering and signal contract rather than redefining cross-package UI meaning.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/web-ui/server_runtime.spec.md
  covers:
    - web_ui.server_runtime.phoenix_authority
    - web_ui.server_runtime.canonical_runtime_boundary
    - web_ui.server_runtime.server_state_subordinate_to_contract
```
