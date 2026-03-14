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
summary: Target package structure for `live_ui`, including native widget modules, LiveView runtime modules, canonical IUR rendering modules, and transport translation modules.
surface:
  - packages/live_ui
  - .spec/specs/live_ui/structure.spec.md
decisions:
  - repo.ecosystem.contract_model
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
  given: A maintainer adds a new native `live_ui` widget and its canonical IUR mapping
  when: The package evolves
  then: The change lands in native widget, IUR renderer, and transport layers without collapsing those concerns into one undifferentiated module boundary
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/live_ui/structure.spec.md
  covers:
    - live_ui.structure.mix_library_layout
    - live_ui.structure.native_widget_module_boundary
    - live_ui.structure.liveview_runtime_modules
    - live_ui.structure.hooks_are_isolated
    - live_ui.structure.transport_translation_modules
    - live_ui.structure.no_dsl_or_iur_authorship
    - live_ui.structure.add_native_widget_without_architecture_drift
```
