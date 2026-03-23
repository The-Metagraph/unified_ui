---
id: repo.ecosystem.elm_ui_naming
status: accepted
date: 2026-03-23
affects:
  - ecosystem.architecture
  - ecosystem.platform_runtimes
  - ecosystem.signal_transport
  - elm_ui.package
  - elm_ui.structure
  - elm_ui.native_widgets
  - elm_ui.server_runtime
  - elm_ui.frontend_runtime
  - elm_ui.iur_renderer
  - elm_ui.transport
  - elm_ui.tooling
---

# Rename the Phoenix-and-Elm Web Runtime Contract from `web_ui` to `elm_ui`

## Context

The repository currently describes the Phoenix-and-Elm web runtime package as
`web_ui`. That name was workable while the ecosystem only needed one web target,
but it is no longer precise about the package's actual intent. The runtime is
not a generic browser package; it is specifically the Phoenix-and-Elm web
runtime contract for the ecosystem, with Elm as the frontend realization layer
and Phoenix as the authoritative server-side runtime.

The design workspace also now contains multiple runtime families, including
`live_ui`, `desktop_ui`, and `terminal_ui`. Keeping the Phoenix-and-Elm target
named `web_ui` makes it harder to distinguish between:

1. generic web-facing runtime concerns,
2. a specific Phoenix-plus-Elm runtime package, and
3. possible future browser runtimes that may not use Elm.

## Decision

1. The Phoenix-and-Elm web runtime contract is renamed from `web_ui` to
   `elm_ui`.
2. The target package identity for that runtime becomes `packages/elm_ui`,
   the target Elixir application identity becomes `:elm_ui`, and the target
   top-level package namespace becomes `ElmUi`.
3. The normative spec surface shall use `elm_ui.*` subject ids and requirement
   ids when referring to that runtime contract.
4. Repository-level architecture, runtime, transport, and cross-package specs
   shall refer to `elm_ui` rather than `web_ui` when naming the Phoenix-and-Elm
   runtime library.
5. The migration is staged: normative specs move first, then planning and
   conformance surfaces, then package implementation and runtime code.

## Consequences

- The repository gains a more precise name for the Phoenix-and-Elm runtime
  contract without changing the roles of `unified_ui`, `unified_iur`, or the
  other runtime libraries.
- Planning, conformance, and package code that still use `web_ui` after this
  ADR are transitional and must be migrated in follow-on changes.
- Future web-facing runtimes are no longer semantically blocked by the generic
  `web_ui` package name.
- Reviewers should expect temporary cross-layer drift immediately after the
  spec rename until planning, conformance, CI references, and package code are
  realigned.
