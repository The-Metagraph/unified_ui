# DesktopUi Runtime

This subject defines the target runtime behavior of `desktop_ui` as a
multiplatform SDL3-based desktop library.

## Related General Specs

- [Platform Runtimes](../platform_runtimes.spec.md)
- [Signal Transport](../signal_transport.spec.md)
- [DesktopUi Package](./package.spec.md)
- [DesktopUi Native Widgets](./native_widgets.spec.md)
- [DesktopUi Transport](./transport.spec.md)
- [DesktopUi Structure](./structure.spec.md)

```spec-meta
id: desktop_ui.runtime
kind: runtime
status: active
summary: Target multiplatform desktop runtime contract for `desktop_ui`, including SDL3-based rendering and input coordination across Windows, macOS, and Linux.
surface:
  - packages/desktop_ui
  - .spec/specs/desktop_ui/runtime.spec.md
decisions:
  - repo.ecosystem.contract_model
  - desktop_ui.runtime.screen_navigation
```

## Requirements

```spec-requirements
- id: desktop_ui.runtime.sdl3_foundation
  statement: The desktop runtime shall use SDL3 as the shared rendering and input foundation across supported desktop targets while allowing platform integration layers to supply target-specific behavior where needed.
  priority: must
  stability: stable

- id: desktop_ui.runtime.shared_runtime_across_targets
  statement: The package shall maintain one coherent desktop runtime model across Windows, macOS, and Linux even when platform integration details differ.
  priority: must
  stability: stable

- id: desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
  statement: The same runtime architecture shall support both direct native `desktop_ui` usage and canonical IUR rendering so the package does not split into unrelated runtime models.
  priority: must
  stability: stable

- id: desktop_ui.runtime.window_lifecycle_and_input
  statement: The runtime shall coordinate window lifecycle, SDL3 callback-driven app execution, desktop input, focus, redraw scheduling, and platform callbacks in a way that preserves canonical desktop UI meaning across supported targets.
  priority: must
  stability: stable

- id: desktop_ui.runtime.interactive_visible_execution
  statement: The compiled visible-window runtime shall support maintained keyboard, pointer, focus, scrolling, selection, command, and multiwindow interaction flows through real hit-testing and event dispatch while preserving the same semantic outcomes as the fallback and canonical runtime paths.
  priority: must
  stability: stable

- id: desktop_ui.runtime.platform_variation_bounded
  statement: Platform-specific runtime behavior may vary where operating-system integration requires it, but those variations shall remain bounded behind the shared `desktop_ui` runtime model.
  priority: must
  stability: stable

- id: desktop_ui.runtime.screen_navigation_support
  statement: The runtime shall provide navigation primitives for moving between screens within a window, including history stack tracking, back/forward navigation, and modal dialogs.
  priority: must
  stability: stable

- id: desktop_ui.runtime.navigation_controller_process
  statement: Screen navigation shall be managed by a dedicated GenServer that maintains navigation state independent of window state, allowing windows to persist across screen transitions.
  priority: must
  stability: stable

- id: desktop_ui.runtime.screen_registry
  statement: Applications shall be able to register screen modules with identifiers for navigation lookup, and the runtime shall resolve navigation targets from this registry.
  priority: must
  stability: stable

- id: desktop_ui.runtime.navigation_actions
  statement: The runtime shall support navigation actions including `navigate/2` for history-push transitions, `replace/2` for history-neutral transitions, `go_back/0` and `go_forward/0` for history traversal, and `open_modal/2`/`close_modal/0` for modal dialogs.
  priority: must
  stability: stable

- id: desktop_ui.runtime.navigation_event_routing
  statement: Widgets shall emit navigation signals (`:navigate_to`, `:replace_with`, `:go_back`, etc.) that route to the navigation controller, and the runtime shall update the current screen state in response to navigation actions.
  priority: must
  stability: stable

- id: desktop_ui.runtime.modal_stack_independence
  statement: Modal dialogs shall be managed on a separate stack from main navigation history, allowing overlays to open and close without affecting back/forward navigation state.
  priority: must
  stability: stable
```

## Scenarios

