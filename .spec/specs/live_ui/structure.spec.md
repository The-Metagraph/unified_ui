# LiveUi Structure

This subject defines the target internal package structure for creating the
`live_ui` library as a LiveView-native runtime package.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [LiveUi Package](./package.spec.md)

```spec-meta
id: live_ui.structure
kind: architecture
status: active
summary: Target package structure for `live_ui`, including widget LiveComponent modules, LiveView runtime modules, canonical IUR rendering modules, and transport translation modules.
surface:
  - packages/live_ui
  - .spec/specs/live_ui/structure.spec.md
decisions:
  - repo.ecosystem.contract_model
  - live_ui.runtime.widget_livecomponents
```

## Requirements

```spec-requirements
- id: live_ui.structure.mix_library_layout
  statement: The package shall be organized as a standard Mix library with package metadata, native widget modules, LiveView runtime modules, canonical IUR renderer modules, browser-bridge modules, and tests under `packages/live_ui`.
  priority: must
  stability: stable

- id: live_ui.structure.native_widget_module_boundary
  statement: Native widget and styling modules shall be distinct from canonical IUR interpretation modules so direct-use native APIs and canonical-renderer responsibilities remain clear.
  priority: must
  stability: stable

- id: live_ui.structure.liveview_runtime_modules
  statement: The package shall contain dedicated LiveView runtime modules for screen mounting, widget composition, assigns and state management, event handling, and lifecycle orchestration.
  priority: must
  stability: stable

- id: live_ui.structure.widget_livecomponent_modules
  statement: The package structure shall include dedicated Phoenix LiveComponent-oriented widget modules for the native widget surface so screens and canonical rendering both target explicit widget component boundaries.
  priority: must
  stability: stable

- id: live_ui.structure.screen_and_renderer_target_widget_boundaries
  statement: Screen modules and canonical renderer modules shall compose widget component instances through explicit widget boundaries rather than bypassing them with ad hoc HTML generation.
  priority: must
  stability: stable

- id: live_ui.structure.helper_wrappers_remain_thin
  statement: Any function-component or helper wrappers kept for ergonomic authoring shall remain thin facades over widget component modules rather than becoming an alternate implementation architecture.
  priority: must
  stability: stable

- id: live_ui.structure.hooks_are_isolated
  statement: Any JavaScript hooks required by the runtime shall be isolated to a clearly bounded browser-bridge layer rather than scattered across native widget or canonical IUR model code.
  priority: must
  stability: stable

- id: live_ui.structure.transport_translation_modules
  statement: The package shall provide dedicated transport translation modules that map between canonical boundary events and the package's native LiveView interaction model.
  priority: must
  stability: stable

- id: live_ui.structure.no_dsl_or_iur_authorship
  statement: The package structure shall not introduce authored DSL ownership or canonical IUR ownership inside `live_ui`; those concerns remain in `unified_ui` and `unified_iur`.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: live_ui.structure.add_native_widget_without_architecture_drift
  covers:
    - live_ui.structure.mix_library_layout
    - live_ui.structure.native_widget_module_boundary
    - live_ui.structure.liveview_runtime_modules
    - live_ui.structure.widget_livecomponent_modules
    - live_ui.structure.screen_and_renderer_target_widget_boundaries
    - live_ui.structure.helper_wrappers_remain_thin
    - live_ui.structure.hooks_are_isolated
    - live_ui.structure.transport_translation_modules
    - live_ui.structure.no_dsl_or_iur_authorship
  given:
    - A maintainer adds a new native `live_ui` widget and its canonical IUR mapping
  when:
    - The package evolves
  then:
    - The change lands in native widget, IUR renderer, and transport layers without collapsing those concerns into one undifferentiated module boundary

- id: live_ui.structure.add_widget_component_without_bypassing_boundary
  covers:
    - live_ui.structure.mix_library_layout
    - live_ui.structure.native_widget_module_boundary
    - live_ui.structure.liveview_runtime_modules
    - live_ui.structure.widget_livecomponent_modules
    - live_ui.structure.screen_and_renderer_target_widget_boundaries
    - live_ui.structure.helper_wrappers_remain_thin
    - live_ui.structure.hooks_are_isolated
    - live_ui.structure.transport_translation_modules
    - live_ui.structure.no_dsl_or_iur_authorship
  given:
    - A maintainer adds a new `live_ui` widget
  when:
    - The package evolves
  then:
    - The maintainer adds or updates an explicit widget component module and routes native and canonical entry points through that same boundary
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live_ui/structure.spec.md
  covers:
    - live_ui.structure.mix_library_layout
    - live_ui.structure.native_widget_module_boundary
    - live_ui.structure.liveview_runtime_modules
    - live_ui.structure.widget_livecomponent_modules
    - live_ui.structure.screen_and_renderer_target_widget_boundaries
    - live_ui.structure.helper_wrappers_remain_thin
    - live_ui.structure.hooks_are_isolated
    - live_ui.structure.transport_translation_modules
    - live_ui.structure.no_dsl_or_iur_authorship
    - live_ui.structure.add_native_widget_without_architecture_drift
    - live_ui.structure.add_widget_component_without_bypassing_boundary
```
