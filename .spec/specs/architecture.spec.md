# Ecosystem Architecture

This subject defines the top-level architecture boundaries for the unified UI ecosystem.

```spec-meta
id: ecosystem.architecture
kind: architecture
status: active
summary: High-level architecture contract for the DSL, the canonical IUR, the native runtime libraries, and the shared event transport boundary.
surface:
  - packages/unified-ui
  - packages/unified_iur
  - packages/live_ui
  - packages/web_ui
  - packages/desktop_ui
  - .spec/specs/architecture.spec.md
  - .spec/specs/dsl_iur_symbiosis.spec.md
  - .spec/specs/platform_runtimes.spec.md
  - .spec/specs/signal_transport.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: ecosystem.architecture.dsl_authoring_boundary
  statement: `unified_ui` shall be the authored DSL boundary for describing ecosystem UIs, widget interactions, and compilation into canonical IUR structures.
  priority: must
  stability: stable

- id: ecosystem.architecture.iur_exchange_boundary
  statement: `unified_iur` shall be the canonical intermediate exchange format between the DSL and renderer/widget libraries.
  priority: must
  stability: stable

- id: ecosystem.architecture.renderer_packages_consume_iur
  statement: Renderer/widget libraries shall treat canonical IUR as the cross-package rendering boundary and shall not require authored DSL modules once IUR is available.
  priority: must
  stability: stable

- id: ecosystem.architecture.runtime_libraries_native_surface
  statement: Renderer/widget libraries shall expose native widget, layering, styling, and signal surfaces that are usable independently of canonical IUR.
  priority: must
  stability: stable

- id: ecosystem.architecture.runtime_libraries_iur_renderer
  statement: Each renderer/widget library shall include a renderer that loads canonical IUR and realizes it through its own native widgets and native signals.
  priority: must
  stability: stable

- id: ecosystem.architecture.shared_transport_contract
  statement: Cross-package UI interaction semantics shall use Jido.Signal values and CloudEvents-compatible event conventions as the shared transport contract.
  priority: must
  stability: stable
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/architecture.spec.md
  covers:
    - ecosystem.architecture.dsl_authoring_boundary
    - ecosystem.architecture.iur_exchange_boundary
    - ecosystem.architecture.renderer_packages_consume_iur
    - ecosystem.architecture.runtime_libraries_native_surface
    - ecosystem.architecture.runtime_libraries_iur_renderer
    - ecosystem.architecture.shared_transport_contract
```
