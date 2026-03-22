defmodule TerminalUi.Widgets.Builder do
  @moduledoc false

  @spec metadata(String.t(), keyword(), map()) :: map()
  def metadata(label, opts, extras \\ %{}) do
    %{
      label: label,
      description: Keyword.get(opts, :description),
      role: Keyword.get(opts, :role),
      variant: Keyword.get(opts, :variant),
      native_surface: true,
      degradation: Keyword.get(opts, :degradation),
      shortcut: Keyword.get(opts, :shortcut),
      focusable: Keyword.get(opts, :focusable, false),
      binding_key: Keyword.get(opts, :binding),
      command: Keyword.get(opts, :command),
      keyboard_hint: Keyword.get(opts, :keyboard_hint)
    }
    |> Map.merge(extras)
    |> compact_map()
  end

  @spec state(keyword(), map()) :: map()
  def state(opts, defaults \\ %{}) do
    overrides =
      %{
        disabled: Keyword.get(opts, :disabled),
        focused: Keyword.get(opts, :focused),
        selected: Keyword.get(opts, :selected),
        expanded: Keyword.get(opts, :expanded),
        open: Keyword.get(opts, :open),
        loading: Keyword.get(opts, :loading),
        fallback: Keyword.get(opts, :fallback),
        checked: Keyword.get(opts, :checked),
        active: Keyword.get(opts, :active),
        current: Keyword.get(opts, :current),
        value: Keyword.get(opts, :value)
      }
      |> compact_map()

    defaults
    |> Map.merge(overrides)
    |> compact_map()
  end

  @spec bindings(keyword(), map()) :: map()
  def bindings(opts, defaults \\ %{}) do
    overrides =
      %{
        value: Keyword.get(opts, :value_binding),
        checked: Keyword.get(opts, :checked_binding),
        selected: Keyword.get(opts, :selected_binding),
        current: Keyword.get(opts, :current_binding),
        items: Keyword.get(opts, :items_binding)
      }
      |> compact_map()

    defaults
    |> Map.merge(overrides)
    |> compact_map()
  end

  @spec styles(keyword()) :: map()
  def styles(opts) do
    %{}
    |> maybe_put(:fg, Keyword.get(opts, :fg))
    |> maybe_put(:bg, Keyword.get(opts, :bg))
    |> maybe_put(:attrs, Keyword.get(opts, :attrs))
    |> maybe_put(:border, Keyword.get(opts, :border))
    |> maybe_put(:padding, Keyword.get(opts, :padding))
    |> maybe_put(:semantic_role, Keyword.get(opts, :semantic_role))
    |> maybe_put(:degradation, Keyword.get(opts, :degradation))
    |> maybe_put(:intent, Keyword.get(opts, :intent))
  end

  @spec events([{atom(), map() | keyword() | nil}]) :: map()
  def events(definitions) when is_list(definitions) do
    Enum.reduce(definitions, %{}, fn
      {_key, nil}, acc ->
        acc

      {key, value}, acc when is_list(value) ->
        Map.put(acc, key, Enum.into(value, %{}))

      {key, value}, acc when is_map(value) ->
        Map.put(acc, key, Map.new(value))
    end)
  end

  @spec normalize_items([keyword() | map()]) :: [map()]
  def normalize_items(items) do
    Enum.map(items, &normalize_item/1)
  end

  @spec compact_map(map()) :: map()
  def compact_map(map) do
    Map.reject(map, fn {_key, value} -> is_nil(value) end)
  end

  defp normalize_item(item) when is_list(item), do: Enum.into(item, %{})
  defp normalize_item(item) when is_map(item), do: Map.new(item)

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
