# DesktopUi Tooling

This subject defines the package tooling and reference surfaces needed to build,
inspect, validate, and package `desktop_ui` as a multiplatform runtime library.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Spec System](../spec_system.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [DesktopUi Package](./package.spec.md)
- [DesktopUi Platform Artifacts](./platform_artifacts.spec.md)
- [DesktopUi SDL3 Runtime And Native Rendering](./sdl3_runtime_rendering.spec.md)

```spec-meta
id: desktop_ui.tooling
kind: tooling
status: active
summary: Target tooling contract for documenting, previewing, validating, and packaging the `desktop_ui` package across supported desktop platforms.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop_ui/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: desktop_ui.tooling.reference_examples
  statement: The package shall include maintained reference examples that demonstrate both direct native `desktop_ui` usage and canonical `unified_iur` rendering through the same desktop runtime library.
  priority: must
  stability: stable

- id: desktop_ui.tooling.preview_and_inspection
  statement: The package shall provide tooling or helper workflows that let maintainers inspect native widget rendering, canonical IUR rendering, styling behavior, boundary event translation, and multiplatform desktop behavior during package development.
  priority: must
  stability: stable

- id: desktop_ui.tooling.validation_workflow
  statement: The package shall provide a repeatable validation workflow for canonical IUR coverage, native widget coverage, runtime behavior across supported targets, and boundary event translation.
  priority: must
  stability: stable

- id: desktop_ui.tooling.platform_build_workflows
  statement: The package shall provide or document repeatable workflows for building and packaging Windows, macOS, and Linux desktop artifacts even when those workflows diverge by target.
  priority: must
  stability: stable

- id: desktop_ui.tooling.documentation_surface
  statement: The package shall document its native widget surface, SDL3-based runtime, canonical IUR renderer entry point, boundary event translation model, and platform-specific artifact expectations as part of package development.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: desktop_ui.tooling_compare_targets_and_entrypoints
  given: A maintainer adds a new widget family, styling attribute, or runtime feature to `desktop_ui`
  when: The maintainer runs package tooling or reference workflows
  then: The maintainer can compare direct native rendering, canonical IUR rendering, and target-platform artifact behavior for the same feature area inside the package
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop_ui/tooling.spec.md
  covers:
    - desktop_ui.tooling.reference_examples
    - desktop_ui.tooling.preview_and_inspection
    - desktop_ui.tooling.validation_workflow
    - desktop_ui.tooling.platform_build_workflows
    - desktop_ui.tooling.documentation_surface
    - desktop_ui.tooling_compare_targets_and_entrypoints
```
