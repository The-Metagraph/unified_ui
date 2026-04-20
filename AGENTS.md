# AGENTS.md

Repo-level orientation for agents working in this repository root.

For rules specific to the Spec Led workspace, also read `.spec/AGENTS.md`.

## First Read

Start with the contract layer before changing code or docs:

1. `.spec/README.md`
2. `.spec/AGENTS.md`
3. `.spec/decisions/README.md`
4. `.spec/specs/package.spec.md`
5. `.spec/specs/architecture.spec.md`
6. `.spec/specs/dsl_iur_symbiosis.spec.md`
7. `.spec/specs/platform_runtimes.spec.md`
8. `.spec/specs/signal_transport.spec.md`
9. `.spec/specs/governance/governance_layer.spec.md`
10. `.spec/specs/governance/contracts/workspace_governance_contract.spec.md`

Read the relevant package specs under `.spec/specs/` before editing a package.
If the change is durable and cross-cutting, also read the matching ADRs under
`.spec/decisions/`.

## What This Repo Is

- Spec Led Development monorepo for a unified UI ecosystem
- Root `mix.exs` is thin and mainly supports repository-wide tooling
- Implementation lives in package-local Mix projects under `packages/`
- `examples/` contains standalone apps and shared tooling for previews,
  validation, and catalog-style review
- The root `README.md` is lightweight; treat `.spec/` and `CLAUDE.md` as more
  authoritative

## Canonical Contract Model

The `.spec/` workspace is the current-truth contract layer for this repository.

- `.spec/specs/**/*.spec.md` are the canonical authored subjects
- `.spec/specs/governance/` contains repository-wide governance contracts
- `.spec/decisions/**/*.md` contains durable ADR rationale
- `.spec/conformance/` contains machine-readable implementation evidence
- `.spec/planning/*/spec-traceability.json` contains machine-readable plan
  coverage manifests

Governance and conformance are separate layers. Do not treat conformance
manifests, planning mirrors, or branch-local notes as substitutes for authored
spec subjects.

## Core Architecture

The ecosystem is organized around one authored DSL package, one canonical IUR
package, and several runtime libraries.

1. `packages/unified-ui`
   - Elixir app: `:unified_ui`
   - Namespace: `UnifiedUi`
   - Role: authored DSL and compiler
   - Uses Spark for sectioned DSL authoring across identity, composition,
     theming, and signals
   - Compiles authored modules into canonical `UnifiedIUR`, not
     renderer-specific output

2. `packages/unified_iur`
   - Elixir app: `:unified_iur`
   - Namespace: `UnifiedIUR`
   - Role: canonical intermediate representation
   - Pure renderer-independent model for widgets, layout, layers, style,
     theming, bindings, and interactions
   - Runtime-native structs must not leak into canonical core values

3. Runtime libraries
   - `packages/live_ui`
   - `packages/elm_ui`
   - `packages/desktop_ui`
   - `packages/terminal_ui`
   - Each runtime is both a native widget/runtime library and a canonical IUR
     renderer
   - Native runtime surfaces remain usable without first loading canonical IUR

## Architectural Invariants

- `unified_ui` is the only authored DSL boundary
- `unified_iur` is the cross-package canonical interchange and rendering
  boundary
- Runtime libraries consume canonical IUR but also own native widget, runtime,
  styling, and local interaction surfaces
- Cross-package UI interaction meaning uses `Jido.Signal` with
  CloudEvents-compatible semantics
- Runtime-native responsibilities must not be moved into `unified_ui` or
  `unified_iur`
- The runtime packages are not IUR-only shells; IUR loading is one renderer
  entry point, not the only usage model

## Change Contracts

When you change canonical package surfaces, the specs must move with the code in
the same change set.

- Changes to canonical `unified_ui` DSL surface must update the affected
  subjects under `.spec/specs/unified-ui/`
- Changes to canonical `unified_iur` interchange surface must update the
  affected subjects under `.spec/specs/unified-iur/`
- Changes to canonical `unified_ui` widget, display-system, or theming surface
  intended for ecosystem-wide authoring must update the paired
  `.spec/specs/unified-iur/` subjects in the same change set
- Changes to canonical `unified_iur` widget, display-system, or theming surface
  intended for ecosystem-wide authoring and rendering must update the paired
  `.spec/specs/unified-ui/` subjects in the same change set
- Repository-wide governance changes belong under `.spec/specs/governance/`
- Durable cross-cutting policy changes must add or update an ADR under
  `.spec/decisions/`

Do not create a separate branch-local proposal layer under `.spec/`. Use the
authored subject specs as current truth and use Git history or pull requests as
the change timeline.

## Runtime Package Expectations

- `live_ui` is the Phoenix LiveView runtime library and IUR renderer
- `elm_ui` is a Phoenix-plus-Elm runtime with explicit server and frontend
  runtime split
- `desktop_ui` is an SDL3-oriented desktop runtime targeting Windows, macOS,
  and Linux
- `terminal_ui` is a terminal runtime targeting Linux, macOS, and Windows with
  capability-aware degradation and fallback behavior

Each runtime may expose and evolve its own native widget set independently of
the DSL, as long as canonical IUR meaning and canonical event meaning are
preserved at the ecosystem boundary.

## Examples and Review Apps

- `examples/shared/` contains shared support code, catalog data, and maintainer
  tooling
- `examples/<widget_name>/` contains standalone example apps
- `examples/demo/` contains the aggregate demo application

Common example path:

- `UnifiedUi` DSL -> `UnifiedIUR` -> `LiveUi`

Useful docs:

- `examples/README.md`
- `examples/running_the_examples.md`
- `examples/catalog.tsv`

## Tooling and Commands

Repository root:

- `mix spec.plan`
- `mix spec.verify --debug`
- `mix spec.check`
- `mix spec.diffcheck`
- `mix spec.report`

Package-local commands:

- run `mix test` from inside the relevant package directory
- `packages/unified-ui`: `mix unified_ui.inspect`, `mix unified_ui.export`,
  `mix unified_ui.validate`
- `packages/unified_iur`: `mix unified_iur.inspect`,
  `mix unified_iur.export`, `mix unified_iur.validate`
- `packages/live_ui`: `mix live_ui.demo`, `mix live_ui.preview`,
  `mix live_ui.inspect`, `mix live_ui.export`, `mix live_ui.validate`
- `examples/shared`: `mix examples.*` tasks for listing, launching, previewing,
  validating, and reporting on example apps

## Practical Working Notes

- If you edit `.spec`, follow `.spec/AGENTS.md`
- Prefer targeted package-local tests over broad repository-wide runs
- When changing repository-wide or package-wide policy, update the subject specs
  first and ADRs second
- When changing canonical DSL or canonical IUR surface, expect coordinated
  changes across code, package specs, and possibly runtime rendering or
  transport subjects
- Conformance evidence lives under `.spec/conformance/`; do not embed that
  evidence into governance subjects
- Generated traceability mirrors are review aids, not the source of truth
- Packages currently target Elixir `~> 1.19`; older runtimes will fail before
  compilation

## High-Signal References

- `CLAUDE.md`
- `.spec/README.md`
- `.spec/AGENTS.md`
- `.spec/specs/package.spec.md`
- `.spec/specs/architecture.spec.md`
- `.spec/specs/dsl_iur_symbiosis.spec.md`
- `.spec/specs/platform_runtimes.spec.md`
- `.spec/specs/signal_transport.spec.md`
- `.spec/specs/governance/governance_layer.spec.md`
- `.spec/specs/governance/contracts/workspace_governance_contract.spec.md`
