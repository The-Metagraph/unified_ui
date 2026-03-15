defmodule UnifiedUi.Dsl.Helpers do
  @moduledoc """
  Author-facing helpers for building canonical authored metadata values.
  """

  @spec annotation_map(keyword() | map() | nil) :: map()
  def annotation_map(nil), do: %{}
  def annotation_map(values) when is_list(values), do: Map.new(values)
  def annotation_map(values) when is_map(values), do: Map.new(values)

  @spec tag_list([atom() | String.t()] | nil) :: [atom() | String.t()]
  def tag_list(nil), do: []
  def tag_list(values) when is_list(values), do: values |> Enum.uniq() |> Enum.reject(&is_nil/1)

  @spec path(atom() | String.t() | [atom() | String.t()] | nil) :: [atom() | String.t()]
  def path(nil), do: []
  def path(value) when is_atom(value) or is_binary(value), do: [value]
  def path(values) when is_list(values), do: values

  @spec metadata(keyword() | map()) :: keyword()
  def metadata(values) when is_list(values), do: values
  def metadata(values) when is_map(values), do: Enum.into(values, [])
end
