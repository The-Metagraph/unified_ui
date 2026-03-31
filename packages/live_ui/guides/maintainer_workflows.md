# Maintainer Workflows

This guide covers the repeatable maintainer workflow for evolving `LiveUi`.

## Daily Package Review Workflow

1. Review the package-local demo with `mix live_ui.demo`.
2. When you need a real browser session, launch `mix live_ui.demo --serve`.
3. Review the maintained example catalog with `mix live_ui.preview`.
4. Inspect native or canonical example structure with `mix live_ui.inspect`.
5. Export metadata, HTML, comparisons, or diagnostics with `mix live_ui.export`.
6. Run `mix live_ui.validate` to review continuity, transport, and authority status.
7. Run `mix live_ui.validate --strict` before treating a runtime-boundary change as release ready.

## Adding a New Native Widget Family

When adding a new native widget family:

1. add the native widget component and tests
2. add or update a maintained native example that exercises the new family
3. add the canonical renderer mapping if the construct is part of canonical `UnifiedIUR`
4. add or update a paired continuity example when native/canonical behavior should stay aligned
5. rerun `mix live_ui.validate --strict`

## Reviewing Boundary Changes

When a change affects transport or canonical rendering:

1. inspect the maintained mixed examples
2. export comparison or diagnostics output for the affected example pair
3. confirm local-only flows remain local where intended
4. confirm boundary-safe flows still produce canonical `Jido.Signal` values
5. confirm the release-readiness report still passes in strict mode

## Compatibility Questions

Before merging a package-boundary change, review:

- whether a native widget change also needs a canonical renderer update
- whether a transport change alters canonical event meaning
- whether a continuity pair now reports drift between native and canonical behavior
- whether the package docs still describe the maintained workflow accurately
