defmodule DesktopUi.Widgets.Navigation do
  @moduledoc """
  Foundational navigation widgets for direct-native `desktop_ui`.
  """

  alias DesktopUi.Widget

  @spec kinds() :: [atom()]
  def kinds do
    [:breadcrumbs, :list, :menu, :tabs]
  end

  @spec tabs(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def tabs(id, items, opts \\ []) do
    navigation_widget(:tabs, id, items, opts)
  end

  @spec menu(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def menu(id, items, opts \\ []) do
    navigation_widget(:menu, id, items, opts)
  end

  @spec breadcrumbs(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def breadcrumbs(id, items, opts \\ []) do
    navigation_widget(:breadcrumbs, id, items, opts)
  end

  @spec list(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def list(id, items, opts \\ []) do
    navigation_widget(:list, id, items, opts)
  end

  defp navigation_widget(kind, id, items, opts) do
    Widget.new(kind,
      id: id,
      metadata:
        %{
          focusable: true,
          role: kind,
          shortcut: Keyword.get(opts, :shortcut),
          shortcut_scope: Keyword.get(opts, :shortcut_scope, :screen),
          focus_group: Keyword.get(opts, :focus_group, "#{id}:#{kind}")
        }
        |> Map.merge(Map.new(Keyword.get(opts, :metadata, []))),
      state: %{
        disabled: Keyword.get(opts, :disabled, false),
        focused: false,
        current: Keyword.get(opts, :current, Keyword.get(opts, :active_item))
      },
      bindings: %{current: Keyword.get(opts, :binding, :current)},
      attributes: %{
        items: Enum.map(items, &Map.new/1),
        current: Keyword.get(opts, :current, Keyword.get(opts, :active_item))
      },
      styles: Map.new(Keyword.get(opts, :styles, [])),
      events:
        %{
          navigation: Keyword.get(opts, :on_navigate, %{intent: :navigate}),
          selection: Keyword.get(opts, :on_select, %{intent: :select_navigation_item}),
          shortcut:
            shortcut_payload(
              Keyword.get(opts, :shortcut),
              Keyword.get(opts, :shortcut_intent, :open_navigation)
            )
        }
        |> Enum.reject(fn {_key, value} -> is_nil(value) end)
        |> Map.new()
    )
  end

  defp shortcut_payload(nil, _intent), do: nil

  defp shortcut_payload(shortcut, intent) do
    %{key: shortcut, intent: intent}
  end
end
