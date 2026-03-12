defmodule UnifiedIUR.ElementHelpers do
  @moduledoc """
  Helper functions for IUR Element protocol implementations.

  This module provides shared utility functions used by protocol
  implementations to reduce code duplication and ensure consistency.

  ## Functions

  * `maybe_put_id/2` - Conditionally add id to metadata map
  * `maybe_put_style/2` - Conditionally add style to metadata map
  * `build_metadata/2` - Build metadata with optional fields

  ## Example

  ```elixir
  defimpl UnifiedIUR.Element, for: MyWidget do
    import UnifiedIUR.ElementHelpers

    def metadata(widget) do
      %{type: :my_widget}
      |> maybe_put_id(widget.id)
      |> maybe_put_style(widget.style)
    end
  end
  ```
  """

  @doc """
  Conditionally adds an id to the given map.

  Returns the map unchanged if id is nil.

  ## Examples

      iex> ElementHelpers.maybe_put_id(%{type: :text}, :my_id)
      %{type: :text, id: :my_id}

      iex> ElementHelpers.maybe_put_id(%{type: :text}, nil)
      %{type: :text}
  """
  @spec maybe_put_id(map(), term()) :: map()
  def maybe_put_id(map, nil), do: map
  def maybe_put_id(map, id), do: Map.put(map, :id, id)

  @doc """
  Conditionally adds a style to the given map.

  Returns the map unchanged if style is nil.

  ## Examples

      iex> ElementHelpers.maybe_put_style(%{type: :text}, %{fg: :cyan})
      %{type: :text, style: %{fg: :cyan}}

      iex> ElementHelpers.maybe_put_style(%{type: :text}, nil)
      %{type: :text}
  """
  @spec maybe_put_style(map(), UnifiedIUR.Style.t() | nil) :: map()
  def maybe_put_style(map, nil), do: map
  def maybe_put_style(map, style), do: Map.put(map, :style, style)

  @doc """
  Builds a metadata map with optional fields.

  Takes a base map and a keyword list of optional fields to conditionally add.

  ## Options

  * `:id` - The element identifier
  * `:style` - The element style

  ## Examples

      iex> ElementHelpers.build_metadata(%{type: :text}, id: :my_id)
      %{type: :text, id: :my_id}

      iex> ElementHelpers.build_metadata(%{type: :text}, id: :my_id, style: %{fg: :cyan})
      %{type: :text, id: :my_id, style: %{fg: :cyan}}

      iex> ElementHelpers.build_metadata(%{type: :text}, [])
      %{type: :text}
  """
  @spec build_metadata(map(), keyword()) :: map()
  def build_metadata(base_map, opts \\ []) do
    base_map
    |> maybe_put_id_opt(Keyword.get(opts, :id))
    |> maybe_put_style_opt(Keyword.get(opts, :style))
  end

  defp maybe_put_id_opt(map, nil), do: map
  defp maybe_put_id_opt(map, id), do: Map.put(map, :id, id)

  defp maybe_put_style_opt(map, nil), do: map
  defp maybe_put_style_opt(map, style), do: Map.put(map, :style, style)
end
