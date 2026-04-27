# LiveUi Package

This subject defines the target package-level contract for creating the
`packages/live_ui` library as the Phoenix LiveView runtime library of the
ecosystem.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)

```spec-meta
id: live_ui.package
kind: package
status: active
summary: Target contract for creating `packages/live_ui` as the LiveView-native runtime library and canonical IUR renderer for the ecosystem.
surface:
  - packages/live_ui
  - .spec/specs/live_ui/package.spec.md
  - .spec/specs/live_ui/structure.spec.md
  - .spec/specs/live_ui/native_widgets.spec.md
  - .spec/specs/live_ui/runtime.spec.md
  - .spec/specs/live_ui/iur_renderer.spec.md
  - .spec/specs/live_ui/transport.spec.md
  - .spec/specs/live_ui/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
  - live_ui.runtime.widget_livecomponents
  - live_ui.tooling.focused_example_alignment
```

## Requirements

```spec-requirements
- id: live_ui.package.library_identity
  statement: `packages/live_ui` shall publish the `:live_ui` Elixir library and use the `LiveUi` namespace as the canonical Phoenix LiveView runtime-library package of the ecosystem.
  priority: must
  stability: stable

- id: live_ui.package.native_runtime_library
  statement: The package shall be a native widget and signal library that is usable directly through its own LiveView-oriented widget surface and not only through canonical IUR rendering.
  priority: must
  stability: stable

- id: live_ui.package.widget_component_library_surface
  statement: The direct-use native `live_ui` library surface shall be a mountable Phoenix LiveComponent-oriented widget library for use inside LiveView screens, not only a collection of stateless HTML helpers.
  priority: must
  stability: stable

- id: live_ui.package.iur_renderer_entrypoint
  statement: The package shall also include a renderer entry point that loads canonical `unified_iur` and realizes it through `live_ui` native widgets, layering, styling, and interaction behavior.
  priority: must
  stability: stable

- id: live_ui.package.not_dsl_or_iur_owner
  statement: The package shall not own the authored DSL boundary or the canonical IUR data model; it consumes canonical IUR and translates canonical event meaning at the runtime boundary.
  priority: must
  stability: stable

- id: live_ui.package.traceable_to_root_specs
  statement: The `live_ui` package subjects shall link back to the repository-level architecture, runtime-library, and signal transport subjects so package design remains subordinate to the root ecosystem contract.
  priority: must
  stability: stable

- id: live_ui.package.focused_example_specialization
  statement: The package review and maintainer example surface shall specialize the repository widget-focused example suite for direct native `live_ui` usage, aligning package example identities with the repository example inventory rather than maintaining a divergent package-local demo or unrelated example catalog.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: live_ui.package.direct_use_and_iur_use
  given: A developer wants to use `live_ui` directly in a Phoenix LiveView application or render canonical `unified_iur`
  when: The developer integrates the package
  then: The package supports both direct native use and canonical IUR rendering without requiring authored DSL modules
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live_ui/package.spec.md
  covers:
    - live_ui.package.library_identity
    - live_ui.package.native_runtime_library
    - live_ui.package.widget_component_library_surface
    - live_ui.package.iur_renderer_entrypoint
    - live_ui.package.not_dsl_or_iur_owner
    - live_ui.package.traceable_to_root_specs
    - live_ui.package.focused_example_specialization
    - live_ui.package.direct_use_and_iur_use
```
