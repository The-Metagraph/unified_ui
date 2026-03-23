# ElmUi Structure

This subject defines the target internal package structure for creating the
`elm_ui` library as a split Phoenix-and-Elm runtime package.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [ElmUi Package](./package.spec.md)

```spec-meta
id: elm_ui.structure
kind: architecture
status: active
summary: Target package structure for `elm_ui`, including native widget modules, Phoenix server modules, Elm frontend modules, canonical IUR rendering modules, and transport translation modules.
surface:
  - packages/elm_ui
  - .spec/specs/elm_ui/structure.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.elm_ui_naming
```

## Requirements

```spec-requirements
- id: elm_ui.structure.mix_and_frontend_layout
  statement: The package shall be organized as a standard Mix library with package metadata, Phoenix server modules, Elm frontend modules, native widget modules, canonical IUR renderer modules, and tests under `packages/elm_ui`.
  priority: must
  stability: stable

- id: elm_ui.structure.server_frontend_boundary
  statement: The Phoenix server-side runtime and Elm frontend runtime shall be separated into clear module and asset boundaries so authoritative server behavior and client-side rendering concerns remain explicit.
  priority: must
  stability: stable

- id: elm_ui.structure.native_widget_module_boundary
  statement: Native widget and styling modules shall be distinct from canonical IUR interpretation modules so direct-use native APIs and canonical-renderer responsibilities remain clear.
  priority: must
  stability: stable

- id: elm_ui.structure.transport_translation_modules
  statement: The package shall provide dedicated transport translation modules that map between canonical boundary events and the package's native Phoenix-and-Elm interaction model.
  priority: must
  stability: stable

- id: elm_ui.structure.frontend_bridge_modules
  statement: Browser bridge, asset bootstrapping, and client-runtime entry modules shall be isolated from canonical model code so web transport concerns do not leak into the canonical IUR layer.
  priority: must
  stability: stable

- id: elm_ui.structure.no_dsl_or_iur_authorship
  statement: The package structure shall not introduce authored DSL ownership or canonical IUR ownership inside `elm_ui`; those concerns remain in `unified_ui` and `unified_iur`.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: elm_ui.structure.add_native_widget_without_architecture_drift
  given: A maintainer adds a new native `elm_ui` widget and its canonical IUR mapping
  when: The package evolves
  then: The change lands in native widget, IUR renderer, frontend, server, and transport layers without collapsing those concerns into one undifferentiated module boundary
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/elm_ui/structure.spec.md
  covers:
    - elm_ui.structure.mix_and_frontend_layout
    - elm_ui.structure.server_frontend_boundary
    - elm_ui.structure.native_widget_module_boundary
    - elm_ui.structure.transport_translation_modules
    - elm_ui.structure.frontend_bridge_modules
    - elm_ui.structure.no_dsl_or_iur_authorship
    - elm_ui.structure.add_native_widget_without_architecture_drift
```
