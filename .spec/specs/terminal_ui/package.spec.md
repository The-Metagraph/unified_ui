# TerminalUi Package

This subject defines the target package-level contract for creating the
`packages/terminal_ui` library as the terminal runtime library of the
ecosystem.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)

```spec-meta
id: terminal_ui.package
kind: package
status: active
summary: Target contract for creating `packages/terminal_ui` as the terminal-native runtime library and canonical IUR renderer for the ecosystem.
surface:
  - packages/terminal_ui
  - .spec/specs/terminal_ui/package.spec.md
  - .spec/specs/terminal_ui/structure.spec.md
  - .spec/specs/terminal_ui/native_widgets.spec.md
  - .spec/specs/terminal_ui/runtime.spec.md
  - .spec/specs/terminal_ui/capabilities.spec.md
  - .spec/specs/terminal_ui/iur_renderer.spec.md
  - .spec/specs/terminal_ui/transport.spec.md
  - .spec/specs/terminal_ui/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: terminal_ui.package.library_identity
  statement: `packages/terminal_ui` shall publish the `:terminal_ui` Elixir library and use the `TerminalUi` namespace as the canonical terminal runtime-library package of the ecosystem.
  priority: must
  stability: stable

- id: terminal_ui.package.native_runtime_library
  statement: The package shall be a native terminal widget and signal library that is usable directly through its own terminal-oriented widget surface and not only through canonical IUR rendering.
  priority: must
  stability: stable

- id: terminal_ui.package.iur_renderer_entrypoint
  statement: The package shall also include a renderer entry point that loads canonical `unified_iur` and realizes it through `terminal_ui` native widgets, terminal display behavior, styling, interaction semantics, and degradation rules.
  priority: must
  stability: stable

- id: terminal_ui.package.term_ui_runtime_scope
  statement: The package shall realize its runtime through a `term_ui`-backed terminal architecture with explicit backend selection, capability detection, and degradation policy rather than desktop-window assumptions.
  priority: must
  stability: stable

- id: terminal_ui.package.not_dsl_or_iur_owner
  statement: The package shall not own the authored DSL boundary or the canonical IUR data model; it consumes canonical IUR and translates canonical event meaning at the terminal runtime boundary.
  priority: must
  stability: stable

- id: terminal_ui.package.traceable_to_root_specs
  statement: The `terminal_ui` package subjects shall link back to the repository-level architecture, runtime-library, and signal transport subjects so package design remains subordinate to the root ecosystem contract.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: terminal_ui.package.direct_use_and_iur_use
  covers:
    - terminal_ui.package.library_identity
    - terminal_ui.package.native_runtime_library
    - terminal_ui.package.iur_renderer_entrypoint
    - terminal_ui.package.term_ui_runtime_scope
    - terminal_ui.package.not_dsl_or_iur_owner
    - terminal_ui.package.traceable_to_root_specs
  given:
    - A developer wants to use `terminal_ui` directly in a terminal application or render canonical `unified_iur`
  when:
    - The developer integrates the package
  then:
    - The package supports both direct native use and canonical IUR rendering without requiring authored DSL modules
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/terminal_ui/package.spec.md
  covers:
    - terminal_ui.package.library_identity
    - terminal_ui.package.native_runtime_library
    - terminal_ui.package.iur_renderer_entrypoint
    - terminal_ui.package.term_ui_runtime_scope
    - terminal_ui.package.not_dsl_or_iur_owner
    - terminal_ui.package.traceable_to_root_specs
    - terminal_ui.package.direct_use_and_iur_use
```
