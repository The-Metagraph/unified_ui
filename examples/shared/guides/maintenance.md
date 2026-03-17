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
7. Update `examples/demo/` so the new control appears in the right category tab
   or Signal Lab story when it should participate in the aggregate overview.
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
5. Re-review `examples/demo/` to confirm the category tabs and Signal Lab still
   feel visually continuous with the current button example.
6. Run `mix examples.release --strict` before merging to confirm the full suite
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
5. Repair `examples/demo/` if the catalog change should also alter the
   category-level overview or Signal Lab story inventory.
6. Finish with `mix examples.release --strict` to confirm the suite is healthy
   again.

## Maintaining the Aggregate Demo

Use the aggregate demo when you need to review the suite by category rather
than by individual widget.

1. Keep the tabbed shell aligned with the current category registry.
2. Keep the same shared theme and style baseline as the current button example.
3. Add a new representative control or signal-lab story when the catalog gains
   a control that materially changes the overview surface.
4. Preserve the links back to the focused `examples/<widget_name>/` apps so the
   overview remains traceable.
5. Run `mix examples.launch demo --dry-run` and `mix examples.validate --strict`
   from `examples/shared/` before merging.
