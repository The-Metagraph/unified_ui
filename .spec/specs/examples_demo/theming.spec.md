# Examples Demo Application Theming

This subject defines the theming and styling contract for the aggregate demo
application under `examples/demo/`, reusing the same visual treatment as the
current `examples/button/` application.

## Related General Specs

- [Examples Demo Application](./package.spec.md)
- [Examples Demo Application Interface](./interface.spec.md)
- [Example Apps DSL Template](../examples/dsl_template.spec.md)
- [UnifiedUi Theming](../unified-ui/theming.spec.md)
- [LiveUi Runtime](../live_ui/runtime.spec.md)

```spec-meta
id: repo.examples_demo.theming
kind: subsystem
status: active
summary: Theming and styling contract for the aggregate `examples/demo/` application, aligned with the current `examples/button/` example.
surface:
  - examples/demo/**
  - .spec/specs/examples_demo/theming.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples_demo.theming.same_theme_identity_as_button_example
  statement: The aggregate demo application shall use the same shared theme identity as the current `examples/button/` example, namely `:example_suite_default`.
  priority: must
  stability: stable

- id: repo.examples_demo.theming.same_shared_style_profile_as_button_example
  statement: The aggregate demo application shall use the same shared style profile as the current `examples/button/` example rather than introducing a separate demo-only baseline.
  priority: must
  stability: stable

- id: repo.examples_demo.theming.same_shell_and_panel_treatment
  statement: The aggregate demo application shall reuse the shared shell and panel style references used by the current button example stack, including `:example_shell`, `:example_panel`, `:example_title`, `:example_summary`, and `:example_notes`.
  priority: must
  stability: stable

- id: repo.examples_demo.theming.same_accent_action_treatment
  statement: Primary actions in the aggregate demo application, including tab-selection affordances and interaction-story triggers, shall reuse the same accent action treatment used by the current button example, including `:example_primary_button`, `tone(:accent)`, and `variant(:solid)` unless a control family requires a different canonical shape.
  priority: must
  stability: stable

- id: repo.examples_demo.theming.same_input_treatment
  statement: Input-oriented controls in the aggregate demo application shall reuse the same shared input treatment used by the current button and text-input example stack, including `:example_primary_input` where applicable.
  priority: must
  stability: stable

- id: repo.examples_demo.theming.same_shared_liveview_shell
  statement: The aggregate demo application shall reuse the same shared LiveView shell styling direction used by the current button example application, including the dark surface treatment, mono typography baseline, accent-led highlights, layered card surfaces, and reviewer-facing signal panels provided by `examples/shared/`.
  priority: must
  stability: stable

- id: repo.examples_demo.theming.local_overrides_only_for_category_clarity
  statement: The aggregate demo application may add local style refinements only when necessary to keep category tabs or interaction stories understandable, and those refinements shall remain subordinate to the shared button-example theme and style profile.
  priority: must
  stability: stable
```

## Styling Baseline

The aggregate demo application shall inherit this shared styling baseline from
the current button example implementation:

- Theme identity: `:example_suite_default`
- Shell style refs: `:example_shell`, `:example_panel`
- Text style refs: `:example_title`, `:example_summary`, `:example_notes`
- Primary action style ref: `:example_primary_button`
- Primary input style ref: `:example_primary_input`
- Visual direction: dark surfaces, bright accent highlights, mono typography, elevated card panels, and reviewer-friendly interaction/signal panels

## Scenarios

```spec-scenarios
- id: repo.examples_demo.theming.compare_demo_to_button_example
  given: A reviewer opens `examples/demo/` and `examples/button/` side by side
  when: The reviewer compares shell, panel, button, and input styling
  then: The reviewer sees the same theme identity, the same baseline style profile, and the same overall visual language across both applications
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples_demo/theming.spec.md
  covers:
    - repo.examples_demo.theming.same_theme_identity_as_button_example
    - repo.examples_demo.theming.same_shared_style_profile_as_button_example
    - repo.examples_demo.theming.same_shell_and_panel_treatment
    - repo.examples_demo.theming.same_accent_action_treatment
    - repo.examples_demo.theming.same_input_treatment
    - repo.examples_demo.theming.same_shared_liveview_shell
    - repo.examples_demo.theming.local_overrides_only_for_category_clarity
    - repo.examples_demo.theming.compare_demo_to_button_example
```
