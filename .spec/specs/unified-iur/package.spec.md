# UnifiedIUR Package

This subject defines the target package-level contract for creating the
`packages/unified_iur` library as the canonical intermediate representation of
the ecosystem.

## Related General Specs

- [Repository Package](../package.spec.md)
- [Ecosystem Architecture](../architecture.spec.md)
- [DSL and IUR Symbiosis](../dsl_iur_symbiosis.spec.md)
- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [Workspace Governance Contract](../governance/contracts/workspace_governance_contract.spec.md)
- [Unified IUR Change Contract](../governance/contracts/unified_iur_change_contract.spec.md)

```spec-meta
id: unified_iur.package
kind: package
status: active
summary: Target contract for creating `packages/unified_iur` as the canonical intermediate representation library used between authored DSL and runtime libraries.
surface:
  - packages/unified_iur
  - .spec/specs/unified-iur/package.spec.md
  - .spec/specs/unified-iur/structure.spec.md
  - .spec/specs/unified-iur/core.spec.md
  - .spec/specs/unified-iur/constructs.spec.md
  - .spec/specs/unified-iur/widgets.spec.md
  - .spec/specs/unified-iur/display_systems.spec.md
  - .spec/specs/unified-iur/theming.spec.md
  - .spec/specs/unified-iur/interactions.spec.md
  - .spec/specs/unified-iur/interoperability.spec.md
  - .spec/specs/unified-iur/tooling.spec.md
decisions:
  - repo.ecosystem.contract_model
  - repo.governance.package_contract_policy
```

## Requirements

```spec-requirements
- id: unified_iur.package.library_identity
  statement: `packages/unified_iur` shall publish the `:unified_iur` Elixir library and use the `UnifiedIUR` namespace as the canonical intermediate representation package for the ecosystem.
  priority: must
  stability: stable

- id: unified_iur.package.exchange_boundary
  statement: The package shall own the canonical exchange model between `unified_ui` authored DSL output and runtime-library IUR renderers, rather than functioning as a renderer or authored DSL package.
  priority: must
  stability: stable

- id: unified_iur.package.renderer_independent_surface
  statement: The package shall define renderer-independent canonical data structures for widgets, layouts, layering, styling, theming, and interaction descriptors without embedding `web_ui`, `live_ui`, or `desktop_ui` native widget models.
  priority: must
  stability: stable

- id: unified_iur.package.direct_runtime_consumption
  statement: The package shall expose canonical structures that runtime libraries can load directly as the renderer entry point described by the root ecosystem specs.
  priority: must
  stability: stable

- id: unified_iur.package.traceable_to_root_specs
  statement: The `unified-iur` package subjects shall link back to the repository-level architecture, DSL and IUR symbiosis, runtime-library, and signal transport subjects so package design remains subordinate to the root ecosystem contract.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: unified_iur.package.shared_exchange_boundary
  given: `unified_ui` compiles canonical UI intent and a runtime library needs to render that intent
  when: The two packages exchange UI state
  then: They meet at canonical `unified_iur` structures rather than at runtime-library widgets or authored DSL modules
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/unified-iur/package.spec.md
  covers:
    - unified_iur.package.library_identity
    - unified_iur.package.exchange_boundary
    - unified_iur.package.renderer_independent_surface
    - unified_iur.package.direct_runtime_consumption
    - unified_iur.package.traceable_to_root_specs
    - unified_iur.package.shared_exchange_boundary
```
