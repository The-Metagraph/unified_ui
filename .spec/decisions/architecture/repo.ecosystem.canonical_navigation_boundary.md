---
id: repo.ecosystem.canonical_navigation_boundary
status: accepted
date: 2026-04-24
affects:
  - ecosystem.signal_transport
  - unified_ui.signals
  - unified_ui.compiler
  - unified_iur.interactions
  - live_ui.runtime
  - elm_ui.server_runtime
  - desktop_ui.runtime
  - terminal_ui.runtime
---

# Canonical Navigation Is Authored as Screen-Transition Intent

## Context

The ecosystem already treats navigation as a canonical interaction family, but
the runtime libraries do not share one host model. Web runtimes can integrate
with page or route transitions, the desktop runtime owns screen navigation
inside windows, and the terminal runtime may need screen replacement or bounded
section changes without any URL model at all.

The authored DSL and canonical IUR therefore need a durable navigation boundary
that can preserve cross-runtime meaning without importing browser-route syntax,
runtime module identities, or host-specific router APIs into the authored
surface.

## Decision

1. Canonical navigation remains part of the authored interaction and signal
   surface rather than becoming a dedicated routing subsystem inside
   `unified_ui`.
2. When authored navigation changes the active top-level UI surface, it is
   expressed as canonical screen-transition intent using transition actions
   such as `navigate_to`, `replace_with`, `go_back`, `go_forward`,
   `open_modal`, and `close_modal`.
3. Canonical transition targets are symbolic screen identifiers plus optional
   params and metadata rather than URLs, host-router names, or runtime-module
   references.
4. Local navigation-like interactions such as tab changes or other in-screen
   destination changes may remain canonical interaction descriptors without
   being forced into browser-route semantics.
5. Runtime libraries translate canonical navigation intent into their own host
   models:
   - `live_ui` and `elm_ui` may resolve canonical screen transitions through
     host page or route integration
   - `desktop_ui` resolves them through screen registry and navigation
     controller primitives
   - `terminal_ui` resolves them through terminal-appropriate screen
     replacement, modal transitions, or bounded section/history behavior

## Consequences

- `UnifiedUi` can author portable navigation meaning without becoming a router.
- `UnifiedIUR` must preserve canonical navigation descriptors in a
  renderer-independent shape.
- Runtime libraries may integrate with their own host navigation systems, but
  those host systems remain runtime concerns rather than authored DSL
  concerns.
- Browser-style route syntax is not the cross-runtime navigation contract of
  the ecosystem.
