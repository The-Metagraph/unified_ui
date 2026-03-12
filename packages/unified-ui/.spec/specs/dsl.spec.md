# DSL

Current authoring contract for the UnifiedUi DSL.

```spec-meta
id: unified_ui.dsl
kind: component
status: active
summary: Compile-time DSL for authoring UI modules, dynamic bindings, styles, signals, and introspection.
surface:
  - lib/unified_ui/dsl.ex
  - lib/unified_ui/info.ex
  - lib/unified_ui/dsl/verifiers.ex
  - lib/unified_ui/dsl/sections/*.ex
  - lib/unified_ui/dsl/style*.ex
  - guides/getting-started.md
  - guides/dsl-reference.md
  - guides/styling-and-theming.md
```

## Requirements

```spec-requirements
- id: unified_ui.dsl.module_compilation
  statement: Modules using UnifiedUi.Dsl shall compile nested UI declarations into a generated view/1 function and support nested blocks and comprehensions.
  priority: must
  stability: evolving

- id: unified_ui.dsl.dynamic_state_bindings
  statement: The DSL shall support state declarations with atom keys and resolve runtime state references for content and boolean widget attributes.
  priority: must
  stability: evolving

- id: unified_ui.dsl.styles_and_themes
  statement: The DSL shall support inline styles, named styles, and theme-aware style resolution for rendered entities.
  priority: must
  stability: evolving

- id: unified_ui.dsl.signal_helpers
  statement: The DSL shall expose standard signal names and allow atom, tuple, and MFA signal handlers on supported entities.
  priority: must
  stability: stable

- id: unified_ui.dsl.compile_time_validation
  statement: DSL verification shall reject duplicate ids, invalid required attributes, invalid label references, invalid signal handler formats, invalid style references, and invalid state references.
  priority: must
  stability: stable

- id: unified_ui.dsl.introspection
  statement: UnifiedUi.Info shall expose compiled widgets, layouts, styles, and standard signals for DSL modules and DSL state maps.
  priority: should
  stability: evolving
```

## Scenarios

```spec-scenarios
- id: unified_ui.dsl.compiled_module_flow
  given:
    - a module that uses UnifiedUi.Dsl with nested entities and declared state
    - runtime state passed to the generated view
  when:
    - the module is compiled and view/1 is called
  then:
    - view/1 returns an IUR tree built from the authored entities
    - runtime-bound values are resolved into the rendered output
  covers:
    - unified_ui.dsl.module_compilation
    - unified_ui.dsl.dynamic_state_bindings

- id: unified_ui.dsl.invalid_definition_rejected
  given:
    - a DSL module with duplicate ids or invalid references
  when:
    - the verifier runs during compilation
  then:
    - compilation fails with a DSL validation error
  covers:
    - unified_ui.dsl.compile_time_validation
```

## Verification

```spec-verification
- kind: source_file
  target: lib/unified_ui/dsl.ex
  covers:
    - unified_ui.dsl.module_compilation
    - unified_ui.dsl.dynamic_state_bindings
    - unified_ui.dsl.styles_and_themes
    - unified_ui.dsl.signal_helpers

- kind: source_file
  target: lib/unified_ui/info.ex
  covers:
    - unified_ui.dsl.introspection

- kind: source_file
  target: lib/unified_ui/dsl/verifiers.ex
  covers:
    - unified_ui.dsl.compile_time_validation

- kind: guide_file
  target: guides/getting-started.md
  covers:
    - unified_ui.dsl.module_compilation
    - unified_ui.dsl.signal_helpers

- kind: guide_file
  target: guides/dsl-reference.md
  covers:
    - unified_ui.dsl.module_compilation
    - unified_ui.dsl.dynamic_state_bindings
    - unified_ui.dsl.signal_helpers

- kind: guide_file
  target: guides/styling-and-theming.md
  covers:
    - unified_ui.dsl.styles_and_themes

- kind: test_file
  target: test/unified_ui/dsl_test.exs
  covers:
    - unified_ui.dsl.module_compilation
    - unified_ui.dsl.dynamic_state_bindings
    - unified_ui.dsl.styles_and_themes
    - unified_ui.dsl.signal_helpers

- kind: test_file
  target: test/unified_ui/dsl/integration_test.exs
  covers:
    - unified_ui.dsl.dynamic_state_bindings
    - unified_ui.dsl.signal_helpers

- kind: test_file
  target: test/unified_ui/dsl/verifiers_test.exs
  covers:
    - unified_ui.dsl.compile_time_validation

- kind: test_file
  target: test/unified_ui/info_test.exs
  covers:
    - unified_ui.dsl.introspection

- kind: command
  target: mix test test/unified_ui/dsl_test.exs test/unified_ui/dsl/integration_test.exs test/unified_ui/dsl/verifiers_test.exs test/unified_ui/info_test.exs
  execute: true
  covers:
    - unified_ui.dsl.module_compilation
    - unified_ui.dsl.dynamic_state_bindings
    - unified_ui.dsl.styles_and_themes
    - unified_ui.dsl.signal_helpers
    - unified_ui.dsl.compile_time_validation
    - unified_ui.dsl.introspection
```
