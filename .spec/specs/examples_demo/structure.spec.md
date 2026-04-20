# Examples Demo Application Structure

This subject defines the required directory, module, and authored-screen
structure for the aggregate demo application under `examples/demo/`.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Example Apps Structure](../examples/structure.spec.md)
- [Examples Demo Application](./package.spec.md)
- [UnifiedUi Structure](../unified-ui/structure.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)

```spec-meta
id: repo.examples_demo.structure
kind: subsystem
status: active
summary: Required package and authored-screen structure for the aggregate `examples/demo/` application.
surface:
  - examples/demo/**
  - .spec/specs/examples_demo/structure.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples_demo.structure.standalone_mix_application_with_default_browser_surface
  statement: `examples/demo/` shall be a standalone Mix application with its own `mix.exs`, `config/`, `lib/`, `priv/`, and `test/` areas so it can be run independently, including a browser-runnable launch surface under the default runtime.
  priority: must
  stability: stable

- id: repo.examples_demo.structure.local_package_dependencies
  statement: The aggregate demo application shall depend on `packages/unified-ui` and `packages/unified_iur` through local path dependencies and may depend on supported runtime packages required for its launch targets, but it shall not require an `examples/shared/` path dependency.
  priority: must
  stability: stable

- id: repo.examples_demo.structure.root_demo_screen
  statement: The application shall expose one root demo-screen entrypoint that owns the tabbed shell, the category-tab registry, and the shared default theme/style selection for the demo session.
  priority: must
  stability: stable

- id: repo.examples_demo.structure.category_fragments
  statement: Each category tab shall be authored through a dedicated `unified_ui` fragment or screen module so category-specific controls, descriptions, and signal stories remain maintainable and traceable.
  priority: must
  stability: stable

- id: repo.examples_demo.structure.category_metadata_registry
  statement: The application shall maintain one category metadata registry that maps each tab to its label, order, summary, and authored fragment module so the tab surface and maintainer tooling stay synchronized.
  priority: must
  stability: stable

- id: repo.examples_demo.structure.interaction_lab_separation
  statement: The dedicated signal-reactivity tab shall be implemented as its own authored fragment or screen module separate from the static category galleries so interaction stories can evolve without destabilizing the category catalog.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: repo.examples_demo.structure.add_new_category_or_control
  given: The ecosystem adds a new control family or the aggregate demo needs another category section
  when: A maintainer extends the aggregate demo application
  then: The maintainer adds or updates one category fragment and the shared category registry without restructuring the entire application shell
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples_demo/structure.spec.md
  covers:
    - repo.examples_demo.structure.standalone_mix_application_with_default_browser_surface
    - repo.examples_demo.structure.local_package_dependencies
    - repo.examples_demo.structure.root_demo_screen
    - repo.examples_demo.structure.category_fragments
    - repo.examples_demo.structure.category_metadata_registry
    - repo.examples_demo.structure.interaction_lab_separation
    - repo.examples_demo.structure.add_new_category_or_control
```
