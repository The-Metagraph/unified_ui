# Phase 1.5 - SDL3 Native Adapter Seam and Render-Plan Skeleton

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `DesktopUi.Sdl3`
- `DesktopUi.Sdl3.App`
- `DesktopUi.Sdl3.Lifecycle`
- `DesktopUi.Sdl3.Window`
- `DesktopUi.Sdl3.RenderPlan`
- `DesktopUi.Sdl3.Renderer`
- `DesktopUi.Sdl3.Events`
- `DesktopUi.Sdl3.Text`
- `DesktopUi.Sdl3.Images`
- `DesktopUi.Runtime`
- `DesktopUi.Renderer`
- `DesktopUi.Reference`
- `DesktopUi.Inspect`

## Relevant Assumptions / Defaults
- This phase introduces a real SDL3-facing adapter seam, but it does not yet
  require full widget-complete native rendering.
- The retained widget/runtime model defined in earlier phases remains the
  semantic source of truth; SDL3-facing modules must adapt that model rather
  than replace it.
- The first concrete native backend remains SDL3 `SDL_Renderer`, while future
  backend evolution such as `SDL_GPU` must stay behind the same adapter
  boundary.
- SDL3 companion-library seams for text and images should be explicit in the
  package surface even if the first implementation remains skeletal or
  diagnostic-heavy.

