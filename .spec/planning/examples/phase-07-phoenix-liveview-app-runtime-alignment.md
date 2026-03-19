# Phase 7 - Phoenix LiveView App Runtime Alignment

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/shared`
- `UnifiedExamples.Shared.Template`
- `UnifiedExamples.Shared.Runtime`
- `UnifiedExamples.Shared.Tooling`
- `LiveUi.Runtime`
- `LiveUi.Component`
- `Phoenix.Endpoint`
- `Phoenix.Router`
- `Phoenix.LiveView`
- `mix phx.server`

## Relevant Assumptions / Defaults
- The example suite already demonstrates the authored `UnifiedUi` DSL to canonical `UnifiedIUR` to `live_ui` rendering path, but the per-app runtime shape must now be upgraded to real Phoenix LiveView applications.
- Every example app should keep the shared template, shared default theme, and shared default style profile even after it gains its own Phoenix endpoint and browser-facing runtime.
- The goal of this phase is not to replace the shared suite tooling, but to make that tooling operate against real LiveView apps that can also be launched independently with `mix phx.server`.

[x] 7 Phase 7 - Phoenix LiveView App Runtime Alignment
  Retrofit the existing example suite so every example directory becomes a real Phoenix LiveView app with its own endpoint, router, LiveView entrypoint, and browser launch workflow while preserving the shared authored DSL template and shared styling contract.

  [x] 7.1 Section - Phoenix App Baseline Per Example
    Define the standard Phoenix application shape that every example app must implement so all widget examples share one consistent runtime contract.

    [x] 7.1.1 Task - Establish the canonical Phoenix application skeleton
      Add the baseline application modules and configuration required for each example directory to boot as an independent Phoenix LiveView app.

      [x] 7.1.1.1 Subtask - Define the required per-app files for `Application`, `Endpoint`, `Router`, root layout, and LiveView entrypoint modules.
      [x] 7.1.1.2 Subtask - Define the required per-app Phoenix and HTTP runtime dependencies, supervision tree entries, and endpoint configuration surface.
      [x] 7.1.1.3 Subtask - Add validation checks that fail when an example app does not expose a runnable Phoenix baseline.

    [x] 7.1.2 Task - Standardize the browser-facing example route contract
      Ensure every example app mounts its widget demonstration through one consistent browser route and LiveView entrypoint shape.

      [x] 7.1.2.1 Subtask - Define the required browser route, LiveView mount path, and root layout contract for every example app.
      [x] 7.1.2.2 Subtask - Define the assigns contract that passes shared template output and runtime metadata into the LiveView entrypoint.
      [x] 7.1.2.3 Subtask - Add checks that verify every example app exposes a predictable URL and page shell.

  [x] 7.2 Section - Shared Phoenix Support and Runtime Reuse
    Extend the shared examples support library so the suite can generate and validate Phoenix app behavior without duplicating the same runtime boilerplate in every example.

    [x] 7.2.1 Task - Add shared helpers for Phoenix app generation and mounting
      Provide reusable helpers that reduce duplication across app-local Phoenix modules while keeping each example independently runnable.

      [x] 7.2.1.1 Subtask - Add shared helpers for building app-local endpoints, routers, layouts, and LiveView mount modules.
      [x] 7.2.1.2 Subtask - Reuse the existing authored DSL template and canonical runtime helpers inside the new Phoenix entrypoint path.
      [x] 7.2.1.3 Subtask - Add tests that prove shared helpers can support multiple example apps without leaking widget-specific behavior.

    [x] 7.2.2 Task - Align shared tooling with the Phoenix runtime contract
      Update suite tooling so preview, validation, and execution workflows recognize LiveView app launch as a first-class capability.

      [x] 7.2.2.1 Subtask - Add a launch descriptor or command surface that points maintainers to the correct `mix phx.server` entrypoint per app.
      [x] 7.2.2.2 Subtask - Update preview and reporting metadata so reviewers can see whether an app is browser-runnable and where it mounts.
      [x] 7.2.2.3 Subtask - Update validation to fail when app-local Phoenix launch commands drift from the shared contract.

  [x] 7.3 Section - Incremental Retrofit of Existing Example Apps
    Convert the current example directories from library-style demo projects into runnable Phoenix LiveView apps without losing coverage of the existing widget catalog.

    [x] 7.3.1 Task - Retrofit the baseline proof and foundational apps
      Upgrade the foundational example directories first so the common Phoenix pattern is proven on the simplest widget families.

      [x] 7.3.1.1 Subtask - Convert `text`, `button`, and `text_input` into runnable Phoenix LiveView apps as the proof set.
      [x] 7.3.1.2 Subtask - Convert the remaining foundational content, form, and input apps onto the same Phoenix baseline.
      [x] 7.3.1.3 Subtask - Add regression coverage that proves the shared theme and style profile still render consistently after the retrofit.

    [x] 7.3.2 Task - Retrofit advanced, overlay, and operational apps
      Upgrade the higher-complexity example directories so the Phoenix baseline also supports layered displays, canvas flows, and operational dashboards.

      [x] 7.3.2.1 Subtask - Convert layout, navigation, data, and feedback apps to the app-local Phoenix runtime shape.
      [x] 7.3.2.2 Subtask - Convert display, overlay, and operational apps to the same browser-launchable pattern.
      [x] 7.3.2.3 Subtask - Add regression coverage for complex examples whose runtime behavior depends on overlays, viewports, or monitoring widgets.

  [x] 7.4 Section - Documentation and Maintainer Launch Workflow
    Make the new Phoenix runtime contract obvious to maintainers so running an example in the browser is documented, repeatable, and reviewable.

    [x] 7.4.1 Task - Document the standalone launch workflow
      Update suite and per-app documentation so the primary way to run an example is explicit and consistent.

      [x] 7.4.1.1 Subtask - Update the root `examples/README.md` with browser launch instructions for standalone example apps.
      [x] 7.4.1.2 Subtask - Update `examples/shared/README.md` and maintenance guides to describe the new Phoenix runtime expectations.
      [x] 7.4.1.3 Subtask - Update per-app readmes so each example advertises its own `mix phx.server` launch path.

    [x] 7.4.2 Task - Add repeatable maintainer launch and smoke-test workflows
      Provide one repeatable way to check that examples boot in a browser-facing runtime before review or release.

      [x] 7.4.2.1 Subtask - Add shared maintainer commands that can dry-run or smoke-test the per-app `mix phx.server` workflow.
      [x] 7.4.2.2 Subtask - Add validation that checks each example app can boot its endpoint and LiveView entrypoint in a controlled test scenario.
      [x] 7.4.2.3 Subtask - Add release-readiness checks that ensure the suite does not regress back to non-runnable library-style examples.

  [x] 7.5 Section - Phase 7 Integration Tests
    Validate that the example suite now supports both shared review tooling and real browser-runnable Phoenix LiveView apps across the widget catalog.

    [x] 7.5.1 Task - Phoenix runtime and browser launch integration scenarios
      Verify that representative example apps across the suite boot through their own endpoints, mount their LiveViews, and preserve the shared authored DSL contract.

      [x] 7.5.1.1 Subtask - Verify the proof apps boot independently through `mix phx.server`-compatible Phoenix entrypoints.
      [x] 7.5.1.2 Subtask - Verify advanced overlay and operational apps also mount correctly through the same Phoenix runtime pattern.
      [x] 7.5.1.3 Subtask - Verify shared tooling, validation, and release-readiness workflows understand and enforce the new LiveView app runtime contract.
