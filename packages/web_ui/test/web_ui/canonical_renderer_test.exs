defmodule WebUi.CanonicalRendererTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Element
  alias UnifiedIUR.Element.Child

  test "canonical foundational structures map into the native web_ui widget model" do
    canonical =
      Element.new(:layout, :column,
        id: "workspace-layout",
        children: [
          Element.new(:widget, :text, id: "workspace-title", attributes: %{content: "Workspace"}),
          Element.new(:composite, :form,
            id: "workspace-form",
            children: [
              Element.new(:composite, :field_group,
                id: "query-group",
                attributes: %{legend: "Search"},
                children: [
                  Element.new(:composite, :field,
                    id: "query-field",
                    attributes: %{name: :query},
                    children: [
                      Child.new(
                        :control,
                        Element.new(:widget, :text_input,
                          id: "query-input",
                          attributes: %{name: :query, value: "Pascal", placeholder: "Search"}
                        )
                      )
                    ]
                  )
                ]
              )
            ]
          )
        ]
      )

    assert {:ok, %WebUi.Widget{kind: :column} = root} = WebUi.Renderer.render(canonical)
    assert Enum.map(root.slot_children.default, & &1.id) == ["workspace-title", "workspace-form"]

    input_widget = find_widget(root, "query-input")

    assert input_widget.kind == :text_input
    assert input_widget.attributes.name == :query
    assert input_widget.attributes.value == "Pascal"
  end

  test "canonical view state reuses the same split runtime path as native screens" do
    canonical =
      Element.new(:layout, :column,
        id: "workspace-layout",
        children: [
          Element.new(:widget, :text, id: "workspace-title", attributes: %{content: "Workspace"}),
          Element.new(:widget, :checkbox,
            id: "alerts-checkbox",
            attributes: %{name: :alerts, checked: true, label: "Alerts"}
          )
        ]
      )

    assert {:ok, runtime_state} =
             WebUi.Runtime.mount_iur_screen(canonical,
               runtime_id: "canonical-workspace",
               title: "Canonical Workspace"
             )

    assert {:ok, model} = WebUi.Runtime.hydrate_frontend(runtime_state)
    assert runtime_state.boundary_mode == :canonical_boundary
    assert find_node(model.tree, "alerts-checkbox").tag == "input"
  end

  defp find_widget(%WebUi.Widget{id: id} = widget, id), do: widget

  defp find_widget(%WebUi.Widget{} = widget, id) do
    widget.slot_children
    |> Map.values()
    |> List.flatten()
    |> Enum.find_value(&find_widget(&1, id))
  end

  defp find_widget(nil, _id), do: nil

  defp find_node(node, id) when is_map(node) do
    if node.id == id do
      node
    else
      node.slots
      |> Enum.flat_map(& &1.children)
      |> Enum.find_value(&find_node(&1, id))
    end
  end

  defp find_node(nil, _id), do: nil
end