[ ] 1.5 Phase 1.5 - SDL3 Native Adapter Seam and Render-Plan Skeleton
  Introduce the first concrete SDL3-facing implementation boundary for
  `desktop_ui` so callback lifecycle ownership, native windows, render-plan
  presentation, event intake, and companion-resource access all have one
  coherent adapter seam before full renderer completeness is pursued.

  [ ] 1.5.1 Section - SDL3 App Ownership and Runtime Handoff
    Implement the package-facing adapter modules that own SDL3 application
    lifecycle concerns and connect the existing semantic desktop runtime to
    callback-driven native execution.

    [ ] 1.5.1.1 Task - Define SDL3 app lifecycle adapter modules
      Create the explicit SDL3-facing modules that describe how `desktop_ui`
      boots, iterates, and shuts down through the callback-oriented native app
      model.

      [ ] 1.5.1.1.1 Subtask - Introduce `DesktopUi.Sdl3` and `DesktopUi.Sdl3.App` as the canonical namespace for SDL3-facing adapter entrypoints.
      [ ] 1.5.1.1.2 Subtask - Define lifecycle contracts for initialization, event callback dispatch, frame iteration, and shutdown without forcing the rest of the package to speak in raw SDL3 callback terms.
      [ ] 1.5.1.1.3 Subtask - Define bounded adapter diagnostics for invalid boot requests, callback ordering failures, and mismatched shutdown state.

    [ ] 1.5.1.2 Task - Define semantic-runtime handoff contracts
      Establish the boundary objects that hand semantic runtime state into the
      SDL3 adapter without collapsing the higher-level package model into
      native-only state.

      [ ] 1.5.1.2.1 Subtask - Define adapter-facing boot requests, window session descriptors, and frame request state that can be produced from the existing `DesktopUi.Runtime` model.
      [ ] 1.5.1.2.2 Subtask - Define the authoritative handoff between semantic runtime realization, redraw intent, and native presentation requests.
      [ ] 1.5.1.2.3 Subtask - Preserve the package rule that direct-native and canonical-IUR entrypoints converge onto one shared runtime model before they cross into SDL3-facing adapter code.

  [ ] 1.5.2 Section - Native Window Registry and Presentation Seam
    Implement the first concrete native window and presentation contracts so
    `desktop_ui` can describe real SDL3 window ownership and frame preparation
    without needing every widget to draw natively yet.

    [ ] 1.5.2.1 Task - Define native window registry and session adapters
      Create the adapter modules and data contracts that map top-level
      `desktop_ui` windows to real SDL3-native windows.

      [ ] 1.5.2.1.1 Subtask - Define `DesktopUi.Sdl3.Window` state and registry contracts for top-level windows, multiwindow flows, and owned transient layers.
      [ ] 1.5.2.1.2 Subtask - Distinguish native-window ownership from in-window transient layers such as overlays, popovers, context menus, and dialogs.
      [ ] 1.5.2.1.3 Subtask - Define adapter diagnostics for invalid window reuse, lost owner-window context, and unsupported native-window transitions.

    [ ] 1.5.2.2 Task - Define render-plan and presentation boundary contracts
      Introduce the retained-rendering boundary that turns semantic widget
      state into SDL3-facing frame instructions before actual low-level drawing
      becomes feature complete.

      [ ] 1.5.2.2.1 Subtask - Define `DesktopUi.Sdl3.RenderPlan` structures that capture logical bounds, layering, clipping, styling resolution output, and placeholder draw operations.
      [ ] 1.5.2.2.2 Subtask - Define `DesktopUi.Sdl3.Renderer` or equivalent adapter modules that accept render plans and present them through an SDL_Renderer-first contract.
      [ ] 1.5.2.2.3 Subtask - Keep render-plan generation and presentation adapter code separate so future SDL3 backend evolution does not rewrite widget or layout semantics.

  [ ] 1.5.3 Section - SDL3 Events and Companion Resource Boundaries
    Implement the native input and asset seams that let SDL3 callbacks,
    pointer/keyboard events, text rendering, and image resources enter the
    existing desktop runtime in a bounded way.

    [ ] 1.5.3.1 Task - Define SDL3 event intake and normalization contracts
      Create the first SDL3-facing input modules that normalize callback and
      event payloads into the package’s semantic interaction model.

      [ ] 1.5.3.1.1 Subtask - Define `DesktopUi.Sdl3.Events` contracts for keyboard, pointer, wheel, hover, drag-initiation, focus, and multiwindow activation events.
      [ ] 1.5.3.1.2 Subtask - Define how SDL3 event payloads are normalized before later transport translation maps cross-package meaning into canonical `Jido.Signal` semantics.
      [ ] 1.5.3.1.3 Subtask - Define diagnostics for unsupported event payloads, invalid focus transitions, and mismatched window-local event routing.

    [ ] 1.5.3.2 Task - Define text and image companion-library seams
      Create explicit package seams for text and image resource preparation so
      later native drawing work does not couple widget semantics directly to
      low-level SDL companion-library usage.

      [ ] 1.5.3.2.1 Subtask - Define `DesktopUi.Sdl3.Text` contracts for font selection, text measurement, and text surface preparation aligned with the SDL_ttf-first spec direction.
      [ ] 1.5.3.2.2 Subtask - Define `DesktopUi.Sdl3.Images` contracts for image decoding, image surface preparation, and raw-pixel fallback aligned with the SDL_image-first spec direction.
      [ ] 1.5.3.2.3 Subtask - Keep text and image seams explicit enough that future platform-native resource backends can evolve behind the same adapter boundary.

  [ ] 1.5.4 Section - Diagnostics, Reference Surfaces, and Evolution Boundaries
    Expose the new SDL3 adapter seam through package-facing inspection and
    reference surfaces so maintainers can reason about the native backend
    contract before the renderer is fully realized.

    [ ] 1.5.4.1 Task - Extend reference and inspection surfaces for SDL3 adapters
      Make the new adapter boundary visible through package helpers without
      requiring native rendering completeness.

      [ ] 1.5.4.1.1 Subtask - Extend package reference surfaces to list SDL3 adapter namespaces, lifecycle ownership boundaries, and native-window mapping responsibilities.
      [ ] 1.5.4.1.2 Subtask - Extend inspection surfaces to summarize render-plan readiness, event normalization seams, and companion-resource boundaries.
      [ ] 1.5.4.1.3 Subtask - Keep helper output explicit about what is skeletal, what is native-backed, and what remains future renderer work.

    [ ] 1.5.4.2 Task - Document bounded backend evolution and incomplete-renderer rules
      Capture how this adapter skeleton constrains future native rendering work
      so maintainers do not treat the seam as throwaway scaffolding.

      [ ] 1.5.4.2.1 Subtask - Document that SDL_Renderer is the first concrete backend and that future SDL_GPU work must preserve the same render-plan and runtime semantics.
      [ ] 1.5.4.2.2 Subtask - Document that the adapter skeleton is allowed to use placeholder draw operations while still exposing authoritative lifecycle, window, and event contracts.
      [ ] 1.5.4.2.3 Subtask - Define validation expectations that prevent helper surfaces from overstating native rendering completeness before later phases deliver it.

  [ ] 1.5.5 Section - Phase 1.5 Integration Tests
    Validate that the new SDL3 adapter seam is real, bounded, and visible
    through the package even before full native widget drawing exists.

    [ ] 1.5.5.1 Task - SDL3 adapter skeleton integration scenarios
      Verify the package can describe a coherent native SDL3 runtime boundary
      without collapsing semantic widget/runtime code into backend-specific
      details.

      [ ] 1.5.5.1.1 Subtask - Verify SDL3 app lifecycle adapters, runtime handoff objects, native window sessions, and render-plan adapters compile and connect coherently.
      [ ] 1.5.5.1.2 Subtask - Verify a minimal native screen can produce native-window and render-plan state through the SDL3 adapter seam without requiring full widget-complete drawing.
      [ ] 1.5.5.1.3 Subtask - Verify invalid callback ordering, malformed event payloads, or broken window ownership fail with deterministic adapter diagnostics.

    [ ] 1.5.5.2 Task - Reference and diagnostics integration scenarios
      Verify the package surfaces the new SDL3 adapter seam clearly enough for
      maintainers to inspect and evolve it safely.

      [ ] 1.5.5.2.1 Subtask - Verify reference helpers expose SDL3 adapter namespaces, lifecycle boundaries, and render-plan responsibilities.
      [ ] 1.5.5.2.2 Subtask - Verify inspection helpers report adapter readiness, text/image seam availability, and bounded backend-evolution assumptions.
      [ ] 1.5.5.2.3 Subtask - Verify helper and validation output distinguishes adapter-skeleton coverage from later full-renderer completeness.
