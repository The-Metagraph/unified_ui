# Example Apps Tooling

This subject defines the tooling and review surfaces expected for the standalone
example-app suite.

## Related General Specs

- [Example Apps Suite](./package.spec.md)
- [Example Apps Catalog](./catalog.spec.md)
- [Examples Demo Application](../examples_demo/package.spec.md)
- [LiveUi Tooling](../live_ui/tooling.spec.md)
- [Spec System](../spec_system.spec.md)

```spec-meta
id: repo.examples.tooling
kind: tooling
status: active
summary: Tooling, index, and validation surfaces for the standalone example-app suite under `examples/`.
surface:
  - examples/**
  - .spec/specs/examples/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples.tooling.index_surface
  statement: The example suite shall provide a top-level index under `examples/` that explains the shared support library, the common DSL template, and the per-widget example-app catalog.
  priority: must
  stability: stable

- id: repo.examples.tooling.independent_run_surface
  statement: Each example application shall be runnable independently so maintainers can review one widget-focused example without starting the entire suite.
  priority: must
  stability: stable

- id: repo.examples.tooling.shared_validation
  statement: The suite shall provide a repeatable validation workflow that checks whether each catalog entry still uses the shared DSL template and shared default theme/style profile.
  priority: must
  stability: stable

- id: repo.examples.tooling.catalog_traceability
  statement: Suite tooling shall allow maintainers to map any example application back to its primary widget or construct, family, and shared review metadata.
  priority: must
  stability: stable

- id: repo.examples.tooling.aggregate_demo_discovery
  statement: The example-suite tooling shall expose the aggregate demo application as the category-oriented review surface and distinguish it from the focused per-widget example applications.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: repo.examples.tooling.review_example_suite
  given: A maintainer wants to review the standalone example-app suite after adding or changing a widget
  when: The maintainer uses the suite index and validation workflow
  then: The maintainer can find the widget-focused app, run it independently, and verify that it still uses the shared DSL template and shared default theme/style
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples/tooling.spec.md
  covers:
    - repo.examples.tooling.index_surface
    - repo.examples.tooling.independent_run_surface
    - repo.examples.tooling.shared_validation
    - repo.examples.tooling.catalog_traceability
    - repo.examples.tooling.aggregate_demo_discovery
    - repo.examples.tooling.review_example_suite
```
