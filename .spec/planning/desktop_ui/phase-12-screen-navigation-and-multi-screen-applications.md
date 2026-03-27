# Phase 12 - Screen Navigation and Multi-Screen Applications

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `DesktopUi.Navigation.Controller`
- `DesktopUi.Navigation.Registry`
- `DesktopUi.Runtime.State`
- `DesktopUi.Runtime.Screen`
- `DesktopUi.Transport`
- `UnifiedIUR.Element`

## Relevant Assumptions / Defaults
- Screen navigation should be modeled after Phoenix LiveView navigation semantics adapted for desktop (no URL routing)
- Navigation state is separate from window state, allowing windows to persist across screen transitions
- Modal dialogs use a separate stack from main navigation history
- Existing single-screen applications continue to work unchanged
- Navigation is application-internal and does not require external routing infrastructure

[ ] 12 Phase 12 - Screen Navigation and Multi-Screen Applications
  Implement screen-to-screen navigation within windows, including navigation
  controller, screen registry, navigation actions, history stack, modal stack,
  and integration with the existing runtime and transport layers.

  [ ] 12.1 Section - Navigation State and Controller
    Implement the core navigation controller GenServer that manages navigation
    state independent of window state, including history stack, forward stack,
    current screen, and modal stack.

    [ ] 12.1.1 Task - Implement navigation controller GenServer
      Create the `DesktopUi.Navigation.Controller` GenServer that manages
      navigation state and responds to navigation actions.

      [ ] 12.1.1.1 Subtask - Define the `DesktopUi.Navigation.State` struct with current screen, history stack, forward stack, modal stack, and params fields.
      [ ] 12.1.1.2 Subtask - Implement the controller GenServer with `navigate/2`, `replace/2`, `go_back/0`, `go_forward/0`, `open_modal/2`, and `close_modal/0` API calls.
      [ ] 12.1.1.3 Subtask - Implement history stack management with push on navigate, pop on back, and forward stack tracking.
      [ ] 12.1.1.4 Subtask - Implement modal stack as independent from main history, allowing overlays without affecting navigation state.

    [ ] 12.1.2 Task - Implement navigation state transitions and validation
      Define state transition logic for navigation actions including bounds
      checking, stack validation, and error handling.

      [ ] 12.1.2.1 Subtask - Implement navigate transition that pushes current screen to history and sets new current screen.
      [ ] 12.1.2.2 Subtask - Implement replace transition that swaps current screen without modifying history.
      [ ] 12.1.2.3 Subtask - Implement go_back and go_forward transitions with empty-stack handling.
      [ ] 12.1.2.4 Subtask - Implement modal open/close transitions that preserve main navigation state.
      [ ] 12.1.2.5 Subtask - Add validation for unknown screen IDs, invalid transitions, and stack boundary conditions.

    [ ] 12.1.3 Task - Implement navigation lifecycle callbacks
      Add optional callbacks for screen modules to react to navigation events.

      [ ] 12.1.3.1 Subtask - Define optional `c:handle_navigation/3` callback for screens to intercept navigation actions.
      [ ] 12.1.3.2 Subtask - Define optional `c:on_mount/2` callback for screens to initialize when becoming current.
      [ ] 12.1.3.3 Subtask - Define optional `c:on_unmount/1` callback for screens to cleanup when leaving current state.

  [ ] 12.2 Section - Screen Registry and Resolution
    Implement the screen registry that applications use to declare available
    screens and the resolution logic that maps navigation targets to screen
    modules.

    [ ] 12.2.1 Task - Implement screen registry
      Create the `DesktopUi.Navigation.Registry` module for application-level
      screen registration and lookup.

      [ ] 12.2.1.1 Subtask - Define the registry structure mapping screen IDs to screen modules with metadata and validation.
      [ ] 12.2.1.2 Subtask - Implement `register_screens/0` callback contract that applications implement to declare available screens.
      [ ] 12.2.1.3 Subtask - Implement `get_screen/1` lookup that returns module or error for unknown screen IDs.
      [ ] 12.2.1.4 Subtask - Add registry validation that checks all registered modules implement the screen behaviour.

    [ ] 12.2.2 Task - Implement screen resolution and mounting
      Add the logic that resolves screen IDs to modules and mounts new screens
      with params.

      [ ] 12.2.2.1 Subtask - Implement resolution logic that looks up screen module from registry and validates existence.
      [ ] 12.2.2.2 Subtask - Implement screen mounting that calls the screen module's mount function with provided params.
      [ ] 12.2.2.3 Subtask - Add param passing that extracts and serializes params from navigation actions.
      [ ] 12.2.2.4 Subtask - Implement error handling for mount failures with fallback to error screen or current screen preservation.

    [ ] 12.2.3 Task - Implement screen metadata and capabilities
      Add optional metadata for screens to declare navigation behavior and
      capabilities.

      [ ] 12.2.3.1 Subtask - Define screen metadata for title, icon, whether screen appears in history, and modal behavior.
      [ ] 12.2.3.2 Subtask - Add capability flags for modal-only, history-exclusion, and navigation-interception.
      [ ] 12.2.3.3 Subtask - Implement metadata lookup for navigation controller to use in transition decisions.

  [ ] 12.3 Section - Navigation Events and Transport Integration
    Integrate navigation with the existing transport layer by defining navigation
    signal types and wiring them to the navigation controller.

    [ ] 12.3.1 Task - Define navigation signal types
      Create canonical signal types for navigation actions that widgets can
      emit and that transport routes to the controller.

      [ ] 12.3.1.1 Subtask - Define `:navigate_to` signal type with target screen ID and params.
      [ ] 12.3.1.2 Subtask - Define `:replace_with` signal type for history-neutral transitions.
      [ ] 12.3.1.3 Subtask - Define `:go_back` and `:go_forward` signal types for history traversal.
      [ ] 12.3.1.4 Subtask - Define `:open_modal` and `:close_modal` signal types for modal stack.
      [ ] 12.3.1.5 Subtask - Add signal payload validation and error handling for malformed navigation events.

    [ ] 12.3.2 Task - Integrate navigation with transport event routing
      Wire navigation signals through the existing transport layer to the
      navigation controller.

      [ ] 12.3.2.1 Subtask - Extend `DesktopUi.Transport` to recognize navigation signal types and route to navigation controller.
      [ ] 12.3.2.2 Subtask - Implement translation from native widget events to navigation signals.
      [ ] 12.3.2.3 Subtask - Add boundary event handling for navigation from canonical IUR interactions.
      [ ] 12.3.2.4 Subtask - Implement event result propagation that returns updated navigation state to runtime.

    [ ] 12.3.3 Task - Add navigation widget helpers
      Provide helper functions and attributes for common widgets to emit
      navigation signals.

      [ ] 12.3.3.1 Subtask - Add `:navigate_to` option to button, link, and menu item widgets.
      [ ] 12.3.3.2 Subtask - Add `:replace_with` option for error and redirect navigation scenarios.
      [ ] 12.3.3.3 Subtask - Add helper functions for programmatic navigation from screen modules.
      [ ] 12.3.3.4 Subtask - Add navigation predicate helpers for determining if back/forward are available.

  [ ] 12.4 Section - Runtime Integration and Screen Swapping
    Integrate navigation with the existing runtime to swap screen content
    within windows while preserving window state.

    [ ] 12.4.1 Task - Extend runtime state for navigation
      Add navigation controller reference and navigation-aware rendering to
      the runtime state.

      [ ] 12.4.1.1 Subtask - Add `:navigation_controller` field to `DesktopUi.Runtime.State` for per-window navigation.
      [ ] 12.4.1.2 Subtask - Add `:current_screen` and `:screen_params` fields for tracking active screen.
      [ ] 12.4.1.3 Subtask - Implement runtime boot logic that starts navigation controller for windows requiring navigation.
      [ ] 12.4.1.4 Subtask - Add shutdown logic that stops navigation controller when window closes.

    [ ] 12.4.2 Task - Implement screen swapping in runtime
      Add the logic that swaps the root widget tree when navigation occurs while
      preserving window state.

      [ ] 12.4.2.1 Subtask - Implement `handle_navigation/2` in runtime that processes navigation controller results.
      [ ] 12.4.2.2 Subtask - Add screen state isolation that preserves each screen's independent assigns and state.
      [ ] 12.4.2.3 Subtask - Implement window state persistence across screen transitions (position, size, focus).
      [ ] 12.4.2.4 Subtask - Add redraw scheduling after navigation actions to refresh window content.

    [ ] 12.4.3 Task - Implement modal overlay rendering
      Add rendering logic for modal screens that appear as overlays on top of
      the current screen.

      [ ] 12.4.3.1 Subtask - Implement modal rendering that layers modal screen widgets above current screen content.
      [ ] 12.4.3.2 Subtask - Add modal backdrop and dimming behavior for focus indication.
      [ ] 12.4.3.3 Subtask - Implement modal focus trapping that keeps focus within modal while open.
      [ ] 12.4.3.4 Subtask - Add keyboard handling (Escape to close, Enter to confirm) for modal interactions.

  [ ] 12.5 Section - Navigation Examples and Documentation
    Create examples demonstrating navigation patterns and document the navigation
    API for application developers.

    [ ] 12.5.1 Task - Implement navigation examples
      Create example applications that demonstrate common navigation patterns.

      [ ] 12.5.1.1 Subtask - Create basic navigation example with home, list, and detail screens.
      [ ] 12.5.1.2 Subtask - Create back/forward navigation example demonstrating history stack.
      [ ] 12.5.1.3 Subtask - Create modal dialog example showing independent modal stack.
      [ ] 12.5.1.4 Subtask - Create multi-window example showing independent navigation per window.

    [ ] 12.5.2 Task - Write navigation documentation
      Document the navigation API, patterns, and best practices for developers.

      [ ] 12.5.2.1 Subtask - Write getting-started guide for screen navigation in desktop_ui applications.
      [ ] 12.5.2.2 Subtask - Document navigation controller API and all navigation actions.
      [ ] 12.5.2.3 Subtask - Document screen registry setup and screen module requirements.
      [ ] 12.5.2.4 Subtask - Document navigation patterns including master-detail, wizards, and modal flows.

  [ ] 12.6 Section - Phase 12 Integration Tests
    Validate screen navigation, history management, modal handling, and runtime
    integration end to end.

    [ ] 12.6.1 Task - Navigation state and controller scenarios
      Verify the navigation controller correctly manages all navigation state
      and transitions.

      [ ] 12.6.1.1 Subtask - Verify navigate action pushes current screen to history and sets new current screen.
      [ ] 12.6.1.2 Subtask - Verify replace action swaps current screen without modifying history.
      [ ] 12.6.1.3 Subtask - Verify go_back and go_forward correctly traverse history and update forward stack.
      [ ] 12.6.1.4 Subtask - Verify modal stack remains independent from main navigation history.
      [ ] 12.6.1.5 Subtask - Verify invalid navigation actions fail with deterministic errors.

    [ ] 12.6.2 Task - Screen registry and resolution scenarios
      Verify screen registry correctly resolves screen IDs and mounts screens
      with params.

      [ ] 12.6.2.1 Subtask - Verify registered screens resolve correctly from screen IDs.
      [ ] 12.6.2.2 Subtask - Verify unknown screen IDs return appropriate errors.
      [ ] 12.6.2.3 Subtask - Verify screen mounting passes params correctly and calls mount callbacks.
      [ ] 12.6.2.4 Subtask - Verify screen metadata and capabilities affect navigation behavior as expected.

    [ ] 12.6.3 Task - Transport and widget integration scenarios
      Verify navigation signals flow from widgets through transport to the
      navigation controller.

      [ ] 12.6.3.1 Subtask - Verify button, link, and menu items emit navigation signals correctly.
      [ ] 12.6.3.2 Subtask - Verify transport routes navigation signals to navigation controller.
      [ ] 12.6.3.3 Subtask - Verify navigation from canonical IUR interactions works correctly.
      [ ] 12.6.3.4 Subtask - Verify navigation helpers are available from screen modules.

    [ ] 12.6.4 Task - Runtime and window integration scenarios
      Verify navigation integrates correctly with the runtime and window state
      is preserved across transitions.

      [ ] 12.6.4.1 Subtask - Verify screen swapping updates window content without recreating the window.
      [ ] 12.6.4.2 Subtask - Verify window position, size, and platform state persist across screen transitions.
      [ ] 12.6.4.3 Subtask - Verify modal screens render as overlays above current screen content.
      [ ] 12.6.4.4 Subtask - Verify focus management works correctly during screen transitions and modal interactions.
      [ ] 12.6.4.5 Subtask - Verify multiple windows maintain independent navigation state.

    [ ] 12.6.5 Task - Example and documentation scenarios
      Verify navigation examples demonstrate all navigation features and
      documentation is complete and accurate.

      [ ] 12.6.5.1 Subtask - Verify basic navigation example demonstrates home, list, and detail navigation.
      [ ] 12.6.5.2 Subtask - Verify history example demonstrates back/forward with stack visualization.
      [ ] 12.6.5.3 Subtask - Verify modal example demonstrates independent modal stack.
      [ ] 12.6.5.4 Subtask - Verify multi-window example shows independent navigation per window.
      [ ] 12.6.5.5 Subtask - Verify documentation covers all navigation API and common patterns.
