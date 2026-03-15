# Example Apps DSL Template

This subject defines the shared DSL template, default theme, and default style
contract used by all standalone example applications.

## Related General Specs

- [Example Apps Suite](./package.spec.md)
- [UnifiedUi Package](../unified-ui/package.spec.md)
- [UnifiedUi DSL](../unified-ui/dsl.spec.md)
- [UnifiedUi Theming](../unified-ui/theming.spec.md)
- [UnifiedIUR Theming](../unified-iur/theming.spec.md)
- [LiveUi Runtime](../live_ui/runtime.spec.md)

```spec-meta
id: repo.examples.dsl_template
kind: subsystem
status: active
summary: Shared DSL template, default theme, and default style contract for the standalone example-app suite.
surface:
  - examples/shared/**
  - .spec/specs/examples/dsl_template.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: repo.examples.dsl_template.shared_unified_ui_template
  statement: `examples/shared/` shall define one shared `unified_ui` DSL template that all example applications use to author their example screen rather than each application inventing its own root DSL shape.
  priority: must
  stability: stable

- id: repo.examples.dsl_template.common_shell
  statement: The shared DSL template shall provide a common example shell containing a title area, a short description area, and one focused demonstration panel into which the primary widget or construct is inserted.
  priority: must
  stability: stable

- id: repo.examples.dsl_template.default_theme_identity
  statement: The shared support library shall define one default example theme identity named `:example_suite_default` that is applied across all example applications by default.
  priority: must
  stability: stable

- id: repo.examples.dsl_template.default_style_profile
  statement: The shared support library shall define one default style profile that applies a common surface tone, accent tone, panel border, spacing rhythm, and typography baseline across all example applications.
  priority: must
  stability: stable

- id: repo.examples.dsl_template.common_tokens_and_roles
  statement: The shared default theme shall expose common semantic roles and tokens for `surface`, `accent`, `success`, `warning`, `critical`, and `muted`, together with default panel and widget variants used consistently across the suite.
  priority: must
  stability: stable

- id: repo.examples.dsl_template.live_ui_render_path
  statement: The shared DSL template shall compile through `unified_ui` into canonical `UnifiedIUR` and then be rendered through `live_ui`, so each example application demonstrates the intended authored-to-runtime flow.
  priority: must
  stability: stable

- id: repo.examples.dsl_template.limited_local_overrides
  statement: Example applications may add local style or content overrides only when needed to clarify the focused widget or construct, and those overrides shall not replace the shared default theme or shared default shell structure.
  priority: must
  stability: stable
```

## Default Theme and Style Profile

The shared template is expected to provide these suite-wide defaults:

- Theme identity: `:example_suite_default`
- Shell variant: `:example_shell`
- Demo panel variant: `:example_panel`
- Default semantic tones: `surface`, `accent`, `success`, `warning`, `critical`, `muted`
- Default style baseline: readable body typography, medium gap spacing, medium border radius, light panel border, and one accent action treatment

## Scenarios

```spec-scenarios
- id: repo.examples.dsl_template.reuse_common_shell
  given: Two different example applications demonstrate different widgets such as `text_input` and `cluster_dashboard`
  when: Both examples are authored through the shared DSL template
  then: Both examples share the same default shell, default theme, and default style profile while differing only in the focused widget content and any necessary widget-specific inputs
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/examples/dsl_template.spec.md
  covers:
    - repo.examples.dsl_template.shared_unified_ui_template
    - repo.examples.dsl_template.common_shell
    - repo.examples.dsl_template.default_theme_identity
    - repo.examples.dsl_template.default_style_profile
    - repo.examples.dsl_template.common_tokens_and_roles
    - repo.examples.dsl_template.live_ui_render_path
    - repo.examples.dsl_template.limited_local_overrides
    - repo.examples.dsl_template.reuse_common_shell
```
