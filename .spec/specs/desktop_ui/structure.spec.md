# DesktopUi Structure

This subject defines the target internal package structure for creating the
`desktop_ui` library as a multiplatform SDL3-based desktop runtime package.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [DesktopUi Package](./package.spec.md)

```spec-meta
id: desktop_ui.structure
kind: architecture
status: active
summary: Target package structure for `desktop_ui`, including native widget modules, SDL3 runtime modules, platform-specific integration modules, canonical IUR rendering modules, and transport translation modules.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop_ui/structure.spec.md
decisions:
  - repo.ecosystem.contract_model
  - desktop_ui.runtime.screen_navigation
```

## Requirements

```spec-requirements
- id: desktop_ui.structure.mix_library_layout
  statement: The package shall be organized as a standard Mix library with package metadata, native widget modules, shared SDL3 runtime modules, platform integration modules, canonical IUR renderer modules, and tests under `packages/desktop_ui`.
  priority: must
  stability: stable

- id: desktop_ui.structure.shared_runtime_vs_platform_modules
  statement: Shared desktop runtime logic, including SDL3 callback lifecycle management, retained rendering preparation, and native display coordination, shall be separated from Windows-, macOS-, and Linux-specific integration modules so platform divergence does not leak into every part of the package.
  priority: must
  stability: stable

- id: desktop_ui.structure.sdl3_adapter_modules
  statement: The package shall provide explicit SDL3-facing adapter modules for application lifecycle ownership, native window coordination, render-plan presentation, event intake, and companion-resource preparation so semantic runtime modules do not collapse into backend-specific code.
  priority: must
  stability: stable

- id: desktop_ui.structure.native_widget_module_boundary
  statement: Native widget and styling modules shall be distinct from canonical IUR interpretation modules so direct-use native APIs and canonical-renderer responsibilities remain clear.
  priority: must
  stability: stable

- id: desktop_ui.structure.transport_translation_modules
  statement: The package shall provide dedicated transport translation modules that map between canonical boundary events and the package's native desktop interaction model.
  priority: must
  stability: stable

- id: desktop_ui.structure.platform_artifact_modules
  statement: The package shall isolate artifact-building and packaging flows from runtime widget logic so Windows, macOS, and Linux artifact pipelines can diverge without destabilizing runtime behavior.
  priority: must
  stability: stable

- id: desktop_ui.structure.no_dsl_or_iur_authorship
  statement: The package structure shall not introduce authored DSL ownership or canonical IUR ownership inside `desktop_ui`; those concerns remain in `unified_ui` and `unified_iur`.
  priority: must
  stability: stable

- id: desktop_ui.structure.navigation_modules
  statement: The package shall provide dedicated navigation modules for screen-to-screen navigation, including a navigation controller GenServer, a screen registry, and navigation event routing integrated with the transport layer.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: desktop_ui.structure.add_platform_support_without_runtime_drift
  covers:
    - desktop_ui.structure.mix_library_layout
    - desktop_ui.structure.shared_runtime_vs_platform_modules
    - desktop_ui.structure.sdl3_adapter_modules
    - desktop_ui.structure.native_widget_module_boundary
    - desktop_ui.structure.transport_translation_modules
    - desktop_ui.structure.platform_artifact_modules
    - desktop_ui.structure.no_dsl_or_iur_authorship
    - desktop_ui.structure.navigation_modules
  given:
    - A maintainer improves Windows, macOS, or Linux integration for `desktop_ui`
  when:
    - The package evolves
  then:
    - The change lands in platform integration or artifact modules without collapsing shared widget, runtime, or IUR renderer concerns into platform-specific code
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop_ui/structure.spec.md
  covers:
    - desktop_ui.structure.mix_library_layout
    - desktop_ui.structure.shared_runtime_vs_platform_modules
    - desktop_ui.structure.sdl3_adapter_modules
    - desktop_ui.structure.native_widget_module_boundary
    - desktop_ui.structure.transport_translation_modules
    - desktop_ui.structure.platform_artifact_modules
    - desktop_ui.structure.no_dsl_or_iur_authorship
    - desktop_ui.structure.navigation_modules
    - desktop_ui.structure.add_platform_support_without_runtime_drift

- kind: source_file
  target: .spec/decisions/desktop_ui/desktop_ui.runtime.screen_navigation.md
  covers:
    - desktop_ui.structure.navigation_modules
```
