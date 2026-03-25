# DesktopUi Platform Artifacts

This subject defines how `desktop_ui` handles multiplatform compilation,
packaging, and desktop-target artifact delivery.

## Related General Specs

- [Platform Runtimes](../platform_runtimes.spec.md)
- [Repository Package](../package.spec.md)
- [DesktopUi Package](./package.spec.md)
- [DesktopUi Structure](./structure.spec.md)
- [DesktopUi Runtime](./runtime.spec.md)

```spec-meta
id: desktop_ui.platform_artifacts
kind: tooling
status: active
summary: Target contract for Windows, macOS, and Linux compilation flows and packaged desktop artifacts in `desktop_ui`.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop_ui/platform_artifacts.spec.md
decisions:
  - repo.ecosystem.contract_model
```

## Requirements

```spec-requirements
- id: desktop_ui.platform_artifacts.first_class_targets
  statement: Windows, macOS, and Linux shall each be treated as first-class desktop targets with explicit build, packaging, and release expectations.
  priority: must
  stability: stable

- id: desktop_ui.platform_artifacts.platform_specific_flows_allowed
  statement: The package shall allow platform-specific compilation and packaging flows for each target platform artifact, including staging SDL3 runtime components and any adopted companion libraries, rather than assuming one universal build flow can emit every desktop artifact correctly.
  priority: must
  stability: stable

- id: desktop_ui.platform_artifacts.artifact_types_may_differ
  statement: The final artifact form may differ by platform, including executables, application bundles, installers, archives, or other native desktop delivery formats appropriate to the target operating system.
  priority: must
  stability: stable

- id: desktop_ui.platform_artifacts.shared_runtime_semantics
  statement: Platform-specific artifact flows shall preserve the same `desktop_ui` runtime semantics, native widget meaning, canonical IUR support, and boundary event translation model across supported targets.
  priority: must
  stability: stable

- id: desktop_ui.platform_artifacts.packaging_not_runtime_logic
  statement: Platform-specific compilation and packaging steps shall remain distinct from widget behavior and runtime logic so artifact delivery concerns do not redefine package semantics, regardless of how SDL3 runtimes and companion libraries are bundled per target.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: desktop_ui.platform_artifacts.build_distinct_platform_outputs
  given: A maintainer prepares a desktop release for Windows, macOS, and Linux
  when: The maintainer builds platform artifacts
  then: The package may use different compilation and packaging flows for each target while preserving one shared runtime and canonical rendering contract
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop_ui/platform_artifacts.spec.md
  covers:
    - desktop_ui.platform_artifacts.first_class_targets
    - desktop_ui.platform_artifacts.platform_specific_flows_allowed
    - desktop_ui.platform_artifacts.artifact_types_may_differ
    - desktop_ui.platform_artifacts.shared_runtime_semantics
    - desktop_ui.platform_artifacts.packaging_not_runtime_logic
    - desktop_ui.platform_artifacts.build_distinct_platform_outputs
```
