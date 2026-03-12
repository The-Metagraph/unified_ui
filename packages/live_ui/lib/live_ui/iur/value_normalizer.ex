defmodule LiveUi.IUR.ValueNormalizer do
  @moduledoc """
  Normalization helpers shared by the IUR interpreter.
  """

  alias LiveUi.IUR.CanvasRecorder

  @default_children_fields ["children"]
  @kind_children_fields %{
    "command_palette" => ["commands"],
    "context_menu" => ["items"],
    "dialog" => ["content", "buttons"],
    "form_builder" => ["fields"],
    "menu" => ["items"],
    "pick_list" => ["options"],
    "split_pane" => ["panes"],
    "tabs" => ["tabs"],
    "tree_view" => ["root_nodes"],
    "viewport" => ["content"]
  }

  @spec kind(map()) :: String.t() | nil
  def kind(payload) when is_map(payload) do
    payload
    |> fetch_any(["kind", "type"])
    |> normalize_string()
  end

  @spec id(map(), String.t()) :: String.t()
  def id(payload, fallback) when is_map(payload) and is_binary(fallback) do
    case payload |> fetch_any(["id", "name", "key"]) |> normalize_string() do
      nil -> fallback
      id -> id
    end
  end

  @spec children(map()) :: [term()]
  def children(payload) when is_map(payload) do
    kind = kind(payload)

    payload
    |> fetch_any(Map.get(@kind_children_fields, kind, @default_children_fields))
    |> normalize_children()
  end

  @spec props(map()) :: map()
  def props(payload) when is_map(payload) do
    payload |> raw_props() |> normalize_map()
  end

  @spec raw_props(map()) :: map()
  def raw_props(payload) when is_map(payload) do
    explicit_props = fetch(payload, "props")
    kind = kind(payload)

    structural_children_fields =
      @default_children_fields ++ Map.get(@kind_children_fields, kind, [])

    if is_map(explicit_props) do
      explicit_props
    else
      payload
      |> Map.drop([
        :__struct__,
        "id",
        :id,
        "kind",
        :kind,
        "type",
        :type,
        "children",
        :children,
        "props",
        :props,
        "schema",
        :schema,
        "source",
        :source,
        "version",
        :version
      ])
      |> Map.drop(
        structural_children_fields ++ Enum.map(structural_children_fields, &String.to_atom/1)
      )
    end
  end

  @spec metadata_props(map()) :: map()
  def metadata_props(metadata) when is_map(metadata) do
    metadata |> raw_metadata_props() |> normalize_map()
  end

  @spec raw_metadata_props(map()) :: map()
  def raw_metadata_props(metadata) when is_map(metadata) do
    metadata
    |> Map.drop([:id, "id", :type, "type"])
  end

  @spec normalize_map(map()) :: map()
  def normalize_map(map) when is_map(map) do
    Enum.into(map, %{}, fn {key, value} -> {normalize_key(key), normalize_value(value)} end)
  end

  @spec normalize_value(term()) :: term()
  def normalize_value(%_{} = struct) do
    struct
    |> normalize_struct()
    |> normalize_value()
  end

  def normalize_value(nil), do: nil
  def normalize_value(value) when is_boolean(value), do: value
  def normalize_value(map) when is_map(map), do: normalize_map(map)

  def normalize_value(map_set) when is_struct(map_set, MapSet),
    do: map_set |> MapSet.to_list() |> Enum.map(&normalize_value/1)

  def normalize_value(tuple) when is_tuple(tuple),
    do: tuple |> Tuple.to_list() |> Enum.map(&normalize_value/1)

  def normalize_value(list) when is_list(list), do: Enum.map(list, &normalize_value/1)
  def normalize_value(value) when is_atom(value), do: Atom.to_string(value)
  def normalize_value(value) when is_function(value, 1), do: CanvasRecorder.record(value)
  def normalize_value(value) when is_function(value), do: inspect(value)
  def normalize_value(value), do: value

  defp normalize_struct(%UnifiedIUR.Style{} = style), do: Map.from_struct(style)
  defp normalize_struct(struct), do: Map.from_struct(struct)

  defp normalize_children(children) when is_list(children), do: children
  defp normalize_children(nil), do: []
  defp normalize_children(child), do: [child]

  defp normalize_key(key) when is_atom(key), do: Atom.to_string(key)
  defp normalize_key(key) when is_binary(key), do: key
  defp normalize_key(key), do: to_string(key)

  defp fetch(map, key), do: Map.get(map, key, Map.get(map, String.to_atom(key)))

  defp fetch_any(map, keys) do
    Enum.find_value(keys, fn key ->
      value = fetch(map, key)
      if is_nil(value), do: nil, else: value
    end)
  end

  defp normalize_string(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      normalized -> normalized
    end
  end

  defp normalize_string(value) when is_atom(value),
    do: value |> Atom.to_string() |> normalize_string()

  defp normalize_string(_value), do: nil
end
