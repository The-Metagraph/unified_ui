defmodule Demo.Widgets.ContentArea do
  @moduledoc """
  Main content area widget displaying the current screen.

  This widget renders the current screen based on the navigation state.
  """

  alias DesktopUi.Widgets
  alias DesktopUi.Navigation.Controller

  def build(id, opts \\ []) do
    nav_controller = Keyword.get(opts, :nav_controller, :demo_nav)
    current_screen = Keyword.get(opts, :current_screen, :home)
    screen_params = Keyword.get(opts, :screen_params, %{})

    nav_state = Controller.get_state(nav_controller)

    Widgets.content(id, [
      # Screen header with breadcrumbs
      build_header(current_screen, screen_params),
      Widgets.separator("content-sep"),
      # Screen content
      build_screen_content(current_screen, screen_params, nav_state)
    ])
  end

  defp build_header(screen_id, screen_params) do
    {title, category, _icon} = get_screen_info(screen_id)

    breadcrumbs = build_breadcrumbs(screen_id, category)

    Widgets.content("screen-header", [
      breadcrumbs,
      Widgets.text("screen-title", title),
      Widgets.text("screen-params", format_params(screen_params))
    ])
  end

  defp build_breadcrumbs(screen_id, nil) do
    Widgets.breadcrumbs("screen-breadcrumbs", [
      %{id: :home, label: "Home", navigate_to: :home}
    ])
  end

  defp build_breadcrumbs(screen_id, category) do
    Widgets.breadcrumbs("screen-breadcrumbs", [
      %{id: :home, label: "Home", navigate_to: :home},
      %{id: category, label: format_category(category), navigate_to: category}
    ])
  end

  defp build_screen_content(:home, _params, _nav_state) do
    Demo.Screens.Home.render(%{})
  end

  defp build_screen_content(widget_id, params, _nav_state) when is_atom(widget_id) do
    Demo.Screens.WidgetScreen.render(Map.put(params, :widget_id, widget_id))
  end

  defp build_screen_content(_screen_id, _params, _nav_state) do
    Widgets.content("default-content", [
      Widgets.text("default-title", "Select a widget to view its demo")
    ])
  end

  # Helper functions

  defp get_screen_info(:home) do
    {"Home", nil, :home}
  end

  defp get_screen_info(screen_id) when is_atom(screen_id) do
    case Demo.Screens.screen_metadata(screen_id) do
      %{title: title, icon: icon, category: category} ->
        {title, category, icon}

      _ ->
        {Atom.to_string(screen_id) |> String.capitalize(), nil, :widget}
    end
  end

  defp format_category(category) when is_atom(category) do
    category |> Atom.to_string() |> String.capitalize()
  end

  defp format_params(params) when params == %{}, do: ""
  defp format_params(params), do: inspect(params)
end
