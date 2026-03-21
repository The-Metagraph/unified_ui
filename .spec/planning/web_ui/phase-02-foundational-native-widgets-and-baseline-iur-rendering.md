# Phase 2 - Foundational Native Widgets and Baseline IUR Rendering

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `WebUi.Widgets`
- `WebUi.Server`
- `WebUi.Frontend`
- `WebUi.Renderer`
- `WebUi.Runtime`
- `UnifiedIUR.Element`
- `UnifiedIUR.Widgets`

## Relevant Assumptions / Defaults
- Foundational widgets, forms, and navigation basics should land before advanced display systems and operational widgets.
- Direct native rendering and canonical `UnifiedIUR` rendering should begin converging as soon as foundational widget families exist.
- The Phoenix side should shape authoritative view state while the Elm side realizes foundational widget rendering and browser interaction.

[ ] 2 Phase 2 - Foundational Native Widgets and Baseline IUR Rendering
  Implement foundational native widgets, baseline forms and navigation, and the first canonical `UnifiedIUR` rendering path across the split `web_ui` runtime.

  [x] 2.1 Section - Foundational Native Widget Families
    Implement the core widget families that make direct-use `web_ui` useful before advanced display systems arrive.

    [x] 2.1.1 Task - Implement foundational content and action widgets
      Define the baseline native widgets for text-bearing, image-bearing, icon-bearing, button-like, link-like, separator, spacer, and content-container rendering.

      [x] 2.1.1.1 Subtask - Implement native widget contracts and rendering support for foundational content, action, and content-container widgets.
      [x] 2.1.1.2 Subtask - Define shared state, slot, accessibility, and browser interaction behavior for these foundational widgets.
      [x] 2.1.1.3 Subtask - Define how foundational widget state is represented on the server side and realized on the Elm side.

    [x] 2.1.2 Task - Implement baseline forms and navigation widgets
      Define the first native form and navigation controls needed for direct package usage and early canonical parity.

      [x] 2.1.2.1 Subtask - Implement native widget support for text input, grouped form composition, button actions, and simple selection controls.
      [x] 2.1.2.2 Subtask - Implement baseline navigation widgets such as tabs, menu-like navigation, and command-triggering controls.
      [x] 2.1.2.3 Subtask - Keep the initial form and navigation APIs ergonomic for direct native usage without weakening canonical parity requirements.

  [x] 2.2 Section - Foundational Server and Frontend Rendering Pipeline
    Implement the split rendering pipeline that makes foundational native widgets work coherently across Phoenix and Elm.

    [x] 2.2.1 Task - Implement server-side foundational view-state generation
      Define how the server runtime turns native widget declarations into authoritative frontend-view state.

      [x] 2.2.1.1 Subtask - Implement server-side view-model generation for foundational widgets, forms, and navigation primitives.
      [x] 2.2.1.2 Subtask - Define deterministic state shape for widget identity, slots, styles, and interaction wiring.
      [x] 2.2.1.3 Subtask - Keep server-generated view state stable enough for diff-friendly review and renderer diagnostics.

    [x] 2.2.2 Task - Implement frontend foundational widget realization
      Define how the Elm runtime renders foundational server-provided widget state and local browser behavior.

      [x] 2.2.2.1 Subtask - Implement Elm view modules for foundational widgets and baseline form and navigation primitives.
      [x] 2.2.2.2 Subtask - Implement bounded local browser behavior for focus, editing, and simple interaction feedback.
      [x] 2.2.2.3 Subtask - Preserve the separation between frontend rendering concerns and server-side meaning or event authority.

  [ ] 2.3 Section - Baseline Canonical IUR Rendering
    Implement the first canonical renderer path that maps foundational `UnifiedIUR` widgets into native `web_ui` widgets.

    [ ] 2.3.1 Task - Implement foundational canonical widget interpretation
      Define the first canonical IUR renderer coverage for foundational widgets, simple layouts, and baseline form composition.

      [ ] 2.3.1.1 Subtask - Implement canonical IUR interpretation for foundational visual widgets, simple layout nodes, and baseline form composition.
      [ ] 2.3.1.2 Subtask - Map canonical widget attributes, children, and metadata into native server and frontend rendering state deterministically.
      [ ] 2.3.1.3 Subtask - Reject canonical inputs that require unsupported widget or layout coverage with actionable diagnostics.

    [ ] 2.3.2 Task - Implement native and canonical rendering convergence
      Ensure direct native rendering and canonical rendering reuse the same widget model instead of diverging early.

      [ ] 2.3.2.1 Subtask - Reuse native widget registration and rendering logic when realizing canonical IUR inputs.
      [ ] 2.3.2.2 Subtask - Align widget identity, style hooks, and interaction wiring across native and canonical paths.
      [ ] 2.3.2.3 Subtask - Define continuity checks that compare native and canonical rendering for the same foundational widget families.

  [ ] 2.4 Section - Foundational Reference Examples
    Implement maintained examples that exercise foundational direct-native and canonical rendering workflows.

    [ ] 2.4.1 Task - Implement foundational native and canonical examples
      Provide review-friendly examples that demonstrate the baseline `web_ui` runtime model and the first canonical renderer path.

      [ ] 2.4.1.1 Subtask - Create direct-native foundational examples that exercise content, action, form, and navigation widgets.
      [ ] 2.4.1.2 Subtask - Create canonical foundational examples that render equivalent `UnifiedIUR` structures through the same runtime.
      [ ] 2.4.1.3 Subtask - Create comparison artifacts that make foundational native versus canonical behavior reviewable.

  [ ] 2.5 Section - Phase 2 Integration Tests
    Validate foundational native widgets, split-runtime rendering, and baseline canonical coverage end to end.

    [ ] 2.5.1 Task - Foundational native rendering scenarios
      Verify foundational widgets, forms, and navigation controls render and behave coherently through the package runtime.

      [ ] 2.5.1.1 Subtask - Verify foundational native widgets render deterministically through the Phoenix and Elm runtime split.
      [ ] 2.5.1.2 Subtask - Verify baseline form editing and navigation interactions update authoritative server state and frontend rendering correctly.
      [ ] 2.5.1.3 Subtask - Verify invalid foundational widget declarations or unsupported state shape fail with actionable diagnostics.

    [ ] 2.5.2 Task - Foundational canonical renderer scenarios
      Verify foundational canonical IUR input maps into the same widget model used by direct native rendering.

      [ ] 2.5.2.1 Subtask - Verify foundational canonical widgets render through native `web_ui` widget reuse rather than a separate renderer stack.
      [ ] 2.5.2.2 Subtask - Verify native and canonical foundational examples preserve the same visual and interaction meaning.
      [ ] 2.5.2.3 Subtask - Verify unsupported canonical inputs fail deterministically with coverage-oriented diagnostics.
