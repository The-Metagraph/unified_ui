defmodule ElmUi.AshUiWidgetPortabilityPhase3IntegrationTest do
  use ExUnit.Case, async: true

  alias ElmUi.ServerRuntime.RenderModel
  alias UnifiedIUR.{Binding, Collection, Fixtures, Forms, Layout}
  alias UnifiedIUR.Widgets.{Foundational, Input, Semantic}

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

  test "native widgets and canonical fixture render the promoted ElmUi surface" do
    for {widget, kind} <- native_cases() do
      assert widget.kind == kind

      model = RenderModel.build(widget)

      assert model.kind == kind
      assert model.metadata.native_surface
    end

    fixture = Fixtures.fixture!("portable_widgets--ash_ui_portability")

    assert {:ok, root} = ElmUi.Renderer.render(fixture.element)

    for {id, kind} <- @fixture_widgets do
      assert %{kind: ^kind} = find_widget(root, id)
    end

    assert RenderModel.build(find_widget(root, "portable-panel")).dom.role == "dialog"
    assert RenderModel.build(find_widget(root, "portable-disclosure")).dom.attributes.open
    assert RenderModel.build(find_widget(root, "portable-segments")).interactions.navigable?
    assert RenderModel.build(find_widget(root, "portable-composer")).interactions.editable?
  end

  test "host form shell crosses the frontend bridge without callback leakage" do
    form =
      Forms.host_form_shell(
        [
          {:fields,
           Forms.form_field(
             Input.text_input(id: "display-name-input", name: :display_name),
             id: "display-name-field",
             label: "Display name"
           )}
        ],
        id: "profile-shell",
        submit_intent: :save_profile,
        validation_summary: "Display name is required",
        validation: %{status: :invalid, errors: ["Display name is required"]},
        allow_partial?: false
      )

    assert {:ok, widget} = ElmUi.Renderer.render(form)
    assert widget.kind == :host_form_shell
    assert widget.attributes.lifecycle == :host_owned
    assert widget.attributes.validation_summary == "Display name is required"
    assert widget.events.submit.intent == :save_profile

    render_model = RenderModel.build(widget)

    assert render_model.dom.role == "form"
    assert render_model.interactions.focusable?

    assert {:ok, runtime_state} =
             ElmUi.Runtime.mount_iur_screen(form,
               runtime_id: "host-form-runtime",
               title: "Host Form Runtime"
             )

    assert {:ok, frontend_model} = ElmUi.Runtime.hydrate_frontend(runtime_state)
    assert find_node(frontend_model.tree, "profile-shell").role == "form"

    assert {:ok, _frontend_model, message} =
             ElmUi.FrontendRuntime.dispatch_interaction(frontend_model,
               family: :submit,
               intent: :save_profile,
               widget_id: "profile-shell",
               payload: %{mapping: %{display_name: "Pat"}}
             )

    refute message.payload |> Map.keys() |> Enum.any?(&String.starts_with?(to_string(&1), "phx"))

    assert {:ok, next_state, acknowledgement} =
             ElmUi.Runtime.handle_frontend_event(runtime_state, message)

    assert next_state.last_boundary_signal.data.mapping == %{display_name: "Pat"}
    assert acknowledgement.payload.event_count == 1
  end

  test "repeated collection native and IUR paths preserve rows payloads and reviewable parity" do
    native =
      ElmUi.Widgets.repeated_collection(
        "artifact-rows",
        [ElmUi.Widgets.text("artifact-summary-template-artifact-1", "artifact.tar")],
        row_metadata: [%{key: "artifact-1", key_source: :key_path, index: 0, diagnostics: []}],
        item_alias: :artifact,
        index_alias: :row,
        key_path: [:id]
      )

    collection = repeated_collection([%{id: "artifact-1", title: "artifact.tar"}])

    assert {:ok, root} = ElmUi.Renderer.render(collection)

    iur_collection = find_widget(root, "artifact-rows")
    iur_button = find_widget(root, "artifact-open-template-artifact-1")

    assert native.attributes.rows == [
             %{key: "artifact-1", key_source: :key_path, index: 0, diagnostics: []}
           ]

    assert [row] = iur_collection.attributes.rows

    assert Map.take(row, [:key, :key_source, :index, :diagnostics]) == %{
             key: "artifact-1",
             key_source: :key_path,
             index: 0,
             diagnostics: []
           }

    assert iur_button.events.click.payload.mapping == %{artifact_id: "artifact-1", row_index: 0}

    assert {:ok, runtime_state} =
             ElmUi.Runtime.mount_iur_screen(collection,
               runtime_id: "collection-runtime",
               title: "Collection Runtime"
             )

    assert {:ok, frontend_model} = ElmUi.Runtime.hydrate_frontend(runtime_state)
    assert find_node(frontend_model.tree, "artifact-summary-template-artifact-1").tag == "div"

    assert {:ok, _frontend_model, message} =
             ElmUi.FrontendRuntime.dispatch_interaction(frontend_model,
               family: :click,
               intent: :open_artifact,
               widget_id: iur_button.id,
               payload: iur_button.events.click.payload
             )

    refute message.payload |> Map.keys() |> Enum.any?(&String.starts_with?(to_string(&1), "phx"))

    assert {:ok, next_state, acknowledgement} =
             ElmUi.Runtime.handle_frontend_event(runtime_state, message)

    assert next_state.last_boundary_signal.data.mapping == %{
             artifact_id: "artifact-1",
             row_index: 0
           }

    assert acknowledgement.payload.event_count == 1
  end

  defp native_cases do
    [
      {ElmUi.Widgets.disclosure("native-disclosure", "Release notes", open: true), :disclosure},
      {ElmUi.Widgets.kicker("native-kicker", "Workflow"), :kicker},
      {ElmUi.Widgets.avatar("native-avatar", "Pat", initials: "PC"), :avatar},
      {ElmUi.Widgets.presence_dot("native-presence", :online), :presence_dot},
      {ElmUi.Widgets.segmented_button_group("native-segments", compact: "Compact"),
       :segmented_button_group},
      {ElmUi.Widgets.list_item_multi_column("native-list-item", name: "artifact.tar"),
       :list_item_multi_column},
      {ElmUi.Widgets.artifact_row("native-artifact", %{id: "artifact-1"}, "artifact.tar"),
       :artifact_row},
      {ElmUi.Widgets.sticky_header("native-header", "Results"), :sticky_header},
      {ElmUi.Widgets.pipeline_stepper_horizontal("native-pipeline", [:queued, :building]),
       :pipeline_stepper_horizontal},
      {ElmUi.Widgets.segmented_progress_bar("native-progress", queued: 20, building: 80),
       :segmented_progress_bar},
      {ElmUi.Widgets.workflow_stage_list_vertical("native-stages", [:plan, :build]),
       :workflow_stage_list_vertical},
      {ElmUi.Widgets.meter_thin("native-meter", 82), :meter_thin},
      {ElmUi.Widgets.slide_over_panel("native-panel", [], visible: true), :slide_over_panel},
      {ElmUi.Widgets.event_callout("native-callout", "Build completed"), :event_callout},
      {ElmUi.Widgets.redline_inline("native-redline", "Draft", "Ready"), :redline_inline},
      {ElmUi.Widgets.code_block_syntax_highlighted("native-code", "IO.puts(\"ready\")"),
       :code_block_syntax_highlighted},
      {ElmUi.Widgets.chat_composer("native-composer", placeholder: "Add a review note"),
       :chat_composer},
      {ElmUi.Widgets.host_form_shell("native-host-form", [],
         validation_summary: "Host validates"
       ), :host_form_shell},
      {ElmUi.Widgets.repeated_collection("native-collection", []), :repeated_collection}
    ]
  end

  defp repeated_collection(items) do
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
