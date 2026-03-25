# Phase 8 - SDL3 Native Build, Visible Window Runtime, and Backend Selection

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `DesktopUi.Sdl3.NativeBuild`
- `DesktopUi.Sdl3.Capabilities`
- `DesktopUi.Sdl3.PortHost`
- `DesktopUi.Sdl3.NativeHost`
- `DesktopUi.Sdl3.Renderer`
- `DesktopUi.Inspect`
- `DesktopUi.Validate`
- `mix desktop_ui.build_host`
- `mix desktop_ui.run`

## Relevant Assumptions / Defaults
- This phase turns the current host-backed SDL3 seam into a buildable native
  runtime path that can open visible windows on machines with SDL3 available,
  while keeping CI and SDL3-less environments on a bounded Elixir-host
  fallback.
- The default maintainers' experience should prefer the compiled SDL3 host when
  it is built and runnable, but fallback behavior must remain explicit instead
  of silently overstating native completeness.
- `SDL_Renderer` remains the first concrete drawing backend and may realize a
  bounded subset of widget visuals through placeholder-oriented drawing
  semantics as long as frames are actually shown in real native windows.
- SDL3 companion-library paths for text and image resources remain optional at
  build time in this phase; missing native dependencies must produce clear
  diagnostics rather than hidden runtime failure.
- Elixir continues to own widget semantics, canonical IUR rendering, runtime
  state, transport meaning, and validation logic above the host boundary.

