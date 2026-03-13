# LiveUi Transport

This subject defines the intended ecosystem-aligned signal and transport
contract for `packages/live_ui`.

```spec-meta
id: live_ui.transport
kind: integration
status: active
summary: Ecosystem-aligned transport contract for `packages/live_ui`, using Phoenix channels plus canonical Jido.Signal and CloudEvents-compatible semantics.
surface:
  - packages/live_ui
  - .spec/specs/live-ui/transport.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.live_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: live_ui.transport.phoenix_channel_bridge
  statement: '`live_ui` shall bridge canonical widget events over Phoenix channels using Jido.Signal values and CloudEvents-compatible semantics.'
  priority: must
  stability: stable

- id: live_ui.transport.canonical_event_meaning
  statement: 'The transport boundary shall preserve canonical event meaning across runtime and renderer boundaries, including stable signal type, source, subject, and payload semantics.'
  priority: must
  stability: stable

- id: live_ui.transport.local_state_not_contract
  statement: 'Renderer-specific local state may vary inside `live_ui`, but local state shall not replace the canonical signal contract at the cross-package boundary.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live-ui/transport.spec.md
  covers:
    - live_ui.transport.phoenix_channel_bridge
    - live_ui.transport.canonical_event_meaning
    - live_ui.transport.local_state_not_contract
```
