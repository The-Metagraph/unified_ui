# Example Apps Suite

This subject defines the repository-level contract for the standalone example
applications that demonstrate the ecosystem through `live_ui` and a shared DSL
template.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [UnifiedUi Package](../unified-ui/package.spec.md)
- [LiveUi Package](../live_ui/package.spec.md)
- [LiveUi Tooling](../live_ui/tooling.spec.md)
- [Examples Demo Application](../examples_demo/package.spec.md)

```spec-meta
id: repo.examples
kind: package
status: active
summary: Repository-level contract for standalone example applications under `examples/` that use a shared DSL template and render through `live_ui`.
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

- id: repo.examples.shared_support_library
  statement: The example suite shall include one shared support library under `examples/shared/` that owns the common DSL template, default theme, default style, and shared example-shell helpers used by all example applications.
  priority: must
  stability: stable

- id: repo.examples.per_widget_app_contract
  statement: The example suite shall include one example application subdirectory for each widget or display construct named in the example catalog, with each application focusing on one primary widget or construct while reusing the common template and style system.
  priority: must
  stability: stable

- id: repo.examples.aggregate_demo_application
  statement: The example suite shall also include one aggregate demo application under `examples/demo/` that groups controls by category and provides a dedicated signal-reactivity tab alongside the per-widget example applications.
  priority: must
  stability: stable

- id: repo.examples.live_ui_runtime_boundary
  statement: Every example application shall render through `live_ui` as the runtime library while authoring its example screen through the shared DSL template rather than through ad hoc native-only screen structure.
  priority: must
  stability: stable

- id: repo.examples.shared_default_theme_and_style
  statement: Every example application shall use the same shared default theme and default style profile supplied by the shared example support library, with app-local overrides allowed only where the example subject itself requires a focused demonstration.
  priority: must
  stability: stable

- id: repo.examples.traceable_to_root_contract
  statement: The example suite subjects shall remain subordinate to the repository-level architecture, `unified_ui`, and `live_ui` package subjects so example-app design does not drift from the ecosystem contract.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: repo.examples.find_widget_example
  given: A maintainer or reviewer wants to see how one `live_ui` widget or display construct is meant to look in a standalone example app
  when: The maintainer opens the example suite catalog
  then: The maintainer can find one dedicated example application subdirectory for that widget or construct, and that application uses the shared DSL template plus the shared default theme and style
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples/package.spec.md
  covers:
    - repo.examples.root_examples_directory
    - repo.examples.shared_support_library
    - repo.examples.per_widget_app_contract
    - repo.examples.aggregate_demo_application
    - repo.examples.live_ui_runtime_boundary
    - repo.examples.shared_default_theme_and_style
    - repo.examples.traceable_to_root_contract
    - repo.examples.find_widget_example
```
