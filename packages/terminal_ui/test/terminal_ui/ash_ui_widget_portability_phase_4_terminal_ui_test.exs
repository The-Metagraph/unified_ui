defmodule TerminalUi.AshUiWidgetPortabilityPhase4TerminalUiTest do
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

  test "terminal native promoted widgets expose explicit fallback semantics" do
    promoted_kinds = Enum.map(native_widgets(), & &1.kind)

    assert Enum.all?(promoted_kinds, &(&1 in TerminalUi.Widgets.kinds()))
    assert Enum.all?(promoted_kinds, &(&1 in TerminalUi.Renderer.supported_kinds()))

    avatar = TerminalUi.Widgets.avatar("native-avatar", "Pat", initials: "PC")
    presence = TerminalUi.Widgets.presence_dot("native-presence", :online)
    panel = TerminalUi.Widgets.slide_over_panel("native-panel", [], visible: true)
    code = TerminalUi.Widgets.code_block_syntax_highlighted("native-code", "IO.puts(:ok)")
    composer = TerminalUi.Widgets.chat_composer("native-composer", submit_intent: :send_review)
    collection = TerminalUi.Widgets.repeated_collection("native-rows", [])

    assert avatar.metadata.degradation_strategy == :initials_text
    assert presence.metadata.degradation_strategy == :status_text
    assert panel.metadata.overlay_role == :slide_over_panel
    assert panel.state.open
    assert code.metadata.degradation_strategy == :plain_code_block
    assert composer.metadata.degradation_strategy == :inline_text_prompt
    assert collection.metadata.degradation_strategy == :linearized_collection

    assert TerminalUi.Degradation.resolve(avatar, backend_mode: :tty) == :initials_text
    assert TerminalUi.Degradation.resolve(panel, backend_mode: :tty) == :inline_overlay
    assert TerminalUi.Degradation.resolve(code, backend_mode: :tty) == :plain_code_block
    assert TerminalUi.Degradation.resolve(composer, backend_mode: :tty) == :inline_text_prompt
  end

  test "terminal renderer consumes promoted IUR fixture through native widgets" do
    fixture = Fixtures.fixture!("portable_widgets--ash_ui_portability")

    assert {:ok, root} = TerminalUi.Renderer.render(fixture.element)

    for {id, kind} <- @fixture_widgets do
      assert %{kind: ^kind} = find_widget(root, id)
    end

    repeated = find_widget(root, "portable-artifact-rows")
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

    assert artifact.attributes.artifact == %{id: "artifact-1"}
    assert hd(summary.attributes.columns).label == "artifact.tar"
    assert panel.metadata.degradation_strategy == :inline_overlay
    assert panel.state.open
    assert composer.events.submit.intent == :send_review

    assert {:ok, runtime_state} =
             TerminalUi.Runtime.mount_iur_screen(fixture.element, backend_mode: :tty)

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "portable-panel" and fallback.fallback == :inline_overlay
           end)

    assert Enum.any?(runtime_state.realization.fallbacks, fn fallback ->
             fallback.widget_id == "portable-composer" and
               fallback.fallback == :inline_text_prompt
           end)
  end

  test "terminal repeated collections preserve row-scope payloads and boundary routing" do
    collection = collection_for([%{id: "artifact-1", title: "artifact.tar"}])

    assert {:ok, root} = TerminalUi.Renderer.render(collection)

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

    assert button.events.keypress.mapping == %{artifact_id: "artifact-1", row_index: 0}

    assert {:ok, runtime_state} =
             TerminalUi.Runtime.mount_iur_screen(collection,
               backend_mode: :tty,
               runtime_id: "terminal-row-runtime",
               title: "Terminal Row Runtime"
             )

    assert "artifact-open-template-artifact-1" in runtime_state.focus.order

    assert runtime_state.realization.event_targets["artifact-open-template-artifact-1"] == [
             :keypress
           ]

    assert {:ok, _runtime_state, route_result} =
             TerminalUi.Runtime.dispatch_widget_interaction(
               runtime_state,
               "artifact-open-template-artifact-1",
               :click,
               intent: :open_artifact,
               payload: button.events.keypress,
               boundary: :boundary
             )

    assert route_result.route == :canonical_boundary
    assert route_result.translation.payload.mapping == %{artifact_id: "artifact-1", row_index: 0}
  end

  test "fallback capability diagnostics include promoted widget constraints" do
    tty = TerminalUi.Capabilities.snapshot(backend_mode: :tty)
    diagnostics = TerminalUi.Capabilities.diagnostics(capabilities: tty)
    plan = TerminalUi.Degradation.plan(tty)

    assert :linearized_collection in tty.keyboard_alternatives
    assert diagnostics.fallback_modes.promoted_widgets == :explicit_fallbacks
    assert :syntax_highlighting_fallback in diagnostics.allowed_variation
    assert :progress_visual_fallback in diagnostics.allowed_variation
    assert :attachment_fallback in diagnostics.allowed_variation
    assert plan.promoted_widget_modes.chat_composer == :inline_text_prompt
    assert plan.promoted_widget_modes.repeated_collection == :linearized_collection
  end

  defp native_widgets do
    [
      TerminalUi.Widgets.disclosure("native-disclosure", "Release notes"),
      TerminalUi.Widgets.kicker("native-kicker", "Workflow"),
      TerminalUi.Widgets.avatar("native-avatar", "Pat", initials: "PC"),
      TerminalUi.Widgets.presence_dot("native-presence", :online),
      TerminalUi.Widgets.segmented_button_group("native-segments", compact: "Compact"),
      TerminalUi.Widgets.list_item_multi_column("native-list-item", name: "artifact.tar"),
      TerminalUi.Widgets.artifact_row("native-artifact", %{id: "artifact-1"}, "artifact.tar"),
      TerminalUi.Widgets.sticky_header("native-header", "Results"),
      TerminalUi.Widgets.pipeline_stepper_horizontal("native-pipeline", [:queued, :building]),
      TerminalUi.Widgets.segmented_progress_bar("native-progress", queued: 20, building: 80),
      TerminalUi.Widgets.workflow_stage_list_vertical("native-stages", [:plan, :build]),
      TerminalUi.Widgets.meter_thin("native-meter", 82),
      TerminalUi.Widgets.slide_over_panel("native-panel", [], visible: true),
      TerminalUi.Widgets.event_callout("native-callout", "Build completed"),
      TerminalUi.Widgets.redline_inline("native-redline", "Draft", "Ready"),
      TerminalUi.Widgets.code_block_syntax_highlighted("native-code", "IO.puts(\"ready\")"),
      TerminalUi.Widgets.chat_composer("native-composer"),
      TerminalUi.Widgets.host_form_shell("native-host-form", []),
      TerminalUi.Widgets.repeated_collection("native-collection", [])
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

  defp find_widget(%TerminalUi.Widget{id: id} = widget, id), do: widget

  defp find_widget(%TerminalUi.Widget{} = widget, id) do
    widget.children
    |> Enum.find_value(&find_widget(&1, id))
  end

  defp find_widget(nil, _id), do: nil
end
