# Self-Contained Refactor Inventory

This guide records the current shared-helper surface that Phase 1 must replace
before the example suite can become fully self-contained.

## Shared Helper Categories

The current shared layer is grouped into four practical categories:

- app bootstrap: `UnifiedExamples.Shared.App`,
  `UnifiedExamples.Shared.Loader`, `UnifiedExamples.Shared.Runtime`, and
  `UnifiedExamples.Shared.RuntimeAdapter`
- screen authoring: `UnifiedExamples.Shared.Template`,
  `UnifiedExamples.Shared.Fixtures`, and
  `UnifiedExamples.Shared.InteractionDemo`
- docs and validation: `UnifiedExamples.Shared.AppReadme`,
  `UnifiedExamples.Shared.Documentation`,
  `UnifiedExamples.Shared.Maintenance`,
  `UnifiedExamples.Shared.ReleaseReadiness`,
  `UnifiedExamples.Shared.Reporting`, `UnifiedExamples.Shared.Tooling`,
  `UnifiedExamples.Shared.Traceability`, and
  `UnifiedExamples.Shared.Validation`
- suite catalog: `UnifiedExamples.Shared` and
  `UnifiedExamples.Shared.Catalog`

## Current Example Usage

The current suite still uses repository-owned helper surfaces in the focused
example projects:

- every example entrypoint uses `UnifiedExamples.Shared.App`
- every current screen module uses `UnifiedExamples.Shared.Template`
- focused screen composition still relies on `example_panel/1` or
  `example_form_panel/1`
- advanced or fixture-heavy examples still alias
  `UnifiedExamples.Shared.Fixtures`
- maintainers currently inspect this state through
  `UnifiedExamples.Shared.SelfContainedBlueprint.inventory/0`

## Browser Shell Baseline

The refactor must preserve the current browser shell emitted by
`examples/shared/lib/unified_examples/shared/app.ex`, including these class
anchors:

- `.example-app-shell`
- `.example-app-header`
- `.example-app-runtime`
- `.example-app-header-top`
- `.example-app-kicker`
- `.example-app-widget`
- `.example-app-title`
- `.example-app-summary`
- `.example-app-notes`

## Theme and Style Baseline

The refactor must preserve the current template baseline emitted by
`examples/shared/lib/unified_examples/shared/template.ex`:

- default theme id: `:example_suite_default`
- semantic roles: `:surface`, `:accent`, `:success`, `:warning`,
  `:critical`, `:muted`, `:foreground`
- theme tokens: `:shell_surface`, `:panel_surface`, `:accent_action`,
  `:input_surface`
- component style ids: `:example_shell`, `:example_panel`,
  `:example_form_shell`, `:example_title`, `:example_summary`,
  `:example_notes`, `:example_primary_button`, `:example_primary_input`
- shared notes baseline: `This example uses the shared suite template, theme,
  and style profile.`

## Phase 1 Outcome

Section `1.1` is complete when the suite has one durable inventory surface that
maintainers can consult before moving any example onto local modules. The
current implementation surface for that inventory is
`UnifiedExamples.Shared.SelfContainedBlueprint.inventory/0` together with this
guide.
