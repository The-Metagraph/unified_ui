# UnifiedIUR Structure

This subject defines the target internal package structure for creating the
`unified_iur` library as a pure, canonical interchange package.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [UnifiedIUR Package](./package.spec.md)

```spec-meta
id: unified_iur.structure
kind: architecture
status: active
summary: Target package structure for `unified_iur`, including canonical element modules, construct modules, interaction descriptors, normalization, and reference surfaces.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/structure.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: unified_iur.structure.mix_library_layout
  statement: The package shall be organized as a standard Mix library with canonical data-model modules, package metadata, tests, and authored references under `packages/unified_iur`.
  priority: must
  stability: stable

- id: unified_iur.structure.core_and_construct_module_split
  statement: The package shall separate core element and metadata concerns from higher-level widget, layout, layering, styling, theming, and interaction construct modules so canonical responsibilities stay navigable.
  priority: must
  stability: stable

- id: unified_iur.structure.normalization_and_conversion_modules
  statement: The package shall provide dedicated normalization or conversion modules for turning authored compile output into stable canonical structures without introducing renderer-specific adapter code.
  priority: must
  stability: stable

- id: unified_iur.structure.reference_and_introspection_modules
  statement: The package shall expose reference or introspection surfaces that let maintainers inspect available canonical constructs, metadata shape, and compatibility expectations from the package itself.
  priority: must
  stability: stable

- id: unified_iur.structure.no_long_lived_runtime
  statement: The package shall remain a pure data-model library and shall not require supervisors, PubSub systems, channels, or long-lived renderer runtime processes merely to construct or inspect canonical IUR.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.structure.maintain_pure_interchange_boundary
  given: A maintainer adds new canonical constructs to `unified_iur`
  when: The package structure evolves
  then: The change lands in pure canonical data-model modules rather than introducing runtime-library or transport-server infrastructure into the package
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-iur/structure.spec.md
  covers:
    - unified_iur.structure.mix_library_layout
    - unified_iur.structure.core_and_construct_module_split
    - unified_iur.structure.normalization_and_conversion_modules
    - unified_iur.structure.reference_and_introspection_modules
    - unified_iur.structure.no_long_lived_runtime
    - unified_iur.structure.maintain_pure_interchange_boundary
```
