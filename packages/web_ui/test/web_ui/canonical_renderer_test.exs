defmodule WebUi.CanonicalRendererTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Forms, Layout}
  alias UnifiedIUR.Widgets.{Foundational, Input}

  test "canonical foundational structures map into the native web_ui widget model" do
    canonical =
      Layout.column(
        [
          Foundational.text("Workspace", id: "workspace-title"),
          Forms.form_builder(
            [
              Forms.field_group(
                [
                  Forms.field(
                    Input.text_input(
                      id: "query-input",
                      name: :query,
                      value: "Pascal",
                      placeholder: "Search"
                    ),
                    id: "query-field",
                    name: :query,
                    label: "Search Query",
                    help: "Used for preview filtering"
                  )
                ],
                id: "query-group",
                legend: "Search"
              )
            ],
            id: "workspace-form"
          )
        ],
        id: "workspace-layout",
        gap: :lg
      )

    assert {:ok, [%WebUi.Widget{kind: :column} = root]} = WebUi.Renderer.render(canonical)

    assert Enum.map(root.slots.default, & &1.id) == ["workspace-title", "workspace-form"]

    input_widget = find_widget([root], "query-input")

    assert input_widget.kind == :text_input
    assert input_widget.props.name == :query
    assert input_widget.props.value == "Pascal"
  end

  test "canonical view state reuses the same split runtime path as native screens" do
    canonical =
      Layout.column(
        [
          Foundational.text("Workspace", id: "workspace-title"),
          Input.checkbox(id: "alerts-checkbox", name: :alerts, value: true, label_text: "Alerts")
        ],
        id: "workspace-layout"
      )

    assert {:ok, view_state} =
             WebUi.Renderer.render_view_state(canonical,
               screen_id: :canonical_workspace,
               title: "Canonical Workspace"
             )

    assert view_state.screen.mode == :canonical
    assert view_state.screen.id == :canonical_workspace

    assert {:ok, envelope} = WebUi.Server.Sync.outbound(view_state, kind: :hydrate)
    assert {:ok, model} = WebUi.Frontend.ingest_sync(envelope)

    assert model.screen_id == :canonical_workspace
    assert find_node(model.frontend_tree, "alerts-checkbox").tag == "input"
  end

  test "unsupported canonical kinds fail with structured coverage diagnostics" do
    unsupported = Input.numeric_input(id: "age-input", name: :age, value: 42)

    assert {:error, %WebUi.Renderer.Error{code: :unsupported_kind, details: details}} =
             WebUi.Renderer.render(unsupported)

    assert details.kind == :numeric_input
    assert :text_input in details.supported_kinds
  end

  defp find_widget(widgets, id) when is_list(widgets) do
    Enum.find_value(widgets, fn widget ->
      if widget.id == id do
        widget
      else
        widget.slots
        |> Map.values()
        |> List.flatten()
        |> find_widget(id)
      end
    end)
  end

  defp find_widget(nil, _id), do: nil

  defp find_node(nodes, id) when is_list(nodes) do
    Enum.find_value(nodes, fn node ->
      if node.id == id do
        node
      else
        node.slots
        |> Enum.flat_map(& &1.children)
        |> find_node(id)
      end
    end)
  end

  defp find_node(nil, _id), do: nil
end
