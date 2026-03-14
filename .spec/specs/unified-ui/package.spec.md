# UnifiedUi Package

This subject defines the target package-level contract for creating the
`packages/unified-ui` library as the canonical authored DSL boundary of the
ecosystem.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [Workspace Governance Contract](../governance/contracts/workspace_governance_contract.spec.md)
- [Unified UI Change Contract](../governance/contracts/unified_ui_change_contract.spec.md)

```spec-meta
id: unified_ui.package
kind: package
status: active
summary: Target contract for creating `packages/unified-ui` as the authored DSL and canonical IUR compiler package for the ecosystem.
surface:
  - packages/unified-ui
  - .spec/specs/unified-ui/package.spec.md
  - .spec/specs/unified-ui/structure.spec.md
  - .spec/specs/unified-ui/dsl.spec.md
  - .spec/specs/unified-ui/widgets.spec.md
  - .spec/specs/unified-ui/display_systems.spec.md
  - .spec/specs/unified-ui/theming.spec.md
  - .spec/specs/unified-ui/compiler.spec.md
  - .spec/specs/unified-ui/signals.spec.md
  - .spec/specs/unified-ui/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.governance.package_contract_policy
```

## Requirements

```spec-requirements
- id: unified_ui.package.library_identity
  statement: `packages/unified-ui` shall publish the `:unified_ui` Elixir library and use the `UnifiedUi` namespace as the canonical authored DSL package for the ecosystem.
  priority: must
  stability: stable

- id: unified_ui.package.dsl_boundary_only
  statement: The package shall own the authored DSL, canonical signal descriptor authoring, compilation, and introspection responsibilities, and shall not become a renderer or runtime-library package for `web_ui`, `live_ui`, or `desktop_ui`.
  priority: must
  stability: stable

- id: unified_ui.package.canonical_iur_dependency
  statement: The package shall depend on canonical `unified_iur` concepts and compile into canonical IUR structures rather than runtime-specific widget trees or platform-specific render instructions.
  priority: must
  stability: stable

- id: unified_ui.package.standalone_authoring_api
  statement: The package shall expose a complete authored API for declaring widgets, layouts, layering, styling, theming, and interaction bindings without requiring any runtime library package to be present during authoring.
  priority: must
  stability: stable

- id: unified_ui.package.traceable_to_root_specs
  statement: The `unified-ui` package subjects shall link back to the repository-level architecture, DSL and IUR symbiosis, and signal transport subjects so package design remains subordinate to the root ecosystem contract.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_ui.package.authoring_without_runtime_packages
  given: A developer adds `packages/unified-ui` to a project without `web_ui`, `live_ui`, or `desktop_ui`
  when: The developer authors UI modules and compiles them into canonical IUR
  then: The package authoring and compilation workflow remains usable without a renderer/runtime package dependency
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-ui/package.spec.md
  covers:
    - unified_ui.package.library_identity
    - unified_ui.package.dsl_boundary_only
    - unified_ui.package.canonical_iur_dependency
    - unified_ui.package.standalone_authoring_api
    - unified_ui.package.traceable_to_root_specs
    - unified_ui.package.authoring_without_runtime_packages
```
