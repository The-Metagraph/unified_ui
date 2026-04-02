defmodule LiveUi.Demo.WidgetPreviewState do
  @moduledoc false

  alias LiveUi.Runtime.State

  @type widget_id ::
          :button
          | :link
          | :text_input
          | :toggle
          | :select
          | :menu
          | :tabs
          | :list
          | :table
          | :tree_view
          | :context_menu
          | :command_palette

  @type t :: %{
          optional(widget_id()) => map()
        }

  @spec defaults() :: t()
  def defaults do
    %{
      button: %{clicks: 0},
      link: %{clicks: 0},
      text_input: %{value: "Live UI"},
      toggle: %{checked: true},
      select: %{value: "display"},
      menu: %{active: "insights"},
      tabs: %{active: "surface"},
      list: %{selected: "button"},
      table: %{selected: "button"},
      tree_view: %{selected: "overlay"},
      context_menu: %{active: "inspect"},
      command_palette: %{query: "wid", active: "widgets"}
    }
  end

  @spec apply(State.t(), map()) :: State.t()
  def apply(%State{} = runtime_state, translation) when is_map(translation) do
    case normalize_widget_id(runtime_state.assigns[:selected_example]) do
      nil ->
        runtime_state

      widget_id ->
        demo_state =
          runtime_state.assigns
          |> Map.get(:widget_demo_state, defaults())
          |> ensure_defaults()
          |> update_widget_state(widget_id, normalize_payload(translation))

        %{runtime_state | assigns: Map.put(runtime_state.assigns, :widget_demo_state, demo_state)}
    end
  end

  @spec ensure_defaults(map() | nil) :: t()
  def ensure_defaults(nil), do: defaults()

  def ensure_defaults(state) when is_map(state) do
    Map.merge(defaults(), state)
  end

  defp update_widget_state(state, :button, _payload) do
    update_in(state, [:button, :clicks], &((&1 || 0) + 1))
  end

  defp update_widget_state(state, :link, _payload) do
    update_in(state, [:link, :clicks], &((&1 || 0) + 1))
  end

  defp update_widget_state(state, :text_input, payload) do
    put_in(state, [:text_input, :value], fetch(payload, "widget_name", state[:text_input][:value]))
  end

  defp update_widget_state(state, :toggle, payload) do
    checked? =
      payload
      |> fetch("widget_enabled")
      |> checkbox_value?()

    put_in(state, [:toggle, :checked], checked?)
  end

  defp update_widget_state(state, :select, payload) do
    value = fetch(payload, "widget_category", state[:select][:value])
    put_in(state, [:select, :value], value)
  end

  defp update_widget_state(state, :menu, payload) do
    put_in(state, [:menu, :active], fetch(payload, "item_id", state[:menu][:active]))
  end

  defp update_widget_state(state, :tabs, payload) do
    put_in(state, [:tabs, :active], fetch(payload, "item_id", state[:tabs][:active]))
  end

  defp update_widget_state(state, :list, payload) do
    put_in(state, [:list, :selected], fetch(payload, "item_id", state[:list][:selected]))
  end

  defp update_widget_state(state, :table, payload) do
    put_in(state, [:table, :selected], fetch(payload, "item_id", state[:table][:selected]))
  end

  defp update_widget_state(state, :tree_view, payload) do
    put_in(state, [:tree_view, :selected], fetch(payload, "item_id", state[:tree_view][:selected]))
  end

  defp update_widget_state(state, :context_menu, payload) do
    put_in(
      state,
      [:context_menu, :active],
      fetch(payload, "item_id", state[:context_menu][:active])
    )
  end

  defp update_widget_state(state, :command_palette, payload) do
    state
    |> put_in(
      [:command_palette, :query],
      fetch(payload, "command_query", state[:command_palette][:query])
    )
    |> put_in(
      [:command_palette, :active],
      fetch(payload, "item_id", state[:command_palette][:active])
    )
  end

  defp update_widget_state(state, _widget_id, _payload), do: state

  defp normalize_widget_id(nil), do: nil

  defp normalize_widget_id(widget_id) when is_atom(widget_id) do
    if widget_id in Map.keys(defaults()), do: widget_id, else: nil
  end

  defp normalize_widget_id(widget_id) when is_binary(widget_id) do
    widget_id
    |> String.to_existing_atom()
    |> normalize_widget_id()
  rescue
    ArgumentError -> nil
  end

  defp normalize_payload(translation) do
    translation
    |> Map.get(:payload, %{})
    |> case do
      payload when is_map(payload) -> Map.new(payload, fn {key, value} -> {to_string(key), value} end)
      _other -> %{}
    end
  end

  defp fetch(payload, key, default \\ nil) do
    Map.get(payload, key, default)
  end

  defp checkbox_value?(value) when value in [true, "true", "on", "1", 1], do: true
  defp checkbox_value?(_value), do: false
end
