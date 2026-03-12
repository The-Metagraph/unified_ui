# Package

UnifiedIUR is a pure-data Intermediate UI Representation layer for shared UI contracts.

```spec-meta
id: unified_iur.package
kind: package
status: active
summary: Package-level contract for platform-agnostic UI data structures and traversal APIs.
surface:
  - README.md
  - mix.exs
  - lib/unified_iur.ex
  - lib/unified_iur/widgets.ex
  - lib/unified_iur/layouts.ex
  - lib/unified_iur/style.ex
  - lib/unified_iur/element.ex
  - lib/unified_iur/widgets/dialog_feedback.ex
  - lib/unified_iur/widgets/input_widgets.ex
```

## Requirements

```spec-requirements
- id: unified_iur.package.platform_agnostic_data_contract
  statement: The package shall represent user interfaces as immutable Elixir structs and protocol implementations without embedding renderer-specific runtime logic.
  priority: must
  stability: stable

- id: unified_iur.package.shared_ui_surface
  statement: The package shall expose widgets, layouts, style, and element traversal modules as a shared UI contract for upstream DSLs and downstream platform renderers.
  priority: must
  stability: stable

- id: unified_iur.package.spec_led_tooling_available
  statement: The package shall include Spec Led tooling in dev and test dependencies so local and CI spec verification tasks can run.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: command
  target: mix test
  execute: true
  covers:
    - unified_iur.package.platform_agnostic_data_contract
    - unified_iur.package.shared_ui_surface
    - unified_iur.package.spec_led_tooling_available
```
