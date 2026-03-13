# WebUi IUR

This subject defines the intended ecosystem-aligned interpretation boundary for
`packages/web_ui`.

```spec-meta
id: web_ui.iur
kind: integration
status: active
summary: Ecosystem-aligned interpretation contract for `packages/web_ui`, centered on canonical UnifiedIUR input and normalized internal render structures.
surface:
  - packages/web_ui
  - .spec/specs/web-ui/iur.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.web_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: web_ui.iur.canonical_input_boundary
  statement: '`web_ui` shall interpret canonical UnifiedIUR as its authoritative cross-package rendering input.'
  priority: must
  stability: stable

- id: web_ui.iur.normalized_render_structures
  statement: 'The library shall normalize canonical UnifiedIUR into internal structures that preserve widget identity, structure, props, and canonical signal bindings needed by the server and frontend runtimes.'
  priority: must
  stability: stable

- id: web_ui.iur.input_boundary_not_broadened
  statement: 'The authored package contract shall not broaden the ecosystem rendering boundary with package-specific authored inputs, non-canonical extension formats, or other alternate authored source shapes unless the ecosystem contract is updated first.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/web-ui/iur.spec.md
  covers:
    - web_ui.iur.canonical_input_boundary
    - web_ui.iur.normalized_render_structures
    - web_ui.iur.input_boundary_not_broadened
```
