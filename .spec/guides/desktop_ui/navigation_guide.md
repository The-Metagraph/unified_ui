# Screen Navigation Guide

This guide covers screen navigation in `desktop_ui` applications, including navigation controllers, screen registries, and navigation patterns.

## Overview

Screen navigation in `desktop_ui` allows applications to manage multiple screens within a window, with support for:

- **Navigation stack** - History management with back/forward navigation
- **Modal dialogs** - Independent modal stack for overlays
- **Screen registry** - Application-level screen declaration
- **Navigation signals** - Widget-based navigation triggers

## Quick Start

### 1. Define Your Screens

Create screen modules that render content:

```elixir
defmodule MyApp.Screens.Home do
  @moduledoc "Home screen"

  def render(assigns) do
    DesktopUi.Widgets.column("home-layout", [
      DesktopUi.Widgets.label("home-title", "Welcome"),
      DesktopUi.Widgets.button("items-button", "View Items",
        navigate_to: :items
      )
    ])
  end
end

defmodule MyApp.Screens.Items do
  def render(assigns) do
    DesktopUi.Widgets.list("items-list",
      [
        %{id: :item1, label: "Item 1"},
        %{id: :item2, label: "Item 2"}
      ],
      on_navigate: %{family: :navigation, type: :navigate_to, screen_id: :detail}
    )
  end
end

defmodule MyApp.Screens.Detail do
  def render(assigns) do
    item_id = Map.get(assigns, :item_id)

    DesktopUi.Widgets.content("detail-content", [
      DesktopUi.Widgets.text("detail-title", "Item #{item_id}"),
      DesktopUi.Widgets.button("back-button", "Back", go_back: true)
    ])
  end
end
```

### 2. Create a Screen Registry

Define a registry module that maps screen IDs to screen modules:

```elixir
defmodule MyApp.Screens do
  @behaviour DesktopUi.Navigation.Registry

  @impl true
  def register do
    %{
      home: {HomeScreen, title: "Home", icon: :home},
      items: {ItemsScreen, title: "Items", icon: :list},
      detail: {DetailScreen, title: "Details", icon: :detail}
    }
  end

  @impl true
  def get_screen(:home), do: HomeScreen
  def get_screen(:items), do: ItemsScreen
  def get_screen(:detail), do: DetailScreen
  def get_screen(_), do: nil

  @impl true
  def screen_metadata(:home) do
    %{
      title: "Home",
      icon: :home,
      appears_in_history?: true,
      modal_only?: false
    }
  end

  def screen_metadata(_), do: %{}
end
```

### 3. Start a Navigation Controller

Start the navigation controller when booting your runtime:

```elixir
{:ok, controller} = DesktopUi.Navigation.Controller.start_link(
  name: :my_nav,
  registry: MyApp.Screens,
  initial_screen: {:home, HomeScreen, %{}}
)

# Or integrate with runtime boot
{:ok, runtime_state} = DesktopUi.Runtime.Boot.start_navigation_controller(
  runtime_state,
  registry: MyApp.Screens,
  initial_screen: {:home, HomeScreen, %{}}
)
```

### 4. Navigate Between Screens

Use the navigation controller API:

```elixir
# Navigate to a screen (adds to history)
{:ok, nav_state, {:transition, :navigated}} =
  DesktopUi.Navigation.Controller.navigate(:my_nav, :items, %{})

# Replace current screen (no history entry)
{:ok, nav_state, {:transition, :replaced}} =
  DesktopUi.Navigation.Controller.replace(:my_nav, :error, %{code: 404})

# Go back
{:ok, nav_state, {:transition, :back}} =
  DesktopUi.Navigation.Controller.go_back(:my_nav)

# Go forward
{:ok, nav_state, {:transition, :forward}} =
  DesktopUi.Navigation.Controller.go_forward(:my_nav)

# Open a modal
{:ok, nav_state, {:transition, :modal_opened}} =
  DesktopUi.Navigation.Controller.open_modal(:my_nav, :confirm_dialog, %{})

# Close modal
{:ok, nav_state, {:transition, :modal_closed}} =
  DesktopUi.Navigation.Controller.close_modal(:my_nav)
```

## Widget Navigation

### Button Navigation

```elixir
DesktopUi.Widgets.button("detail-button", "View Details",
  navigate_to: :detail,
  navigate_params: %{item_id: 123}
)
```

### Back/Forward Buttons

```elixir
# Back button
DesktopUi.Widgets.button("back-button", "Back", go_back: true)

# Forward button
DesktopUi.Widgets.button("forward-button", "Forward", go_forward: true)
```

### Modal Buttons

```elixir
DesktopUi.Widgets.button("confirm-button", "Open Confirm",
  open_modal: :confirm_dialog,
  navigate_params: %{message: "Are you sure?"}
)
```

### Menu Navigation

```elixir
DesktopUi.Widgets.menu(
  "main-menu",
  [
    %{id: :home, label: "Home"},
    %{id: :items, label: "Items"},
    %{id: :settings, label: "Settings"}
  ],
  on_navigate: %{family: :navigation, type: :navigate_to}
)
```

## Navigation Signals

Create navigation signals directly:

