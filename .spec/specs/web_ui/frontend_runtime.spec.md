# WebUi Frontend Runtime

This subject defines the target Elm client-side runtime behavior of `web_ui`.

## Related General Specs

- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [WebUi Package](./package.spec.md)
- [WebUi Native Widgets](./native_widgets.spec.md)
- [WebUi Transport](./transport.spec.md)

```spec-meta
id: web_ui.frontend_runtime
kind: runtime
status: active
summary: Target Elm frontend runtime contract for `web_ui`, including native rendering, bounded local state, and browser-facing interaction handling.
surface:
  - packages/web_ui
  - .spec/specs/web_ui/frontend_runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: web_ui.frontend_runtime.elm_rendering_layer
  statement: The Elm frontend runtime shall realize native `web_ui` widgets and canonical-IUR-driven widgets through Elm rendering and browser-facing interaction handling.
  priority: must
  stability: stable

- id: web_ui.frontend_runtime.local_state_bounded
  statement: The frontend runtime may hold bounded local UI state needed for responsive browser interaction, but that local state shall not redefine canonical package-boundary event meaning.
  priority: must
  stability: stable

- id: web_ui.frontend_runtime.native_and_iur_entrypoints_share_frontend
  statement: The same frontend runtime architecture shall support both direct native `web_ui` usage and canonical IUR rendering so the package does not split into unrelated browser models.
  priority: must
  stability: stable

- id: web_ui.frontend_runtime.browser_capabilities
  statement: The frontend runtime shall handle browser-facing capabilities such as local interaction feedback, layout realization, and client-side responsiveness through Elm-native mechanisms rather than through renderer-specific escape hatches outside the package.
  priority: must
  stability: stable

- id: web_ui.frontend_runtime.canonical_meaning_preserved
  statement: The frontend runtime shall preserve canonical IUR meaning and canonical event meaning when rendering or interacting with widgets that originate from the ecosystem boundary.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: web_ui.frontend_runtime_handle_native_interaction
  given: A user interacts with a widget rendered by the Elm frontend runtime
  when: The interaction updates browser-local UI behavior or crosses to the server runtime
  then: The frontend handles native browser behavior while preserving canonical meaning when boundary translation is required
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/web_ui/frontend_runtime.spec.md
  covers:
    - web_ui.frontend_runtime.elm_rendering_layer
    - web_ui.frontend_runtime.local_state_bounded
    - web_ui.frontend_runtime.native_and_iur_entrypoints_share_frontend
    - web_ui.frontend_runtime.browser_capabilities
    - web_ui.frontend_runtime.canonical_meaning_preserved
    - web_ui.frontend_runtime_handle_native_interaction
```
