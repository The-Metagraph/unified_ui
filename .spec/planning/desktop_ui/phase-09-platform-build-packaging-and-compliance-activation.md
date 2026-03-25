# Phase 9 - Platform Build, Packaging, and Compliance Activation

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `DesktopUi.Build`
- `DesktopUi.Package`
- `DesktopUi.Artifacts`
- `DesktopUi.Reference`
- `DesktopUi.Validate`
- `mix desktop_ui.build`
- `mix desktop_ui.package`
- `mix spec.compliance desktop_ui`

## Relevant Assumptions / Defaults
- This phase turns the current build diagnostics into repeatable target build and
  packaging workflows without overstating native completeness when SDL3 is not
  present on the maintainer machine.
- Build and packaging outputs may remain review-oriented and staged when a real
  compiled SDL3 host is unavailable, but they must report that state explicitly
  and deterministically.
- The package-scoped compliance layer should verify `desktop_ui` planning,
  implementation, tooling, and artifact workflow surfaces in the same repo
  model already used by the other packages.
- Windows, macOS, and Linux remain first-class targets even when their artifact
  staging details diverge.

[ ] 9 Phase 9 - Platform Build, Packaging, and Compliance Activation
  Add the first repeatable target build and packaging workflows for
  `desktop_ui`, expose the resulting artifact and readiness diagnostics through
  maintainer tooling, and onboard the package into machine-checked conformance.

  [x] 9.1 Section - Target Build Staging Workflows
    Define and implement package-local build staging for Windows, macOS, and
    Linux so maintainers can generate deterministic target output directories
    and readiness manifests from one command surface.

    [x] 9.1.1 Task - Implement target build planning and staging surfaces
      Introduce the package modules and task entrypoints that prepare
      per-target desktop build directories, manifests, and launch metadata.

      [x] 9.1.1.1 Subtask - Add a `DesktopUi.Build` surface that defines target staging roots, manifest shapes, and runtime-readiness reporting.
      [x] 9.1.1.2 Subtask - Add `mix desktop_ui.build --target windows|macos|linux [--dry-run]` as the maintainer entrypoint for deterministic target staging.
      [x] 9.1.1.3 Subtask - Keep staged outputs explicit about whether they include a compiled SDL3 host or a bounded review-only fallback bundle.

  [x] 9.2 Section - Packaging Workflows and Artifact Diagnostics
    Extend target staging into repeatable packaging workflows so maintainers can
    create reviewable desktop artifacts and see which parts of the package are
    actually runnable.

    [x] 9.2.1 Task - Implement package-local packaging surfaces
      Create packaging manifests and artifact outputs that follow the bounded
      platform workflow policy already defined in `DesktopUi.Artifacts`.

      [x] 9.2.1.1 Subtask - Add a `DesktopUi.Package` surface that turns staged target outputs into archive or bundle artifacts per platform.
      [x] 9.2.1.2 Subtask - Add `mix desktop_ui.package --target windows|macos|linux [--dry-run]` for reviewable packaging workflows.
      [x] 9.2.1.3 Subtask - Surface archive paths, bundle contents, compiled-host presence, and fallback-only warnings through inspection, reference, and validation helpers.

  [x] 9.3 Section - DesktopUi Conformance Activation
    Onboard `desktop_ui` into the package-scoped compliance system so its plan,
    implementation, tooling, and artifact surfaces are verified from the repo
    root like the other runtime packages.

    [x] 9.3.1 Task - Add desktop_ui package conformance coverage
      Create the machine-readable conformance manifest and the repo-level tests
      that verify `desktop_ui` through `mix spec.compliance`.

      [x] 9.3.1.1 Subtask - Add `.spec/conformance/desktop_ui/manifest.json` with deterministic evidence for planning, runtime, tooling, build, and packaging surfaces.
      [x] 9.3.1.2 Subtask - Update root compliance docs and tests so `mix spec.compliance desktop_ui` is a supported package workflow.
      [x] 9.3.1.3 Subtask - Choose an explicit CI enforcement mode for `desktop_ui` based on the evidence added in this phase.

  [ ] 9.4 Section - Phase 9 Integration Tests
    Validate target staging, packaging, and package-scoped compliance end to
    end without requiring SDL3 to be installed on every CI machine.

    [ ] 9.4.1 Task - Build, packaging, and compliance integration scenarios
      Verify the new task surfaces and conformance layer stay deterministic
      across SDL3-ready and SDL3-less environments.

      [ ] 9.4.1.1 Subtask - Verify build staging distinguishes compiled-host-ready bundles from fallback-review bundles for each target.
      [ ] 9.4.1.2 Subtask - Verify packaging commands emit deterministic artifact diagnostics and output paths for Windows, macOS, and Linux.
      [ ] 9.4.1.3 Subtask - Verify `mix spec.compliance desktop_ui` and changed-package compliance detection report the package correctly.
