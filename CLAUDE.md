# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture

This is a unified UI ecosystem monorepo organized around a **Spec Led Development** workflow. The architecture follows a three-layer pipeline:

1. **`unified_ui`** (DSL layer) - Authored DSL surface using Spark. Authors describe widgets, layouts, theming, and signals. The compiler lowers authored modules into canonical `UnifiedIUR`.

2. **`unified_iur`** (IUR layer) - Pure Elixir library defining the canonical intermediate representation. This is the portable boundary between DSL output and runtime libraries. Owns core element model, construct families (widgets, layouts, forms, layers), styling, theming, and interaction descriptors.

3. **Runtime libraries** - Each runtime library (`live_ui`, `elm_ui`, `desktop_ui`, `terminal_ui`) exposes both native widget surfaces usable independently AND a renderer that loads canonical IUR through native widgets. Runtime libraries translate between canonical `Jido.Signal` events and their local signal models.

**Key principle**: Runtime libraries are not IUR-only shells; they are first-class native UI libraries. Loading IUR is one renderer entry point, not the only way to use them.

## Common Commands

### Root (repository)

```bash
# Spec-led development workflow
mix spec.plan          # Generate/update .spec/state.json
mix spec.verify        # Verify all spec requirements
mix spec.check         # Strict verification (fails on warnings)
mix spec.diffcheck     # Run when code/docs/tests changed
mix spec.report        # Coverage and weak-spot summaries
```

### Testing in packages

```bash
# From any package directory (packages/*/):
mix test               # Run package tests
mix test test/specific_test.exs  # Run single test file

# Linting
mix format             # Format code
mix credo              # Lint with Credo
```

### `unified_ui` package

```bash
cd packages/unified-ui
mix unified_ui.inspect --example foundational_screen
mix unified_ui.export --example themed_signal_workspace --format snapshot
mix unified_ui.validate
```

### `unified_iur` package

```bash
cd packages/unified_iur
mix unified_iur.inspect FIXTURE_ID --format report
mix unified_iur.export FIXTURE_ID --format fixture
mix unified_iur.validate --strict
```

### `live_ui` package

```bash
cd packages/live_ui
mix live_ui.demo [home|EXAMPLE_ID] [--format summary|html|report]
mix live_ui.demo --serve        # Launch browser demo at http://127.0.0.1:4040
mix live_ui.preview EXAMPLE_ID
mix live_ui.inspect EXAMPLE_ID
mix live_ui.export EXAMPLE_ID
mix live_ui.validate --strict
```

### Examples suite

```bash
cd examples/shared
mix examples.list              # List catalog
mix examples.launch button --dry-run
mix examples.launch button --smoke-test
mix examples.preview button
mix examples.validate --strict
mix examples.report

# Run individual example directly
cd examples/button
mix phx.server                 # Serves at http://127.0.0.1:5000
```

## Spec Led Development

The `.spec/` workspace contains authored subject specs, governance contracts, and ADRs. This is **current-truth only** - use Git history for change timeline.

- `.spec/specs/**/*.spec.md` - Authored subject specs with `spec-meta`, `spec-requirements`, `spec-verification`, `spec-scenarios`, and `spec-exceptions` blocks
- `.spec/specs/governance/` - Repository-wide governance contracts
- `.spec/decisions/` - Durable ADRs for cross-cutting policy
- `.spec/conformance/*/manifest.json` - Machine-readable implementation evidence
- `.spec/planning/*/spec-traceability.json` - Plan coverage manifests

**Workflow after making changes:**
1. Update relevant `.spec/specs/**/*.spec.md` files
2. Add or revise ADRs only for cross-cutting durable policy
3. Run `mix spec.verify --debug`
4. Run `mix spec.check`
5. Run `mix spec.diffcheck` when code/docs/tests changed

**Verification kinds:** Prefer `source_file`, `test_file`, `guide_file`, `readme_file`, `workflow_file`, or `command`. Use `covers:` markers in source files only when they remain stable.

## Package Structure

- `packages/unified-ui/` - DSL authoring surface and compiler
- `packages/unified_iur/` - Canonical IUR data structures and validation
- `packages/live_ui/` - Phoenix LiveView runtime library with native widgets and IUR renderer
- `packages/elm_ui/` - Elm-based runtime library
- `packages/desktop_ui/` - Desktop-native runtime library
- `packages/terminal_ui/` - Terminal UI runtime library
- `examples/` - Standalone Phoenix LiveView example apps demonstrating each widget/construct
- `examples/shared/` - Shared support library with catalog, runtime helpers, and maintainer tasks

## Key Architecture Decisions

- **DSL is the single authored boundary** - runtime libraries consume IUR, not authored modules
- **IUR is the cross-package rendering boundary** - renderer packages must not require authored DSL modules once IUR is available
- **Jido.Signal is the shared transport contract** - cross-package UI interactions use CloudEvents-compatible events
- **Governance is separate from conformance** - policy lives in `.spec/specs/governance/`, evidence in `.spec/conformance/`

## References

- [Spec System](.spec/specs/spec_system.spec.md) - Workspace contract
- [Ecosystem Architecture](.spec/specs/architecture.spec.md) - High-level architecture
- [Governance Layer](.spec/specs/governance/governance_layer.spec.md) - Governance contracts
- [LiveUi README](packages/live_ui/README.md) - Runtime details
- [UnifiedUi README](packages/unified-ui/README.md) - DSL and compiler details
- [Examples README](examples/README.md) - Example suite catalog
