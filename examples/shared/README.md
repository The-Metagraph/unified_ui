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
- shared helpers for booting each example as a standalone Phoenix LiveView app
- the shared interaction-story contract that keeps browser-visible outcomes and
  canonical signal previews aligned across the suite

Main modules:

- `UnifiedExamples.Shared`
- `UnifiedExamples.Shared.Documentation`
- `UnifiedExamples.Shared.Loader`
- `UnifiedExamples.Shared.Tooling`
- `UnifiedExamples.Shared.Template`
- `UnifiedExamples.Shared.Runtime`

Standalone widget apps under `examples/<widget_name>/` should depend on this
package through a local path dependency.

Aggregate review surface:

- `examples/demo/` complements the focused widget apps with one tabbed overview
  shell grouped by category
- the aggregate demo should keep the same shared theme and style baseline as
  the current button example
- the aggregate demo should retain one dedicated Signal Lab tab for
  cross-control interaction stories that remain traceable back to the focused
  example apps

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
- every standalone app must explain one meaningful authored interaction using
  either source-driven interaction storytelling or target-driven interaction
  storytelling

Maintainer workflows:

- `mix examples.list` prints the current suite catalog
- `mix examples.launch <directory> --dry-run` prints the exact `mix phx.server`
  command for one example app
- `mix examples.launch <directory> --smoke-test` boots the example through its
  Phoenix endpoint and verifies the LiveView entrypoint responds
- `mix examples.preview <directory>` prints a preview report, metadata, or HTML
- `mix examples.run <directory>` runs the target example app through its own
  `mix test` workflow
- `mix examples.validate` checks catalog continuity and shared-template/theme
  reuse across the suite
- `mix examples.report` prints the cross-family review summary for the suite
- `mix examples.release` runs the full maintainer workflow report and can fail
  strict release checks with `--strict`
- `mix phx.server` remains the direct browser entrypoint from each
  `examples/<widget_name>/` directory

Phoenix launch helpers:

- `UnifiedExamples.Shared.Tooling.launch_descriptor/2` builds the app-local
  `mix phx.server` command and mount metadata for one example app
- `UnifiedExamples.Shared.Tooling.smoke_launch/2` boots the example through the
  shared Phoenix runtime contract and returns the response metadata used by the
  maintainer smoke workflow

Interaction storytelling:

- source-driven interaction storytelling means the showcased widget originates
  the primary interaction reviewers should try
- target-driven interaction storytelling means a shared trigger or companion
  control updates the showcased passive or structural surface in a browser-
  visible way
- every launched example must show both `Meaningful Interaction Story` and
  `Canonical Signal Preview` panels in the browser

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

Maintenance workflow:

- see [guides/maintenance.md](./guides/maintenance.md) for the final repeatable
  workflow for adding a new example app, updating the aggregate demo, reviewing
  shared-template changes, and running the release gate
