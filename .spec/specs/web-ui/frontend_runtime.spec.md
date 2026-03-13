# WebUi Frontend Runtime

This subject defines the intended ecosystem-aligned frontend runtime contract
for `packages/web_ui`.

```spec-meta
id: web_ui.frontend_runtime
kind: runtime
status: active
summary: Ecosystem-aligned frontend runtime contract for `packages/web_ui`, using Elm for client-side rendering and local state while preserving canonical IUR and event semantics.
surface:
  - packages/web_ui
  - .spec/specs/web-ui/frontend_runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.web_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: web_ui.frontend_runtime.elm_client_runtime
  statement: '`web_ui` shall use Elm as its client-side rendering and local-state runtime.'
  priority: must
  stability: stable

- id: web_ui.frontend_runtime.canonical_boundary_preserved
  statement: 'The frontend runtime shall preserve canonical IUR and event semantics across the Phoenix-to-Elm boundary rather than introducing an alternate authored UI contract.'
  priority: must
  stability: stable

- id: web_ui.frontend_runtime.local_state_subordinate
  statement: 'Frontend-local state and browser interop may exist for renderer convenience, but they shall remain subordinate to the canonical cross-package IUR and signal contract.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/web-ui/frontend_runtime.spec.md
  covers:
    - web_ui.frontend_runtime.elm_client_runtime
    - web_ui.frontend_runtime.canonical_boundary_preserved
    - web_ui.frontend_runtime.local_state_subordinate
```
