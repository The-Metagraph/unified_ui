# UnifiedIUR Core

This subject backfills the current core model for `packages/unified_iur`,
including the element protocol, metadata helper functions, and the
platform-agnostic style representation.

```spec-meta
id: unified_iur.core
kind: subsystem
status: active
summary: Current core protocol and style contract for `packages/unified_iur`, derived from the implemented element, helper, and style modules.
surface:
  - packages/unified_iur/lib/unified_iur/element.ex
  - packages/unified_iur/lib/unified_iur/element_helpers.ex
  - packages/unified_iur/lib/unified_iur/style.ex
  - packages/unified_iur/test/unified_iur_test.exs
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: unified_iur.core.element_protocol
  statement: The package shall define `UnifiedIUR.Element` as the current polymorphic contract for retrieving child elements and metadata from IUR structs.
  priority: must
  stability: stable

- id: unified_iur.core.protocol_fallback
  statement: "The package shall provide a fallback `UnifiedIUR.Element` implementation for unknown values that returns no children and `type: :unknown`."
  priority: must
  stability: stable

- id: unified_iur.core.metadata_helpers
  statement: The package shall provide helper functions for building metadata maps with optional `id` and `style` fields so protocol implementations can stay structurally consistent.
  priority: must
  stability: stable

- id: unified_iur.core.style_model
  statement: The package shall provide a platform-agnostic style struct with constructor and merge helpers for the current foreground, background, text-attribute, spacing, sizing, and alignment fields.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified_iur/lib/unified_iur/element.ex
  covers:
    - unified_iur.core.element_protocol
    - unified_iur.core.protocol_fallback

- kind: source_file
  target: packages/unified_iur/lib/unified_iur/element_helpers.ex
  covers:
    - unified_iur.core.metadata_helpers

- kind: source_file
  target: packages/unified_iur/lib/unified_iur/style.ex
  covers:
    - unified_iur.core.style_model

- kind: source_file
  target: packages/unified_iur/test/unified_iur_test.exs
  covers:
    - unified_iur.core.element_protocol
```
