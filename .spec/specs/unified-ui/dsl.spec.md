# UnifiedUi DSL

This subject backfills the current `UnifiedUi.Dsl` surface from the package code,
including compile-time indexing, validation, style handling, and introspection.

```spec-meta
id: unified_ui.dsl
kind: subsystem
status: active
summary: Current Spark-based DSL contract for `packages/unified-ui`, derived from the package implementation and tests.
surface:
  - packages/unified-ui/lib/unified_ui/dsl.ex
  - packages/unified-ui/lib/unified_ui/dsl
  - packages/unified-ui/lib/unified_ui/info.ex
  - packages/unified-ui/test/unified_ui/dsl
  - packages/unified-ui/test/unified_ui/info_test.exs
decisions:
  - repo.governance.contract_policy
```

## Requirements

```spec-requirements
- id: unified_ui.dsl.module_compilation
  statement: The package shall provide a Spark-based DSL that compiles module-body UI declarations into the generated component surface expected by `UnifiedUi` modules.
  priority: must
  stability: stable

- id: unified_ui.dsl.dynamic_state_bindings
  statement: The DSL shall support state-backed attribute values and preserve runtime state context through compile indexing and view building.
  priority: must
  stability: stable

- id: unified_ui.dsl.styles_and_themes
  statement: The DSL shall support named styles and themes alongside inline style data and resolve them during IUR construction.
  priority: must
  stability: stable

- id: unified_ui.dsl.signal_helpers
  statement: The DSL layer shall expose standard signal names and helper utilities for shaping and validating handler payloads used by authored UI modules.
  priority: must
  stability: stable

- id: unified_ui.dsl.compile_time_validation
  statement: DSL compilation shall verify unique ids, valid label references, and supported signal handler formats before a module is accepted.
  priority: must
  stability: stable

- id: unified_ui.dsl.introspection
  statement: The package shall expose introspection helpers that return compiled widgets, layouts, styles, and supported signals for a DSL module or DSL state.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl.ex
  covers:
    - unified_ui.dsl.module_compilation
    - unified_ui.dsl.dynamic_state_bindings
    - unified_ui.dsl.styles_and_themes
    - unified_ui.dsl.signal_helpers

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/compile_index.ex
  covers:
    - unified_ui.dsl.dynamic_state_bindings

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/dsl/verifiers.ex
  covers:
    - unified_ui.dsl.compile_time_validation

- kind: source_file
  target: packages/unified-ui/lib/unified_ui/info.ex
  covers:
    - unified_ui.dsl.introspection

- kind: source_file
  target: packages/unified-ui/test/unified_ui/dsl_test.exs
  covers:
    - unified_ui.dsl.module_compilation
    - unified_ui.dsl.dynamic_state_bindings
    - unified_ui.dsl.styles_and_themes
    - unified_ui.dsl.signal_helpers

- kind: source_file
  target: packages/unified-ui/test/unified_ui/dsl/integration_test.exs
  covers:
    - unified_ui.dsl.dynamic_state_bindings
    - unified_ui.dsl.signal_helpers

- kind: source_file
  target: packages/unified-ui/test/unified_ui/dsl/verifiers_test.exs
  covers:
    - unified_ui.dsl.compile_time_validation

- kind: source_file
  target: packages/unified-ui/test/unified_ui/info_test.exs
  covers:
    - unified_ui.dsl.introspection
```
