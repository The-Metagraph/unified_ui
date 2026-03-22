# Maintainer Workflows

`terminal_ui` treats runtime scaffolding, capability seams, and package
reference surfaces as release-shaping work from the beginning.

## Package Commands

- `mix deps.get`
- `mix compile`
- `mix test`
- `mix docs`
- `mix terminal_ui.inspect --format catalog`
- `mix terminal_ui.inspect native_styled_review --format diagnostics`
- `mix terminal_ui.inspect styled_degradation_review --format comparison`
- `mix terminal_ui.validate`
- `mix terminal_ui.validate --format report`
- `mix terminal_ui.validate --strict`

## Workspace Commands

- `mix spec.plancheck terminal_ui`

## Helper Modules

- `TerminalUi.Reference`
  - inspect the package-facing capability and module surface
- `TerminalUi.Info`
  - inspect the lightweight package summary
- `TerminalUi.Tooling`
  - inspect current package workflows and docs surfaces
- `TerminalUi.Inspect`
  - preview maintained native, canonical, and mixed examples through one
    runtime-aware tooling surface
- `TerminalUi.Validate`
  - validate example coverage, renderer determinism, transport translation,
    capability handling, and tooling availability

## Suggested Review Loop

1. Start with `mix terminal_ui.inspect --format catalog` to choose the maintained
   example or parity artifact that matches the area you are changing.
2. Inspect a concrete native or canonical example with
   `mix terminal_ui.inspect EXAMPLE_ID --format diagnostics`.
3. Compare continuity-heavy artifacts such as `styled_degradation_review` or
   `transport_flow_review` when a change touches shared runtime behavior.
4. Run `mix terminal_ui.validate` after code changes to confirm renderer,
   transport, and capability behavior still align.
5. Keep the package docs and reference helpers in sync with the same change set
   whenever runtime or widget behavior changes.

## Evolution Guardrails

- `terminal_ui` does not redefine authored DSL or canonical IUR contracts.
- Upstream `UnifiedUi` and `UnifiedIUR` changes should flow through planning,
  package implementation, and validation together.
- Runtime changes should preserve one shared native/canonical runtime model,
  one transport boundary, and one bounded degradation policy.
- Use `mix terminal_ui.validate --strict` before treating a change as release
  ready.
