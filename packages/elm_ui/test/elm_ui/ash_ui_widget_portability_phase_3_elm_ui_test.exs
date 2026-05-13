defmodule ElmUi.AshUiWidgetPortabilityPhase3ElmUiTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.Fixtures
  alias UnifiedIUR.Forms
  alias UnifiedIUR.Widgets.Semantic

  test "native ElmUi promoted widgets expose deterministic Phoenix-and-Elm widget structs" do
    assert Enum.all?(
             [
               :disclosure,
               :kicker,
               :avatar,
               :presence_dot,
               :segmented_button_group,
               :list_item_multi_column,
               :artifact_row,
               :sticky_header,
               :pipeline_stepper_horizontal,
               :segmented_progress_bar,
               :workflow_stage_list_vertical,
               :meter_thin,
               :slide_over_panel,
               :event_callout,
               :redline_inline,
               :code_block_syntax_highlighted,
               :chat_composer,
               :host_form_shell,
               :repeated_collection
             ],
             &(&1 in ElmUi.Widgets.kinds())
           )

    disclosure = ElmUi.Widgets.disclosure("disclosure", "Release notes", open: true)
    segments = ElmUi.Widgets.segmented_button_group("segments", compact: "Compact")

    artifact =
      ElmUi.Widgets.artifact_row("artifact", %{id: "artifact-1"}, "artifact.tar", status: :ready)

    composer =
      ElmUi.Widgets.chat_composer("composer",
        placeholder: "Add a review note",
        on_submit: %{intent: :send_review}
      )

    host_shell =
      ElmUi.Widgets.host_form_shell(
        "host-form",
        [ElmUi.Widgets.text_input("name-input", name: :name)],
        validation_summary: "Host validates",
        on_submit: %{intent: :save_profile}
      )

    collection =
      ElmUi.Widgets.repeated_collection("collection", [
        ElmUi.Widgets.text("row-copy", "Row")
      ])

    assert disclosure.family == :semantic
    assert disclosure.state.open
    assert segments.attributes.items == [%{id: :compact, label: "Compact", value: "Compact"}]
    assert artifact.attributes.title == "artifact.tar"
    assert composer.family == :workflow
    assert composer.events.submit.intent == :send_review
    assert host_shell.kind == :host_form_shell
    assert host_shell.attributes.lifecycle == :host_owned
    assert collection.family == :collection
    assert hd(collection.slot_children.row).id == "row-copy"
  end

  test "ElmUi renderer consumes promoted IUR fixture through native widget structs" do
    fixture = Fixtures.fixture!("portable_widgets--ash_ui_portability")

    assert {:ok, root} = ElmUi.Renderer.render(fixture.element)

    for {id, kind} <- [
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
        ] do
      assert %{kind: ^kind} = find_widget(root, id)
    end

    repeated = find_widget(root, "portable-artifact-rows")
    row = find_widget(root, "portable-artifact-row-template-artifact-1")
    artifact = find_widget(root, "portable-artifact-template-artifact-1")
    summary = find_widget(root, "portable-artifact-summary-template-artifact-1")

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
  end

  test "host form shell and promoted widgets hydrate through the frontend runtime" do
    host_form =
      Forms.host_form_shell(
        [
          {:fields,
           Forms.form_field(
             UnifiedIUR.Widgets.Input.text_input(id: "display-name-input", name: :display_name),
             id: "display-name-field",
             label: "Display name"
           )}
        ],
        id: "profile-shell",
        submit_intent: :save_profile,
        validation_summary: "Host validates profile changes"
      )

    assert {:ok, host_widget} = ElmUi.Renderer.render(host_form)
    assert host_widget.kind == :host_form_shell
    assert host_widget.attributes.owner == :host
    assert host_widget.events.submit.intent == :save_profile
    assert hd(host_widget.slot_children.fields).kind == :form_field

    promoted =
      UnifiedIUR.Layout.column(
        [
          Semantic.artifact_row(%{id: "artifact-1"}, "artifact.tar",
            id: "artifact-row",
            status: :ready
          ),
          host_form
        ],
        id: "portable-runtime"
      )

    assert {:ok, runtime_state} =
             ElmUi.Runtime.mount_iur_screen(promoted,
               runtime_id: "portable-runtime",
               title: "Portable Runtime"
             )

    assert {:ok, model} = ElmUi.Runtime.hydrate_frontend(runtime_state)

    assert find_node(model.tree, "artifact-row").tag == "article"
    assert find_node(model.tree, "profile-shell").tag == "form"
    assert find_node(model.tree, "profile-shell").role == "form"
  end

  defp find_widget(%ElmUi.Widget{id: id} = widget, id), do: widget

  defp find_widget(%ElmUi.Widget{} = widget, id) do
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
