# Native Runtime and Examples

`LiveUi` is a directly usable native LiveView widget and runtime library.

## Native Surface

The native package surface includes:

- foundational widgets such as text, labels, inputs, buttons, and content containers
- forms, field groups, and navigation widgets
- advanced data, overlay, display, and operational widgets
- native theme/style helpers through `LiveUi.Theme` and `LiveUi.Style`
- native screen definitions through `LiveUi.Screen`

## Maintained Example Groups

The maintained example catalog is intentionally split into three paths:

- `:native`: directly authored runtime screens
- `:canonical`: `UnifiedIUR` examples rendered through the shared runtime
- `:mixed`: comparison and transport workflows that exercise both paths together

Every catalog entry exposes:

- a stable example `id`
- a `preview_id` for maintainer tooling
- a `review_artifact` identity used in exports and review workflows
- `families` describing the feature areas the example covers
- `coverage` metadata describing native/canonical/transport expectations

## Preview and Inspection

Use the package tooling to review maintained examples:

- `mix live_ui.preview native_styled_profile --format html`
- `mix live_ui.inspect native_styled_operations --format comparison`
- `mix live_ui.export styled_continuity_compare --format diagnostics`

These commands are designed to keep example review anchored to the package
contract rather than one-off debug helpers.
