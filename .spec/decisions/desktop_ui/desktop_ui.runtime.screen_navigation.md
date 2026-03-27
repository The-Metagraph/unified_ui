---
id: desktop_ui.runtime.screen_navigation
status: accepted
date: 2026-03-26
affects:
  - desktop_ui.runtime
  - desktop_ui.structure
---

# Screen Navigation for DesktopUi

## Context

`desktop_ui` currently supports a 1:1 relationship between screens and windows: mounting a screen creates a runtime state with a single root widget tree. This is analogous to Phoenix LiveView's one-LiveView-per-page model, but LiveView provides navigation primitives (`push_navigate/2`, `push_patch/2`, `handle_params/2`) that allow moving between views within the same application. Desktop applications need equivalent navigation capabilities to support multi-screen applications with home screens, detail screens, settings, and back/forward navigation.

## Decision

`desktop_ui` will add a Navigation layer that provides screen-to-screen navigation within a window, modeled after Phoenix LiveView's navigation semantics but adapted for desktop without URL routing:

1. **Navigation Controller** - A GenServer that manages navigation state including history stack, current screen, forward stack, and modal stack
2. **Screen Registry** - Applications register available screen modules with identifiers for navigation lookup
3. **Navigation Actions** - `navigate/2`, `replace/2`, `go_back/0`, `go_forward/0`, `open_modal/2`, `close_modal/0`
4. **Navigation Events** - Widgets emit navigation signals (`:navigate_to`, `:replace_with`) that route to the controller
5. **History Stack** - Navigation history supports back/forward semantics like web browsers
6. **Modal Stack** - Separate stack for dialogs/overlays that don't affect main navigation history
7. **Runtime Integration** - `DesktopUi.Runtime` handles navigation actions by swapping screen state while preserving window state

### Navigation State Structure

```elixir
%Navigation.State{
  current: :screen_id,
  history: [:home, :list],      # Back navigation
  forward: [],                   # Forward navigation (after back)
  modals: [:dialog_screen],      # Modal stack
  params: %{}                    # Current screen params
}
```

### Screen Registry

Applications declare available screens:

```elixir
defmodule MyApp.Screens do
  def register do
    %{
      home: HomeScreen,
      list: ItemListScreen,
      detail: ItemDetailScreen,
      settings: SettingsScreen
    }
  end
end
```

### Navigation Actions

```elixir
# Navigate to screen, adding to history
Navigation.navigate(:detail, %{item_id: 123})

# Replace current screen, no history entry
Navigation.replace(:error, %{code: 404})

# Go back in history
Navigation.go_back()

# Open modal (independent stack)
Navigation.open_modal(:confirm_dialog, %{action: :delete})
```

### Widget Integration

```elixir
# Emit navigation signals from widgets
DesktopUi.Widgets.button("view_btn", "View Details",
  on_click: {:navigate_to, :detail}
)

DesktopUi.Widgets.link("settings_link", "Settings",
  on_click: {:navigate_to, :settings}
)
```

## Consequences

- Applications can implement multi-screen flows without managing window lifecycle manually
- Navigation state is separate from window state, allowing windows to persist across screen transitions
- History stack provides familiar back/forward semantics
- Modal stack keeps dialogs separate from main navigation flow
- No URL routing required - navigation is application-internal
- Consistent with LiveView navigation mental model for developers working across web and desktop
- Existing single-screen applications continue to work unchanged