```spec-scenarios
- id: desktop_ui.runtime_run_same_screen_on_multiple_targets
  covers:
    - desktop_ui.runtime.sdl3_foundation
    - desktop_ui.runtime.shared_runtime_across_targets
    - desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
    - desktop_ui.runtime.window_lifecycle_and_input
    - desktop_ui.runtime.interactive_visible_execution
    - desktop_ui.runtime.platform_variation_bounded
    - desktop_ui.runtime.screen_navigation_support
    - desktop_ui.runtime.navigation_controller_process
    - desktop_ui.runtime.screen_registry
    - desktop_ui.runtime.navigation_actions
    - desktop_ui.runtime.navigation_event_routing
    - desktop_ui.runtime.modal_stack_independence
  given:
    - The same native or canonical-IUR-driven screen is launched on Windows, macOS, and Linux
  when:
    - `desktop_ui` runs the screen
  then:
    - The package preserves one runtime model and one canonical UI meaning while allowing target-specific integration details underneath

- id: desktop_ui.runtime_interact_with_visible_native_window
  covers:
    - desktop_ui.runtime.sdl3_foundation
    - desktop_ui.runtime.shared_runtime_across_targets
    - desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
    - desktop_ui.runtime.window_lifecycle_and_input
    - desktop_ui.runtime.interactive_visible_execution
    - desktop_ui.runtime.platform_variation_bounded
    - desktop_ui.runtime.screen_navigation_support
    - desktop_ui.runtime.navigation_controller_process
    - desktop_ui.runtime.screen_registry
    - desktop_ui.runtime.navigation_actions
    - desktop_ui.runtime.navigation_event_routing
    - desktop_ui.runtime.modal_stack_independence
  given:
    - A maintainer runs a compiled visible-window `desktop_ui` example and interacts with focusable controls, pointers, scrolling regions, and secondary windows
  when:
    - Input events flow through the runtime
  then:
    - The runtime preserves the same binding, command, transport, and window-management semantics expected by native and canonical package flows

- id: desktop_ui.runtime_navigate_between_screens
  covers:
    - desktop_ui.runtime.sdl3_foundation
    - desktop_ui.runtime.shared_runtime_across_targets
    - desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
    - desktop_ui.runtime.window_lifecycle_and_input
    - desktop_ui.runtime.interactive_visible_execution
    - desktop_ui.runtime.platform_variation_bounded
    - desktop_ui.runtime.screen_navigation_support
    - desktop_ui.runtime.navigation_controller_process
    - desktop_ui.runtime.screen_registry
    - desktop_ui.runtime.navigation_actions
    - desktop_ui.runtime.navigation_event_routing
    - desktop_ui.runtime.modal_stack_independence
  given:
    - A desktop_ui application with multiple registered screens
  when:
    - A widget emits a `:navigate_to` signal for a registered screen
  then:
    - The navigation controller updates the current screen, pushes the previous screen onto the history stack, and the runtime renders the new screen within the same window

- id: desktop_ui.runtime_back_navigation
  covers:
    - desktop_ui.runtime.sdl3_foundation
    - desktop_ui.runtime.shared_runtime_across_targets
    - desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
    - desktop_ui.runtime.window_lifecycle_and_input
    - desktop_ui.runtime.interactive_visible_execution
    - desktop_ui.runtime.platform_variation_bounded
    - desktop_ui.runtime.screen_navigation_support
    - desktop_ui.runtime.navigation_controller_process
    - desktop_ui.runtime.screen_registry
    - desktop_ui.runtime.navigation_actions
    - desktop_ui.runtime.navigation_event_routing
    - desktop_ui.runtime.modal_stack_independence
  given:
    - A user has navigated through multiple screens (home → list → detail)
  when:
    - The user triggers `:go_back` navigation
  then:
    - The navigation controller pops from the history stack to return to the previous screen, and the forward stack stores the detail screen for potential forward navigation

- id: desktop_ui.runtime_replace_current_screen
  covers:
    - desktop_ui.runtime.sdl3_foundation
    - desktop_ui.runtime.shared_runtime_across_targets
    - desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
    - desktop_ui.runtime.window_lifecycle_and_input
    - desktop_ui.runtime.interactive_visible_execution
    - desktop_ui.runtime.platform_variation_bounded
    - desktop_ui.runtime.screen_navigation_support
    - desktop_ui.runtime.navigation_controller_process
    - desktop_ui.runtime.screen_registry
    - desktop_ui.runtime.navigation_actions
    - desktop_ui.runtime.navigation_event_routing
    - desktop_ui.runtime.modal_stack_independence
  given:
    - A user is viewing a screen and an error occurs or an auth redirect is needed
  when:
    - The navigation controller receives a `:replace` action
  then:
    - The current screen is replaced without adding to the history stack, preventing back navigation to the replaced screen

- id: desktop_ui.runtime_modal_dialog_independent_history
  covers:
    - desktop_ui.runtime.sdl3_foundation
    - desktop_ui.runtime.shared_runtime_across_targets
    - desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
    - desktop_ui.runtime.window_lifecycle_and_input
    - desktop_ui.runtime.interactive_visible_execution
    - desktop_ui.runtime.platform_variation_bounded
    - desktop_ui.runtime.screen_navigation_support
    - desktop_ui.runtime.navigation_controller_process
    - desktop_ui.runtime.screen_registry
    - desktop_ui.runtime.navigation_actions
    - desktop_ui.runtime.navigation_event_routing
    - desktop_ui.runtime.modal_stack_independence
  given:
    - A user is viewing a screen with navigation history
  when:
    - A modal dialog is opened via `:open_modal` and then closed
  then:
    - The modal appears on top of the current screen, and closing it returns to the same screen without affecting the navigation history stack

- id: desktop_ui.runtime_window_persists_across_screen_transitions
  covers:
    - desktop_ui.runtime.sdl3_foundation
    - desktop_ui.runtime.shared_runtime_across_targets
    - desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
    - desktop_ui.runtime.window_lifecycle_and_input
    - desktop_ui.runtime.interactive_visible_execution
    - desktop_ui.runtime.platform_variation_bounded
    - desktop_ui.runtime.screen_navigation_support
    - desktop_ui.runtime.navigation_controller_process
    - desktop_ui.runtime.screen_registry
    - desktop_ui.runtime.navigation_actions
    - desktop_ui.runtime.navigation_event_routing
    - desktop_ui.runtime.modal_stack_independence
  given:
    - A window is open displaying a screen
  when:
    - Navigation occurs to a different screen
  then:
    - The window remains open with the same position, size, and platform state; only the screen content changes
```

