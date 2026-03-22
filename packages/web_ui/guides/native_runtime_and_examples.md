# Native Runtime And Examples

Direct-native `web_ui` usage starts with the package widget surface:

- `WebUi.Widgets`
- `WebUi.Layout`
- `WebUi.Layer`

## Native Screen Authoring

Use `WebUi.Widgets.screen/4` for simple package-native screens, or return a
screen map with explicit `root` and `metadata` when you need stable IDs or
theme metadata for review workflows.

Mount native screens through:

- `WebUi.Runtime.mount_native_screen/2`
- `WebUi.Runtime.hydrate_frontend/1`

## Example Suites

`WebUi.Examples` exposes maintained suites for:

- minimal native runtime behavior
- foundational forms and navigation
- advanced display and layered workflows
- transport-focused workflows
- styling-heavy review scenarios

Use:

- `WebUi.Examples.native_examples/0` for the native suite
- `WebUi.Examples.catalog/0` for metadata
- `WebUi.Examples.coverage_matrix/0` for workflow and parity coverage

## Review Metadata

Each example entry includes:

- category: native, canonical, or mixed
- workflow: minimal, foundational, advanced, transport, or styling
- coverage tags
- parity obligations
- stable preview, inspection, comparison, and export artifact names
