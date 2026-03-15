# Phase 1 - Package Scaffold and DSL Backbone

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `UnifiedUi`
- `UnifiedUi.Dsl`
- `UnifiedUi.Dsl.Extension`
- `UnifiedUi.Reference`
- `UnifiedUi.Info`
- `UnifiedUi.Compiler`

## Relevant Assumptions / Defaults
- Spark is the intended DSL substrate and should be adopted explicitly in the package backbone.
- `unified_ui` remains an authored DSL and compiler package, not a runtime library.
- The authored module model must stabilize before higher-level widget families and compiler passes are added.

[ ] 1 Phase 1 - Package Scaffold and DSL Backbone
  Implement the Mix package scaffold, Spark-based DSL backbone, authored identity rules, and baseline reference surfaces that every later `unified_ui` phase depends on.

  [ ] 1.1 Section - Mix Package and Namespace Scaffold
    Implement the baseline package structure, namespace layout, and library packaging rules required for `unified_ui`.

    [ ] 1.1.1 Task - Implement the baseline Mix library skeleton
      Establish `packages/unified-ui` as a standard Elixir library with package metadata, package documentation entry points, and test support.

      [ ] 1.1.1.1 Subtask - Create `packages/unified-ui/mix.exs` with package metadata, docs configuration, Spark dependency policy, and `unified_iur` dependency wiring.
      [ ] 1.1.1.2 Subtask - Create the top-level `UnifiedUi` namespace module together with package-facing entry modules for DSL use, compiler access, and reference surfaces.
      [ ] 1.1.1.3 Subtask - Create `lib/`, `test/`, example-support, and package guide directories aligned with the `unified_ui` structure spec.

    [ ] 1.1.2 Task - Implement package namespace and directory boundaries
      Separate authored DSL concerns from compiler, signal, reference, and tooling concerns while preventing runtime-library leakage.

      [ ] 1.1.2.1 Subtask - Create dedicated module areas for DSL entities and sections, compiler passes, signal descriptors, introspection surfaces, and tooling helpers.
      [ ] 1.1.2.2 Subtask - Establish naming conventions for public package modules and author-facing namespaces under `UnifiedUi`.
      [ ] 1.1.2.3 Subtask - Prevent the package structure from introducing renderer adapters, required supervisors, or runtime-library namespaces.

  [ ] 1.2 Section - Spark DSL Extension Backbone
    Implement the Spark-based authoring foundation that all authored UI modules will use.

    [ ] 1.2.1 Task - Implement the Spark extension and DSL entrypoint
      Define the package-level DSL extension and author-facing `use` surface for authored UI modules.

      [ ] 1.2.1.1 Subtask - Create the Spark DSL extension module and the package entry macro used by authored `UnifiedUi` modules.
      [ ] 1.2.1.2 Subtask - Define the baseline authored module contract for declaring canonical UI intent through sectioned DSL declarations.
      [ ] 1.2.1.3 Subtask - Expose author-facing helpers that keep authored modules concise without hiding canonical meaning behind runtime-specific helpers.

    [ ] 1.2.2 Task - Implement section registration and authored module organization
      Define the section model that later phases will extend with widgets, display systems, theming, and signal declarations.

      [ ] 1.2.2.1 Subtask - Create DSL sections for identity and metadata, structure and composition, style and theme, and interaction declaration scaffolding.
      [ ] 1.2.2.2 Subtask - Create registries or section metadata surfaces that can grow to support canonical widgets, layouts, layers, and signal families without changing the authored module model.
      [ ] 1.2.2.3 Subtask - Define how authored module defaults, imports, and extension points are registered at compile time.

  [ ] 1.3 Section - Authored Identity and Placement Invariants
    Implement the authored identity rules and placement constraints that make later widget and display-system authoring safe.

    [ ] 1.3.1 Task - Implement authored identity and naming rules
      Define stable authored identifiers, naming expectations, and traceability hooks for UI modules and authored entities.

      [ ] 1.3.1.1 Subtask - Define canonical authored identity fields for modules, declared elements, themes, and signal bindings.
      [ ] 1.3.1.2 Subtask - Define naming and uniqueness rules for authored entity identifiers within one module and across section scopes.
      [ ] 1.3.1.3 Subtask - Define authored traceability metadata that later compiler passes can preserve into `UnifiedIUR`.

    [ ] 1.3.2 Task - Implement parent-child placement and compile-time error contracts
      Establish the baseline placement rules and author-facing diagnostics that later construct families must follow.

      [ ] 1.3.2.1 Subtask - Define section-boundary rules for where authored entities may appear inside one DSL module.
      [ ] 1.3.2.2 Subtask - Define baseline parent-child placement rules for authored nodes before higher-level widget families are introduced.
      [ ] 1.3.2.3 Subtask - Define compile-time validation errors for duplicate identifiers, invalid placement, and incomplete authored declarations.

  [ ] 1.4 Section - Reference and Introspection Baseline
    Implement the package-facing reference surfaces that let maintainers inspect the authored DSL without a renderer runtime.

    [ ] 1.4.1 Task - Implement authored DSL reference surfaces
      Provide package helpers that report supported sections, registered construct families, and authoring capabilities.

      [ ] 1.4.1.1 Subtask - Implement reference helpers that list available DSL sections, section purposes, and registered extension points.
      [ ] 1.4.1.2 Subtask - Implement package surfaces that report the currently supported canonical construct-family categories.
      [ ] 1.4.1.3 Subtask - Implement reference helpers that expose baseline identity, naming, and placement rules to maintainers.

    [ ] 1.4.2 Task - Implement authored module summaries and inspection helpers
      Provide lightweight introspection that can summarize authored modules before full compilation exists.

      [ ] 1.4.2.1 Subtask - Implement authored module summary helpers for declared identifiers, section usage, and validation state.
      [ ] 1.4.2.2 Subtask - Implement inspection helpers that surface registered widgets, layouts, styles, and interactions as they are added to the package.
      [ ] 1.4.2.3 Subtask - Implement baseline inspection surfaces that do not require `live_ui`, `web_ui`, or `desktop_ui` to be present.

  [ ] 1.5 Section - Phase 1 Integration Tests
    Validate package bootstrap, Spark DSL registration, authored invariants, and reference surfaces end to end.

    [ ] 1.5.1 Task - Package and DSL backbone integration scenarios
      Verify the package loads as a pure library and that minimal authored modules compile through the DSL backbone.

      [ ] 1.5.1.1 Subtask - Verify the package boots without starting runtime infrastructure or renderer adapters.
      [ ] 1.5.1.2 Subtask - Verify a minimal authored `UnifiedUi` module can register through the Spark extension and expose section metadata.
      [ ] 1.5.1.3 Subtask - Verify incomplete or malformed authored modules fail with compile-time diagnostics rather than runtime errors.

    [ ] 1.5.2 Task - Validation and introspection integration scenarios
      Verify reference and inspection helpers remain usable before the higher-level authored surface is complete.

      [ ] 1.5.2.1 Subtask - Verify reference helpers report available sections and construct-family categories without a renderer runtime.
      [ ] 1.5.2.2 Subtask - Verify authored identity and placement invariants are visible through package inspection surfaces.
      [ ] 1.5.2.3 Subtask - Verify duplicate identifiers and invalid placement rules are enforced deterministically across authored modules.
