# UnifiedUi Structure

This subject defines the target internal package structure for creating the
`unified_ui` library in a way that keeps authored DSL concerns separate from
runtime-library concerns.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [Repository Package](../package.spec.md)
- [UnifiedUi Package](./package.spec.md)

```spec-meta
id: unified_ui.structure
kind: architecture
status: active
summary: Target package structure for `unified_ui`, including authored DSL, compiler, signal, introspection, and test surfaces.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/structure.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: unified_ui.structure.mix_package_layout
  statement: The package shall be organized as a standard Mix library with package metadata, public entry modules, test support, and authored examples arranged under `packages/unified-ui`.
  priority: must
  stability: stable

- id: unified_ui.structure.dsl_modules
  statement: The package shall group authored DSL declarations under dedicated modules for entities, sections, style and theme declarations, validators, and author-facing helpers rather than mixing them into runtime-library code.
  priority: must
  stability: stable

- id: unified_ui.structure.compiler_modules
  statement: The package shall provide dedicated compiler modules for translating authored DSL declarations into canonical IUR, resolving defaults, styles, themes, and layer relationships, and exposing deterministic compile results.
  priority: must
  stability: stable

- id: unified_ui.structure.signal_modules
  statement: The package shall provide dedicated signal modules for canonical signal descriptor authoring, validation, and introspection without embedding renderer-specific local signal implementations.
  priority: must
  stability: stable

- id: unified_ui.structure.introspection_and_reference
  statement: The package shall expose introspection and reference surfaces that can report available authored widgets, layouts, layers, style attributes, themes, and supported interaction bindings from the package itself.
  priority: must
  stability: stable

- id: unified_ui.structure.no_required_long_lived_runtime
  statement: The package shall not require long-lived runtime supervisors, PubSub systems, or renderer adapters merely to author or compile canonical UI definitions.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.structure.separated_authoring_and_runtime_boundaries
  given: A maintainer is adding new authored widgets or compiler passes to `unified_ui`
  when: The maintainer updates package modules
  then: The change lands in DSL, compiler, or signal modules rather than introducing renderer-runtime code into the package
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-ui/structure.spec.md
  covers:
    - unified_ui.structure.mix_package_layout
    - unified_ui.structure.dsl_modules
    - unified_ui.structure.compiler_modules
    - unified_ui.structure.signal_modules
    - unified_ui.structure.introspection_and_reference
    - unified_ui.structure.no_required_long_lived_runtime
    - unified_ui.structure.separated_authoring_and_runtime_boundaries
```
