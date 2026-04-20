# Examples Demo Application Tooling

This subject defines the documentation, launcher, and validation expectations
for the aggregate demo application under `examples/demo/`.

## Related General Specs

- [Examples Demo Application](./package.spec.md)
- [Examples Demo Application Interface](./interface.spec.md)
- [Examples Demo Application Interaction Lab](./interaction_lab.spec.md)
- [Example Apps Tooling](../examples/tooling.spec.md)
- [Spec System](../spec_system.spec.md)

```spec-meta
id: repo.examples_demo.tooling
kind: tooling
status: active
summary: Tooling, documentation, and validation contract for the aggregate `examples/demo/` application.
surface:
  - examples/demo/**
  - .spec/specs/examples_demo/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples_demo.tooling.independent_launch_surface
  statement: The aggregate demo application shall be independently runnable through its default browser-runnable launch surface and also discoverable through the suite launcher workflow, with runtime selection available and `live_ui` used when no runtime is specified.
  priority: must
  stability: stable

- id: repo.examples_demo.tooling.index_presence
  statement: The root examples index and suite tooling shall identify the aggregate demo application as the category-oriented review surface distinct from the per-widget example applications.
  priority: must
  stability: stable

- id: repo.examples_demo.tooling.tab_and_story_validation
  statement: Validation tooling shall confirm that the aggregate demo application still provides the required category tabs, the dedicated signal lab, and the minimum interaction story inventory defined by this spec set.
  priority: must
  stability: stable

- id: repo.examples_demo.tooling.documentation_surface
  statement: The aggregate demo application shall document its category tabs, the interaction lab purpose, and how reviewers should use it alongside the per-widget example applications.
  priority: must
  stability: stable

- id: repo.examples_demo.tooling.traceable_review_metadata
  statement: The aggregate demo application shall expose review metadata that maps each category tab and interaction story back to the example-suite catalog or canonical control families so maintainers can audit coverage drift.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: repo.examples_demo.tooling.launch_demo_for_review
  given: A reviewer wants one browser-runnable overview of the control families and signal-reactivity stories
  when: The reviewer uses the examples index or suite launcher tooling
  then: The reviewer can find, launch, optionally override the runtime, and validate the aggregate demo application without manually discovering its internal structure
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples_demo/tooling.spec.md
  covers:
    - repo.examples_demo.tooling.independent_launch_surface
    - repo.examples_demo.tooling.index_presence
    - repo.examples_demo.tooling.tab_and_story_validation
    - repo.examples_demo.tooling.documentation_surface
    - repo.examples_demo.tooling.traceable_review_metadata
    - repo.examples_demo.tooling.launch_demo_for_review
```
