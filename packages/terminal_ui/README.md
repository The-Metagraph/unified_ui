# TerminalUi

`terminal_ui` is the terminal-target runtime library for the unified ecosystem.
It supports both direct-native terminal screens and canonical `UnifiedIUR`
rendering through one shared `term_ui`-backed runtime boundary.

## Main Surfaces

- `TerminalUi.Widgets` exposes the direct-native widget surface.
- `TerminalUi.Runtime` defines the shared terminal runtime boundary.
- `TerminalUi.Backend` and `TerminalUi.Capabilities` expose backend selection
  and capability seams.
- `TerminalUi.Renderer` defines the canonical renderer entrypoint that later
  phases will expand.
- `TerminalUi.Transport`, `TerminalUi.Tooling`, `TerminalUi.Reference`, and
  `TerminalUi.Info` provide package boundaries for transport, maintainer
  workflows, and package introspection.
- `TerminalUi.Inspect` and `TerminalUi.Validate` provide repeatable maintainer
  workflows for previewing examples, inspecting capability-aware realization,
  and validating renderer and transport behavior.

## Shared Runtime Model

`terminal_ui` does not own the authored DSL or canonical IUR definitions.
Instead, it consumes canonical `UnifiedIUR`, realizes it through native
terminal widgets, and translates canonical interaction meaning at the terminal
runtime boundary.

Both entry paths stay inside one package:

- direct-native `TerminalUi.Widgets` screens mount through `TerminalUi.Runtime`
- canonical `UnifiedIUR` trees render through `TerminalUi.Renderer` and then
  mount through the same `TerminalUi.Runtime`
- capability detection, backend selection, degradation, styling, and transport
  stay shared across both paths

## Capability Profiles

`terminal_ui` keeps backend and capability assumptions explicit:

- `:raw` rich-terminal mode preserves Unicode, richer color, mouse, and
  positioned canvas behavior when available
- `:tty` fallback-terminal mode keeps keyboard-first behavior, explicit
  Unicode-to-ASCII degradation, and bounded presentation fallbacks such as
  inline overlays and paged scroll

Use the maintained examples and inspection tooling to compare both modes
without leaving the package boundary.

## Maintainer Workflow

Package-local checks:

- `mix deps.get`
- `mix compile`
- `mix test`
- `mix docs`
- `mix terminal_ui.inspect --format catalog`
- `mix terminal_ui.inspect native_styled_review --format diagnostics`
- `mix terminal_ui.validate`
- `mix terminal_ui.validate --format report`
- `mix terminal_ui.validate --strict`

Workspace checks:

- `mix spec.plancheck terminal_ui`

## Guides

- `guides/runtime_backbone.md`
- `guides/native_runtime_and_examples.md`
- `guides/canonical_rendering_and_transport.md`
- `guides/styling_capabilities_and_inspection.md`
- `guides/maintainer_workflows.md`

## Release Readiness

Treat `mix terminal_ui.validate --strict` as the package release-readiness
gate. It keeps example coverage, renderer determinism, shared runtime behavior,
transport translation, capability degradation, tooling, and docs aligned before
the package evolves further.
