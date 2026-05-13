defmodule TerminalUi.AshUiWidgetPortabilityPhase4IntegrationTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Binding, Collection, Forms, Interaction, Layout}
  alias UnifiedIUR.Widgets.{Foundational, Semantic, Workflow}

  @matrix_path Path.expand(
                 "../../../../.spec/planning/ash_ui_widget_portability/runtime-parity-matrix.json",
                 __DIR__
               )

  test "terminal native and canonical runtime entrypoints realize every parity matrix widget" do
    for entry <- matrix_entries() do
      kind = kind(entry)
      native = native_widget(kind)
      canonical = canonical_element(kind)

      assert native.kind == kind

      assert {:ok, native_state} =
               TerminalUi.Runtime.mount_native_screen(screen_for(native, "native-#{kind}"),
                 backend_mode: :tty
               )

      assert native_state.source_kind == :native
      assert native_state.realization.tree.kind == kind

      assert {:ok, rendered} = TerminalUi.Renderer.render(canonical)
      assert rendered.kind == kind

      assert {:ok, canonical_state} =
               TerminalUi.Runtime.mount_iur_screen(canonical,
                 backend_mode: :tty,
                 runtime_id: "terminal-portable-#{kind}"
               )

      assert canonical_state.source_kind == :canonical
      assert canonical_state.realization.tree.kind == kind

      assert runtime_entry(entry)["support"] in ["direct", "fallback"]
      assert_required_events!(native.events, entry, "terminal native #{kind}")
      assert_required_events!(rendered.events, entry, "terminal rendered #{kind}")

      assert_required_events!(
        Map.get(canonical_state.realization.event_targets, to_string(rendered.id), []),
        entry,
        "terminal runtime #{kind}"
      )

      assert_semantic_contract!(entry, canonical_state.realization.tree)
      assert_runtime_fallback!(entry, canonical_state)
      assert_runtime_fallback!(entry, native_state)
    end
  end

  test "terminal promoted fixture reports explicit degradation diagnostics" do
    fixture = UnifiedIUR.Fixtures.fixture!("portable_widgets--ash_ui_portability")

    assert {:ok, runtime_state} =
             TerminalUi.Runtime.mount_iur_screen(fixture.element,
               backend_mode: :tty,
               runtime_id: "terminal-portable-fixture"
             )

    fallbacks = MapSet.new(runtime_state.realization.fallbacks, &{&1.widget_id, &1.fallback})

    assert {"portable-panel", :inline_overlay} in fallbacks
    assert {"portable-composer", :inline_text_prompt} in fallbacks
    assert {"portable-code", :plain_code_block} in fallbacks
    assert {"portable-artifact-rows", :linearized_collection} in fallbacks

    assert runtime_state.realization.diagnostics.capability_profile == :fallback_terminal

    assert runtime_state.realization.diagnostics.capability_fallbacks.promoted_widgets ==
             :explicit_fallbacks

    assert :syntax_highlighting_fallback in runtime_state.realization.diagnostics.allowed_variation
    assert :progress_visual_fallback in runtime_state.realization.diagnostics.allowed_variation
    assert :row_scope_linearization in runtime_state.realization.diagnostics.allowed_variation
  end

  test "terminal repeated collections preserve rows, empty states, updates, and row actions" do
    populated =
      collection_for([
        %{id: "artifact-1", title: "artifact.tar"},
        %{id: "artifact-2", title: "artifact.zip"}
      ])

    assert {:ok, populated_root} = TerminalUi.Renderer.render(populated)

    populated_collection = find_widget(populated_root, "artifact-rows")
    second_artifact = find_widget(populated_root, "artifact-template-artifact-2")
    second_summary = find_widget(populated_root, "artifact-summary-template-artifact-2")
    second_button = find_widget(populated_root, "artifact-open-template-artifact-2")

    assert Enum.map(populated_collection.attributes.rows, & &1.key) == [
             "artifact-1",
             "artifact-2"
           ]

    assert second_artifact.kind == :artifact_row
    assert second_artifact.attributes.artifact.id == "artifact-2"
    assert hd(second_summary.attributes.columns).label == "artifact.zip"
    assert second_button.events.keypress.mapping == %{artifact_id: "artifact-2", row_index: 1}

    assert {:ok, populated_state} =
             TerminalUi.Runtime.mount_iur_screen(populated,
               backend_mode: :tty,
               runtime_id: "terminal-row-integration"
             )

    assert populated_state.realization.event_targets["artifact-open-template-artifact-2"] == [
             :keypress
           ]

    assert {:ok, _runtime_state, route_result} =
             TerminalUi.Runtime.dispatch_widget_interaction(
               populated_state,
               "artifact-open-template-artifact-2",
               :click,
               intent: :open_artifact,
               payload: second_button.events.keypress,
               boundary: :boundary
             )

    assert route_result.route == :canonical_boundary
    assert route_result.translation.payload.mapping == %{artifact_id: "artifact-2", row_index: 1}

    assert {:ok, empty_root} = TerminalUi.Renderer.render(collection_for([]))
    empty_collection = find_widget(empty_root, "artifact-rows")
    [empty_state] = empty_collection.slot_children.empty_state

    assert empty_collection.attributes.rows == []
    assert empty_state.kind == :text
    assert empty_state.attributes.content == "No artifacts"

    assert {:ok, updated_root} =
             TerminalUi.Renderer.render(
               collection_for([
                 %{id: "artifact-1", title: "artifact-v2.tar"},
                 %{id: "artifact-3", title: "artifact-new.tar"}
               ])
             )

    updated_collection = find_widget(updated_root, "artifact-rows")
    updated_summary = find_widget(updated_root, "artifact-summary-template-artifact-1")

    assert Enum.map(updated_collection.attributes.rows, & &1.key) == [
             "artifact-1",
             "artifact-3"
           ]

    assert hd(updated_summary.attributes.columns).label == "artifact-v2.tar"
    assert runtime_matrix()["row_scope"]["terminal"]["row_action_events"] == ["keypress"]
  end

  defp canonical_element(:disclosure) do
    Semantic.disclosure("Details",
      id: "disclosure",
      open?: true,
      content_label: "Expanded details",
      interaction: Interaction.open(intent: :toggle_details, element_id: "disclosure")
    )
  end

  defp canonical_element(:kicker),
    do: Semantic.kicker("Workflow", id: "kicker", role: :eyebrow, summary: "Workflow context")

  defp canonical_element(:avatar) do
    Semantic.avatar("Pat Charbon",
      id: "avatar",
      initials: "PC",
      source: "/avatars/pc.png",
      status: :online
    )
  end

  defp canonical_element(:presence_dot),
    do: Semantic.presence_dot(:online, id: "presence-dot", label: "Assignee online", pulse?: true)

  defp canonical_element(:segmented_button_group) do
    Semantic.segmented_button_group([compact: "Compact", detailed: "Detailed"],
      id: "segmented-button-group",
      active_item: :compact,
      interactions: [
        Interaction.selection(
          intent: :select_density,
          element_id: "segmented-button-group",
          selection: :compact
        ),
        Interaction.change(
          intent: :change_density,
          element_id: "segmented-button-group",
          value: :compact
        )
      ]
    )
  end

  defp canonical_element(:list_item_multi_column) do
    Semantic.list_item_multi_column([name: "artifact.tar", status: "ready"],
      id: "list-item-multi-column",
      label: "Artifact",
      value: "artifact.tar",
      status: :ready
    )
  end

  defp canonical_element(:artifact_row) do
    Semantic.artifact_row(%{id: "artifact-1"}, "artifact.tar",
      id: "artifact-row",
      status: :ready,
      interactions: [
        Interaction.click(
          intent: :open_artifact,
          element_id: "artifact-row",
          mapping: %{artifact_id: "artifact-1"}
        ),
        Interaction.selection(
          intent: :select_artifact,
          element_id: "artifact-row",
          selection: "artifact-1"
        )
      ]
    )
  end

  defp canonical_element(:sticky_header),
    do: Semantic.sticky_header("Results", id: "sticky-header", stuck?: true, elevation: :raised)

  defp canonical_element(:pipeline_stepper_horizontal) do
    Workflow.pipeline_stepper_horizontal([queued: "Queued", building: "Building"],
      id: "pipeline-stepper-horizontal",
      active_item: :building,
      status: :running
    )
  end

  defp canonical_element(:segmented_progress_bar) do
    Workflow.segmented_progress_bar([queued: 10, building: 90],
      id: "segmented-progress-bar",
      current: 90,
      maximum: 100,
      label: "Build progress"
    )
  end

  defp canonical_element(:workflow_stage_list_vertical) do
    Workflow.workflow_stage_list_vertical([plan: "Plan", build: "Build"],
      id: "workflow-stage-list-vertical",
      active_item: :build,
      status: :running
    )
  end

  defp canonical_element(:meter_thin),
    do: Workflow.meter_thin(70, id: "meter-thin", maximum: 100, severity: :warning)

  defp canonical_element(:slide_over_panel) do
    Workflow.slide_over_panel([Foundational.text("Panel", id: "panel-copy")],
      id: "slide-over-panel",
      title: "Details",
      placement: :end,
      visible?: true,
      interactions: [
        Interaction.open(intent: :open_panel, element_id: "slide-over-panel"),
        Interaction.close(intent: :close_panel, element_id: "slide-over-panel")
      ]
    )
  end

  defp canonical_element(:event_callout) do
    Workflow.event_callout("Saved",
      id: "event-callout",
      title: "Deployment",
      severity: :success,
      timestamp: "2026-05-13T10:35:00Z"
    )
  end

  defp canonical_element(:redline_inline),
    do: Workflow.redline_inline("Draft", "Ready", id: "redline-inline", label: "Status change")

  defp canonical_element(:code_block_syntax_highlighted) do
    Workflow.code_block_syntax_highlighted("IO.puts(:ok)",
      id: "code-block-syntax-highlighted",
      language: :elixir,
      label: "Example",
      wrap?: true
    )
  end

  defp canonical_element(:chat_composer) do
    Workflow.chat_composer(
      id: "chat-composer",
      placeholder: "Add a review note",
      submit_intent: :send_review,
      actions: [send: "Send"],
      interactions: [
        Interaction.submit(intent: :send_review, element_id: "chat-composer"),
        Interaction.change(intent: :edit_review, element_id: "chat-composer", value: "Draft")
      ]
    )
  end

  defp canonical_element(:host_form_shell) do
    Forms.host_form_shell([Foundational.text("Field", id: "host-form-copy")],
      id: "host-form-shell",
      submit_intent: :save_form,
      validation_summary: "Ready",
      interactions: [
        Interaction.submit(intent: :save_form, element_id: "host-form-shell"),
        Interaction.change(intent: :change_form, element_id: "host-form-shell", value: :dirty)
      ]
    )
  end

  defp canonical_element(:repeated_collection),
    do: collection_for([%{id: "artifact-1", title: "artifact.tar"}])

  defp native_widget(:disclosure),
    do:
      TerminalUi.Widgets.disclosure("native-disclosure", "Details",
        open: true,
        on_toggle: %{intent: :toggle_details}
      )

  defp native_widget(:kicker), do: TerminalUi.Widgets.kicker("native-kicker", "Workflow")

  defp native_widget(:avatar),
    do: TerminalUi.Widgets.avatar("native-avatar", "Pat", initials: "PC")

  defp native_widget(:presence_dot),
    do: TerminalUi.Widgets.presence_dot("native-presence", :online)

  defp native_widget(:segmented_button_group) do
    TerminalUi.Widgets.segmented_button_group("native-segments", [compact: "Compact"],
      active_item: :compact,
      on_select: %{intent: :select_density},
      on_change: %{intent: :change_density}
    )
  end

  defp native_widget(:list_item_multi_column),
    do: TerminalUi.Widgets.list_item_multi_column("native-list-item", name: "artifact.tar")

  defp native_widget(:artifact_row) do
    TerminalUi.Widgets.artifact_row("native-artifact", %{id: "artifact-1"}, "artifact.tar",
      on_activate: %{intent: :open_artifact},
      on_select: %{intent: :select_artifact}
    )
  end

  defp native_widget(:sticky_header),
    do: TerminalUi.Widgets.sticky_header("native-header", "Results")

  defp native_widget(:pipeline_stepper_horizontal),
    do: TerminalUi.Widgets.pipeline_stepper_horizontal("native-pipeline", [:queued])

  defp native_widget(:segmented_progress_bar),
    do: TerminalUi.Widgets.segmented_progress_bar("native-progress", queued: 10)

  defp native_widget(:workflow_stage_list_vertical),
    do: TerminalUi.Widgets.workflow_stage_list_vertical("native-stages", [:plan])

  defp native_widget(:meter_thin), do: TerminalUi.Widgets.meter_thin("native-meter", 70)

  defp native_widget(:slide_over_panel) do
    TerminalUi.Widgets.slide_over_panel("native-panel", [],
      visible: true,
      on_open: %{intent: :open_panel},
      on_close: %{intent: :close_panel}
    )
  end

  defp native_widget(:event_callout),
    do: TerminalUi.Widgets.event_callout("native-callout", "Saved")

  defp native_widget(:redline_inline),
    do: TerminalUi.Widgets.redline_inline("native-redline", "Draft", "Ready")

  defp native_widget(:code_block_syntax_highlighted),
    do: TerminalUi.Widgets.code_block_syntax_highlighted("native-code", "IO.puts(:ok)")

  defp native_widget(:chat_composer) do
    TerminalUi.Widgets.chat_composer("native-composer",
      submit_intent: :send_review,
      on_submit: %{intent: :send_review},
      on_change: %{intent: :edit_review}
    )
  end

  defp native_widget(:host_form_shell) do
    TerminalUi.Widgets.host_form_shell("native-host-form", [],
      submit_intent: :save_form,
      on_submit: %{intent: :save_form},
      on_change: %{intent: :change_form}
    )
  end

  defp native_widget(:repeated_collection),
    do: TerminalUi.Widgets.repeated_collection("native-rows", [])

  defp collection_for(items) do
    Collection.repeated_collection(
      Layout.row(
        [
          Semantic.artifact_row(Binding.row_value(:artifact, :record), "Artifact",
            id: "artifact-template",
            status: :ready
          ),
          Semantic.list_item_multi_column(Binding.row_value(:artifact, :columns),
            id: "artifact-summary-template",
            label: "Artifact summary",
            value: Binding.row_index(:row),
            status: :ready
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

  defp with_columns(%{id: id, title: title}) do
    %{id: id, record: %{id: id}, columns: %{name: title}}
  end

  defp screen_for(widget, id), do: %{id: id, title: "Portable #{id}", root: widget}

  defp runtime_matrix do
    @matrix_path
    |> File.read!()
    |> JSON.decode!()
  end

  defp matrix_entries, do: runtime_matrix()["widgets"]
  defp kind(entry), do: entry |> Map.fetch!("kind") |> String.to_existing_atom()
  defp runtime_entry(entry), do: Map.fetch!(entry, "terminal")

  defp required_events(entry),
    do:
      entry
      |> runtime_entry()
      |> Map.fetch!("required_events")
      |> Enum.map(&String.to_existing_atom/1)

  defp assert_required_events!(events, entry, context) do
    actual =
      cond do
        is_map(events) -> Map.keys(events)
        is_list(events) -> events
        true -> []
      end

    missing = required_events(entry) -- actual
    assert missing == [], "#{context} missing required events #{inspect(missing)}"
  end

  defp assert_runtime_fallback!(entry, runtime_state) do
    expected =
      entry
      |> runtime_entry()
      |> Map.fetch!("fallback")

    fallback_entry =
      Enum.find(runtime_state.realization.fallbacks, &(&1.kind == kind(entry)))

    case expected do
      nil ->
        assert fallback_entry == nil

      fallback ->
        assert fallback_entry.fallback == String.to_existing_atom(fallback)

        assert runtime_state.realization.diagnostics.capability_fallbacks.promoted_widgets ==
                 :explicit_fallbacks
    end
  end

  defp assert_semantic_contract!(entry, node) do
    observations = semantic_observations(node.kind, node)

    missing =
      entry["required_semantics"]
      |> Enum.reject(&present?(Map.get(observations, &1)))

    assert missing == [],
           "#{entry["kind"]} missing required semantics #{inspect(missing)} in #{inspect(observations)}"
  end

  defp semantic_observations(:disclosure, node) do
    %{
      "label" => attr(node, :label),
      "expanded_state" => has_state?(node, :open) || has_state?(node, :expanded),
      "toggle_interaction" => has_event?(node, :toggle),
      "content_label" => attr(node, :content_label)
    }
  end

  defp semantic_observations(:kicker, node),
    do: %{
      "value" => attr(node, :value),
      "role" => attr(node, :role),
      "summary" => attr(node, :summary)
    }

  defp semantic_observations(:avatar, node) do
    %{
      "label" => attr(node, :label),
      "initials" => attr(node, :initials),
      "source" => attr(node, :source),
      "status" => attr(node, :status)
    }
  end

  defp semantic_observations(:presence_dot, node) do
    %{
      "status" => attr(node, :status),
      "label" => attr(node, :label),
      "active_state" => has_state?(node, :active)
    }
  end

  defp semantic_observations(:segmented_button_group, node) do
    %{
      "items" => attr(node, :items),
      "active_item" => attr(node, :active_item),
      "selection_mode" => attr(node, :selection_mode),
      "selection_interaction" => has_event?(node, :select)
    }
  end

  defp semantic_observations(:list_item_multi_column, node) do
    %{
      "columns" => attr(node, :columns),
      "label" => attr(node, :label),
      "value" => attr(node, :value),
      "status" => attr(node, :status)
    }
  end

  defp semantic_observations(:artifact_row, node) do
    %{
      "artifact_identity" => get_in(attr(node, :artifact) || %{}, [:id]),
      "title" => attr(node, :title),
      "status" => attr(node, :status),
      "activation_interaction" => has_event?(node, :activate)
    }
  end

  defp semantic_observations(:sticky_header, node) do
    %{
      "title" => attr(node, :title),
      "stuck_state" => has_state?(node, :active),
      "elevation" => attr(node, :elevation)
    }
  end

  defp semantic_observations(:pipeline_stepper_horizontal, node) do
    %{
      "steps" => attr(node, :steps),
      "active_item" => attr(node, :active_item),
      "status" => attr(node, :status),
      "orientation" => attr(node, :orientation)
    }
  end

  defp semantic_observations(:segmented_progress_bar, node) do
    %{
      "segments" => attr(node, :segments),
      "current" => attr(node, :current),
      "maximum" => attr(node, :maximum),
      "label" => attr(node, :label)
    }
  end

  defp semantic_observations(:workflow_stage_list_vertical, node) do
    %{
      "stages" => attr(node, :stages),
      "active_item" => attr(node, :active_item),
      "status" => attr(node, :status),
      "orientation" => attr(node, :orientation)
    }
  end

  defp semantic_observations(:meter_thin, node) do
    %{
      "current" => attr(node, :current),
      "minimum" => attr(node, :minimum),
      "maximum" => attr(node, :maximum),
      "severity" => attr(node, :severity)
    }
  end

  defp semantic_observations(:slide_over_panel, node) do
    %{
      "title" => attr(node, :title),
      "placement" => attr(node, :placement),
      "open_state" => has_state?(node, :open),
      "overlay_lifecycle" =>
        metadata(node, :overlay_lifecycle) || metadata(node, :overlay_role) ||
          Map.get(node, :layer_role)
    }
  end

  defp semantic_observations(:event_callout, node) do
    %{
      "message" => attr(node, :message),
      "title" => attr(node, :title),
      "severity" => attr(node, :severity),
      "timestamp" => attr(node, :timestamp)
    }
  end

  defp semantic_observations(:redline_inline, node) do
    %{
      "before_text" => attr(node, :before_text),
      "after_text" => attr(node, :after_text),
      "label" => attr(node, :label)
    }
  end

  defp semantic_observations(:code_block_syntax_highlighted, node) do
    %{
      "code" => attr(node, :code),
      "language" => attr(node, :language),
      "wrap" => has_attr?(node, :wrap),
      "label" => attr(node, :label)
    }
  end

  defp semantic_observations(:chat_composer, node) do
    %{
      "placeholder" => attr(node, :placeholder),
      "submit_intent" => attr(node, :submit_intent),
      "actions" => attr(node, :actions),
      "multiline" => has_attr?(node, :multiline)
    }
  end

  defp semantic_observations(:host_form_shell, node) do
    %{
      "owner" => attr(node, :owner),
      "lifecycle" => attr(node, :lifecycle),
      "validation" => attr(node, :validation_summary) || attr(node, :validation_errors),
      "submit_interaction" => has_event?(node, :submit)
    }
  end

  defp semantic_observations(:repeated_collection, node) do
    %{
      "source" => attr(node, :rows),
      "template" => node.children,
      "row_scope" => attr(node, :item_alias) && attr(node, :index_alias),
      "empty_state" => has_attr?(node, :empty_state),
      "row_identity" => Enum.map(attr(node, :rows) || [], & &1.key)
    }
  end

  defp attr(node, key), do: get_in(node, [:attributes, key])
  defp metadata(node, key), do: get_in(node, [:metadata, key])
  defp has_attr?(node, key), do: Map.has_key?(Map.get(node, :attributes, %{}), key)
  defp has_state?(node, key), do: Map.has_key?(Map.get(node, :state, %{}), key)
  defp has_event?(node, event), do: event in List.wrap(Map.get(node, :events, []))

  defp present?(nil), do: false
  defp present?(false), do: true
  defp present?([]), do: false
  defp present?(_value), do: true

  defp find_widget(%TerminalUi.Widget{id: id} = widget, id), do: widget

  defp find_widget(%TerminalUi.Widget{} = widget, id) do
    Enum.find_value(widget.children, &find_widget(&1, id))
  end

  defp find_widget(nil, _id), do: nil
end
