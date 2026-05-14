# UnifiedIUR Core

This subject defines the core canonical element model that every higher-level
`unified_iur` construct builds on.

## Related General Specs

- [Ecosystem Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [UnifiedIUR Package](./package.spec.md)
- [UnifiedIUR Interoperability](./interoperability.spec.md)

```spec-meta
id: unified_iur.core
kind: subsystem
status: active
summary: Target core element, metadata, identity, child traversal, and canonical value-model contract for `unified_iur`.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/core.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: unified_iur.core.canonical_element_model
  statement: The package shall define a canonical element model that every widget, layout, layer, and composite construct can participate in for traversal, introspection, and renderer consumption.
  priority: must
  stability: stable

- id: unified_iur.core.identity_and_metadata
  statement: Canonical elements shall support stable identity, type information, metadata, and optional descriptive annotations needed for authored traceability and runtime-library interpretation.
  priority: must
  stability: stable

- id: unified_iur.core.child_relationship_model
  statement: The package shall define a uniform child relationship model so container widgets, layouts, layered compositions, and composite widgets expose nested canonical structure consistently.
  priority: must
  stability: stable

- id: unified_iur.core.pure_immutable_values
  statement: Canonical IUR elements and helpers shall remain pure immutable values that can be created, merged, inspected, and transformed without long-lived runtime state.
  priority: must
  stability: stable

- id: unified_iur.core.extensible_without_breaking_shape
  statement: The core element model shall allow new canonical construct families to be added while preserving a stable inspection and traversal shape for existing runtime consumers.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.core.walk_canonical_tree
  covers:
    - unified_iur.core.canonical_element_model
    - unified_iur.core.identity_and_metadata
    - unified_iur.core.child_relationship_model
    - unified_iur.core.pure_immutable_values
    - unified_iur.core.extensible_without_breaking_shape
  given:
    - A runtime library receives canonical IUR for a complex screen with nested containers and layered content
  when:
    - The runtime walks the canonical structure
  then:
    - It can discover element identity, type, metadata, and nested children through one consistent element model
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-iur/core.spec.md
  covers:
    - unified_iur.core.canonical_element_model
    - unified_iur.core.identity_and_metadata
    - unified_iur.core.child_relationship_model
    - unified_iur.core.pure_immutable_values
    - unified_iur.core.extensible_without_breaking_shape
    - unified_iur.core.walk_canonical_tree
```
