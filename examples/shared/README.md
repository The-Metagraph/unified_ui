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
- `UnifiedExamples.Shared.Documentation`
- `UnifiedExamples.Shared.Loader`
- `UnifiedExamples.Shared.Tooling`
- `UnifiedExamples.Shared.Template`
- `UnifiedExamples.Shared.Runtime`

Standalone widget apps under `examples/<widget_name>/` should depend on this
package through a local path dependency.

Shared template contract:

- the shared template entrypoint is `UnifiedExamples.Shared.Template`
- the shared default theme id is `:example_suite_default`
- the shared default style profile includes `:example_shell`, `:example_panel`,
  `:example_form_shell`, `:example_title`, `:example_summary`,
  `:example_notes`, `:example_primary_button`, and
  `:example_primary_input`
- every standalone app should use either `example_panel/1` or
  `example_form_panel/1`
- every standalone app should inherit the same common notes, title, summary,
  and shell treatment unless the example-specific content itself needs to vary

Maintainer workflows:

- `mix examples.list` prints the current suite catalog
- `mix examples.preview <directory>` prints a preview report, metadata, or HTML
- `mix examples.run <directory>` runs the target example app through its own
  `mix test` workflow
- `mix examples.validate` checks catalog continuity and shared-template/theme
  reuse across the suite
- `mix examples.report` prints the cross-family review summary for the suite

Documentation checks:

- `UnifiedExamples.Shared.Documentation.report/0` verifies the root suite index
  and this shared README stay aligned with the implemented catalog and shared
  template contract
- the documentation checks confirm the suite continues to describe
  `examples/catalog.tsv`, `examples/shared/`, the common template, and the
  current app directories

Cross-package traceability:

- `UnifiedExamples.Shared.Traceability.report/0` verifies the example suite
  stays linked to the `unified_ui`, `unified_iur`, and `live_ui` package
  contracts
- per-app review metadata includes a `traceability` map describing the authored
  DSL path, canonical IUR path, runtime rendering path, and the relevant root
  and package spec files
- see [guides/traceability.md](./guides/traceability.md) for the reviewer-facing
  traceability workflow
