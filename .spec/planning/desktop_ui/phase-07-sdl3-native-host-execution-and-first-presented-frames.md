# Phase 7 - SDL3 Native Host Execution and First Presented Frames

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `DesktopUi.Sdl3.App`
- `DesktopUi.Sdl3.RenderPlan`
- `DesktopUi.Sdl3.Renderer`
- `DesktopUi.Sdl3.Events`
- `DesktopUi.Sdl3.Text`
- `DesktopUi.Sdl3.Images`
- `DesktopUi.Runtime`
- `DesktopUi.Transport`
- `DesktopUi.Inspect`
- `DesktopUi.Validate`

## Relevant Assumptions / Defaults
- This phase turns the existing SDL3 adapter seam into a real executable native
  runtime path without replacing the retained widget/runtime model that already
  exists in Elixir.
- The first executable SDL3 runtime shall use a native host process launched
  from Elixir through a bounded host boundary rather than a long-lived
  NIF-owned frame loop.
- Elixir remains the source of truth for widget semantics, canonical IUR
  rendering, style resolution, transport meaning, and validation.
- The native host owns SDL3 callback lifecycle execution, native window
  handles, renderer lifetime, companion-resource lifetime, and event pumping on
  the native side.
- The first executable presentation backend remains SDL3 `SDL_Renderer`; any
  future `SDL_GPU` path must preserve the same host boundary and semantic
  contract.
- This phase may begin with placeholder or simplified widget drawing, but it
  must produce real native windows, real frame presentation, and real event
  round-trips.