```elixir
alias DesktopUi.Navigation.Signal

# Navigate signal
signal = Signal.navigate(:detail, %{item_id: 123})

# Replace signal
signal = Signal.replace(:error, %{code: 404})

# Back signal
signal = Signal.go_back()

# Forward signal
signal = Signal.go_forward()

# Modal signals
signal = Signal.open_modal(:confirm_dialog, %{message: "OK"})
signal = Signal.close_modal()

# Execute signal
{:ok, nav_state, transition} = Signal.execute(signal, controller)
```

## Lifecycle Callbacks

Screen modules can implement optional lifecycle callbacks:

```elixir
defmodule MyApp.Screens.Detail do
  @behaviour DesktopUi.Navigation.Lifecycle

  # Called when screen becomes current
  @impl true
  def on_mount(screen_id, params) do
    {:cont, %{item_id: Map.get(params, :item_id)}}
  end

  # Called when screen is no longer current
  @impl true
  def on_unmount(screen_id, state) do
    # Clean up subscriptions, etc.
    :ok
  end

  # Called before navigation (can intercept)
  @impl true
  def handle_navigation(from, to, action, params) do
    # Can return {:halt, state} to cancel navigation
    {:cont, params}
  end

  def render(assigns) do
    # ...
  end
end
```

## Navigation State

The navigation state maintains:

- `current` - Current screen ID
- `current_module` - Current screen module
- `current_params` - Current screen params
- `history` - Stack of previous screens (for back navigation)
- `forward` - Stack of forward screens (for forward navigation)
- `modals` - Stack of modal screens
- `modal_open?` - Whether a modal is currently open

Access navigation state:

```elixir
nav_state = DesktopUi.Navigation.Controller.get_state(controller)

# Check state
DesktopUi.Navigation.State.can_go_back?(nav_state)
DesktopUi.Navigation.State.can_go_forward?(nav_state)
DesktopUi.Navigation.State.modal_open?(nav_state)

# Get current screen
{screen_id, screen_module, params} =
  DesktopUi.Navigation.State.current_screen(nav_state)
```

## Runtime Integration

Handle navigation events in the runtime:

```elixir
# Check if event is navigation
if DesktopUi.Navigation.Integration.navigation_event?(event) do
  {:ok, new_runtime, nav_state, transition} =
    DesktopUi.Navigation.Integration.handle_event(runtime_state, event)
end

# Query navigation state
DesktopUi.Navigation.Integration.can_go_back?(runtime_state)
DesktopUi.Navigation.Integration.can_go_forward?(runtime_state)
DesktopUi.Navigation.Integration.modal_open?(runtime_state)
DesktopUi.Navigation.Integration.current_modal(runtime_state)
```

## Common Patterns

### Master-Detail Navigation

```elixir
# Master list with item selection
DesktopUi.Widgets.list(
  "items-list",
  items,
  on_navigate: %{
    family: :navigation,
    type: :navigate_to,
    screen_id: :detail
  }
)

# Detail screen with back button
DesktopUi.Widgets.button("back-button", "Back", go_back: true)
```

### Wizard Flow

```elixir
# Navigate between wizard steps
DesktopUi.Navigation.Controller.navigate(controller, :wizard_step_2, %{
  step: 2,
  data: previous_data
})

# Use replace for wizard steps to avoid building history
DesktopUi.Navigation.Controller.replace(controller, :wizard_step_3, %{
  step: 3,
  data: current_data
})
```

### Modal Dialogs

```elixir
# Open modal
DesktopUi.Navigation.Controller.open_modal(controller, :confirm_dialog, %{
  message: "Are you sure?",
  on_confirm: :delete_item
})

# In modal screen, provide close/confirm actions
DesktopUi.Widgets.button("cancel-button", "Cancel", close_modal: true)
DesktopUi.Widgets.button("confirm-button", "Confirm", close_modal: true)
```

### Error Handling

```elixir
# Replace current screen with error screen
DesktopUi.Navigation.Controller.replace(controller, :error, %{
  code: 404,
  message: "Item not found"
})

# Or use navigate if you want error screen in history
DesktopUi.Navigation.Controller.navigate(controller, :error, %{
  code: 500,
  message: "Server error"
})
```

## Best Practices

1. **Use a screen registry** - Centralize screen ID to module mapping
2. **Prefer navigate over replace** - Navigate provides history, replace does not
3. **Use modals for temporary context** - Modals should be short-lived interactions
4. **Handle navigation errors** - Always check for `{:error, reason}` results
5. **Clean up in on_unmount** - Unsubscribe from events, close resources
6. **Validate in handle_navigation** - Check if navigation should proceed
7. **Use params for data** - Pass data through navigation params, not assigns

## API Reference

- `DesktopUi.Navigation` - Main navigation module
- `DesktopUi.Navigation.Controller` - Navigation controller GenServer
- `DesktopUi.Navigation.State` - Navigation state struct and helpers
- `DesktopUi.Navigation.Registry` - Registry behaviour for screen registration
- `DesktopUi.Navigation.Lifecycle` - Optional lifecycle callbacks for screens
- `DesktopUi.Navigation.Signal` - Navigation signal types
- `DesktopUi.Navigation.Integration` - Runtime integration helpers
- `DesktopUi.Widgets.Navigation` - Navigation widget helpers
