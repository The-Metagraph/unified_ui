defmodule LiveUi.IUR.Dependency do
  @moduledoc """
  Validates optional canonical schema markers on incoming IUR payloads.
  """

  alias LiveUi.ConfigurationError

  @schema "unified_iur"
  @marker_keys ["schema", "source", "version"]

  @spec validate_markers(map()) :: :ok | {:error, ConfigurationError.t()}
  def validate_markers(payload) when is_map(payload) do
    markers =
      Enum.reduce(@marker_keys, %{}, fn key, acc -> Map.put(acc, key, fetch(payload, key)) end)

    cond do
      not schema_markers_present?(markers) ->
        :ok

      Enum.any?(@marker_keys, &blank?(markers[&1])) ->
        {:error,
         ConfigurationError.new("incomplete unified_iur schema markers", %{markers: markers})}

      markers["schema"] != @schema ->
        {:error,
         ConfigurationError.new("unsupported unified_iur schema marker", %{
           schema: markers["schema"]
         })}

      true ->
        :ok
    end
  end

  def validate_markers(_payload) do
    {:error, ConfigurationError.new("unified_iur payload must be a map")}
  end

  @spec markers_present?(map()) :: boolean()
  def markers_present?(%{__struct__: _}), do: false

  def markers_present?(payload) when is_map(payload) do
    payload
    |> Enum.reduce(%{}, fn {key, value}, acc -> Map.put(acc, to_string(key), value) end)
    |> schema_markers_present?()
  end

  def markers_present?(_payload), do: false

  defp fetch(map, "schema"), do: Map.get(map, "schema", Map.get(map, :schema))
  defp fetch(map, "source"), do: Map.get(map, "source", Map.get(map, :source))
  defp fetch(map, "version"), do: Map.get(map, "version", Map.get(map, :version))
  defp blank?(value), do: not (is_binary(value) and String.trim(value) != "")

  defp schema_markers_present?(markers) when is_map(markers) do
    not blank?(Map.get(markers, "schema")) or not blank?(Map.get(markers, "version"))
  end
end
