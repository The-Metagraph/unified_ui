defmodule UnifiedIUR.Reference do
  @moduledoc """
  Package-facing reference helpers for the canonical module areas exposed by
  `UnifiedIUR`.
  """

  alias UnifiedIUR.Element
  alias UnifiedIUR.Tree

  @spec module_areas() :: %{UnifiedIUR.module_area() => module()}
  def module_areas do
    UnifiedIUR.module_areas()
  end

  @spec construct_families() :: [Element.element_type()]
  def construct_families do
    UnifiedIUR.Core.element_types()
  end

  @spec public_type_categories() :: [atom()]
  def public_type_categories do
    [:element, :metadata, :child, :tree, :summary, :invariant]
  end

  @spec identity_metadata_shape() :: map()
  def identity_metadata_shape do
    %{
      identity_fields: [:id, :type, :kind],
      metadata_fields: [:authored_ref, :description, :annotations, :tags, :extra]
    }
  end

  @spec tree_shape_conventions() :: map()
  def tree_shape_conventions do
    %{
      child_shapes: [:leaf, :single, :multi],
      child_wrapper: UnifiedIUR.Element.Child,
      empty_child_representation: %{slot: :default, element: nil}
    }
  end

  @spec summarize_element(Element.t()) :: map()
  def summarize_element(%Element{} = element) do
    %{
      id: element.id,
      type: element.type,
      kind: element.kind,
      child_shape: Element.child_shape(element),
      child_slots: Enum.map(element.children, & &1.slot),
      metadata: %{
        description: element.metadata.description,
        tags: element.metadata.tags,
        annotation_keys: Map.keys(element.metadata.annotations)
      }
    }
  end

  @spec summarize_tree(Element.t()) :: map()
  def summarize_tree(%Element{} = root) do
    nodes = Tree.depth_first(root)

    %{
      total_elements: length(nodes),
      element_ids: Enum.map(nodes, & &1.id),
      type_histogram: Enum.frequencies_by(nodes, & &1.type),
      shape_signature: Tree.shape_signature(root)
    }
  end
end
