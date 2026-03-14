# DesktopUi Package

This subject defines the target package-level contract for creating the
`packages/desktop_ui` library as the native desktop runtime library of the
ecosystem.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)

```spec-meta
id: desktop_ui.package
kind: package
status: active
summary: Target contract for creating `packages/desktop_ui` as the multiplatform desktop runtime library and canonical IUR renderer for the ecosystem.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop_ui/package.spec.md
  - .spec/specs/desktop_ui/structure.spec.md
  - .spec/specs/desktop_ui/native_widgets.spec.md
  - .spec/specs/desktop_ui/runtime.spec.md
  - .spec/specs/desktop_ui/iur_renderer.spec.md
  - .spec/specs/desktop_ui/transport.spec.md
  - .spec/specs/desktop_ui/platform_artifacts.spec.md
  - .spec/specs/desktop_ui/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: desktop_ui.package.library_identity
  statement: `packages/desktop_ui` shall publish the `:desktop_ui` Elixir library and use the `DesktopUi` namespace as the canonical native desktop runtime-library package of the ecosystem.
  priority: must
  stability: stable

- id: desktop_ui.package.native_runtime_library
  statement: The package shall be a native desktop widget and signal library that is usable directly through its own desktop-oriented widget surface and not only through canonical IUR rendering.
  priority: must
  stability: stable

- id: desktop_ui.package.iur_renderer_entrypoint
  statement: The package shall also include a renderer entry point that loads canonical `unified_iur` and realizes it through `desktop_ui` native widgets, layering, styling, and interaction behavior.
  priority: must
  stability: stable

- id: desktop_ui.package.multiplatform_scope
  statement: The package shall target Windows, macOS, and Linux as first-class desktop platforms and make multiplatform desktop delivery an explicit architectural concern rather than a later packaging detail.
  priority: must
  stability: stable

- id: desktop_ui.package.not_dsl_or_iur_owner
  statement: The package shall not own the authored DSL boundary or the canonical IUR data model; it consumes canonical IUR and translates canonical event meaning at the desktop runtime boundary.
  priority: must
  stability: stable

- id: desktop_ui.package.traceable_to_root_specs
  statement: The `desktop_ui` package subjects shall link back to the repository-level architecture, runtime-library, and signal transport subjects so package design remains subordinate to the root ecosystem contract.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: desktop_ui.package.direct_use_and_iur_use
  given: A developer wants to use `desktop_ui` directly in a desktop application or render canonical `unified_iur`
  when: The developer integrates the package
  then: The package supports both direct native use and canonical IUR rendering without requiring authored DSL modules
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop_ui/package.spec.md
  covers:
    - desktop_ui.package.library_identity
    - desktop_ui.package.native_runtime_library
    - desktop_ui.package.iur_renderer_entrypoint
    - desktop_ui.package.multiplatform_scope
    - desktop_ui.package.not_dsl_or_iur_owner
    - desktop_ui.package.traceable_to_root_specs
    - desktop_ui.package.direct_use_and_iur_use
```
