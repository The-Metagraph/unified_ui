# LiveUi Interpreter

This subject backfills the current IUR interpretation surface for
`packages/live_ui`, based on its normalization helpers and descriptor pipeline.

```spec-meta
id: live_ui.interpreter
kind: integration
status: active
summary: Current descriptor normalization contract for `packages/live_ui`, including accepted input shapes, schema marker validation, and normalized signal binding extraction.
surface:
  - packages/live_ui/lib/live_ui/descriptor.ex
  - packages/live_ui/lib/live_ui/iur
  - packages/live_ui/test/live_ui/iur
  - packages/live_ui/test/live_ui/architecture/golden_parity_test.exs
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: live_ui.interpreter.accepted_inputs
  statement: 'The interpreter shall accept the current supported input shapes: canonical map payloads, UnifiedIUR protocol structs, and compatible extension structs that expose the same structural fields.'
  priority: must
  stability: stable

- id: live_ui.interpreter.descriptor_normalization
  statement: 'The interpreter shall normalize accepted inputs into `LiveUi.Descriptor` trees with stable ids, normalized kinds, normalized props, interpreted children, and extracted signal bindings.'
  priority: must
  stability: stable

- id: live_ui.interpreter.schema_markers
  statement: 'The interpreter support code shall validate the current optional unified_iur schema markers and reject incomplete or unsupported marker sets when those markers are present.'
  priority: must
  stability: stable

- id: live_ui.interpreter.source_iur_parity
  statement: 'The package shall preserve the current parity contract in which module-backed screens and canonical raw IUR inputs can produce the same normalized descriptor and rendered HTML outputs through the shared interpretation pipeline.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/live_ui/lib/live_ui/iur/interpreter.ex
  covers:
    - live_ui.interpreter.accepted_inputs
    - live_ui.interpreter.descriptor_normalization

- kind: source_file
  target: packages/live_ui/lib/live_ui/iur/value_normalizer.ex
  covers:
    - live_ui.interpreter.descriptor_normalization

- kind: source_file
  target: packages/live_ui/lib/live_ui/iur/dependency.ex
  covers:
    - live_ui.interpreter.schema_markers

- kind: source_file
  target: packages/live_ui/lib/live_ui/descriptor.ex
  covers:
    - live_ui.interpreter.descriptor_normalization

- kind: source_file
  target: packages/live_ui/test/live_ui/iur/interpreter_test.exs
  covers:
    - live_ui.interpreter.accepted_inputs
    - live_ui.interpreter.descriptor_normalization

- kind: source_file
  target: packages/live_ui/test/live_ui/iur/dependency_test.exs
  covers:
    - live_ui.interpreter.schema_markers

- kind: source_file
  target: packages/live_ui/test/live_ui/architecture/golden_parity_test.exs
  covers:
    - live_ui.interpreter.source_iur_parity
```
