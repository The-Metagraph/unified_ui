# Example Apps Suite

This subject defines the repository-level contract for the standalone example
applications that demonstrate the ecosystem through a common authored example
contract and runtime-selectable rendering.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [UnifiedUi Package](../unified-ui/package.spec.md)
- [UnifiedIUR Package](../unified-iur/package.spec.md)
- [Examples Demo Application](../examples_demo/package.spec.md)

```spec-meta
id: repo.examples
kind: package
status: active
summary: Repository-level contract for standalone example applications under `examples/` that preserve one common example-shell and styling contract while allowing runtime selection.
surface:
  - examples/**
  - .spec/specs/examples/package.spec.md
  - .spec/specs/examples/structure.spec.md
  - .spec/specs/examples/dsl_template.spec.md
  - .spec/specs/examples/catalog.spec.md
  - .spec/specs/examples/tooling.spec.md
  - .spec/specs/examples_demo/package.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples.root_examples_directory
  statement: The repository shall keep standalone example applications under the root `examples/` directory rather than embedding them inside `packages/`.
  priority: must
  stability: stable

- id: repo.examples.self_contained_app_contract
  statement: The example suite shall not require a repository-owned shared support library under `examples/shared/`; focused and aggregate example applications shall own their own authored modules, runtime entrypoints, theme definitions, and example-shell helpers locally.
  priority: must
  stability: stable

- id: repo.examples.per_widget_app_contract
  statement: The example suite shall include one example application subdirectory for each widget or display construct named in the example catalog, with each application focusing on one primary widget or construct while preserving the common example-shell, theme, and style contract.
  priority: must
  stability: stable

- id: repo.examples.aggregate_demo_application
  statement: The example suite shall also include one aggregate demo application under `examples/demo/` that groups controls by category and provides a dedicated signal-reactivity tab alongside the per-widget example applications.
  priority: must
  stability: stable

- id: repo.examples.runtime_selection_boundary
  statement: Every example application shall compile authored screens through `unified_ui` into canonical `UnifiedIUR` and render through the runtime selected for the launch session, with maintained launcher targets for `live_ui`, `desktop_ui`, `elm_ui`, and `terminal_ui`, and with `live_ui` as the default runtime when no command-line runtime argument or equivalent override is provided.
  priority: must
  stability: stable

- id: repo.examples.shared_default_theme_and_style
  statement: Every example application shall use the same suite default theme and default style profile by default, with app-local overrides allowed only where the example subject itself requires a focused demonstration.
  priority: must
  stability: stable

- id: repo.examples.traceable_to_root_contract
  statement: The example suite subjects shall remain subordinate to the repository-level architecture, `unified_ui`, `unified_iur`, and platform-runtime subjects so example-app design does not drift from the ecosystem contract.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: repo.examples.find_widget_example
  given: A maintainer or reviewer wants to see how one widget or display construct is meant to look in a standalone example app
  when: The maintainer opens the example suite catalog
  then: The maintainer can find one dedicated example application subdirectory for that widget or construct, and that application preserves the common example shell plus the suite default theme and style baseline
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples/package.spec.md
  covers:
    - repo.examples.root_examples_directory
    - repo.examples.self_contained_app_contract
    - repo.examples.per_widget_app_contract
    - repo.examples.aggregate_demo_application
    - repo.examples.runtime_selection_boundary
    - repo.examples.shared_default_theme_and_style
    - repo.examples.traceable_to_root_contract
    - repo.examples.find_widget_example
```
