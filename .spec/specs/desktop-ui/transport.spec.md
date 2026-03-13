# DesktopUi Transport

This subject defines the intended ecosystem-aligned signal and transport
contract for `packages/desktop_ui`.

```spec-meta
id: desktop_ui.transport
kind: integration
status: active
summary: Ecosystem-aligned transport contract for `packages/desktop_ui`, using canonical Jido.Signal values and CloudEvents-compatible semantics inside the runtime and at package boundaries.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop-ui/transport.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.desktop_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: desktop_ui.transport.internal_canonical_signals
  statement: '`desktop_ui` shall use canonical Jido.Signal values and CloudEvents-compatible semantics for internal runtime and widget communication, not only for external package boundaries.'
  priority: must
  stability: stable

- id: desktop_ui.transport.native_input_normalization
  statement: 'Native platform input shall be normalized into the canonical signal contract before events cross package boundaries.'
  priority: must
  stability: stable

- id: desktop_ui.transport.local_state_not_contract
  statement: 'Renderer-specific local state may vary inside `desktop_ui`, but local state shall not replace the canonical signal contract at the cross-package boundary.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop-ui/transport.spec.md
  covers:
    - desktop_ui.transport.internal_canonical_signals
    - desktop_ui.transport.native_input_normalization
    - desktop_ui.transport.local_state_not_contract
```
