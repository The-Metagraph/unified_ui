# Unified

Unified is a spec-led Elixir monorepo for building one UI ecosystem across multiple runtime targets.

The project is organized around a clear pipeline:

1. `unified_ui` is the authored DSL.
2. `unified_iur` is the canonical intermediate UI representation.
3. Runtime packages such as `live_ui`, `elm_ui`, and `terminal_ui` render that canonical representation through their own native widget systems.

The goal is not to force every target into the same runtime model. The goal is to keep authoring, canonical meaning, and runtime realization separate so each target can stay native while still participating in one shared ecosystem.

## Core Concepts

### 1. Authored UI: `unified_ui`

`unified_ui` is the authoring boundary.

Authors describe screens, widgets, layout, interactions, theming, and signals here.  
It is renderer-agnostic by design. It does not own browser runtime details, LiveView details, or terminal details.

### 2. Canonical UI: `unified_iur`

`unified_iur` is the canonical exchange format.

It defines the portable UI model that sits between authored DSL output and renderer/runtime packages.  
This includes canonical widgets, layout/display constructs, layers, themes, bindings, and interaction descriptors.

### 3. Runtime Libraries

Runtime packages consume canonical `unified_iur` and also expose their own native widget surfaces.

Current runtime families in the repo include:

- `packages/live_ui`: Phoenix LiveView runtime library
- `packages/elm_ui`: Phoenix + Elm web runtime library
- `packages/terminal_ui`: terminal runtime library
- `packages/desktop_ui`: spec/planning surface exists, implementation is still evolving

Each runtime package has two responsibilities:

- expose a directly usable native runtime/widget model
- provide a renderer that realizes canonical `unified_iur` through that native model

### 4. Shared Transport Boundary

When UI meaning crosses package boundaries, the ecosystem uses `Jido.Signal` and CloudEvents-compatible conventions.

That means local/native runtime details can stay local, while cross-package behavior remains canonical and traceable.

## Mental Model

```text
unified_ui
    -> authored DSL and compiler
    -> emits canonical UI meaning

unified_iur
    -> canonical intermediate representation
    -> shared rendering boundary

runtime packages
    -> live_ui
    -> elm_ui
    -> terminal_ui
    -> desktop_ui
    -> each renders IUR through native widgets and native runtime behavior
```

## Design Principles

- One authored DSL, not one runtime.
- Canonical UI meaning is portable; runtime realization is target-specific.
- Native widget systems are first-class and usable directly.
- Canonical rendering should reuse native widgets rather than introduce a second unrelated renderer stack.
- Cross-package interaction semantics must remain explicit and transportable.
- Specs, plans, and conformance are part of the implementation system, not side documentation.

## Spec-Led Development

This repository uses a Spec Led workflow under [`.spec`](/Users/Pascal/code/unified/.spec).

That workspace contains:

- authored current-truth specs under [`.spec/specs`](/Users/Pascal/code/unified/.spec/specs)
- ADRs under [`.spec/decisions`](/Users/Pascal/code/unified/.spec/decisions)
- phased implementation plans under [`.spec/planning`](/Users/Pascal/code/unified/.spec/planning)
- package-scoped conformance manifests under [`.spec/conformance`](/Users/Pascal/code/unified/.spec/conformance)

In practice, the repo treats these as linked layers:

- specs define what must be true
- planning defines how it will be delivered
- conformance defines how it is verified

## Repository Layout

```text
.spec/
  specs/          current-truth package and ecosystem specs
  decisions/      ADRs and durable design rationale
  planning/       phased implementation plans and traceability manifests
  conformance/    machine-readable package compliance manifests

packages/
  unified-ui/     authored DSL package
  unified_iur/    canonical intermediate representation package
  live_ui/        LiveView runtime package
  elm_ui/         Phoenix + Elm runtime package
  terminal_ui/    terminal runtime package
  desktop_ui/     desktop runtime package surface (evolving)

lib/
  root repo tooling, especially spec/compliance tasks
```

## Common Workflows

### Root workspace

Install root dependencies and run the repo-level checks:

```bash
mix deps.get
mix test
mix spec.plan
mix spec.plancheck elm_ui
mix spec.compliance elm_ui
mix spec.compliance.ci --base origin/main
```

### `unified_ui`

Work on the authored DSL and compiler:

```bash
cd packages/unified-ui
mix test
mix unified_ui.inspect --example foundational_screen
mix unified_ui.export --example themed_signal_workspace --format snapshot
mix unified_ui.validate
```

### `unified_iur`

Work on the canonical intermediate representation:

```bash
cd packages/unified_iur
mix test
mix unified_iur.inspect foundational_form --format report
mix unified_iur.export foundational_form --format snapshot
mix unified_iur.validate --strict
```

### `live_ui`

Work on the LiveView runtime:

```bash
cd packages/live_ui
mix test
mix live_ui.preview
mix live_ui.inspect native_styled_profile
mix live_ui.export canonical_styled_operations --format comparison
mix live_ui.validate --strict
```

### `elm_ui`

Work on the Phoenix + Elm runtime:

```bash
cd packages/elm_ui
mix test
mix elm_ui.preview --format catalog
mix elm_ui.inspect native_styling
mix elm_ui.export styling_continuity --format comparison
mix elm_ui.validate --strict
```

### `terminal_ui`

Work on the terminal runtime:

```bash
cd packages/terminal_ui
mix test
mix terminal_ui.inspect --format catalog
mix terminal_ui.inspect native_styled_review
mix terminal_ui.validate --strict
```

## Current Status

The repo currently has strong implementation coverage for:

- `unified_ui`
- `unified_iur`
- `live_ui`
- `elm_ui`
- `terminal_ui`

`desktop_ui` is already part of the ecosystem contract and planning surface, but its implementation is still evolving.

## What The Root App Is

The root `unified` Mix project is mainly the repo-level tooling host.

It currently exists to support:

- spec indexing and verification flows
- package plan coverage checks
- package implementation compliance checks
- CI-oriented changed-package compliance evaluation

It is not the primary runtime package for the ecosystem.

## Where To Start

If you are new to the repo:

1. Read [`.spec/README.md`](/Users/Pascal/code/unified/.spec/README.md)
2. Read [`.spec/specs/architecture.spec.md`](/Users/Pascal/code/unified/.spec/specs/architecture.spec.md)
3. Pick the package you care about under [`packages/`](/Users/Pascal/code/unified/packages)
4. Use that package’s README and Mix tasks as your working surface
5. Use `mix spec.plancheck <package>` and `mix spec.compliance <package>` before promoting changes

## License

Apache-2.0
