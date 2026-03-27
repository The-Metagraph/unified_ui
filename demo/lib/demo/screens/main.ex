defmodule Demo.Screens.Main do
  @moduledoc """
  Main demo screen that integrates all layout components.

  This is the primary screen for the desktop_ui demo application.
  """

  alias DesktopUi.Widgets
  alias DesktopUi.Navigation.Controller
  alias Demo.Widgets.{Sidebar, Topbar, ContentArea}

  def render(assigns) do
    nav_controller = Keyword.get(assigns, :nav_controller, :demo_nav)
    current_screen = Keyword.get(assigns, :current_screen, :home)
    screen_params = Keyword.get(assigns, :screen_params, %{})

    # Get current category from params for sidebar highlighting
    current_category = Map.get(screen_params, :category)
    current_widget = Map.get(screen_params, :widget_id)

    Widgets.window("demo-window", "Desktop UI Demo", [
      Widgets.column("demo-layout", [
        # Topbar
        Topbar.build("demo-topbar"),
        Widgets.separator("topbar-sep"),
        # Main content area with sidebar
        Widgets.row("main-area", [
          # Sidebar with navigation
          Sidebar.build("demo-sidebar",
            current_category: current_category,
            current_widget: current_widget
          ),
          Widgets.separator("sidebar-sep"),
          # Content area showing current screen
          ContentArea.build("demo-content",
            nav_controller: nav_controller,
            current_screen: current_screen,
            screen_params: screen_params
          )
        ])
      ])
    ])
  end
end
