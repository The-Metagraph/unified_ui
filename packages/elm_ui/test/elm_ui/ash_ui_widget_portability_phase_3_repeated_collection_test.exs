defmodule ElmUi.AshUiWidgetPortabilityPhase3RepeatedCollectionTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Binding
  alias UnifiedIUR.Collection
  alias UnifiedIUR.Layout
  alias UnifiedIUR.Widgets.Foundational
  alias UnifiedIUR.Widgets.Semantic

  test "repeated collection renders stable rows for insert update remove and empty state cases" do
    initial =
      collection_for([
        %{id: "artifact-1", title: "artifact.tar"},
        %{id: "artifact-2", title: "docs.zip"}
      ])

    updated =
      collection_for([
        %{id: "artifact-2", title: "docs-v2.zip"},
        %{id: "artifact-3", title: "release.zip"}
      ])

    empty = collection_for([])

    assert {:ok, initial_root} = ElmUi.Renderer.render(initial)
    assert {:ok, updated_root} = ElmUi.Renderer.render(updated)
    assert {:ok, empty_root} = ElmUi.Renderer.render(empty)

    assert find_widget(initial_root, "artifact-row-template-artifact-1")
    assert find_widget(initial_root, "artifact-row-template-artifact-2")

    assert find_widget(initial_root, "artifact-summary-template-artifact-1").attributes.columns
           |> hd()
           |> Map.fetch!(:label) == "artifact.tar"

    refute find_widget(updated_root, "artifact-row-template-artifact-1")
    assert find_widget(updated_root, "artifact-row-template-artifact-2")
    assert find_widget(updated_root, "artifact-row-template-artifact-3")

    assert find_widget(updated_root, "artifact-summary-template-artifact-2").attributes.columns
           |> hd()
           |> Map.fetch!(:label) == "docs-v2.zip"

    assert find_widget(empty_root, "artifact-rows-empty-state-0").attributes.content ==
             "No artifacts"
  end

  test "row-scope interaction mappings cross the Elm frontend/server bridge" do
    collection = collection_for([%{id: "artifact-1", title: "artifact.tar"}])

    assert {:ok, root} = ElmUi.Renderer.render(collection)

    button = find_widget(root, "artifact-open-template-artifact-1")

    assert button.events.click.payload.mapping == %{artifact_id: "artifact-1", row_index: 0}

    assert {:ok, runtime_state} =
             ElmUi.Runtime.mount_iur_screen(collection,
               runtime_id: "row-scope-runtime",
               title: "Row Scope Runtime"
             )

    assert {:ok, model} = ElmUi.Runtime.hydrate_frontend(runtime_state)

    assert {:ok, _updated_model, message} =
             ElmUi.FrontendRuntime.dispatch_interaction(model,
               family: :click,
               intent: :open_artifact,
               widget_id: button.id,
               payload: button.events.click.payload
             )

    assert message.payload.payload.mapping == %{artifact_id: "artifact-1", row_index: 0}

    assert {:ok, next_state, acknowledgement} =
             ElmUi.Runtime.handle_frontend_event(runtime_state, message)

    assert next_state.last_boundary_signal.data.mapping == %{
             artifact_id: "artifact-1",
             row_index: 0
           }

    assert acknowledgement.payload.event_count == 1
  end

  test "row diagnostics identify missing duplicate and unsupported row-scope data" do
    assert {:ok, missing_key_root} =
             collection_for([%{id: "artifact-1", title: "artifact.tar"}], key_path: [:missing])
             |> ElmUi.Renderer.render()

    assert {:ok, duplicate_key_root} =
             collection_for(
               [
                 %{id: "artifact-1", title: "artifact.tar", status: :ready},
                 %{id: "artifact-2", title: "docs.zip", status: :ready}
               ],
               key_path: [:status]
             )
             |> ElmUi.Renderer.render()

    assert {:ok, unresolved_root} =
             unresolved_collection([%{id: "artifact-1", title: "artifact.tar"}])
             |> ElmUi.Renderer.render()

    assert [missing_row] = find_widget(missing_key_root, "artifact-rows").attributes.rows
    assert missing_row.key_source == :index_fallback
    assert :missing_key in missing_row.diagnostics

    assert duplicate_key_root
           |> find_widget("artifact-rows")
           |> Map.fetch!(:attributes)
           |> Map.fetch!(:rows)
           |> Enum.all?(&(:duplicate_key in &1.diagnostics))

    assert [unresolved_row] =
             find_widget(unresolved_root, "unresolved-artifact-rows").attributes.rows

    assert :unresolved_row_scope in unresolved_row.diagnostics
  end

  defp collection_for(items, opts \\ []) do
    Collection.repeated_collection(
      row_template(),
      id: "artifact-rows",
      source: [
        name: :artifacts,
        path: [:artifacts],
        value: Enum.map(items, &with_columns/1)
      ],
      item_alias: :artifact,
      index_alias: :row,
      key_path: Keyword.get(opts, :key_path, [:id]),
      empty_state: "No artifacts"
    )
  end

  defp unresolved_collection(items) do
    Collection.repeated_collection(
      Layout.row(
        [
          Foundational.text("Unresolved",
            id: "unresolved-title-template",
            bindings: [Binding.row_value(:other, :title)]
          )
        ],
        id: "unresolved-row-template"
      ),
      id: "unresolved-artifact-rows",
      source: [
        name: :artifacts,
        path: [:artifacts],
        value: items
      ],
      item_alias: :artifact,
      index_alias: :row,
      key_path: [:id]
    )
  end

  defp row_template do
    Layout.row(
      [
        Semantic.list_item_multi_column(Binding.row_value(:artifact, :columns),
          id: "artifact-summary-template",
          label: "Artifact"
        ),
        Foundational.button("Open",
          id: "artifact-open-template",
          action: [
            intent: :open_artifact,
            mapping: %{
              artifact_id: Binding.row_value(:artifact, :id),
              row_index: Binding.row_index(:row)
            }
          ]
        )
      ],
      id: "artifact-row-template"
    )
  end

  defp with_columns(%{title: title} = item), do: Map.put_new(item, :columns, %{name: title})
  defp with_columns(item), do: item

  defp find_widget(%ElmUi.Widget{id: id} = widget, id), do: widget

  defp find_widget(%ElmUi.Widget{} = widget, id) do
    widget.slot_children
    |> Map.values()
    |> List.flatten()
    |> Enum.find_value(&find_widget(&1, id))
  end

  defp find_widget(nil, _id), do: nil
end
