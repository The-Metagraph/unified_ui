defmodule WebUi.Iur.DescriptorDefaults do
  @moduledoc """
  Canonical default-prop normalization for interpreted Unified-IUR widget descriptors.
  """

  @global_defaults %{
    visible: true
  }

  @widget_defaults %{
    "button" => %{disabled: false},
    "menu_item" => %{disabled: false},
    "table" => %{sort_direction: :asc},
    "tab" => %{disabled: false, closable: false},
    "tree_node" => %{expanded: false, selectable: true},
    "tree_view" => %{show_root: true}
  }

  @spec canonicalize_widget_props(map(), String.t()) :: map()
  def canonicalize_widget_props(props, widget_kind)
      when is_map(props) and is_binary(widget_kind) do
    defaults = defaults_for(widget_kind)

    props
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      cond do
        is_nil(value) ->
          acc

        default_value?(defaults, key, value) ->
          acc

        true ->
          Map.put(acc, key, value)
      end
    end)
  end

  def canonicalize_widget_props(props, _widget_kind) when is_map(props) do
    Enum.reduce(props, %{}, fn {key, value}, acc ->
      if is_nil(value), do: acc, else: Map.put(acc, key, value)
    end)
  end

  defp defaults_for(widget_kind) when is_binary(widget_kind) do
    Map.merge(@global_defaults, Map.get(@widget_defaults, widget_kind, %{}))
  end

  defp default_value?(defaults, key, value) when is_map(defaults) do
    Map.get(defaults, key, :__web_ui_default_missing__) == value
  end
end
