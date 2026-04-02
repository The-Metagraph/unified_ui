# Phase 11 - Widget LiveComponent Contract and Runtime Backbone Realignment

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Component`
- `LiveUi.Screen`
- `LiveUi.Runtime`
- `LiveUi.Runtime.ScreenComponent`
- `LiveUi.Renderer`
- `LiveUi.Style`
- `LiveUi.Theme`
- `UnifiedIUR.Element`
- `UnifiedIUR.Interaction`

## Relevant Assumptions / Defaults
- The intended `live_ui` architecture is that native widgets are real mountable Phoenix LiveComponent-backed runtime units, not just function-component render helpers.
- `live_ui` still keeps one shared server-authoritative screen runtime; the change is that the runtime is composed from explicit widget component boundaries.
- Canonical `UnifiedIUR` rendering must target the same widget component boundaries used by direct native `live_ui` usage.
- Pure layout primitives may remain structural helpers unless they need their own event or lifecycle boundary.

[ ] 11 Phase 11 - Widget LiveComponent Contract and Runtime Backbone Realignment
  Define the shared widget LiveComponent contract, make widget identity and routing explicit, and realign the runtime backbone so screens and canonical rendering both compose real widget component boundaries.

  [ ] 11.1 Section - Shared Widget Component Contract
    Define the common contract that every mountable `live_ui` widget component must satisfy so maintainers can implement widgets consistently across native and canonical paths.

    [ ] 11.1.1 Task - Define the shared widget LiveComponent behaviour and macro surface
      Create one package-level component contract for mountable widgets that covers metadata, assigns, lifecycle, bounded local state, and event handling expectations.

      [ ] 11.1.1.1 Subtask - Introduce a shared widget-component behaviour or `use` macro that formalizes mount, update, render, metadata, and bounded local-state expectations for native widgets.
      [ ] 11.1.1.2 Subtask - Define which current `LiveUi.Component` metadata and style hooks remain common across all widgets and which values become widget-component-specific concerns.
      [ ] 11.1.1.3 Subtask - Define how pure layout primitives such as `row`, `column`, and `grid` stay structural unless a lifecycle or event boundary is explicitly required.

    [ ] 11.1.2 Task - Define widget identity, addressing, and event-routing rules
      Make widget instances addressable inside screens so the shared runtime can mount, update, and route events to specific widget component boundaries.

      [ ] 11.1.2.1 Subtask - Define stable widget instance identity rules for direct-native and canonical-rendered widget trees.
      [ ] 11.1.2.2 Subtask - Define how widget-targeted events route through the shared screen runtime without collapsing widget boundaries into anonymous HEEx fragments.
      [ ] 11.1.2.3 Subtask - Define how widget-local params and ephemeral state are keyed, updated, and discarded when widgets mount or unmount.

  [ ] 11.2 Section - Shared Runtime Backbone Realignment
    Refactor the screen runtime so it becomes an orchestrator of widget component instances instead of the sole place where all widget behavior effectively lives.

    [ ] 11.2.1 Task - Refactor the screen runtime to compose widget component instances
      Update the runtime host so screens render through explicit widget component boundaries in both native and canonical modes.

      [ ] 11.2.1.1 Subtask - Refactor `LiveUi.Runtime.ScreenComponent` and related runtime modules to render widget component instances rather than only direct function-component output.
      [ ] 11.2.1.2 Subtask - Ensure the runtime keeps server authority over screen and boundary meaning while still delegating bounded local lifecycle work to mounted widget components.
      [ ] 11.2.1.3 Subtask - Add focused runtime tests that prove widget instances preserve identity and state correctly across server updates and rerenders.

    [ ] 11.2.2 Task - Introduce bounded widget-local state infrastructure
      Support widget-local UI state where needed without confusing it with authoritative application or screen state.

      [ ] 11.2.2.1 Subtask - Define the runtime data structures used to store and reconcile widget-local ephemeral state.
      [ ] 11.2.2.2 Subtask - Ensure widget-local state remains subordinate to authoritative screen or application state and never becomes the package-boundary source of truth.
      [ ] 11.2.2.3 Subtask - Add tests that prove widget-local state resets, updates, and teardown behavior remain predictable.

  [ ] 11.3 Section - Transitional Compatibility Surfaces
    Keep the package usable while the implementation migrates from helper-first rendering to real widget component boundaries.

    [ ] 11.3.1 Task - Keep native authoring ergonomics while changing the underlying architecture
      Preserve direct-use ergonomics where possible, but make those entry points thin wrappers over the new widget component model.

      [ ] 11.3.1.1 Subtask - Define which existing function-component APIs remain as compatibility wrappers and how they delegate to the widget component boundary.
      [ ] 11.3.1.2 Subtask - Add diagnostics or maintainer guidance for paths that still bypass the intended widget component architecture.
      [ ] 11.3.1.3 Subtask - Add migration coverage that proves existing direct-use call sites can move onto the new widget architecture incrementally.

  [ ] 11.4 Section - Phase 11 Integration Tests
    Validate the shared widget-component contract and the refactored runtime backbone end to end before widget-family migrations begin.

    [ ] 11.4.1 Task - Widget-component runtime integration scenarios
      Verify the shared runtime can mount, update, and route events to explicit widget component boundaries in realistic screen flows.

      [ ] 11.4.1.1 Subtask - Verify representative widget instances preserve identity across rerenders in both direct-native and canonical-rendered flows.
      [ ] 11.4.1.2 Subtask - Verify widget-targeted events route through the shared runtime to the correct component boundary.
      [ ] 11.4.1.3 Subtask - Verify widget-local ephemeral state remains bounded and never replaces server-authoritative screen state.

    [ ] 11.4.2 Task - Transitional compatibility integration scenarios
      Verify existing direct-use authoring surfaces remain usable while delegating to the new widget component architecture.

      [ ] 11.4.2.1 Subtask - Verify compatibility wrappers still render through widget component boundaries rather than diverging into a second implementation model.
      [ ] 11.4.2.2 Subtask - Verify legacy screens can migrate incrementally without breaking runtime authority or event semantics.
      [ ] 11.4.2.3 Subtask - Verify runtime diagnostics make it obvious when a path is still bypassing the intended widget-component contract.
