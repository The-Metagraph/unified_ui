# Example Suite Maintenance Workflow

Use the same workflow every time you add, review, or repair an example app.

## Adding a New Example App

1. Create the new standalone Phoenix LiveView app under `examples/<widget_name>/`.
2. Reuse `UnifiedExamples.Shared.Template` and the shared default theme/style
   contract instead of inventing a new app-local shell.
3. Add the app to `UnifiedExamples.Shared.Catalog` and regenerate
   `examples/catalog.tsv`.
4. Run `mix examples.launch <widget_name> --dry-run` from `examples/shared/`
   to confirm the browser launch command and mount URL.
5. Run `mix examples.launch <widget_name> --smoke-test` from `examples/shared/`
   to verify the Phoenix endpoint and LiveView entrypoint respond.
6. Run `mix examples.preview <widget_name> --format report` from
   `examples/shared/` to confirm the screen, widget family, and shared theme.
7. Run `mix examples.release --strict` from `examples/shared/` to verify the
   documentation, traceability, catalog, and release-readiness gates all pass.

## Reviewing Shared Template or Theme Changes

1. Run `mix examples.report` from `examples/shared/` to inspect cross-family
   impact.
2. Dry-run and smoke-test at least one representative browser app from each
   affected family with `mix examples.launch <widget_name> --dry-run` and
   `mix examples.launch <widget_name> --smoke-test`.
3. Preview at least one representative app from each affected family with
   `mix examples.preview <widget_name>`.
4. Run `mix examples.validate --strict` to catch shared-template or
   shared-theme drift.
5. Run `mix examples.release --strict` before merging to confirm the full suite
   still passes the final maintainer workflow.

## Repairing Catalog or Metadata Drift

1. Run `mix examples.list` to verify the catalog view.
2. Run `mix examples.validate --format report` to inspect the exact failing
   directories and metadata issues.
3. Run `mix examples.launch <widget_name> --smoke-test` for one failing app to
   confirm whether the Phoenix browser path is also broken.
4. Repair the shared template, theme, app metadata, or Phoenix runtime contract
   until the validation
   report is clean.
5. Finish with `mix examples.release --strict` to confirm the suite is healthy
   again.
