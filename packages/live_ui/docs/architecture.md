# LiveUi Architecture

## Goal

`live_ui` should be a reusable Phoenix LiveView widget library and rendering runtime for canonical `UnifiedIUR` trees.

The core architectural intent is:

- `UnifiedIUR` is the primary rendering contract.
- `live_ui` owns an independent widget library, layout system, layer system, theme system, and event bridge.
- the same `live_ui` widgets should be usable directly as public components without going through `UnifiedIUR`.
- upstream tools may produce `UnifiedIUR`, but `live_ui` should not depend on their widget implementations once the IUR boundary is crossed.

`live_ui` may accept optional source modules that produce `UnifiedIUR` through `init/1`, `update/2`, and `view/1`, but those sources are adapters into the same IUR-first pipeline rather than the package's defining contract.

## Design Principles

- Treat canonical `UnifiedIUR` as the stable input contract for rendering.
- Keep `live_ui` responsible for interpretation, widget rendering, layering, theming, runtime state, and event bridging.
- Make the widget library independent from upstream producers such as `unified_ui`.
- Expose the widget library as a public component surface that can be composed directly in LiveView.
- Use one normalization boundary so raw `UnifiedIUR` and adapter-produced `UnifiedIUR` converge on the same render tree.
- Ensure that IUR-driven rendering and direct widget composition use the same underlying widget implementations.
- Keep server-side state authoritative even when JavaScript hooks are used for richer interactions.
- Support the full canonical widget catalog plus any explicitly adopted extension kinds.
- Do not require `live_ui` to own a standalone Phoenix endpoint, router, asset bundle, or release.

## Host Integration

`live_ui` should remain a host-mounted library rather than a standalone Phoenix application.

The recommended host-facing API should be three complementary paths:

- direct widget path: hosts render `live_ui` widgets and layouts directly as public Phoenix components
- primary IUR path: canonical `UnifiedIUR` mounted through a generic LiveView entrypoint or component boundary
- adapter path: thin `LiveUi.Screen` wrappers around source modules that emit `UnifiedIUR`

All three paths should converge on the same library-owned widget semantics.

The host Phoenix application should be responsible for:

- mounting `live_ui` routes or components from its router
- providing layouts, auth plugs, session data, and endpoint configuration
- importing `live_ui` JavaScript hooks and theme assets into its own asset pipeline
- choosing whether a screen is composed directly from `live_ui` widgets, provided as canonical `UnifiedIUR`, or produced by a source module

Example host asset registration:

```javascript
import LiveUiHooks from "../../deps/live_ui/assets/js/live_ui"

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: {
    ...LiveUiHooks,
  },
})
```

`live_ui` should be responsible for:

- publishing mount helpers and route conventions
- publishing the `LiveUi.Screen` macro for optional source-module wrappers
- publishing hook and theme asset entrypoints that host assets can register
- exposing a public widget and layout component surface for direct use in LiveView
- accepting host-provided session and runtime context without assuming a particular app shell
- keeping the interpreter, widget library, theme system, layer system, runtime, and signal bridge independent from host-specific business logic

## Proposed Module Map

### Host-facing integration

- `LiveUi`
  - Public API for library configuration and mounting helpers.
  - Exposes `dynamic_session/2` for module-backed sources and `dynamic_iur_session/2` for canonical raw IUR.
- `LiveUi.Screen`
  - Macro for defining a host-facing LiveView wrapper for one source module.
  - Public API shape: `use LiveUi.Screen, source: MyApp.SomeSource`.
  - The source module must emit `UnifiedIUR` from `view/1`.
- `LiveUi.Router`
  - Optional helper macro or helper functions for mounting screens from a host router.
- `LiveUi.Assets`
  - Exposes JS hook registration and theme asset entrypoints so the host app can import them into its own bundle.
- `LiveUi.Session`
  - Normalizes host session, assigns, and route params into runtime context for the mounted screen.

### Input adapters

- `LiveUi.Source`
  - Validates source modules and raw `UnifiedIUR` payloads.
  - Treats source modules as adapters that produce canonical `UnifiedIUR`.