[x] 7 Phase 7 - SDL3 Native Host Execution and First Presented Frames
  Introduce the first real executable SDL3-native runtime path for
  `desktop_ui` by adding a native host process, framed Elixir-to-native
  coordination, real native window ownership, real presented frames, and
  event/resource round-trips that preserve the package’s retained semantic
  model.

  [x] 7.1 Section - Native Host Process and Framed Runtime Protocol
    Define and implement the executable native-host boundary that allows Elixir
    runtime state and render intent to cross into an SDL3-owned process
    without collapsing package semantics into backend-specific code.

    [x] 7.1.1 Task - Define the SDL3 native-host ownership model
      Establish the package-level host boundary, launch semantics, and failure
      model for the native process that will own SDL3 execution.

      [x] 7.1.1.1 Subtask - Introduce explicit host-facing modules such as `DesktopUi.Sdl3.Host` and a default implementation such as `DesktopUi.Sdl3.PortHost`.
      [x] 7.1.1.2 Subtask - Define how native-host boot, liveness, shutdown, crash reporting, and version compatibility are represented on the Elixir side.
      [x] 7.1.1.3 Subtask - Keep the host boundary narrow enough that Elixir runtime, renderer, transport, and widget modules remain authoritative above it.

    [x] 7.1.2 Task - Define the framed Elixir-to-native protocol
      Create the message protocol that carries boot requests, render plans,
      events, diagnostics, and resource requests between Elixir and the SDL3
      host process.

      [x] 7.1.2.1 Subtask - Define protocol message families for boot, window lifecycle, frame presentation, event batches, text/image resources, diagnostics, and shutdown.
      [x] 7.1.2.2 Subtask - Define framing, message correlation, and error envelopes so host communication remains deterministic under partial failures.
      [x] 7.1.2.3 Subtask - Separate control messages from larger payloads so future text/image/resource traffic can evolve without rewriting the whole protocol.

  [x] 7.2 Section - SDL3 Callback Lifecycle and Native Window Execution
    Turn the current lifecycle and window seam into a real executable SDL3 app
    that owns the native main-thread runtime and maps `desktop_ui` windows onto
    real SDL3 windows.

    [x] 7.2.1 Task - Implement the callback-driven SDL3 host application skeleton
      Build the first native executable path that uses SDL3’s callback-oriented
      lifecycle to initialize, iterate, process events, and quit cleanly.

      [x] 7.2.1.1 Subtask - Implement host-side lifecycle handling for `SDL_AppInit`, `SDL_AppEvent`, `SDL_AppIterate`, and `SDL_AppQuit`.
      [x] 7.2.1.2 Subtask - Define how booted Elixir runtime state becomes host-managed SDL app state without duplicating semantic runtime logic.
      [x] 7.2.1.3 Subtask - Surface deterministic diagnostics for invalid callback ordering, unsupported initialization environments, and unrecoverable host boot failures.

    [x] 7.2.2 Task - Execute real native-window ownership and update flows
      Make the host create, update, focus, resize, and close real SDL3 windows
      according to the package’s native-window mapping rules.

      [x] 7.2.2.1 Subtask - Map top-level `desktop_ui` windows and multiwindow sessions to real SDL3 windows with stable host-side identities.
      [x] 7.2.2.2 Subtask - Keep overlays, dialogs, popovers, and context menus as in-window layered surfaces by default while preserving their owner-window relationship.
      [x] 7.2.2.3 Subtask - Implement bounded host-side handling for DPI changes, window moves, resize callbacks, and focus transitions without drifting from the shared runtime contract.

  [x] 7.3 Section - Render-Plan Encoding and First Presented Frames
    Convert retained render plans into actual SDL3-presented frames so the
    package moves from placeholder reporting to real native presentation.

    [x] 7.3.1 Task - Encode retained render plans for host presentation
      Define how Elixir-side render plans become host-side drawing commands
      while preserving logical units, clipping, layering, and styling meaning.

      [x] 7.3.1.1 Subtask - Introduce explicit frame-encoding modules that serialize `DesktopUi.Sdl3.RenderPlan` data into the framed host protocol.
      [x] 7.3.1.2 Subtask - Preserve logical bounds, window assignment, clip regions, transient layers, and resolved style output through the encoded frame format.
      [x] 7.3.1.3 Subtask - Keep render-plan encoding independent from host drawing internals so future renderer evolution does not rewrite Elixir-side widget or layout semantics.

    [x] 7.3.2 Task - Present the first real frames through SDL_Renderer
      Implement a concrete `SDL_Renderer`-first draw loop that can clear
      windows, apply logical presentation, and draw retained-plan operations
      into visible native frames.

      [x] 7.3.2.1 Subtask - Implement host-side logical-presentation setup so `desktop_ui` logical units resolve consistently across DPI differences.
      [x] 7.3.2.2 Subtask - Implement first-pass drawing for core retained draw operations such as background fills, bounds, placeholder surfaces, text labels, and layer shells.
      [x] 7.3.2.3 Subtask - Implement present and redraw scheduling so frame output is visible, repeatable, and only reissued when runtime redraw intent requires it.

  [x] 7.4 Section - Text, Image, and Event Round-Trip Execution
    Complete the first executable round-trip by turning companion-resource and
    native event seams into real host-managed behavior that feeds back into the
    Elixir runtime.

    [x] 7.4.1 Task - Implement host-managed text and image resources
      Turn the existing SDL3 text/image seams into real host-side resource
      preparation that can support presented frames.

      [x] 7.4.1.1 Subtask - Implement host-side font loading, text measurement, and text surface or texture preparation aligned with the SDL_ttf-first package direction.
      [x] 7.4.1.2 Subtask - Implement host-side image decoding and image surface or texture preparation aligned with the SDL_image-first package direction.
      [x] 7.4.1.3 Subtask - Define resource caching, invalidation, and failure diagnostics so text/image lifetime remains bounded and reviewable.

    [x] 7.4.2 Task - Implement native event flow back into the Elixir runtime
      Close the loop by letting real SDL3 input and window events re-enter the
      retained `desktop_ui` runtime through the host protocol.

      [x] 7.4.2.1 Subtask - Translate keyboard, pointer, wheel, focus, hover, drag-initiation, and window events from SDL3 into host protocol event envelopes.
      [x] 7.4.2.2 Subtask - Reuse `DesktopUi.Sdl3.Events` and `DesktopUi.Transport` semantics so native host execution does not invent a parallel interaction model.
      [x] 7.4.2.3 Subtask - Validate end-to-end event round-trips for local handling, boundary-worthy signals, and multiwindow focus transitions.

  [x] 7.5 Section - Tooling, Diagnostics, and Local Execution Workflow
    Make the real native execution path visible and usable for maintainers so
    SDL3 execution can be inspected and validated as part of daily package
    development.

    [x] 7.5.1 Task - Extend package tooling for executable SDL3 runs
      Add maintainer workflows that can launch, inspect, and validate the real
      host-backed execution path rather than only semantic helper surfaces.

      [x] 7.5.1.1 Subtask - Introduce a package-local run or preview workflow that boots the SDL3 host for a maintained native or canonical example.
      [x] 7.5.1.2 Subtask - Extend inspection and validation helpers to report host readiness, protocol state, presented-frame diagnostics, and resource status.
      [x] 7.5.1.3 Subtask - Document the local prerequisites for building and running the SDL3 host on supported development targets.

    [x] 7.5.2 Task - Add bounded diagnostics and fallback rules for real execution
      Keep the first executable path trustworthy by making host/runtime
      failures easy to diagnose and by being explicit about what remains
      placeholder-level.

      [x] 7.5.2.1 Subtask - Surface clear diagnostics for host boot failure, protocol mismatch, missing SDL3 runtime resources, and failed frame presentation.
      [x] 7.5.2.2 Subtask - Distinguish between real native execution coverage and still-placeholder widget rendering so tooling does not overstate completeness.
      [x] 7.5.2.3 Subtask - Keep backend-evolution rules explicit so later SDL_GPU exploration remains subordinate to the same execution, protocol, and runtime contract.

  [x] 7.6 Section - Phase 7 Integration Tests
    Validate the first executable SDL3 runtime path end to end so maintainers
    can trust that `desktop_ui` now owns a real native execution boundary and
    not only a semantic adapter skeleton.

    [x] 7.6.1 Task - Native host execution integration scenarios
      Verify the host-backed runtime can boot, present frames, and process
      events without breaking the retained package model.

      [x] 7.6.1.1 Subtask - Verify a maintained native example can boot through the SDL3 host, create a real native window, and present at least one visible frame.
      [x] 7.6.1.2 Subtask - Verify a maintained canonical `UnifiedIUR` example can follow the same path through the renderer, host protocol, and presented-frame loop.
      [x] 7.6.1.3 Subtask - Verify native input events can round-trip from SDL3 into Elixir runtime handling and, when appropriate, back out through canonical boundary translation.

    [x] 7.6.2 Task - Diagnostics and execution-boundary integration scenarios
      Verify host/process failures remain bounded and reviewable instead of
      destabilizing the package runtime model.

      [x] 7.6.2.1 Subtask - Verify host boot errors, protocol mismatches, and missing resource dependencies fail with deterministic diagnostics.
      [x] 7.6.2.2 Subtask - Verify inspection and validation workflows distinguish executable-frame coverage from placeholder or unimplemented widget rendering.
      [x] 7.6.2.3 Subtask - Verify the executable SDL3 host path preserves existing package invariants around logical units, transport meaning, and shared native-vs-canonical runtime behavior.
