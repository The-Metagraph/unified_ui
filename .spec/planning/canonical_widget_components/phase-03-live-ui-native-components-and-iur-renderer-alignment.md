# Phase 3 - LiveUi Native Components and IUR Renderer Alignment

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Widget`
- `LiveUi.Component`
- `LiveUi.Renderer`
- `LiveUi.Runtime.ScreenComponent`
- `LiveUi.Signal`
- `UnifiedIUR.Element`
- `UnifiedIUR.Interaction`

## Relevant Assumptions / Defaults
- LiveUi widgets are LiveComponent-backed runtime units where a lifecycle or
  event boundary is needed.
- Pure structural helpers may remain function components when they do not need
  bounded widget state.
- Canonical IUR rendering targets the same native components used by direct
  LiveUi usage.
- All work in this phase is not done.

[ ] 3 Phase 3 - LiveUi Native Components and IUR Renderer Alignment
  Implement the expanded widget-component catalog in LiveUi and make the
  canonical renderer map IUR input into those same native components.

  [x] 3.1 Section - LiveUi Component Module Backbone
    Establish shared module layout, assigns contracts, and renderer dispatch
    conventions for the expanded catalog.

    [x] 3.1.1 Task - Define component modules and assigns contracts
      Create the component boundaries and shared assign validation needed for
      consistent implementation.

      [x] 3.1.1.1 Subtask - Add component modules or grouped modules for content, identity, controls, rows, progress, layers, callouts, redline, code, and composer widgets.
      [x] 3.1.1.2 Subtask - Define assign contracts for canonical props, children, interaction descriptors, and accessibility metadata.
      [x] 3.1.1.3 Subtask - Ensure helper APIs delegate to component boundaries rather than creating parallel render implementations.

    [x] 3.1.2 Task - Define shared rendering and style hooks
      Keep styling token-driven and reusable across native and IUR-rendered
      LiveUi paths.

      [x] 3.1.2.1 Subtask - Define common class, token, state, and size hooks for the expanded catalog.
      [x] 3.1.2.2 Subtask - Avoid literal color, font, or spacing values in component output where theme tokens should apply.
      [x] 3.1.2.3 Subtask - Add component metadata used by tooling and focused examples.

  [x] 3.2 Section - Content, Identity, Form, Control, and Composer Components
    Implement LiveUi-native components for the widgets that are central to
    content, identity, form, and messaging surfaces.

    [x] 3.2.1 Task - Implement content, identity, and disclosure components
      Realize the passive and stateful content widgets through LiveView-native
      markup and component boundaries.

      [x] 3.2.1.1 Subtask - Implement inline rich heading and kicker components with safe text segment rendering.
      [x] 3.2.1.2 Subtask - Implement avatar and presence dot components with accessible labels and theme variants.
      [x] 3.2.1.3 Subtask - Implement disclosure with native open-state rendering and child body composition.

    [x] 3.2.2 Task - Implement form, segmented control, and composer components
      Realize interactive controls while preserving canonical signal meaning.

      [x] 3.2.2.1 Subtask - Implement segmented button group with pressed state and canonical selection event translation.
      [x] 3.2.2.2 Subtask - Implement runtime-owned form shell with LiveView and AshPhoenix integration hooks that remain LiveUi-local.
      [x] 3.2.2.3 Subtask - Implement chat composer with textarea, tool area, disabled state, send event, and change event handling.

  [x] 3.3 Section - Row, Workflow, Layer, Callout, Redline, and Code Components
    Implement the operational and document-workflow components used by list,
    process, overlay, and text-review surfaces.

    [x] 3.3.1 Task - Implement row and workflow components
      Build components for selectable rows, artifact summaries, workflow
      steppers, segmented progress, stage lists, and thin meters.

      [x] 3.3.1.1 Subtask - Implement multi-column list row and artifact row with button and link variants.
      [x] 3.3.1.2 Subtask - Implement horizontal stepper and vertical stage list with active, done, and pending state.
      [x] 3.3.1.3 Subtask - Implement segmented progress and thin meter with normalized values and accessible progress metadata.

    [x] 3.3.2 Task - Implement layer, callout, redline, and code components
      Build components for shell surfaces and specialized text display.

      [x] 3.3.2.1 Subtask - Implement sticky frosted header with fallback styling and positional children.
      [x] 3.3.2.2 Subtask - Implement slide-over panel as non-modal contextual layer with open state and size.
      [x] 3.3.2.3 Subtask - Implement event callout, redline inline, and pre-tokenized code block with safe text escaping.

  [x] 3.4 Section - LiveUi IUR Renderer Convergence
    Connect UnifiedIUR input for the expanded catalog to the same LiveUi native
    components used directly.

    [x] 3.4.1 Task - Add renderer dispatch for expanded widgets
      Map each canonical IUR widget type into native LiveUi components.

      [x] 3.4.1.1 Subtask - Add renderer clauses for every expanded widget family.
      [x] 3.4.1.2 Subtask - Map IUR props, children, accessibility metadata, and interaction descriptors into component assigns.
      [x] 3.4.1.3 Subtask - Ensure unknown or unsupported values produce diagnostics rather than silent fallback markup.

    [x] 3.4.2 Task - Map canonical interactions into LiveView behavior
      Preserve event meaning while translating into LiveView event mechanics.

      [x] 3.4.2.1 Subtask - Translate selection, submit, change, send, row activation, step navigation, and inline actions into LiveUi signal handling.
      [x] 3.4.2.2 Subtask - Preserve canonical payload mapping for selected values, row ids, fields, composer text, and step ids.
      [x] 3.4.2.3 Subtask - Keep disclosure and slide-over local state bounded and subordinate to screen authority.

  [ ] 3.5 Section - Phase 3 Integration Tests
    Validate LiveUi native component usage and IUR-rendered usage converge on
    the same behavior and safety guarantees.

    [ ] 3.5.1 Task - Native component scenarios
      Verify direct LiveUi usage covers representative widgets from every
      expanded family.

      [ ] 3.5.1.1 Subtask - Verify each component renders required content, state, accessibility metadata, and children.
      [ ] 3.5.1.2 Subtask - Verify interactive components emit the expected canonical signal meaning.
      [ ] 3.5.1.3 Subtask - Verify redline and code components escape malicious text fixtures.

    [ ] 3.5.2 Task - IUR renderer scenarios
      Verify canonical IUR renders through native LiveUi components rather than
      renderer-only markup.

      [ ] 3.5.2.1 Subtask - Verify IUR fixtures for every expanded family render through component boundaries.
      [ ] 3.5.2.2 Subtask - Verify repeated row IUR renders deterministic repeated child components.
      [ ] 3.5.2.3 Subtask - Verify renderer and native component outputs preserve the same semantic state and event meaning.
