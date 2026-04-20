# Examples Demo Application

This subject defines the repository-level contract for one aggregate demo
application under `examples/demo/` that showcases the ecosystem controls by
category and includes a dedicated signal-driven interaction tab.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [Example Apps Suite](../examples/package.spec.md)
- [Example Apps Catalog](../examples/catalog.spec.md)
- [Example Apps DSL Template](../examples/dsl_template.spec.md)
- [UnifiedUi Package](../unified-ui/package.spec.md)

```spec-meta
id: repo.examples_demo
kind: package
status: active
summary: Contract for the aggregate `examples/demo/` application that presents all control categories in one tabbed review surface and includes a dedicated signal-reactivity tab.
surface:
  - examples/demo/**
  - .spec/specs/examples_demo/package.spec.md
  - .spec/specs/examples_demo/structure.spec.md
  - .spec/specs/examples_demo/interface.spec.md
  - .spec/specs/examples_demo/theming.spec.md
  - .spec/specs/examples_demo/interaction_lab.spec.md
  - .spec/specs/examples_demo/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples_demo.aggregate_demo_application
  statement: The repository shall include one aggregate demo application at `examples/demo/` in addition to the per-widget example applications so reviewers can inspect the control families through one unified browser-runnable surface.
  priority: must
  stability: stable

- id: repo.examples_demo.runtime_selected_demo_application
  statement: The aggregate demo application shall be authored through `unified_ui`, compiled to canonical `UnifiedIUR`, and rendered through the runtime selected for the session, with `live_ui` as the default runtime when no command-line runtime argument or equivalent override is provided.
  priority: must
  stability: stable

- id: repo.examples_demo.category_oriented_review_surface
  statement: The aggregate demo application shall organize controls by category rather than by directory or implementation module so the review surface matches how maintainers and designers evaluate the control families.
  priority: must
  stability: stable

- id: repo.examples_demo.shared_theme_and_style_continuity
  statement: The aggregate demo application shall reuse the same shared example-suite default theme and style baseline used by the current `examples/button/` application so its presentation remains visually continuous with the per-widget example applications.
  priority: must
  stability: stable

- id: repo.examples_demo.signal_reactivity_demonstration
  statement: The aggregate demo application shall include a dedicated tab that demonstrates authored canonical signal flows where one control changes the visible state, styling, content, or behavior of other controls.
  priority: must
  stability: stable

- id: repo.examples_demo.subordinate_to_example_suite
  statement: The aggregate demo application shall complement the per-widget example suite rather than replace it, and its category/tab definitions shall remain traceable to the current example catalog and root ecosystem specs.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: repo.examples_demo.review_controls_by_category
  given: A maintainer wants to inspect the current ecosystem controls without opening dozens of separate example applications
  when: The maintainer opens `examples/demo/`
  then: The maintainer can switch between category tabs and review representative controls for each category through one shared application shell

- id: repo.examples_demo.observe_signal_reactivity
  given: A maintainer wants to verify that authored DSL interactions compile into meaningful runtime behavior
  when: The maintainer opens the dedicated signal-driven interaction tab and manipulates its controls
  then: The maintainer can see one or more other controls or panels react visibly to the emitted canonical signals
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples_demo/package.spec.md
  covers:
    - repo.examples_demo.aggregate_demo_application
    - repo.examples_demo.runtime_selected_demo_application
    - repo.examples_demo.category_oriented_review_surface
    - repo.examples_demo.shared_theme_and_style_continuity
    - repo.examples_demo.signal_reactivity_demonstration
    - repo.examples_demo.subordinate_to_example_suite
    - repo.examples_demo.review_controls_by_category
    - repo.examples_demo.observe_signal_reactivity
```
