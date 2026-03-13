---
id: repo.ecosystem.contract_model
status: accepted
date: 2026-03-13
affects:
  - ecosystem.architecture
  - ecosystem.dsl_iur_symbiosis
  - ecosystem.platform_runtimes
  - ecosystem.signal_transport
---

# Ecosystem Centers on DSL, IUR, Native Runtime Libraries, and Shared Event Boundaries

## Context

The repository defines one authored DSL package, one canonical intermediate representation package, and multiple runtime libraries with different platform technologies. The architecture needs a durable statement of where authored UI intent lives, where canonical interchange lives, how runtime libraries remain native libraries in their own right, and how canonical event meaning is preserved when those libraries consume IUR.

## Decision

1. `unified_ui` owns the authored DSL surface and compiles canonical UI intent into `unified_iur`.
2. `unified_iur` owns the canonical intermediate representation for widgets, layouts, layering, styling, and theming.
3. Runtime libraries such as `web_ui`, `live_ui`, and `desktop_ui` own native widget, layering, styling, and signal surfaces that are usable independently of canonical IUR.
4. Every canonical `unified_iur` widget, layout, layering, and styling construct intended for ecosystem rendering must be representable in each runtime library's native surface.
5. Each runtime library includes a renderer that loads canonical `unified_iur` and realizes it through that library's own native widgets and native signals.
6. Cross-package interaction semantics use `Jido.Signal` and CloudEvents-compatible event conventions as the canonical boundary contract.
7. Runtime libraries may translate between the canonical boundary contract and their own native local signal models, but they must preserve canonical event meaning at ecosystem boundaries.
8. Governance for these ecosystem boundaries lives in the root `.spec` workspace, and executable conformance is introduced later as a separate layer.

## Consequences

- DSL and IUR changes are expected to move together when canonical rendering semantics change.
- Runtime libraries are not IUR-only shells; they are first-class native UI libraries with their own direct-use surfaces.
- Loading IUR is a renderer entry point inside each runtime library, not the only way those libraries can be used.
- Runtime libraries must maintain parity between the canonical IUR surface and their native widgets, layering constructs, and styling attributes.
- Native local signal models may differ across runtimes, but translation at ecosystem boundaries must preserve canonical event meaning.
- Cross-cutting architecture changes must update the ecosystem subject specs and this ADR in the same change set.
