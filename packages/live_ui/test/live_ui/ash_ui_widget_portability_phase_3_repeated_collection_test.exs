defmodule LiveUi.AshUiWidgetPortabilityPhase3RepeatedCollectionTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias UnifiedIUR.Binding
  alias UnifiedIUR.Collection
  alias UnifiedIUR.Interaction
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

    initial_html = render_collection(initial)
    updated_html = render_collection(updated)
    empty_html = render_collection(empty)

    assert initial_html =~ ~s(data-live-ui-collection-row="artifact-1")
    assert initial_html =~ ~s(data-live-ui-collection-row="artifact-2")
    assert initial_html =~ ~s(id="artifact-summary-template-artifact-1")
    assert initial_html =~ "artifact.tar"

    refute updated_html =~ ~s(data-live-ui-collection-row="artifact-1")
    assert updated_html =~ ~s(data-live-ui-collection-row="artifact-2")
    assert updated_html =~ ~s(data-live-ui-collection-row="artifact-3")
    assert updated_html =~ "docs-v2.zip"
    assert updated_html =~ "release.zip"

    assert empty_html =~ ~s(data-live-ui-collection-slot="empty")
    assert empty_html =~ "No artifacts"
  end

  test "row-scope interaction mappings are resolved before LiveView emits canonical events" do
    html =
      collection_for([%{id: "artifact-1", title: "artifact.tar"}])
      |> render_collection()

    interaction = decode_interaction!(html)

    assert interaction.family == :click
    assert interaction.intent == :open_artifact
    assert interaction.payload.mapping == %{artifact_id: "artifact-1", row_index: 0}
    assert html =~ ~s(data-live-ui-row-key-source="key_path")
    refute html =~ "unresolved_row_scope"
  end

  test "row diagnostics identify missing duplicate and unsupported row-scope data" do
    missing_key_html =
      collection_for([%{id: "artifact-1", title: "artifact.tar"}], key_path: [:missing])
      |> render_collection()

    duplicate_key_html =
      collection_for(
        [
          %{id: "artifact-1", title: "artifact.tar", status: :ready},
          %{id: "artifact-2", title: "docs.zip", status: :ready}
        ],
        key_path: [:status]
      )
      |> render_collection()

    unresolved_html =
      unresolved_collection([%{id: "artifact-1", title: "artifact.tar"}])
      |> render_collection()

    assert missing_key_html =~ ~s(data-live-ui-row-key-source="index_fallback")
    assert missing_key_html =~ "missing_key"
    assert duplicate_key_html =~ "duplicate_key"
    assert unresolved_html =~ "unresolved_row_scope"
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

  defp render_collection(element) do
    render_component(&LiveUi.Renderer.render/1, %{
      element: element,
      event_target: "#runtime-host"
    })
  end

  defp decode_interaction!(html) do
    [_, encoded] = Regex.run(~r/phx-value-interaction="([^"]+)"/, html)

    encoded
    |> Base.url_decode64!(padding: false)
    |> :erlang.binary_to_term([:safe])
    |> Interaction.new()
  end
end
