defmodule WebUi.Iur.ValueNormalizer do
  @moduledoc """
  Canonical recursive value normalization for interpreted Unified-IUR descriptor values.
  """

  @spec canonicalize(term()) :: term()
  def canonicalize(%MapSet{} = set) do
    set
    |> MapSet.to_list()
    |> Enum.map(&canonicalize/1)
    |> Enum.sort_by(&inspect/1)
  end

  def canonicalize(%_{} = struct), do: struct |> Map.from_struct() |> canonicalize_map()
  def canonicalize(map) when is_map(map), do: canonicalize_map(map)
  def canonicalize(list) when is_list(list), do: Enum.map(list, &canonicalize/1)

  def canonicalize(tuple) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list()
    |> Enum.map(&canonicalize/1)
    |> List.to_tuple()
  end

  def canonicalize(other), do: other

  defp canonicalize_map(map) when is_map(map) do
    map
    |> Enum.reduce(%{}, fn {key, value}, acc ->
      normalized_value = canonicalize(value)

      if is_nil(normalized_value) do
        acc
      else
        Map.put(acc, normalize_key(key), normalized_value)
      end
    end)
  end

  defp normalize_key(key) when is_atom(key), do: key

  defp normalize_key(key) when is_binary(key) do
    try do
      String.to_existing_atom(key)
    rescue
      ArgumentError -> key
    end
  end

  defp normalize_key(key), do: key
end
