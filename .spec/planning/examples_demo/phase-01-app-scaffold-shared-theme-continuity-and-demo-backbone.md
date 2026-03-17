# Phase 1 - App Scaffold, Shared Theme Continuity, and Demo Backbone

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `examples/demo`
- `examples/shared`
- `UnifiedExamples.Shared.Template`
- `UnifiedExamples.Shared.App`
- `UnifiedExamples.Shared.Runtime`
- `UnifiedUi.Dsl`
- `UnifiedIUR`
- `LiveUi.Runtime`
- `Phoenix.Endpoint`
- `Phoenix.Router`
- `Phoenix.LiveView`
- `mix phx.server`

## Relevant Assumptions / Defaults
- The aggregate demo app should launch as a standalone Phoenix LiveView app under `examples/demo/` and not as a hidden mode inside `examples/shared/`.
- The demo app should inherit the same shared theme identity, style profile, and LiveView shell treatment as the current `examples/button/` example rather than inventing a new visual baseline.
- The root demo screen should establish the category registry, tab state, and shared reviewer-facing metadata before any individual category galleries are implemented.

[ ] 1 Phase 1 - App Scaffold, Shared Theme Continuity, and Demo Backbone
  Establish the aggregate demo application as a standalone Phoenix LiveView app, bind it to the shared examples theme/style contract, and create the root authored structure that later phases will extend with category tabs and signal-driven stories.

  [ ] 1.1 Section - Phoenix App and Package Scaffold
    Create the standalone Mix and Phoenix application baseline so `examples/demo/` can boot independently and participate in the same runtime workflows as the rest of the examples suite.

    [ ] 1.1.1 Task - Establish the canonical Phoenix application skeleton for `examples/demo/`
      Define the package layout, supervision tree, endpoint configuration, and LiveView entrypoint modules required for the demo app to launch through `mix phx.server`.

      [ ] 1.1.1.1 Subtask - Add the `mix.exs`, `config/`, `lib/`, `priv/`, and `test/` layout required for a standalone Phoenix LiveView example app.
      [ ] 1.1.1.2 Subtask - Define the `Application`, `Endpoint`, `Router`, layout, and LiveView modules that form the stable runtime entrypoint for the aggregate demo.
      [ ] 1.1.1.3 Subtask - Add launch and smoke-test coverage that proves the demo app can boot independently from the per-widget example applications.

    [ ] 1.1.2 Task - Align local dependencies with the existing example-suite contract
      Ensure the new demo app depends on the shared examples support library and the implemented ecosystem packages through the same path-based workflow as the other example apps.

      [ ] 1.1.2.1 Subtask - Add local path dependencies on `examples/shared`, `packages/unified-ui`, `packages/unified_iur`, and `packages/live_ui`.
      [ ] 1.1.2.2 Subtask - Reuse the shared launch and runtime helpers instead of duplicating example-suite boilerplate in the demo app.
      [ ] 1.1.2.3 Subtask - Add validation that fails if the demo app drifts away from the shared dependency contract.

  [ ] 1.2 Section - Shared Theme and Style Continuity
    Bind the aggregate demo app to the same visual contract as the current button example so the demo remains a first-class member of the existing example suite rather than a visually separate site.

    [ ] 1.2.1 Task - Reuse the shared button-example theme identity and style profile
      Carry the `:example_suite_default` theme and the shared style refs into the new demo app without creating a demo-specific baseline.

      [ ] 1.2.1.1 Subtask - Reuse the shared theme identity `:example_suite_default` in the root demo screen and its category fragments.
      [ ] 1.2.1.2 Subtask - Reuse the existing shared style refs such as `:example_shell`, `:example_panel`, `:example_title`, `:example_summary`, `:example_notes`, `:example_primary_button`, and `:example_primary_input`.
      [ ] 1.2.1.3 Subtask - Add regression checks that compare the demo app shell baseline against the current button example's shell and panel treatment.

    [ ] 1.2.2 Task - Reuse the shared LiveView shell treatment
      Make the aggregate demo app render inside the same dark, mono, accent-led browser shell used by the current button example application.

      [ ] 1.2.2.1 Subtask - Reuse the shared layout and root-shell helpers from `examples/shared` instead of duplicating CSS or HTML shell structure.
      [ ] 1.2.2.2 Subtask - Define how the demo app passes category and interaction metadata into the shared shell so the runtime can decorate the page consistently.
      [ ] 1.2.2.3 Subtask - Add tests that fail if the demo app falls back to an unstyled or demo-specific shell.

  [ ] 1.3 Section - Root Demo Screen and Category Registry Backbone
    Create the authored backbone for the demo app so later phases can add category galleries and signal-lab content without restructuring the application shell.

    [ ] 1.3.1 Task - Define the root authored screen and tab state model
      Implement the root `unified_ui` screen or fragment that owns the tabbed demo shell, active-tab state, and top-level descriptive copy.

      [ ] 1.3.1.1 Subtask - Define the root screen identity, title, summary, and high-level reviewer notes for the aggregate demo.
      [ ] 1.3.1.2 Subtask - Define the active-tab state and how it is represented in the authored DSL and LiveView runtime assigns.
      [ ] 1.3.1.3 Subtask - Add compile and runtime checks that prove the root demo screen can render before any individual category galleries are populated.

    [ ] 1.3.2 Task - Define the category registry and fragment boundaries
      Establish one stable registry that maps category ids to labels, ordering, descriptions, and authored fragments.

      [ ] 1.3.2.1 Subtask - Define the required category ids `foundational_content`, `forms_and_input`, `layout_and_display`, `navigation_and_selection`, `data_and_feedback`, `overlays_and_operational`, and `signal_lab`.
      [ ] 1.3.2.2 Subtask - Define one dedicated fragment or screen module boundary per category so later phases can be implemented incrementally.
      [ ] 1.3.2.3 Subtask - Add tests that prove the category registry remains ordered, complete, and traceable.

  [ ] 1.4 Section - Reference Surfaces and Launch Metadata
    Add the basic inspection and metadata surfaces that make the aggregate demo app easy to discover, launch, and review before the category content is complete.

    [ ] 1.4.1 Task - Define launch metadata and root review information
      Add the metadata the example-suite tooling will need to identify the demo app as the aggregate category-oriented surface.

      [ ] 1.4.1.1 Subtask - Define the demo app's review metadata including purpose, category count, theme identity, and launch path.
      [ ] 1.4.1.2 Subtask - Define how the root LiveView and shared launcher expose the demo app's browser URL and review summary.
      [ ] 1.4.1.3 Subtask - Add tests that prove the metadata stays aligned with the root screen and category registry.

  [ ] 1.5 Section - Phase 1 Integration Tests
    Validate that the aggregate demo app can boot as a standalone Phoenix LiveView app, reuse the shared examples styling baseline, and expose the root category shell plus launch metadata.

    [ ] 1.5.1 Task - Scaffold and runtime integration scenarios
      Verify the new demo app boots cleanly through the same runtime path expected by the rest of the example suite.

      [ ] 1.5.1.1 Subtask - Verify the demo app launches through `mix phx.server` and mounts its root LiveView entrypoint.
      [ ] 1.5.1.2 Subtask - Verify the root shell renders with the shared button-example theme and style baseline.
      [ ] 1.5.1.3 Subtask - Verify the category registry and launch metadata are present and internally consistent.
