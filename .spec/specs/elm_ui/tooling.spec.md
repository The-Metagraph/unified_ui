# ElmUi Tooling

This subject defines the package tooling and reference surfaces needed to build,
inspect, and validate `elm_ui` as a runtime library.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Spec System](../spec_system.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [ElmUi Package](./package.spec.md)

```spec-meta
id: elm_ui.tooling
kind: tooling
status: active
summary: Target tooling contract for documenting, previewing, validating, and evolving the `elm_ui` package.
surface:
  - packages/elm_ui
  - .spec/specs/elm_ui/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.elm_ui_naming
```

## Requirements

```spec-requirements
- id: elm_ui.tooling.reference_examples
  statement: The package shall include maintained reference examples that demonstrate both direct native `elm_ui` usage and canonical `unified_iur` rendering through the same web runtime library.
  priority: must
  stability: stable

- id: elm_ui.tooling.preview_and_inspection
  statement: The package shall provide tooling or helper workflows that let maintainers inspect native widget rendering, canonical IUR rendering, styling behavior, and boundary event translation during package development.
  priority: must
  stability: stable

- id: elm_ui.tooling.validation_workflow
  statement: The package shall provide a repeatable validation workflow for canonical IUR coverage, native widget coverage, server and frontend runtime behavior, and boundary event translation.
  priority: must
  stability: stable

- id: elm_ui.tooling.documentation_surface
  statement: The package shall document its native widget surface, Phoenix server runtime, Elm frontend runtime, canonical IUR renderer entry point, and boundary event translation model as part of package development.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: elm_ui.tooling_compare_native_and_iur_paths
  covers:
    - elm_ui.tooling.reference_examples
    - elm_ui.tooling.preview_and_inspection
    - elm_ui.tooling.validation_workflow
    - elm_ui.tooling.documentation_surface
  given:
    - A maintainer adds a new widget family or styling attribute to `elm_ui`
  when:
    - The maintainer runs package tooling or reference workflows
  then:
    - The maintainer can compare direct native rendering and canonical IUR rendering for the same feature area inside the package
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/elm_ui/tooling.spec.md
  covers:
    - elm_ui.tooling.reference_examples
    - elm_ui.tooling.preview_and_inspection
    - elm_ui.tooling.validation_workflow
    - elm_ui.tooling.documentation_surface
    - elm_ui.tooling_compare_native_and_iur_paths
```
