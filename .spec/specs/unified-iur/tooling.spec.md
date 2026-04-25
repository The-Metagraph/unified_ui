# UnifiedIUR Tooling

This subject defines the package tooling and reference surfaces needed to build,
inspect, and evolve `unified_iur` as the canonical exchange model.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Spec System](../spec_system.spec.md)
- [UnifiedIUR Package](./package.spec.md)
- [UnifiedIUR Interoperability](./interoperability.spec.md)

```spec-meta
id: unified_iur.tooling
kind: tooling
status: active
summary: Target tooling contract for documenting, inspecting, validating, and evolving the `unified_iur` package.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: unified_iur.tooling.reference_examples
  statement: The package shall include maintained reference examples or fixtures that demonstrate canonical widgets, layouts, layers, styles, themes, and interaction descriptors in IUR form.
  priority: must
  stability: stable

- id: unified_iur.tooling.introspection_helpers
  statement: The package shall provide tooling or helper workflows that let maintainers inspect canonical element trees, metadata, styling structures, and interaction descriptors without involving a runtime library.
  priority: must
  stability: stable

- id: unified_iur.tooling.validation_workflow
  statement: The package shall provide a repeatable validation workflow for canonical structure consistency, deterministic shape, extension safety, and parity with the authored DSL contract.
  priority: must
  stability: stable

- id: unified_iur.tooling.documentation_surface
  statement: The package shall document its canonical construct families, metadata model, styling and theming model, interaction descriptor model, and runtime-library interoperability expectations as part of package development.
  priority: must
  stability: stable

- id: unified_iur.tooling.navigation_transition_review_surfaces
  statement: The package shall expose maintained fixtures and inspection or export workflows that make canonical navigation transition descriptors reviewable without requiring a runtime library or host router.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.tooling.inspect_canonical_fixture
  given: A maintainer adds a new canonical widget or layering construct to `unified_iur`
  when: The maintainer runs package tooling or helper workflows
  then: The maintainer can inspect canonical fixtures and structure output without relying on a renderer runtime
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-iur/tooling.spec.md
  covers:
    - unified_iur.tooling.reference_examples
    - unified_iur.tooling.introspection_helpers
    - unified_iur.tooling.validation_workflow
    - unified_iur.tooling.documentation_surface
    - unified_iur.tooling.navigation_transition_review_surfaces
    - unified_iur.tooling.inspect_canonical_fixture
```
