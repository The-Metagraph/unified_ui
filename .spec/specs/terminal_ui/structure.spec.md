# TerminalUi Structure

This subject defines the target internal package structure for creating the
`terminal_ui` library as a `term_ui`-backed terminal runtime package.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [TerminalUi Package](./package.spec.md)

```spec-meta
id: terminal_ui.structure
kind: architecture
status: active
summary: Target package structure for `terminal_ui`, including native widget modules, terminal runtime adapter modules, capability and degradation modules, canonical IUR rendering modules, and transport translation modules.
surface:
  - packages/terminal_ui
  - .spec/specs/terminal_ui/structure.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: terminal_ui.structure.mix_library_layout
  statement: The package shall be organized as a standard Mix library with package metadata, native widget modules, shared terminal runtime modules, capability and degradation modules, canonical IUR renderer modules, and tests under `packages/terminal_ui`.
  priority: must
  stability: stable

- id: terminal_ui.structure.term_ui_adapter_boundary
  statement: Shared `term_ui` adapter logic shall be separated from `terminal_ui` package-facing widget modules so backend integration does not leak into every public API surface.
  priority: must
  stability: stable

- id: terminal_ui.structure.native_widget_module_boundary
  statement: Native widget and styling modules shall be distinct from canonical IUR interpretation modules so direct-use native APIs and canonical-renderer responsibilities remain clear.
  priority: must
  stability: stable

- id: terminal_ui.structure.transport_translation_modules
  statement: The package shall provide dedicated transport translation modules that map between canonical boundary events and the package's native terminal interaction model.
  priority: must
  stability: stable

- id: terminal_ui.structure.capability_and_degradation_modules
  statement: Capability detection, backend selection, charset fallback, color degradation, and keyboard-alternative policies shall be isolated from canonical model code so terminal limits remain explicit and reviewable.
  priority: must
  stability: stable

- id: terminal_ui.structure.no_dsl_or_iur_authorship
  statement: The package structure shall not introduce authored DSL ownership or canonical IUR ownership inside `terminal_ui`; those concerns remain in `unified_ui` and `unified_iur`.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: terminal_ui.structure.add_terminal_widget_without_architecture_drift
  given: A maintainer adds a new native `terminal_ui` widget and its canonical IUR mapping
  when: The package evolves
  then: The change lands in native widget, runtime adapter, capability, renderer, and transport layers without collapsing those concerns into one undifferentiated module boundary
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/terminal_ui/structure.spec.md
  covers:
    - terminal_ui.structure.mix_library_layout
    - terminal_ui.structure.term_ui_adapter_boundary
    - terminal_ui.structure.native_widget_module_boundary
    - terminal_ui.structure.transport_translation_modules
    - terminal_ui.structure.capability_and_degradation_modules
    - terminal_ui.structure.no_dsl_or_iur_authorship
    - terminal_ui.structure.add_terminal_widget_without_architecture_drift
```
