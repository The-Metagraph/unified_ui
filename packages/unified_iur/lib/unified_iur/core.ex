defmodule UnifiedIUR.Core do
  @moduledoc """
  Namespace anchor for canonical core element and metadata concerns.
  """

  alias UnifiedIUR.{Element, Metadata, Tree}

  @canonical_element_types [:widget, :layout, :layer, :style, :theme, :interaction, :composite]

  @spec modules() :: %{element: module(), metadata: module(), tree: module()}
  def modules do
    %{
      element: Element,
      metadata: Metadata,
      tree: Tree
    }
  end

  @spec element_types() :: [Element.element_type()]
  def element_types do
    @canonical_element_types
  end
end
