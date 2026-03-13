# LiveUi Runtime

This subject defines the intended ecosystem-aligned runtime contract for
`packages/live_ui`.

```spec-meta
id: live_ui.runtime
kind: runtime
status: active
summary: Ecosystem-aligned runtime contract for `packages/live_ui`, centered on a server-authoritative LiveView runtime driven by canonical UnifiedIUR and canonical signals.
surface:
  - packages/live_ui
  - .spec/specs/live-ui/runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.live_ui.ecosystem_alignment
```

## Requirements

```spec-requirements
- id: live_ui.runtime.liveview_execution_model
  statement: '`live_ui` shall execute as a Phoenix LiveView runtime whose rendered state is driven by canonical UnifiedIUR interpretation and native widget rendering.'
  priority: must
  stability: stable

- id: live_ui.runtime.server_authoritative_behavior
  statement: 'The runtime shall preserve server-authoritative UI behavior even when local widget behavior requires browser-assisted interaction.'
  priority: must
  stability: stable

- id: live_ui.runtime.local_state_subordinate
  statement: 'Renderer-local or hook-local state may exist for runtime convenience, but it shall remain subordinate to the canonical server-side runtime model and shall not redefine cross-package UI meaning.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live-ui/runtime.spec.md
  covers:
    - live_ui.runtime.liveview_execution_model
    - live_ui.runtime.server_authoritative_behavior
    - live_ui.runtime.local_state_subordinate
```
