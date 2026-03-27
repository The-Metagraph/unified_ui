defmodule Demo.Screens.Home do
  @moduledoc """
  Home screen for the desktop_ui demo application.

  Displays a welcome message with links to widget categories.
  """

  alias DesktopUi.Widgets

  def render(assigns) do
    Widgets.column("home-screen", [
      # Header
      Widgets.content("home-header", [
        Widgets.icon("home-icon", :home),
        Widgets.label("home-title", "Desktop UI Demo"),
        Widgets.text("home-subtitle", "Explore the widget catalog using the sidebar or menu")
      ]),
      Widgets.separator("home-sep-1"),
      # Welcome message
      Widgets.content("home-welcome", [
        Widgets.text("welcome-title", "Welcome to Desktop UI Demo"),
        Widgets.text("welcome-desc",
          "This demo showcases all available widgets organized by category. " <>
          "Use the sidebar on the left or the menu in the top bar to navigate between widgets."
        )
      ]),
      Widgets.separator("home-sep-2"),
      # Category overview
      Widgets.content("home-categories", [
        Widgets.text("categories-title", "Widget Categories:"),
        category_list()
      ])
    ])
  end

  defp category_list do
    categories = [
      {:content, "Content", "Basic content widgets (button, text, icon, etc.)"},
      {:layout, "Layout", "Layout containers (box, row, column, grid)"},
      {:forms, "Forms", "Form building widgets"},
      {:input, "Input", "User input controls"},
      {:navigation, "Navigation", "Navigation widgets (menu, tabs, list)"},
      {:data, "Data", "Data display (table, tree, charts)"},
      {:feedback, "Feedback", "Status and progress indicators"},
      {:display, "Display", "Advanced display (viewport, canvas)"},
      {:overlay, "Overlay", "Modal dialogs and overlays"},
      {:operational, "Operational", "System monitoring widgets"}
    ]

    Widgets.column("category-list",
      Enum.map(categories, fn {id, title, desc} ->
        Widgets.button("cat-#{id}", title,
          navigate_to: id,
          navigate_params: %{category: id},
          styles: %{text_align: :left}
        )
      end)
    )
  end
end
