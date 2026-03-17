# Example Apps Structure

This subject defines the required directory and package structure for the
standalone example applications under `examples/`.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Example Apps Suite](./package.spec.md)
- [Examples Demo Application](../examples_demo/package.spec.md)
- [UnifiedUi Structure](../unified-ui/structure.spec.md)
- [LiveUi Structure](../live_ui/structure.spec.md)

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
- id: repo.examples.structure.shared_library_layout
  statement: `examples/shared/` shall be a shared support library package that can be referenced by every example application through a local path dependency.
  priority: must
  stability: stable

- id: repo.examples.structure.example_app_directory
  statement: Each focused per-widget or per-construct example application shall live in its own subdirectory at `examples/<widget_name>/`, where `<widget_name>` matches the primary widget or construct name in snake_case.
  priority: must
  stability: stable

- id: repo.examples.structure.aggregate_demo_directory
  statement: The aggregate category-oriented demo application shall live at `examples/demo/` as a first-class member of the example suite rather than being embedded inside `examples/shared/` or a package directory.
  priority: must
  stability: stable

- id: repo.examples.structure.example_app_is_mix_project
  statement: Each example application shall be a standalone Mix project with its own `mix.exs`, `config/`, `lib/`, and `test/` areas so the example can be run and validated independently.
  priority: must
  stability: stable

- id: repo.examples.structure.shared_dependencies
  statement: Each example application shall depend on `examples/shared`, `packages/unified-ui`, `packages/unified_iur`, and `packages/live_ui` through local path dependencies.
  priority: must
  stability: stable

- id: repo.examples.structure.example_screen_entrypoint
  statement: Each focused per-widget or per-construct example application shall expose one primary example-screen entrypoint that instantiates the shared DSL template with one focused widget or construct demonstration plus minimal supporting content.
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
  given: The ecosystem adds a new widget or display construct to the supported `live_ui` surface
  when: A maintainer extends the example suite
  then: The maintainer adds one new standalone Mix project under `examples/<widget_name>/` and wires it to the shared support library plus the package path dependencies
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples/structure.spec.md
  covers:
    - repo.examples.structure.shared_library_layout
    - repo.examples.structure.example_app_directory
    - repo.examples.structure.aggregate_demo_directory
    - repo.examples.structure.example_app_is_mix_project
    - repo.examples.structure.shared_dependencies
    - repo.examples.structure.example_screen_entrypoint
    - repo.examples.structure.narrow_demo_scope
    - repo.examples.structure.add_new_widget_app
```
