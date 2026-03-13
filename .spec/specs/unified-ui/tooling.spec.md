# UnifiedUi Tooling

This subject defines the package tooling needed to create, document, inspect,
and validate `unified_ui` as a library package.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Spec System](../spec_system.spec.md)
- [UnifiedUi Package](./package.spec.md)
- [UnifiedUi Compiler](./compiler.spec.md)

```spec-meta
id: unified_ui.tooling
kind: tooling
status: active
summary: Target tooling contract for building, documenting, inspecting, and validating the `unified_ui` package.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: unified_ui.tooling.reference_examples
  statement: The package shall include maintained authored examples or reference modules that demonstrate canonical widgets, layouts, styling, theming, and signal binding patterns.
  priority: must
  stability: stable

- id: unified_ui.tooling.compiler_inspection
  statement: The package shall provide tooling or helper workflows that let developers inspect compiled canonical IUR and compiled signal descriptors during package development.
  priority: must
  stability: stable

- id: unified_ui.tooling.authoring_validation_workflow
  statement: The package shall provide a repeatable validation workflow for DSL compilation, canonical IUR parity, signal descriptor shape, and example coverage.
  priority: must
  stability: stable

- id: unified_ui.tooling.documentation_surface
  statement: The package shall document its authored widget categories, styling and theming model, signal interaction model, and canonical IUR compilation model as part of the package developer workflow.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.tooling.inspect_example_output
  given: A maintainer adds a new canonical widget or style attribute to `unified_ui`
  when: The maintainer runs package tooling or helper workflows
  then: The maintainer can inspect the updated compiled canonical output and package examples without involving a runtime library
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-ui/tooling.spec.md
  covers:
    - unified_ui.tooling.reference_examples
    - unified_ui.tooling.compiler_inspection
    - unified_ui.tooling.authoring_validation_workflow
    - unified_ui.tooling.documentation_surface
    - unified_ui.tooling.inspect_example_output
```
