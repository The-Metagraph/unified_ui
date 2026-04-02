# Phase 12 - Foundational, Input, Navigation, and Form Widget Component Migration

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `LiveUi.Widgets.Text`
- `LiveUi.Widgets.Label`
- `LiveUi.Widgets.Image`
- `LiveUi.Widgets.Icon`
- `LiveUi.Widgets.Button`
- `LiveUi.Widgets.Link`
- `LiveUi.Widgets.Separator`
- `LiveUi.Widgets.Spacer`
- `LiveUi.Widgets.Content`
- `LiveUi.Widgets.Container`
- `LiveUi.Widgets.Box`
- `LiveUi.Widgets.ScreenShell`
- `LiveUi.Widgets.TextInput`
- `LiveUi.Widgets.Toggle`
- `LiveUi.Widgets.Select`
- `LiveUi.Widgets.Menu`
- `LiveUi.Widgets.Tabs`
- `LiveUi.Widgets.CommandPalette`
- `LiveUi.Forms.FormBuilder`
- `LiveUi.Forms.FieldGroup`
- `LiveUi.Forms.Field`

## Relevant Assumptions / Defaults
- Phase 11 has established the shared widget-component contract and the runtime backbone for mounting widget component instances.
- Foundational, input, navigation, and form surfaces should set the implementation pattern that later widget families follow.
- These families must remain directly usable by native `live_ui` authors while becoming real widget component boundaries internally.
- Browser-visible styling and canonical interaction lowering from earlier phases must continue to work through the new widget architecture.

[ ] 12 Phase 12 - Foundational, Input, Navigation, and Form Widget Component Migration
  Migrate the most frequently used widget families and form surfaces onto the new widget-component architecture while preserving direct-use ergonomics, canonical parity, and existing style behavior.

  [ ] 12.1 Section - Foundational Widget Component Migration
    Move foundational content and container widgets onto explicit widget component boundaries and make them the reference implementation for the rest of the package.

    [ ] 12.1.1 Task - Convert foundational content widgets to the shared widget-component contract
      Migrate text, label, image, icon, button, and link surfaces so they render and update through real widget component boundaries.

      [ ] 12.1.1.1 Subtask - Convert `text`, `label`, `image`, and `icon` to explicit widget component implementations while preserving current style hooks and metadata.
      [ ] 12.1.1.2 Subtask - Convert `button` and `link` to widget component implementations with explicit click and navigation event handling paths.
      [ ] 12.1.1.3 Subtask - Add regression tests that prove foundational content widgets preserve identity, styling, and event semantics through rerenders.

    [ ] 12.1.2 Task - Convert foundational container widgets to the shared widget-component contract
      Migrate content-bearing shells and container surfaces so nested widget composition flows through explicit widget boundaries.

      [ ] 12.1.2.1 Subtask - Convert `content`, `container`, `box`, and `screen_shell` to widget component implementations that compose child widget boundaries safely.
      [ ] 12.1.2.2 Subtask - Convert `separator` and `spacer` to whichever implementation form the Phase 11 contract requires for mountable foundational widget surfaces.
      [ ] 12.1.2.3 Subtask - Add tests that prove nested foundational component trees preserve ordering, slots, styling, and identity across updates.

  [ ] 12.2 Section - Input and Form Component Migration
    Move input widgets and form-building surfaces onto the widget-component architecture so local input lifecycle becomes explicit but still remains subordinate to server authority.

    [ ] 12.2.1 Task - Convert input widgets to mountable widget components
      Migrate `text_input`, `toggle`, and `select` so they manage bounded local UI lifecycle through explicit widget component boundaries.

      [ ] 12.2.1.1 Subtask - Convert `text_input`, `toggle`, and `select` to widget component implementations with explicit change and submit surfaces.
      [ ] 12.2.1.2 Subtask - Ensure bounded widget-local input state still reconciles correctly with server-authoritative assigns and canonical interaction meaning.
      [ ] 12.2.1.3 Subtask - Add tests that prove input widgets preserve focus-sensitive behavior, server updates, and canonical event lowering through the new architecture.

    [ ] 12.2.2 Task - Convert form composition surfaces to the widget-component architecture
      Migrate form wrappers so grouped form behavior still composes naturally around mounted widget components.

      [ ] 12.2.2.1 Subtask - Update `form_builder`, `field_group`, and `field` surfaces to compose mounted widget components without bypassing widget boundaries.
      [ ] 12.2.2.2 Subtask - Define how form-level submit and change handling cooperate with widget-level bounded local state and canonical interaction routing.
      [ ] 12.2.2.3 Subtask - Add tests that prove grouped forms still validate, submit, and rerender predictably.

  [ ] 12.3 Section - Navigation Widget Component Migration
    Migrate menu, tabs, and command palette onto the widget-component architecture and keep native and canonical navigation semantics aligned.

    [ ] 12.3.1 Task - Convert navigation widgets to explicit component boundaries
      Migrate the core navigation surfaces so they own their own bounded lifecycle and event targeting while staying subordinate to the shared runtime.

      [ ] 12.3.1.1 Subtask - Convert `menu`, `tabs`, and `command_palette` to widget component implementations with explicit click, patch, navigate, and change behavior where appropriate.
      [ ] 12.3.1.2 Subtask - Ensure navigation widgets preserve canonical item attributes, active and disabled state, and shared style treatment through the component migration.
      [ ] 12.3.1.3 Subtask - Add tests that prove navigation widgets still route direct-native and canonical interactions through the same widget component boundaries.

  [ ] 12.4 Section - Phase 12 Integration Tests
    Validate foundational, input, navigation, and form migrations end to end before broader advanced-family work begins.

    [ ] 12.4.1 Task - Foundational and input widget integration scenarios
      Verify the most common widget surfaces now behave as real widget components without breaking native authoring or canonical rendering.

      [ ] 12.4.1.1 Subtask - Verify foundational widgets preserve identity, styling, and slots through mounted widget component boundaries.
      [ ] 12.4.1.2 Subtask - Verify input widgets reconcile bounded local state with server-authoritative assigns and canonical interactions.
      [ ] 12.4.1.3 Subtask - Verify form wrappers continue to compose predictably around mounted widget components.

    [ ] 12.4.2 Task - Navigation integration scenarios
      Verify navigation widgets remain fully usable after the component migration in direct-native and canonical flows.

      [ ] 12.4.2.1 Subtask - Verify menus, tabs, and command palettes still route click, patch, navigate, and change behavior correctly.
      [ ] 12.4.2.2 Subtask - Verify canonical navigation rendering targets the same widget component boundaries as direct-native navigation usage.
      [ ] 12.4.2.3 Subtask - Verify bounded navigation widget state never replaces authoritative screen or application state.
