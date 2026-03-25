# Maintainer Workflows

Run package-local checks from `packages/desktop_ui`:

```bash
mix deps.get
mix compile
mix test
mix desktop_ui.inspect --format catalog
mix desktop_ui.inspect native_styled_review --format diagnostics
mix desktop_ui.validate
mix desktop_ui.validate --format report
mix desktop_ui.validate --strict
```

Run the current workspace planning check from the repository root:

```bash
mix spec.traceability.generate desktop_ui
mix spec.plancheck desktop_ui
```

Useful helper surfaces while working:

- `DesktopUi.Examples.catalog/0`
- `DesktopUi.Reference.package_reference/0`
- `DesktopUi.Reference.example_summary/0`
- `DesktopUi.Reference.transport_summary/0`
- `DesktopUi.Reference.style_summary/0`
- `DesktopUi.Reference.artifact_summary/0`
- `DesktopUi.Validate.validation_report/0`

Treat `mix desktop_ui.validate --strict` as the package release-readiness gate
for day-to-day maintenance.

## Evolution Guardrails

Keep these guardrails explicit when the package changes:

- `desktop_ui` does not own authored `UnifiedUi` or canonical `UnifiedIUR`
  definitions.
- Changes to widgets, renderer behavior, platform integration, or transport
  should move with maintained examples, validation, docs, and traceability.
- Root ecosystem subjects in `.spec/specs/architecture.spec.md`,
  `.spec/specs/platform_runtimes.spec.md`, and
  `.spec/specs/signal_transport.spec.md` are part of the package review
  surface, not optional background reading.
