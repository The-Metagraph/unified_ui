# Interoperability

`UnifiedIUR` is the canonical exchange boundary for runtime-library packages.

## Runtime-Library Expectations

Runtime libraries such as `live_ui`, `elm_ui`, and `desktop_ui` are expected to:

- accept canonical `UnifiedIUR.Element` trees
- preserve canonical element identity and metadata meaning
- interpret portable bindings, styles, themes, and interactions
- preserve promoted widget meaning and repeated collection row-scope bindings
- reject or isolate runtime-local state that is not part of canonical IUR

`UnifiedIUR.Interoperability` provides package-facing helpers for walking,
classifying, and checking compatibility of canonical values.

## Extension Safety

Canonical growth is governed by additive, portable shape changes. When adding a
new construct family or attachment shape:

- keep identity fields stable
- keep slot structure deterministic
- keep attachments portable
- keep host-owned form lifecycle data outside canonical structs while retaining
  canonical submit, validation, and action-placement intent
- keep repeated collection sources, row-scope references, and row action
  payloads independent of Ash relationship traversal and renderer callbacks
- update the paired `unified_ui` parity expectation
- update reference fixtures and validation coverage in the same change set

## Diagnostics and Review

Use these surfaces during review:

- `UnifiedIUR.Validate.diagnostics/1`
- `UnifiedIUR.Inspect.fixture/1`
- `UnifiedIUR.Export.diff/2`
- `UnifiedIUR.PortableWidgetSupport.surface_validation/1`
- `mix unified_iur.validate --strict`

These helpers are intended to make portability and compatibility issues visible
before runtime-library packages are changed.
