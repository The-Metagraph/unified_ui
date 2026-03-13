# UnifiedUi Adapters

This subject describes the adapter-layer contract in `packages/unified-ui`,
including renderer contracts, coordination, canonical event normalization,
shared helper modules, and the security pipeline.

```spec-meta
id: unified_ui.adapters
kind: subsystem
status: active
summary: Adapter-layer contract for `packages/unified-ui`, covering renderer behaviour over supported IUR elements, coordination, canonical event normalization, shared-state utilities, and the security pipeline.
surface:
  - packages/unified-ui/lib/unified_ui/adapters
  - packages/unified-ui/test/unified_ui/adapters
  - packages/unified-ui/test/unified_ui/integration/phase_3_test.exs
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: unified_ui.adapters.renderer_contract
  statement: The package shall define a renderer behaviour with `render/2`, `update/3`, and `destroy/1` callbacks over canonical IUR trees, including package-defined elements that implement `UnifiedIUR.Element`, and renderer-owned state.
  priority: must
  stability: stable

- id: unified_ui.adapters.coordination
  statement: The adapter layer shall coordinate platform detection, renderer selection, multi-platform rendering, and signal routing across the terminal, desktop, and web adapters implemented by the package.
  priority: must
  stability: stable

- id: unified_ui.adapters.event_normalization
  statement: The package shall provide adapter-side event normalization and dispatch helpers that convert platform events into canonical `Jido.Signal` values and optionally dispatch them through the shared runtime component boundary.
  priority: must
  stability: stable

- id: unified_ui.adapters.shared_support
  statement: The adapter layer shall expose shared pure utilities for IUR traversal, style and id inspection, and renderer state bookkeeping used across renderers.
  priority: must
  stability: stable

- id: unified_ui.adapters.security_pipeline
  statement: The adapter layer shall validate event actions and payloads, sanitize user-provided data, and redact sensitive fields before renderer-driven dispatch uses that data.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified-ui/lib/unified_ui/adapters/protocol.ex
  covers:
    - unified_ui.adapters.renderer_contract

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/adapters/coordinator.ex
  covers:
    - unified_ui.adapters.coordination

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/adapters/event.ex
  covers:
    - unified_ui.adapters.event_normalization

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/adapters/shared.ex
  covers:
    - unified_ui.adapters.shared_support

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/adapters/state.ex
  covers:
    - unified_ui.adapters.shared_support

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/adapters/security.ex
  covers:
    - unified_ui.adapters.security_pipeline

- kind: source_file
  target: packages/unified-ui/test/unified_ui/adapters/coordinator_test.exs
  covers:
    - unified_ui.adapters.coordination

- kind: source_file
  target: packages/unified-ui/test/unified_ui/adapters/event_test.exs
  covers:
    - unified_ui.adapters.event_normalization

- kind: source_file
  target: packages/unified-ui/test/unified_ui/adapters/shared_test.exs
  covers:
    - unified_ui.adapters.shared_support

- kind: source_file
  target: packages/unified-ui/test/unified_ui/adapters/state_test.exs
  covers:
    - unified_ui.adapters.shared_support

- kind: source_file
  target: packages/unified-ui/test/unified_ui/adapters/security_test.exs
  covers:
    - unified_ui.adapters.security_pipeline

- kind: source_file
  target: packages/unified-ui/test/unified_ui/integration/phase_3_test.exs
  covers:
    - unified_ui.adapters.renderer_contract
    - unified_ui.adapters.coordination
    - unified_ui.adapters.event_normalization
    - unified_ui.adapters.shared_support
```
