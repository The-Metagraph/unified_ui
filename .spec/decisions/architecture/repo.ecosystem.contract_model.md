---
id: repo.ecosystem.contract_model
status: accepted
date: 2026-03-12
affects:
  - ecosystem.architecture
  - ecosystem.dsl_iur_symbiosis
  - ecosystem.platform_runtimes
  - ecosystem.signal_transport
  - repo.governance.ecosystem_contract
---

# Ecosystem Centers on DSL, IUR, Renderer, and Signal Boundaries

## Context

The repository contains one authored DSL package, one canonical intermediate representation package, and multiple renderer/widget libraries with different runtime technologies. The architecture needs one durable explanation of where authored UI intent lives, where canonical rendering data lives, how renderer libraries stay independent, and how widget interaction events move across package boundaries.

## Decision

1. `unified_ui` owns the authored DSL surface and compiles canonical UI intent into `unified_iur`.
2. `unified_iur` owns the canonical intermediate representation for widgets, layouts, layering, and theming.
3. Renderer/widget libraries such as `web_ui`, `live_ui`, and `desktop_ui` own native widget implementations and runtime behavior while also consuming canonical `unified_iur`.
4. Every canonical widget, layout, layering, and theming construct intended for ecosystem-wide authoring must be representable in the `unified_ui` DSL.
5. Cross-package interaction semantics use `Jido.Signal` and CloudEvents-compatible event conventions as the canonical transport model.
6. `desktop_ui` uses that same canonical signal model for internal runtime and widget communication as well as external boundaries.
7. Governance for these ecosystem boundaries lives in the root `.spec` workspace, and executable conformance is introduced later as a separate layer.

## Consequences

- DSL and IUR changes are expected to move together when canonical rendering semantics change.
- Layering and theming remain first-class DSL concerns rather than separate authoring subsystems.
- Renderer/widget libraries keep architectural independence instead of becoming thin reimplementations of the DSL.
- `desktop_ui` event flow should converge on the same signal semantics used by the web and LiveView runtimes.
- Cross-cutting architecture changes must update ecosystem specs and, when durable, their ADRs in the same change set.
- Future conformance work will validate these boundaries explicitly rather than being folded into governance contracts prematurely.
