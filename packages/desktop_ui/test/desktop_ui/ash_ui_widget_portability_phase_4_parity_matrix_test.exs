defmodule DesktopUi.AshUiWidgetPortabilityPhase4ParityMatrixTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Binding, Collection, Forms, Layout}
  alias UnifiedIUR.Widgets.{Foundational, Semantic, Workflow}

  @matrix_path Path.expand(
                 "../../../../.spec/planning/ash_ui_widget_portability/runtime-parity-matrix.json",
                 __DIR__
               )

  test "parity matrix covers every promoted canonical widget kind" do
    matrix_kinds = matrix_kinds()

    expected_kinds =
      (Semantic.kinds() ++ Workflow.kinds() ++ [:host_form_shell, :repeated_collection])
      |> Enum.sort()

    assert matrix_kinds == expected_kinds
    assert Enum.all?(matrix_kinds, &(&1 in DesktopUi.Renderer.supported_kinds()))
    assert Enum.all?(matrix_kinds, &(&1 in DesktopUi.Widgets.kinds()))
  end

  test "desktop renderer realizes every matrix widget without fallback" do
    for entry <- matrix_entries() do
      kind = kind(entry)
      desktop = runtime_entry(entry, "desktop")

      assert desktop["support"] == "direct"
      assert desktop["fallback"] == nil
      assert {:ok, %{kind: ^kind}} = DesktopUi.Renderer.render(canonical_element(kind))
    end
  end

  test "desktop native events match matrix interaction expectations" do
    for entry <- matrix_entries() do
      required_events = required_events(entry, "desktop")
      native_widget = native_widget(kind(entry))

      assert Enum.all?(required_events, &Map.has_key?(native_widget.events, &1)),
             "desktop #{entry["kind"]} missing events #{inspect(required_events)}"
    end
  end

  test "desktop repeated collection validation preserves row-scope diagnostics and payloads" do
    assert {:ok, root} = DesktopUi.Renderer.render(row_scope_collection())

    repeated = find_widget(root, "artifact-rows")
    button = find_widget(root, "artifact-open-template-artifact-1-0")

    rows = repeated.attributes.rows

    assert Enum.map(rows, &Map.take(&1, [:key, :key_source, :index])) == [
             %{key: "artifact-1", key_source: :key_path, index: 0},
             %{key: "artifact-1", key_source: :key_path, index: 1},
             %{key: "2", key_source: :index_fallback, index: 2}
           ]

    assert Enum.all?(Enum.take(rows, 2), &(:duplicate_key in &1.diagnostics))
    assert :missing_key in Enum.at(rows, 2).diagnostics
    assert button.events.click.payload.mapping == %{artifact_id: "artifact-1", row_index: 0}
  end

  defp canonical_element(:disclosure), do: Semantic.disclosure("Details", id: "disclosure")
  defp canonical_element(:kicker), do: Semantic.kicker("Workflow", id: "kicker")
  defp canonical_element(:avatar), do: Semantic.avatar("Pat", id: "avatar", initials: "PC")
  defp canonical_element(:presence_dot), do: Semantic.presence_dot(:online, id: "presence-dot")

  defp canonical_element(:segmented_button_group) do
    Semantic.segmented_button_group([compact: "Compact"], id: "segmented-button-group")
  end

  defp canonical_element(:list_item_multi_column) do
    Semantic.list_item_multi_column([name: "artifact.tar"], id: "list-item-multi-column")
  end

  defp canonical_element(:artifact_row) do
    Semantic.artifact_row(%{id: "artifact-1"}, "artifact.tar", id: "artifact-row")
  end

  defp canonical_element(:sticky_header),
    do: Semantic.sticky_header("Results", id: "sticky-header")

  defp canonical_element(:pipeline_stepper_horizontal) do
    Workflow.pipeline_stepper_horizontal([queued: "Queued"], id: "pipeline-stepper-horizontal")
  end

  defp canonical_element(:segmented_progress_bar) do
    Workflow.segmented_progress_bar([queued: 10], id: "segmented-progress-bar")
  end

  defp canonical_element(:workflow_stage_list_vertical) do
    Workflow.workflow_stage_list_vertical([plan: "Plan"], id: "workflow-stage-list-vertical")
  end

  defp canonical_element(:meter_thin), do: Workflow.meter_thin(70, id: "meter-thin")

  defp canonical_element(:slide_over_panel) do
    Workflow.slide_over_panel([Foundational.text("Panel", id: "panel-copy")],
      id: "slide-over-panel",
      visible?: true
    )
  end

  defp canonical_element(:event_callout), do: Workflow.event_callout("Saved", id: "event-callout")

  defp canonical_element(:redline_inline) do
    Workflow.redline_inline("Draft", "Ready", id: "redline-inline")
  end

  defp canonical_element(:code_block_syntax_highlighted) do
    Workflow.code_block_syntax_highlighted("IO.puts(:ok)", id: "code-block-syntax-highlighted")
  end

  defp canonical_element(:chat_composer), do: Workflow.chat_composer(id: "chat-composer")

  defp canonical_element(:host_form_shell) do
    Forms.host_form_shell([Foundational.text("Field", id: "host-form-copy")],
      id: "host-form-shell"
    )
  end

  defp canonical_element(:repeated_collection), do: row_scope_collection()

  defp native_widget(:disclosure),
    do:
      DesktopUi.Widgets.disclosure("native-disclosure", "Details", on_toggle: %{intent: :toggle})

  defp native_widget(:kicker), do: DesktopUi.Widgets.kicker("native-kicker", "Workflow")
  defp native_widget(:avatar), do: DesktopUi.Widgets.avatar("native-avatar", "Pat")

  defp native_widget(:presence_dot),
    do: DesktopUi.Widgets.presence_dot("native-presence", :online)

  defp native_widget(:segmented_button_group) do
    DesktopUi.Widgets.segmented_button_group("native-segments", [compact: "Compact"],
      on_select: %{intent: :select},
      on_change: %{intent: :change}
    )
  end

  defp native_widget(:list_item_multi_column),
    do: DesktopUi.Widgets.list_item_multi_column("native-list-item", name: "artifact.tar")

  defp native_widget(:artifact_row) do
    DesktopUi.Widgets.artifact_row("native-artifact", %{id: "artifact-1"}, "artifact.tar",
      on_click: %{intent: :open},
      on_select: %{intent: :select}
    )
  end

  defp native_widget(:sticky_header),
    do: DesktopUi.Widgets.sticky_header("native-header", "Results")

  defp native_widget(:pipeline_stepper_horizontal),
    do: DesktopUi.Widgets.pipeline_stepper_horizontal("native-pipeline", [:queued])

  defp native_widget(:segmented_progress_bar),
    do: DesktopUi.Widgets.segmented_progress_bar("native-progress", queued: 10)

  defp native_widget(:workflow_stage_list_vertical),
    do: DesktopUi.Widgets.workflow_stage_list_vertical("native-stages", [:plan])

  defp native_widget(:meter_thin), do: DesktopUi.Widgets.meter_thin("native-meter", 70)

  defp native_widget(:slide_over_panel) do
    DesktopUi.Widgets.slide_over_panel("native-panel", [],
      on_open: %{intent: :open},
      on_close: %{intent: :close}
    )
  end

  defp native_widget(:event_callout),
    do: DesktopUi.Widgets.event_callout("native-callout", "Saved")

  defp native_widget(:redline_inline),
    do: DesktopUi.Widgets.redline_inline("native-redline", "Draft", "Ready")

  defp native_widget(:code_block_syntax_highlighted),
    do: DesktopUi.Widgets.code_block_syntax_highlighted("native-code", "IO.puts(:ok)")

  defp native_widget(:chat_composer) do
    DesktopUi.Widgets.chat_composer("native-composer",
      on_submit: %{intent: :submit},
      on_change: %{intent: :change}
    )
  end

  defp native_widget(:host_form_shell) do
    DesktopUi.Widgets.host_form_shell("native-host-form", [],
      on_submit: %{intent: :submit},
      on_change: %{intent: :change}
    )
  end

  defp native_widget(:repeated_collection),
    do: DesktopUi.Widgets.repeated_collection("native-rows", [])

  defp row_scope_collection do
    Collection.repeated_collection(
      Layout.row(
        [
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
        value: [
          %{id: "artifact-1", title: "first"},
          %{id: "artifact-1", title: "duplicate"},
          %{title: "missing"}
        ]
      ],
      item_alias: :artifact,
      index_alias: :row,
      key_path: [:id],
      empty_state: "No artifacts"
    )
  end

  defp matrix_entries, do: matrix()["widgets"]

  defp matrix_kinds do
    matrix_entries()
    |> Enum.map(&kind/1)
    |> Enum.sort()
  end

  defp matrix do
    @matrix_path
    |> File.read!()
    |> JSON.decode!()
  end

  defp runtime_entry(entry, runtime), do: Map.fetch!(entry, runtime)

  defp required_events(entry, runtime),
    do:
      entry
      |> runtime_entry(runtime)
      |> Map.fetch!("required_events")
      |> Enum.map(&String.to_existing_atom/1)

  defp kind(entry), do: entry |> Map.fetch!("kind") |> String.to_existing_atom()

  defp find_widget(%DesktopUi.Widget{id: id} = widget, id), do: widget

  defp find_widget(%DesktopUi.Widget{} = widget, id) do
    Enum.find_value(widget.children, &find_widget(&1, id))
  end

  defp find_widget(nil, _id), do: nil
end