- `LiveUi.Source.IUR`
  - Accepts canonical `UnifiedIUR` structs or map-shaped payloads.
  - Optionally validates canonical schema markers.

### Interpretation and render-tree normalization

- `LiveUi.IUR.Dependency`
  - Validates canonical schema markers such as schema name, schema source, and version.
- `LiveUi.IUR.ValueNormalizer`
  - Canonicalizes map, list, tuple, and set values before render-tree generation.
- `LiveUi.IUR.Interpreter`
  - Accepts canonical `UnifiedIUR` nodes and compatible extension nodes implementing `UnifiedIUR.Element`.
  - Produces a normalized render tree with stable ids, kinds, props, children, style traits, layer traits, and signal bindings.
  - Rejects unsupported node kinds explicitly instead of dropping them.

### Widget library

- `LiveUi.Widgets`
  - Public component namespace for direct widget composition.
  - Exposes the same widget semantics used by IUR-driven rendering.
- `LiveUi.WidgetRegistry`
  - Maps normalized kinds to independent widget and layout implementations.
- `LiveUi.Components.Layouts`
  - Owns layout containers such as `vbox`, `hbox`, `viewport`, and `split_pane`.
- `LiveUi.Components.BasicWidgets`
  - Owns core widgets such as `text`, `button`, `label`, and `text_input`.
- `LiveUi.Components.DataViz`
  - Owns data visualization widgets such as `gauge`, `sparkline`, `bar_chart`, `line_chart`, and `canvas`.
- `LiveUi.Components.Navigation`
  - Owns menus, tabs, tree views, commands, and related navigation widgets.
- `LiveUi.Components.Feedback`
  - Owns dialogs, alert dialogs, toasts, and related feedback widgets.
- `LiveUi.Components.Forms`
  - Owns form builders, pick lists, fields, and advanced input widgets.
- `LiveUi.Components.Extensions`
  - Owns explicitly adopted extension widgets that are not yet canonical but are part of the library contract.

### Theme system

- `LiveUi.Style.Compiler`
  - Maps `UnifiedIUR` style values into semantic classes, CSS variables, and inline geometry where needed.
- `LiveUi.Style.Theme`
  - Owns the library theme contract, default design tokens, variants, and host-overridable theme surfaces.

### Layer system

- `LiveUi.Layers`
  - Owns stacking order, overlay roots, backdrop semantics, and floating-surface coordination.
- `LiveUi.WidgetState`
  - Stores server-authoritative UI-only state such as active tabs, tree expansion, table sort state, viewport scroll position, split percentages, command palette query, dialog visibility, toast visibility, and other layer-affecting widget state.

### LiveView runtime

- `LiveUi.Runtime.Model`
  - Stores source input, domain state, widget state, render tree, signal bindings, layer state, errors, and render metadata.
- `LiveUi.Runtime`
  - Owns the deterministic rebuild cycle.
  - Rebuild sequence: current source -> canonical IUR -> normalized render tree -> rendered assigns.
- `LiveUi.Live.Engine`
  - Internal generic LiveView runtime engine.
  - Mounts the runtime model using host-provided session and params, handles `phx-*` events and hook-originated events, rebuilds the render tree, and reassigns the view.
- `LiveUi.Live.DynamicLive`
  - Public generic entry point for canonical `UnifiedIUR` and validated runtime-selected sources.
- host-defined wrapper LiveViews
  - Thin host-facing LiveViews that delegate to `LiveUi.Live.Engine` through `use LiveUi.Screen, source: MyApp.SomeSource`.

### Event and signal bridge

- `LiveUi.Signals.Encoder`
  - Converts LiveView events into concrete `%Jido.Signal{}` values with stable `data` payloads.
- `LiveUi.Live.EventRouter`
  - Extracts widget metadata from `phx-value-*` payloads.
  - Accepts hook-originated payloads through the same normalization boundary.
  - Merges widget-local and layer-local state changes before source updates when needed.

## Data Flow

### Direct widget path