## Verification

```spec-verification
- kind: source_file
  target: .spec/specs/desktop_ui/runtime.spec.md
  covers:
    - desktop_ui.runtime.sdl3_foundation
    - desktop_ui.runtime.shared_runtime_across_targets
    - desktop_ui.runtime.native_and_iur_entrypoints_share_runtime
    - desktop_ui.runtime.window_lifecycle_and_input
    - desktop_ui.runtime.interactive_visible_execution
    - desktop_ui.runtime.platform_variation_bounded
    - desktop_ui.runtime.screen_navigation_support
    - desktop_ui.runtime.navigation_controller_process
    - desktop_ui.runtime.screen_registry
    - desktop_ui.runtime.navigation_actions
    - desktop_ui.runtime.navigation_event_routing
    - desktop_ui.runtime.modal_stack_independence
    - desktop_ui.runtime_run_same_screen_on_multiple_targets
    - desktop_ui.runtime_interact_with_visible_native_window
    - desktop_ui.runtime_navigate_between_screens
    - desktop_ui.runtime_back_navigation
    - desktop_ui.runtime_replace_current_screen
    - desktop_ui.runtime_modal_dialog_independent_history
    - desktop_ui.runtime_window_persists_across_screen_transitions

- kind: source_file
  target: .spec/decisions/desktop_ui/desktop_ui.runtime.screen_navigation.md
  covers:
    - desktop_ui.runtime.screen_navigation_support
    - desktop_ui.runtime.navigation_controller_process
    - desktop_ui.runtime.screen_registry
    - desktop_ui.runtime.navigation_actions
    - desktop_ui.runtime.navigation_event_routing
    - desktop_ui.runtime.modal_stack_independence
```
