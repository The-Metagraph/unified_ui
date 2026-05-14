# Example Apps Tooling

This subject defines the tooling and review surfaces expected for the standalone
example-app suite.

## Related General Specs

- [Example Apps Suite](./package.spec.md)
- [Example Apps Catalog](./catalog.spec.md)
- [Spec System](../spec_system.spec.md)

```spec-meta
id: repo.examples.tooling
kind: tooling
status: active
summary: Tooling, index, launch, and validation surfaces for the standalone example-app suite under `examples/`.
surface:
  - examples/**
  - .spec/specs/examples/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples.tooling.index_surface
  statement: The example suite shall provide a top-level index under `examples/` that explains the common example-shell contract, the suite default theme/style baseline, the supported runtime targets, the default runtime behavior, and the focused per-widget example-app catalog.
  priority: must
  stability: stable

- id: repo.examples.tooling.independent_run_surface
  statement: Each example application shall be runnable independently so maintainers can review one widget-focused example without starting the entire suite.
  priority: must
  stability: stable

- id: repo.examples.tooling.runtime_selection_surface
  statement: The suite shall provide a documented launch surface that accepts runtime selection through a command-line argument or equivalent override for `live_ui`, `desktop_ui`, `elm_ui`, and `terminal_ui`, shall default to `live_ui` when no runtime is specified, and may satisfy non-browser runtimes through review-oriented runtime output when a standalone launcher is not yet maintained.
  priority: must
  stability: stable

- id: repo.examples.tooling.shared_validation
  statement: The suite shall provide a repeatable validation workflow that checks whether each catalog entry still preserves the common example-shell contract, the suite default theme/style baseline, and the documented runtime-selection contract.
  priority: must
  stability: stable

- id: repo.examples.tooling.catalog_traceability
  statement: Suite tooling shall allow maintainers to map any example application back to its primary widget or construct, family, and shared review metadata.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: repo.examples.tooling.review_example_suite
  covers:
    - repo.examples.tooling.index_surface
    - repo.examples.tooling.independent_run_surface
    - repo.examples.tooling.runtime_selection_surface
    - repo.examples.tooling.shared_validation
  given:
    - A maintainer wants to review the standalone example-app suite after adding or changing a widget
  when:
    - The maintainer uses the suite index and validation workflow
  then:
    - The maintainer can find the widget-focused app, run it independently through the chosen maintained runtime target, and verify that it still preserves the common example-shell contract, the suite default theme/style baseline, and the default runtime behavior
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples/tooling.spec.md
  covers:
    - repo.examples.tooling.index_surface
    - repo.examples.tooling.independent_run_surface
    - repo.examples.tooling.runtime_selection_surface
    - repo.examples.tooling.shared_validation
    - repo.examples.tooling.catalog_traceability
    - repo.examples.tooling.review_example_suite
```