1. A host composes a screen directly from public `live_ui` widgets and layouts.
2. The public widget surface uses the same semantic contracts, theme system, and layer system as IUR-driven rendering.
3. Events flow through the same signal bridge and runtime helpers where interaction state is needed.

### Canonical IUR path

1. A host route, component, or preview tool provides canonical `UnifiedIUR` input.
2. `LiveUi.Source.IUR` validates schema markers when present.
3. `LiveUi.IUR.Interpreter` normalizes the input into a render tree used by the widget library.
4. `LiveUi.WidgetRegistry` resolves each node to the same underlying widget or layout implementation used by the direct widget path.
5. `LiveUi.Style.Compiler` and `LiveUi.Style.Theme` apply theme tokens, variants, and semantic styling.
6. `LiveUi.Layers` coordinates overlays, floating surfaces, and stacking semantics.
7. The shared engine emits HEEx from the widget library.
8. User events are encoded back into concrete `%Jido.Signal{}` values and routed through the runtime.
9. The runtime rebuilds the render tree and lets LiveView diff the DOM.

### Source-module adapter path

1. A host-defined wrapper LiveView is written manually with `use LiveUi.Screen, source: MyApp.SomeSource`.
2. `LiveUi.Session` normalizes host route params, session values, and assigns into runtime context.
3. The source module runs `init/1` and `update/2`.
4. The source module emits canonical `UnifiedIUR` from `view/1`.
5. The runtime enters the same canonical IUR path described above.

## Widget Library Responsibilities

The independent widget library should own:

- layout primitives
- basic controls and text presentation
- forms and validation surfaces
- navigation and hierarchical widgets
- feedback and overlay widgets
- data visualization widgets
- adopted extension widgets required by the supported IUR contract
- the semantic contract between render-tree traits and actual DOM structure
- a public component API for directly composing screens without `UnifiedIUR`

The library should not depend on upstream renderers from `unified_ui` or any other producer.

## Theme System Responsibilities

The theme system should own:

- default design tokens for spacing, typography, color, elevation, and motion
- semantic component variants derived from `UnifiedIUR` style metadata
- stable CSS variable and class contracts for host overrides
- host-specific theme extension points that do not require changing IUR payload shapes
- consistent theme behavior across both direct widget use and IUR-driven rendering

`UnifiedIUR` may carry style intent, but `live_ui` should decide how that intent maps onto the concrete rendered theme contract.

## Layer System Responsibilities

The layer system should own:

- z-order and overlay precedence
- backdrop behavior
- floating and anchored surface coordination
- focus return, escape handling, and transient dismissal semantics
- consistent mounting surfaces for dialogs, toasts, menus, palettes, and other floating widgets
- shared behavior across both direct widget use and IUR-driven rendering

Layering should be treated as a first-class rendering concern rather than as incidental widget-specific markup.

## State Model

`live_ui` should keep the following state domains explicit:

- source domain state owned by the source module, if one exists
- widget-local state owned by the library runtime
- layer-local state owned by the layer system
- render metadata derived from the normalized render tree
- runtime context supplied by the host

These domains should remain separate so the library can rebuild deterministically and keep server state authoritative.

## Compatibility Story

`UnifiedIUR` is the core compatibility contract.

- `live_ui` should work directly with canonical `UnifiedIUR` without requiring `unified_ui`.
- `unified_ui` is one possible upstream producer of `UnifiedIUR`, not a required runtime dependency for the widget library itself.
- explicitly adopted extension kinds may remain supported where the library chooses to extend the canonical contract.
- the public widget API should remain aligned with the same semantics that the interpreter expects from `UnifiedIUR`.

## Verification Strategy

The architecture should be verified through:

- interpreter tests that validate schema markers, signal extraction, and render-tree normalization
- widget-library tests that prove kind coverage, direct widget composition, styling, layering, and server-correct rendering
- runtime tests that prove deterministic rebuilds and server-authoritative widget state
- golden tests that show canonical `UnifiedIUR` and adapter-produced `UnifiedIUR` render identically after the IUR boundary
- parity tests that show direct widget usage and IUR-driven rendering share the same library semantics where equivalent
