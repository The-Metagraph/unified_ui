# Unified Examples Shared

`examples/shared` is the common support library for the standalone example-app
suite.

It owns:

- the shared dependency wiring to the local `unified_ui`, `unified_iur`, and
  `live_ui` packages
- the common DSL template used by all standalone example apps
- the shared default theme and default style profile for the suite
- helper functions for compiling authored examples and mounting them through the
  canonical `live_ui` runtime path

Main modules:

- `UnifiedExamples.Shared`
- `UnifiedExamples.Shared.Loader`
- `UnifiedExamples.Shared.Tooling`
- `UnifiedExamples.Shared.Template`
- `UnifiedExamples.Shared.Runtime`

Standalone widget apps under `examples/<widget_name>/` should depend on this
package through a local path dependency.

Maintainer workflows:

- `mix examples.list` prints the current suite catalog
- `mix examples.preview <directory>` prints a preview report, metadata, or HTML
- `mix examples.run <directory>` runs the target example app through its own
  `mix test` workflow
- `mix examples.validate` checks catalog continuity and shared-template/theme
  reuse across the suite
- `mix examples.report` prints the cross-family review summary for the suite
