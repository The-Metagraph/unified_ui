# DesktopUi Package

This subject defines the intended ecosystem-aligned package contract for
`packages/desktop_ui`.

```spec-meta
id: desktop_ui.package
kind: package
status: active
summary: Ecosystem-aligned package contract for `packages/desktop_ui` as an independent cross-platform desktop widget library with canonical UnifiedIUR input, SDL2-based runtime targets, and canonical signal transport.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop-ui
decisions:
  - repo.ecosystem.contract_model
  - repo.desktop_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: desktop_ui.package.library_position
  statement: '`desktop_ui` shall remain an independent desktop widget library rather than an authored DSL boundary.'
  priority: must
  stability: stable

- id: desktop_ui.package.canonical_input_boundary
  statement: 'The authored cross-package input boundary for `desktop_ui` shall be canonical UnifiedIUR.'
  priority: must
  stability: stable

- id: desktop_ui.package.cross_platform_scope
  statement: '`desktop_ui` shall target Windows, macOS, and Linux as its intended desktop runtime scope.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop-ui/package.spec.md
  covers:
    - desktop_ui.package.library_position
    - desktop_ui.package.canonical_input_boundary
    - desktop_ui.package.cross_platform_scope
```
