# ElmUi Package

This subject defines the target package-level contract for creating the
`packages/elm_ui` library as the Phoenix-and-Elm web runtime library of the
ecosystem.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)

```spec-meta
id: elm_ui.package
kind: package
status: active
summary: Target contract for creating `packages/elm_ui` as the Phoenix-and-Elm web runtime library and canonical IUR renderer for the ecosystem.
surface:
  - packages/elm_ui
  - .spec/specs/elm_ui/package.spec.md
  - .spec/specs/elm_ui/structure.spec.md
  - .spec/specs/elm_ui/native_widgets.spec.md
  - .spec/specs/elm_ui/server_runtime.spec.md
  - .spec/specs/elm_ui/frontend_runtime.spec.md
  - .spec/specs/elm_ui/iur_renderer.spec.md
  - .spec/specs/elm_ui/transport.spec.md
  - .spec/specs/elm_ui/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.ecosystem.elm_ui_naming
```

## Requirements

```spec-requirements
- id: elm_ui.package.library_identity
  statement: `packages/elm_ui` shall publish the `:elm_ui` Elixir library and use the `ElmUi` namespace as the canonical Phoenix-and-Elm web runtime-library package of the ecosystem.
  priority: must
  stability: stable

- id: elm_ui.package.native_runtime_library
  statement: The package shall be a native widget and signal library that is usable directly through its own web-oriented widget surface and not only through canonical IUR rendering.
  priority: must
  stability: stable

- id: elm_ui.package.iur_renderer_entrypoint
  statement: The package shall also include a renderer entry point that loads canonical `unified_iur` and realizes it through `elm_ui` native widgets, layering, styling, and interaction behavior.
  priority: must
  stability: stable

- id: elm_ui.package.phoenix_elm_split
  statement: The package shall realize its web runtime through a Phoenix server-side representation and an Elm client-side rendering and local-state layer while preserving canonical IUR and event meaning at the ecosystem boundary.
  priority: must
  stability: stable

- id: elm_ui.package.not_dsl_or_iur_owner
  statement: The package shall not own the authored DSL boundary or the canonical IUR data model; it consumes canonical IUR and translates canonical event meaning at the web runtime boundary.
  priority: must
  stability: stable

- id: elm_ui.package.traceable_to_root_specs
  statement: The `elm_ui` package subjects shall link back to the repository-level architecture, runtime-library, and signal transport subjects so package design remains subordinate to the root ecosystem contract.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: elm_ui.package.direct_use_and_iur_use
  covers:
    - elm_ui.package.library_identity
    - elm_ui.package.native_runtime_library
    - elm_ui.package.iur_renderer_entrypoint
    - elm_ui.package.phoenix_elm_split
    - elm_ui.package.not_dsl_or_iur_owner
    - elm_ui.package.traceable_to_root_specs
  given:
    - A developer wants to use `elm_ui` directly in a Phoenix-and-Elm application or render canonical `unified_iur`
  when:
    - The developer integrates the package
  then:
    - The package supports both direct native use and canonical IUR rendering without requiring authored DSL modules
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/elm_ui/package.spec.md
  covers:
    - elm_ui.package.library_identity
    - elm_ui.package.native_runtime_library
    - elm_ui.package.iur_renderer_entrypoint
    - elm_ui.package.phoenix_elm_split
    - elm_ui.package.not_dsl_or_iur_owner
    - elm_ui.package.traceable_to_root_specs
    - elm_ui.package.direct_use_and_iur_use
```
