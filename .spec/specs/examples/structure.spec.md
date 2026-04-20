# Example Apps Structure

This subject defines the required directory and package structure for the
standalone example applications under `examples/`.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Example Apps Suite](./package.spec.md)
- [Examples Demo Application](../examples_demo/package.spec.md)
- [UnifiedUi Structure](../unified-ui/structure.spec.md)

```spec-meta
id: repo.examples.structure
kind: subsystem
status: active
summary: Directory and package structure for standalone widget example applications under `examples/`.
surface:
  - examples/**
  - .spec/specs/examples/structure.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples.structure.self_contained_examples
  statement: Focused and aggregate example applications shall keep their authored modules, runtime entrypoints, theme definitions, and example-shell helpers within their own project directories and shall not require an `examples/shared/` path dependency.
  priority: must
  stability: stable

- id: repo.examples.structure.example_app_directory
  statement: Each focused per-widget or per-construct example application shall live in its own subdirectory at `examples/<widget_name>/`, where `<widget_name>` matches the primary widget or construct name in snake_case.
  priority: must
  stability: stable

- id: repo.examples.structure.aggregate_demo_directory
  statement: The aggregate category-oriented demo application shall live at `examples/demo/` as a first-class member of the example suite rather than being embedded inside another support package or a package directory.
  priority: must
  stability: stable

- id: repo.examples.structure.example_app_is_mix_project
  statement: Each example application shall be a standalone Mix project with its own `mix.exs`, `config/`, `lib/`, and `test/` areas so the example can be run and validated independently.
  priority: must
  stability: stable

- id: repo.examples.structure.local_package_dependencies
  statement: Each example application shall depend on `packages/unified-ui` and `packages/unified_iur` through local path dependencies and may depend on one or more supported runtime packages required for its launch targets, but no focused example application shall require an `examples/shared/` path dependency.
  priority: must
  stability: stable

- id: repo.examples.structure.example_screen_entrypoint
  statement: Each focused per-widget or per-construct example application shall expose one primary example-screen entrypoint that instantiates the common example shell and default theme/style baseline with one focused widget or construct demonstration plus minimal supporting content.
  priority: must
  stability: stable

- id: repo.examples.structure.narrow_demo_scope
  statement: Each focused per-widget or per-construct example application shall foreground one primary widget or construct and use any additional scaffolding widgets only to support understandable demonstration of that primary subject.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: repo.examples.structure.add_new_widget_app
  given: The ecosystem adds a new widget or display construct to the current example surface
  when: A maintainer extends the example suite
  then: The maintainer adds one new standalone Mix project under `examples/<widget_name>/`, wires the required package path dependencies, and adds any supported runtime-package dependencies needed for its launch surface
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples/structure.spec.md
  covers:
    - repo.examples.structure.self_contained_examples
    - repo.examples.structure.example_app_directory
    - repo.examples.structure.aggregate_demo_directory
    - repo.examples.structure.example_app_is_mix_project
    - repo.examples.structure.local_package_dependencies
    - repo.examples.structure.example_screen_entrypoint
    - repo.examples.structure.narrow_demo_scope
    - repo.examples.structure.add_new_widget_app
```
