defmodule UnifiedIUR.ReferenceTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child
  alias UnifiedIUR.Reference

  test "exposes construct families and public type categories" do
    assert [:widget, :layout, :layer, :style, :theme, :interaction, :composite] ==
             Reference.construct_families()

    assert [:element, :metadata, :child, :tree, :summary, :invariant] ==
             Reference.public_type_categories()
  end

  test "describes identity, metadata, and tree-shape conventions" do
    assert %{
             identity_fields: [:id, :type, :kind],
             metadata_fields: [:authored_ref, :description, :annotations, :tags, :extra]
           } = Reference.identity_metadata_shape()

    assert %{
             child_shapes: [:leaf, :single, :multi],
             child_wrapper: UnifiedIUR.Element.Child,
             empty_child_representation: %{slot: :default, element: nil}
           } = Reference.tree_shape_conventions()
  end

  test "summarizes canonical elements and trees for maintainers" do
    child = Element.new(:widget, :button, id: "child")

    root =
      Element.new(:layout, :stack,
        id: "root",
        metadata: [description: "Toolbar", annotations: [source: "dsl"], tags: [:toolbar]],
        children: [Child.new(:content, child)]
      )

    assert %{
             id: "root",
             type: :layout,
             kind: :stack,
             child_shape: :single,
             child_slots: [:content],
             metadata: %{
               description: "Toolbar",
               tags: [:toolbar],
               annotation_keys: [:source]
             }
           } = Reference.summarize_element(root)

    assert %{
             total_elements: 2,
             element_ids: ["root", "child"],
             type_histogram: %{layout: 1, widget: 1},
             shape_signature: %{type: :layout, kind: :stack, child_shape: :single}
           } = Reference.summarize_tree(root)
  end
end
