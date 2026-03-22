# Maintainer Workflows

`web_ui` treats examples, tooling, and documentation as release surfaces.

## Package Commands

- `mix deps.get`
- `mix compile`
- `mix test`
- `mix docs`

## Workspace Commands

- `mix spec.plancheck web_ui`
- `mix spec.compliance web_ui`

## Helper Modules

- `WebUi.Inspect`
  - preview native, canonical, and mixed examples through one workflow
- `WebUi.Export`
  - export stable review artifacts backed by example metadata
- `WebUi.Validate`
  - validate example coverage, runtime behavior, and release readiness
- `WebUi.Reference`
  - inspect the current package-facing capability surface
- `WebUi.Info`
  - inspect the current package summary and validation state

## Recommended Review Loop

1. Inspect example metadata through `WebUi.Examples.catalog/0`.
2. Preview example behavior through `WebUi.Inspect.preview/1`.
3. Export a review artifact through `WebUi.Export.artifact/1`.
4. Run release-readiness checks through `WebUi.Validate.release_readiness/1`.
