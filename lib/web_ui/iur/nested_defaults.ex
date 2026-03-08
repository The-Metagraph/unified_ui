defmodule WebUi.Iur.NestedDefaults do
  @moduledoc """
  Canonical nested default-profile pruning for interpreted Unified-IUR descriptor values.
  """

  @style_defaults %{attrs: []}
  @table_column_defaults %{sortable: true, align: :left}

  @spec canonicalize_nested_prop(String.t(), term(), term()) :: term()
  def canonicalize_nested_prop(_widget_kind, :style, value) when is_map(value) do
    prune_defaults(value, @style_defaults)
  end

  def canonicalize_nested_prop("table", :columns, columns) when is_list(columns) do
    Enum.map(columns, fn
      column when is_map(column) -> prune_defaults(column, @table_column_defaults)
      other -> other
    end)
  end

  def canonicalize_nested_prop(_widget_kind, _key, value), do: value

  defp prune_defaults(map, defaults) when is_map(map) and is_map(defaults) do
    map
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      if Map.get(defaults, key, :__web_ui_nested_default_missing__) == value do
        acc
      else
        Map.put(acc, key, value)
      end
    end)
  end
end