[ ] 8 Phase 8 - SDL3 Native Build, Visible Window Runtime, and Backend Selection
  Add the first buildable native SDL3 host workflow for `desktop_ui` by
  defining host-build capabilities, compiling a real SDL3 executable when
  dependencies exist, selecting between compiled and fallback host backends,
  and turning the current host-backed execution path into a visible-window
  maintainer workflow.

  [x] 8.1 Section - Native Build Workflow and Capability Discovery
    Define how the package detects native SDL3 support, where the host source
    and executable live, and how maintainers discover whether they can run the
    visible native backend on their machine.

    [x] 8.1.1 Task - Define the native host build surface
      Introduce the package-level modules and plan surface that describe the
      future compiled SDL3 host without requiring it to exist yet.

      [x] 8.1.1.1 Subtask - Add a dedicated Phase 8 plan file and planning index entry for visible-window SDL3 execution.
      [x] 8.1.1.2 Subtask - Introduce a `DesktopUi.Sdl3.NativeBuild` surface that defines source roots, output paths, executable naming, and build-recipe boundaries.
      [x] 8.1.1.3 Subtask - Keep the native build surface separate from host runtime ownership so later build logic does not leak into semantic runtime modules.

    [x] 8.1.2 Task - Define SDL3 capability discovery and backend recommendation rules
      Make native host availability reviewable before the package starts trying
      to run compiled SDL3 code.

      [x] 8.1.2.1 Subtask - Introduce a `DesktopUi.Sdl3.Capabilities` surface for discovering compilers, SDL3 libraries, and built host executables.
      [x] 8.1.2.2 Subtask - Define deterministic backend recommendation rules for compiled-native, fallback-Elixir, and missing-dependency states.
      [x] 8.1.2.3 Subtask - Surface capability and build-readiness diagnostics through inspection, reference, info, and validation helpers.

  [x] 8.2 Section - SDL3 Native Host Build and Launch Selection
    Build the first compiled SDL3 host executable and teach the package how to
    launch it when native prerequisites are satisfied.

    [x] 8.2.1 Task - Add the compiled SDL3 host source and build task
      Introduce the native source tree and the package task that turns it into
      a runnable host executable.

      [x] 8.2.1.1 Subtask - Add a native host source tree under `packages/desktop_ui/native/desktop_ui_sdl3_host`.
      [x] 8.2.1.2 Subtask - Add `mix desktop_ui.build_host` to compile the native host using discovered SDL3 toolchain and library settings.
      [x] 8.2.1.3 Subtask - Make build failures deterministic and diagnostic when compilers or SDL3 companion libraries are missing.

    [x] 8.2.2 Task - Teach the host boundary to choose compiled or fallback execution
      Update the current port-host launch path so maintainers can run the real
      native host when it exists while preserving a bounded fallback path.

      [x] 8.2.2.1 Subtask - Prefer the compiled SDL3 host when a built executable is present and compatible.
      [x] 8.2.2.2 Subtask - Keep the current Elixir host available as an explicit fallback for CI and SDL3-less environments.
      [x] 8.2.2.3 Subtask - Surface which backend was chosen through host status, inspection, and run-task output.

  [x] 8.3 Section - Visible Window Presentation and Frame Lifecycle
    Replace placeholder-only host reporting with real visible SDL3 window and
    frame presentation behavior for the compiled host path.

    [x] 8.3.1 Task - Implement visible native-window boot and lifecycle handling
      Make the compiled SDL3 host create real windows, honor the callback
      lifecycle, and remain alive long enough for maintainers to observe the
      rendered frame.

      [x] 8.3.1.1 Subtask - Map booted `desktop_ui` windows to actual SDL3 windows in the compiled host.
      [x] 8.3.1.2 Subtask - Keep callback lifecycle, redraw, and shutdown handling aligned with the existing Elixir-owned runtime contract.
      [x] 8.3.1.3 Subtask - Support bounded linger or quit behavior so visible-window runs are testable and maintainable.

    [x] 8.3.2 Task - Implement real frame drawing for visible placeholder semantics
      Use `SDL_Renderer` to draw visible window chrome, surfaces, and
      placeholder widget bounds from the existing retained render plan.

      [x] 8.3.2.1 Subtask - Realize logical bounds, clear colors, and clip regions in real SDL3 renderer calls.
      [x] 8.3.2.2 Subtask - Draw visible placeholder geometry for core draw kinds such as window chrome, layer shells, viewport regions, and widget placeholders.
      [x] 8.3.2.3 Subtask - Distinguish real visible drawing from still-unimplemented widget-complete rendering in host diagnostics and renderer summaries.

  [ ] 8.4 Section - Native Resources, Tooling, and Visible Execution Diagnostics
    Extend the visible host path so it reports native dependency state,
    optional resource support, and maintainer workflow details clearly.

    [ ] 8.4.1 Task - Extend native resource handling and diagnostics
      Make text and image companion-library support visible in the compiled-host
      build and runtime story without requiring every machine to have them.

      [ ] 8.4.1.1 Subtask - Add build/runtime diagnostics for SDL3 text and image companion-library availability.
      [ ] 8.4.1.2 Subtask - Keep text/image requests bounded and reviewable when the visible host is running without full companion-library support.
      [ ] 8.4.1.3 Subtask - Preserve existing Elixir-side resource contracts while reporting which parts are truly native-backed.

    [ ] 8.4.2 Task - Update maintainer tooling and docs for visible execution
      Make the visible SDL3 runtime path easy to build, run, inspect, and
      troubleshoot from package-local workflows.

      [ ] 8.4.2.1 Subtask - Extend `mix desktop_ui.run` and related helpers with backend and visible-runtime diagnostics.
      [ ] 8.4.2.2 Subtask - Document SDL3 native prerequisites, build steps, and fallback behavior in the package README and guides.
      [ ] 8.4.2.3 Subtask - Extend validation and reference surfaces so maintainers can tell whether native build, native run, and fallback execution are each healthy.

  [ ] 8.5 Section - Phase 8 Integration Tests
    Validate the buildable and visible SDL3 host path end to end while keeping
    CI trustworthy on machines without SDL3 installed.

    [ ] 8.5.1 Task - Native build and backend-selection integration scenarios
      Verify the package chooses the correct execution path depending on build
      and dependency state.

      [ ] 8.5.1.1 Subtask - Verify capability detection distinguishes compiled-native-ready, buildable-but-not-built, and fallback-only environments.
      [ ] 8.5.1.2 Subtask - Verify the port host prefers a compiled native host when available and falls back explicitly when it is not.
      [ ] 8.5.1.3 Subtask - Verify run, inspect, and validation tooling report the selected backend and dependency state deterministically.

    [ ] 8.5.2 Task - Visible execution and diagnostics integration scenarios
      Verify the visible SDL3 execution path remains bounded, reviewable, and
      semantically aligned with the retained runtime contract.

      [ ] 8.5.2.1 Subtask - Verify the compiled host path can acknowledge boot, present at least one visible frame, and shut down cleanly when SDL3 is available.
      [ ] 8.5.2.2 Subtask - Verify validation and inspection distinguish real visible-frame execution from fallback or placeholder-only execution.
      [ ] 8.5.2.3 Subtask - Verify logical units, window ownership, and transport/event semantics remain coherent across compiled-native and fallback host backends.
