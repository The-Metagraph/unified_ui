defmodule Demo.Widgets.Topbar do
  @moduledoc """
  Application topbar widget with menu and status.
  """

  alias DesktopUi.Widgets
  alias Demo.Screens

  def build(id, opts \\ []) do
    Widgets.row(id, [
      # Logo/title
      Widgets.content("topbar-logo", [
        Widgets.icon("app-icon", :application),
        Widgets.label("app-title", "Desktop UI Demo")
      ]),
      Widgets.spacer("topbar-spacer"),
      # Menu
      Widgets.menu("topbar-menu", build_menu_items(), current: nil),
      Widgets.separator("topbar-menu-sep"),
      # Search
      Widgets.text_input("topbar-search",
        placeholder: "Search widgets...",
        size: :sm
      )
    ], gap: 16)
  end

  defp build_menu_items do
    categories = Screens.categories()

    Enum.map(categories, fn category ->
      category_name = category |> Atom.to_string() |> String.capitalize()
      widgets = Screens.widgets_for_category(category)

      %{
        id: category,
        label: category_name,
        children: Enum.map(widgets, fn {widget_id, title, _desc} ->
          %{
            id: widget_id,
            label: title,
            navigate_to: widget_id,
            navigate_params: %{widget_id: widget_id, category: category}
          }
        end)
      }
    end)
  end
end
