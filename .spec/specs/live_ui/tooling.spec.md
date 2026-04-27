# LiveUi Tooling

This subject defines the package tooling and reference surfaces needed to build,
inspect, and validate `live_ui` as a runtime library.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Spec System](../spec_system.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [LiveUi Package](./package.spec.md)

```spec-meta
id: live_ui.tooling
kind: tooling
status: active
summary: Target tooling contract for documenting, previewing, validating, and evolving the `live_ui` package.
surface:
  - packages/live_ui
  - .spec/specs/live_ui/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
  - live_ui.tooling.focused_example_alignment
```

## Requirements

```spec-requirements
- id: live_ui.tooling.reference_examples
  statement: The package shall include maintained widget-focused reference examples aligned one-for-one with the repository `examples/` inventory, using direct native `live_ui` widgets and runtime entrypoints as the package-specialized example surface while preserving canonical `unified_iur` review paths against those same example identities where package validation requires them.
  priority: must
  stability: stable

- id: live_ui.tooling.preview_and_inspection
  statement: The package shall provide tooling or helper workflows that let maintainers inspect native widget rendering, canonical IUR rendering, styling behavior, and boundary event translation through the same focused example ids rather than through a separate package-local demo or divergent comparison catalog.
  priority: must
  stability: stable

- id: live_ui.tooling.validation_workflow
  statement: The package shall provide a repeatable validation workflow for canonical IUR coverage, native widget coverage, server-authoritative runtime behavior, and boundary event translation.
  priority: must
  stability: stable

- id: live_ui.tooling.documentation_surface
  statement: The package shall document its native widget surface, LiveView runtime model, canonical IUR renderer entry point, and boundary event translation model as part of package development.
  priority: must
  stability: stable

- id: live_ui.tooling.no_package_local_demo_workbench
  statement: The package shall not maintain an aggregate package-local demo workbench or second widget catalog that diverges from the repository example suite; maintainer review shall begin from focused example applications aligned with the repository inventory.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: live_ui.tooling_compare_native_and_iur_paths
  given: A maintainer adds a new widget family or styling attribute to `live_ui`
  when: The maintainer runs package tooling or reference workflows
  then: The maintainer can review the aligned focused example for that widget, compare direct native rendering and canonical IUR rendering for the same example identity, and avoid creating a second package-only demo surface
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live_ui/tooling.spec.md
  covers:
    - live_ui.tooling.reference_examples
    - live_ui.tooling.preview_and_inspection
    - live_ui.tooling.validation_workflow
    - live_ui.tooling.documentation_surface
    - live_ui.tooling.no_package_local_demo_workbench
    - live_ui.tooling_compare_native_and_iur_paths
```
