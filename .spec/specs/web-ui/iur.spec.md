# WebUi IUR

This subject backfills the current canonical `unified_iur` interpretation
contract implemented by `packages/web_ui`.

```spec-meta
id: web_ui.iur
kind: integration
status: active
summary: Current IUR interpretation contract for `packages/web_ui`, including dependency compatibility checks, deterministic descriptor normalization, signal-to-event mapping, and default-value pruning.
surface:
  - packages/web_ui/lib/web_ui/iur/dependency.ex
  - packages/web_ui/lib/web_ui/iur/interpreter.ex
  - packages/web_ui/lib/web_ui/iur/value_normalizer.ex
  - packages/web_ui/lib/web_ui/iur/descriptor_defaults.ex
  - packages/web_ui/lib/web_ui/iur/nested_defaults.ex
  - packages/web_ui/test/web_ui/iur
  - packages/web_ui/test/web_ui/integration
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: web_ui.iur.dependency_compatibility
  statement: 'The package shall enforce the current `unified_iur` dependency compatibility checks for canonical schema markers, canonical source identifiers, dependency version matching, and canonical struct detection.'
  priority: must
  stability: stable

- id: web_ui.iur.descriptor_normalization
  statement: 'The interpreter shall accept the current supported IUR maps and canonical structs, normalize them into deterministic root, widget, signal, and event representations, and map current widget signal fields through the Elm binding helpers.'
  priority: must
  stability: stable

- id: web_ui.iur.default_pruning
  statement: 'The current value normalizer and descriptor-default helpers shall canonicalize deep values and prune the currently implemented global, widget, style, and nested table defaults from interpreted widget props.'
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/web_ui/lib/web_ui/iur/dependency.ex
  covers:
    - web_ui.iur.dependency_compatibility

- kind: source_file
  target: packages/web_ui/lib/web_ui/iur/interpreter.ex
  covers:
    - web_ui.iur.descriptor_normalization

- kind: source_file
  target: packages/web_ui/lib/web_ui/iur/value_normalizer.ex
  covers:
    - web_ui.iur.default_pruning

- kind: source_file
  target: packages/web_ui/lib/web_ui/iur/descriptor_defaults.ex
  covers:
    - web_ui.iur.default_pruning

- kind: source_file
  target: packages/web_ui/lib/web_ui/iur/nested_defaults.ex
  covers:
    - web_ui.iur.default_pruning

- kind: source_file
  target: packages/web_ui/test/web_ui/iur/dependency_test.exs
  covers:
    - web_ui.iur.dependency_compatibility

- kind: source_file
  target: packages/web_ui/test/web_ui/iur/interpreter_test.exs
  covers:
    - web_ui.iur.descriptor_normalization

- kind: source_file
  target: packages/web_ui/test/web_ui/iur/value_normalizer_test.exs
  covers:
    - web_ui.iur.default_pruning

- kind: source_file
  target: packages/web_ui/test/web_ui/iur/descriptor_defaults_test.exs
  covers:
    - web_ui.iur.default_pruning

- kind: source_file
  target: packages/web_ui/test/web_ui/iur/nested_defaults_test.exs
  covers:
    - web_ui.iur.default_pruning

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_16_unified_iur_interpretation_test.exs
  covers:
    - web_ui.iur.descriptor_normalization

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_27_canonical_unified_iur_dependency_test.exs
  covers:
    - web_ui.iur.dependency_compatibility

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_28_canonical_unified_iur_extended_mapping_test.exs
  covers:
    - web_ui.iur.descriptor_normalization

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_29_canonical_unified_iur_signal_coercion_test.exs
  covers:
    - web_ui.iur.descriptor_normalization

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_30_canonical_unified_iur_descriptor_parity_test.exs
  covers:
    - web_ui.iur.descriptor_normalization

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_31_canonical_unified_iur_deep_value_parity_test.exs
  covers:
    - web_ui.iur.default_pruning

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_32_canonical_unified_iur_nested_default_parity_test.exs
  covers:
    - web_ui.iur.default_pruning

- kind: source_file
  target: packages/web_ui/test/web_ui/integration/phase_33_canonical_unified_iur_collection_normalization_test.exs
  covers:
    - web_ui.iur.default_pruning
```
