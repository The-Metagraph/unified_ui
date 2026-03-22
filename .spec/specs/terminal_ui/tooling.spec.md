# TerminalUi Tooling

This subject defines the package tooling and reference surfaces needed to build,
inspect, validate, and evolve `terminal_ui` as a terminal runtime library.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Spec System](../spec_system.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [TerminalUi Package](./package.spec.md)
- [TerminalUi Capabilities](./capabilities.spec.md)

```spec-meta
id: terminal_ui.tooling
kind: tooling
status: active
summary: Target tooling contract for documenting, previewing, inspecting, and validating the `terminal_ui` package across richer and limited terminal environments.
surface:
  - packages/terminal_ui
  - .spec/specs/terminal_ui/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: terminal_ui.tooling.reference_examples
  statement: The package shall include maintained reference examples that demonstrate both direct native `terminal_ui` usage and canonical `unified_iur` rendering through the same terminal runtime library.
  priority: must
  stability: stable

- id: terminal_ui.tooling.preview_and_inspection
  statement: The package shall provide tooling or helper workflows that let maintainers inspect native widget rendering, canonical IUR rendering, styling behavior, capability degradation, boundary event translation, and backend behavior during package development.
  priority: must
  stability: stable

- id: terminal_ui.tooling.validation_workflow
  statement: The package shall provide a repeatable validation workflow for canonical IUR coverage, native widget coverage, runtime behavior across richer and limited terminal environments, and boundary event translation.
  priority: must
  stability: stable

- id: terminal_ui.tooling.backend_compatibility_workflows
  statement: The package shall provide or document repeatable workflows for validating richer raw-mode behavior, TTY-compatible fallback behavior, Unicode-to-ASCII degradation, and color-depth reduction expectations.
  priority: must
  stability: stable

- id: terminal_ui.tooling.documentation_surface
  statement: The package shall document its native widget surface, `term_ui`-backed runtime, capability and degradation model, canonical IUR renderer entry point, and boundary event translation model as part of package development.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: terminal_ui.tooling_compare_backends_and_entrypoints
  given: A maintainer adds a new widget family, styling attribute, or runtime feature to `terminal_ui`
  when: The maintainer runs package tooling or reference workflows
  then: The maintainer can compare direct native rendering, canonical IUR rendering, and richer versus limited terminal behavior for the same feature area inside the package
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/terminal_ui/tooling.spec.md
  covers:
    - terminal_ui.tooling.reference_examples
    - terminal_ui.tooling.preview_and_inspection
    - terminal_ui.tooling.validation_workflow
    - terminal_ui.tooling.backend_compatibility_workflows
    - terminal_ui.tooling.documentation_surface
    - terminal_ui.tooling_compare_backends_and_entrypoints
```
