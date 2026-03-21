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

  test "advanced canonical widgets and layered display nodes map into the native web_ui model" do
    canonical =
      Element.new(:layer, :overlay,
        id: "ops-overlay",
        children: [
          Child.new(
            :base,
            Element.new(:layout, :split_pane,
              id: "ops-split",
              attributes: %{ratio: 0.6},
              children: [
                Child.new(
                  :primary,
                  Element.new(:layout, :viewport,
                    id: "log-viewport",
                    attributes: %{offset: %{x: 0, y: 120}, scrollbars: :auto},
                    children: [
                      Child.new(
                        :content,
                        Element.new(:widget, :table,
                          id: "cluster-table",
                          attributes: %{
                            columns: [%{id: :name, label: "Name"}],
                            rows: [%{id: "node-a", cells: ["Node A"]}]
                          }
                        )
                      )
                    ]
                  )
                ),
                Child.new(
                  :secondary,
                  Element.new(:widget, :status,
                    id: "status-banner",
                    attributes: %{text: "Watching cluster", severity: :info}
                  )
                )
              ]
            )
          ),
          Child.new(
            :layers,
            Element.new(:layer, :dialog,
              id: "inspect-dialog",
              attributes: %{title: "Inspect Node", modal: false},
              children: [
                Child.new(
                  :content,
                  Element.new(:widget, :markdown_viewer,
                    id: "dialog-doc",
                    attributes: %{source: "# Inspect"}
                  )
                )
              ]
            )
          )
        ]
      )

    assert {:ok, %WebUi.Widget{kind: :overlay} = root} = WebUi.Renderer.render(canonical)
    assert Enum.map(root.slot_children.layers, & &1.id) == ["inspect-dialog"]

    viewport = find_widget(root, "log-viewport")
    dialog = find_widget(root, "inspect-dialog")
    table = find_widget(root, "cluster-table")

    assert viewport.kind == :viewport
    assert viewport.attributes.offset == %{x: 0, y: 120}
    assert dialog.kind == :dialog
    refute dialog.attributes.modal
    assert table.family == :data
  end

  test "advanced canonical screens reuse the same runtime hydration path as native advanced screens" do
    canonical =
      Element.new(:layer, :overlay,
        id: "ops-overlay",
        children: [
          Child.new(
            :base,
            Element.new(:layout, :viewport,
              id: "log-viewport",
              attributes: %{offset: 64},
              children: [
                Child.new(
                  :content,
                  Element.new(:widget, :log_viewer,
                    id: "ops-log-viewer",
                    attributes: %{entries: [%{id: "entry-1", message: "Connected"}]}
                  )
                )
              ]
            )
          ),
          Child.new(
            :layers,
            Element.new(:layer, :dialog,
              id: "inspect-dialog",
              attributes: %{title: "Inspect Node"},
              children: [
                Child.new(
                  :content,
                  Element.new(:widget, :inline_feedback,
                    id: "dialog-feedback",
                    attributes: %{message: "Inspecting", severity: :info}
                  )
                )
              ]
            )
          )
        ]
      )

    assert {:ok, runtime_state} =
             WebUi.Runtime.mount_iur_screen(canonical,
               runtime_id: "canonical-advanced",
               title: "Canonical Advanced"
             )

    assert {:ok, model} = WebUi.Runtime.hydrate_frontend(runtime_state)

    assert find_node(model.tree, "log-viewport").role == "region"
    assert find_node(model.tree, "inspect-dialog").tag == "dialog"
    assert find_node(model.tree, "inspect-dialog").browser.focusable?
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
