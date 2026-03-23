# Maintainer Workflows

`elm_ui` treats examples, tooling, and documentation as release surfaces.

## Package Commands

- `mix deps.get`
- `mix compile`
- `mix test`

## Workspace Commands

- `mix spec.plancheck elm_ui`
- `mix spec.compliance elm_ui`

## Helper Modules

- `ElmUi.Inspect`
  - preview native, canonical, and mixed examples through one workflow
- `ElmUi.Export`
  - export stable review artifacts backed by example metadata
- `ElmUi.Validate`
  - validate example coverage, runtime behavior, and release readiness
- `ElmUi.Reference`
  - inspect the current package-facing capability surface
- `ElmUi.Info`
  - inspect the current package summary and validation state

## Recommended Review Loop

1. Inspect example metadata through `ElmUi.Examples.catalog/0`.
2. Preview example behavior through `ElmUi.Inspect.preview/1`.
3. Export a review artifact through `ElmUi.Export.artifact/1`.
4. Run release-readiness checks through `ElmUi.Validate.release_readiness/1`.
