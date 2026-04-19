# Self-Contained Example Blueprint

This guide defines the target local project shape for the self-contained
examples refactor. It is the Phase 1 section `1.2` contract for what each
example must own after the shared helper layer is removed.

## Required Local Runtime Modules

Every migrated example should own explicit runtime modules for:

- `:application`: Phoenix application startup tree
- `:endpoint`: endpoint configuration and browser runtime
- `:router`: browser route and mount path
- `:layouts`: root layout and browser shell HTML and CSS
- `:live`: LiveView entrypoint that renders the focused screen

## Required Local Authored Modules

Every migrated example should own explicit authored modules for:

- `:screen`: focused `unified_ui` screen and widget composition
- `:theme`: localized `:example_suite_default` theme definition
- `:style_profile`: localized shell, panel, title, summary, notes, and control
  style ids
- `:helpers`: local helper functions needed by the screen or LiveView

## Conditional Local Surfaces

Some examples need a little more than the baseline runtime and authored set:

- `:fixtures`: required when the example currently depends on
  `UnifiedExamples.Shared.Fixtures`
- `:interaction_support`: required when the example needs focused local
  interaction metadata or reviewer guidance
- `:documentation`: required when local run or review details are specific to
  that example project

## Abstraction Boundary Policy

The self-contained target state forbids repository-owned example scaffolding:

- no focused example path dependency on `examples/shared/`
- no `UnifiedExamples.Shared.App`
- no `UnifiedExamples.Shared.Template`
- no `example_panel/1` or `example_form_panel/1`

Framework macros remain allowed:

- `use Phoenix.LiveView`
- `use Phoenix.Component`
- `use UnifiedUi.Dsl`

## Validation Rules

Later phases should enforce at least these rules:

- `:no_examples_shared_path_dependency`
- `:no_repo_scaffolding_macros`
- `:explicit_runtime_modules_present`
- `:explicit_authored_modules_present`
- `:preserved_visual_baseline`

The structured implementation surface for this guide lives in
`UnifiedExamples.Shared.SelfContainedBlueprint.target_blueprint/0` and
`UnifiedExamples.Shared.SelfContainedBlueprint.abstraction_boundary_policy/0`.
