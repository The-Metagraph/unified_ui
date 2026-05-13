defmodule DesktopUi.AshUiWidgetPortabilityPhase4DesktopUiTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Binding, Collection, Fixtures, Layout}
  alias UnifiedIUR.Widgets.{Foundational, Semantic}

  @fixture_widgets [
    {"portable-disclosure", :disclosure},
    {"portable-kicker", :kicker},
    {"portable-avatar", :avatar},
    {"portable-presence", :presence_dot},
    {"portable-segments", :segmented_button_group},
    {"portable-list-item", :list_item_multi_column},
    {"portable-artifact-row", :artifact_row},
    {"portable-sticky-header", :sticky_header},
    {"portable-pipeline", :pipeline_stepper_horizontal},
    {"portable-progress", :segmented_progress_bar},
    {"portable-stages", :workflow_stage_list_vertical},
    {"portable-meter", :meter_thin},
    {"portable-panel", :slide_over_panel},
    {"portable-callout", :event_callout},
    {"portable-redline", :redline_inline},
    {"portable-code", :code_block_syntax_highlighted},
    {"portable-composer", :chat_composer},
    {"portable-artifact-rows", :repeated_collection}
  ]

  test "desktop native promoted widgets expose retained widget semantics" do
    promoted_kinds = Enum.map(native_widgets(), & &1.kind)

    assert Enum.all?(promoted_kinds, &(&1 in DesktopUi.Widgets.kinds()))
    assert Enum.all?(promoted_kinds, &(&1 in DesktopUi.Renderer.supported_kinds()))

    disclosure = DesktopUi.Widgets.disclosure("native-disclosure", "Release notes", open: true)
    segments = DesktopUi.Widgets.segmented_button_group("native-segments", compact: "Compact")
    panel = DesktopUi.Widgets.slide_over_panel("native-panel", [], visible: true)
    composer = DesktopUi.Widgets.chat_composer("native-composer", submit_intent: :send_review)
    collection = DesktopUi.Widgets.repeated_collection("native-rows", [])

    assert disclosure.metadata.focusable
    assert disclosure.state.open
    assert segments.metadata.selection_mode == :single
    assert panel.metadata.overlay_role == :slide_over_panel
    assert panel.state.open
    assert composer.metadata.focusable
    assert composer.attributes.submit_intent == :send_review
    assert collection.metadata.row_scope?
  end

  test "desktop renderer consumes promoted IUR fixture through native widgets" do
    fixture = Fixtures.fixture!("portable_widgets--ash_ui_portability")

    assert {:ok, root} = DesktopUi.Renderer.render(fixture.element)

    for {id, kind} <- @fixture_widgets do
      assert %{kind: ^kind} = find_widget(root, id)
    end

    repeated = find_widget(root, "portable-artifact-rows")
    row = find_widget(root, "portable-artifact-row-template-artifact-1")
    artifact = find_widget(root, "portable-artifact-template-artifact-1")
    summary = find_widget(root, "portable-artifact-summary-template-artifact-1")
    panel = find_widget(root, "portable-panel")
    composer = find_widget(root, "portable-composer")

    assert repeated.attributes.rows == [
             %{
               key: "artifact-1",
               key_source: :key_path,
               index: 0,
               item: %{
                 id: "artifact-1",
                 record: %{id: "artifact-1"},
                 columns: %{name: "artifact.tar"}
               },
               diagnostics: []
             }
           ]

    assert row.kind == :row
    assert artifact.attributes.artifact == %{id: "artifact-1"}
    assert hd(summary.attributes.columns).label == "artifact.tar"
    assert panel.metadata.overlay_role == :slide_over_panel
    assert panel.state.open
    assert composer.events.submit.intent == :send_review
  end

  test "desktop repeated collections preserve row-scope payloads and runtime routing metadata" do
    collection = collection_for([%{id: "artifact-1", title: "artifact.tar"}])

    assert {:ok, root} = DesktopUi.Renderer.render(collection)

    button = find_widget(root, "artifact-open-template-artifact-1")
    repeated = find_widget(root, "artifact-rows")

    assert repeated.attributes.rows
           |> hd()
           |> Map.take([:key, :key_source, :index, :diagnostics]) == %{
             key: "artifact-1",
             key_source: :key_path,
             index: 0,
             diagnostics: []
           }

    assert button.events.click.payload.mapping == %{artifact_id: "artifact-1", row_index: 0}

    assert {:ok, runtime_state} =
             DesktopUi.Runtime.mount_iur_screen(collection,
               runtime_id: "desktop-row-runtime",
               title: "Desktop Row Runtime"
             )

    assert "artifact-open-template-artifact-1" in runtime_state.focus.order

    assert runtime_state.realization.event_targets["artifact-open-template-artifact-1"] == [
             :click
           ]

    assert {:ok, _runtime_state, route_result} =
             DesktopUi.Runtime.dispatch_widget_interaction(
               runtime_state,
               "artifact-open-template-artifact-1",
               :click,
               intent: :open_artifact,
               payload: button.events.click.payload,
               boundary: :boundary
             )

    assert route_result.route == :canonical_boundary
    assert route_result.translation.payload.mapping == %{artifact_id: "artifact-1", row_index: 0}
  end

  defp native_widgets do
    [
      DesktopUi.Widgets.disclosure("native-disclosure", "Release notes"),
      DesktopUi.Widgets.kicker("native-kicker", "Workflow"),
      DesktopUi.Widgets.avatar("native-avatar", "Pat", initials: "PC"),
      DesktopUi.Widgets.presence_dot("native-presence", :online),
      DesktopUi.Widgets.segmented_button_group("native-segments", compact: "Compact"),
      DesktopUi.Widgets.list_item_multi_column("native-list-item", name: "artifact.tar"),
      DesktopUi.Widgets.artifact_row("native-artifact", %{id: "artifact-1"}, "artifact.tar"),
      DesktopUi.Widgets.sticky_header("native-header", "Results"),
      DesktopUi.Widgets.pipeline_stepper_horizontal("native-pipeline", [:queued, :building]),
      DesktopUi.Widgets.segmented_progress_bar("native-progress", queued: 20, building: 80),
      DesktopUi.Widgets.workflow_stage_list_vertical("native-stages", [:plan, :build]),
      DesktopUi.Widgets.meter_thin("native-meter", 82),
      DesktopUi.Widgets.slide_over_panel("native-panel", [], visible: true),
      DesktopUi.Widgets.event_callout("native-callout", "Build completed"),
      DesktopUi.Widgets.redline_inline("native-redline", "Draft", "Ready"),
      DesktopUi.Widgets.code_block_syntax_highlighted("native-code", "IO.puts(\"ready\")"),
      DesktopUi.Widgets.chat_composer("native-composer"),
      DesktopUi.Widgets.host_form_shell("native-host-form", []),
      DesktopUi.Widgets.repeated_collection("native-collection", [])
    ]
  end

  defp collection_for(items) do
    Collection.repeated_collection(
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
      ),
      id: "artifact-rows",
      source: [
        name: :artifacts,
        path: [:artifacts],
        value: Enum.map(items, &with_columns/1)
      ],
      item_alias: :artifact,
      index_alias: :row,
      key_path: [:id],
      empty_state: "No artifacts"
    )
  end

  defp with_columns(%{title: title} = item), do: Map.put_new(item, :columns, %{name: title})

  defp find_widget(%DesktopUi.Widget{id: id} = widget, id), do: widget

  defp find_widget(%DesktopUi.Widget{} = widget, id) do
    widget.children
    |> Enum.find_value(&find_widget(&1, id))
  end

  defp find_widget(nil, _id), do: nil
end
