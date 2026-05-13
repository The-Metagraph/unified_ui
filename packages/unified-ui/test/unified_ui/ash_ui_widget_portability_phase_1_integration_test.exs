defmodule UnifiedUi.AshUiWidgetPortabilityPhase1IntegrationTest do
  use ExUnit.Case, async: true

  alias Spark.Dsl.Extension
  alias UnifiedUi.{Export, Info}

  @semantic_kinds [
    :disclosure,
    :kicker,
    :avatar,
    :presence_dot,
    :segmented_button_group,
    :list_item_multi_column,
    :artifact_row,
    :sticky_header
  ]

  @workflow_kinds [
    :pipeline_stepper_horizontal,
    :segmented_progress_bar,
    :workflow_stage_list_vertical,
    :meter_thin,
    :slide_over_panel,
    :event_callout,
    :redline_inline,
    :code_block_syntax_highlighted,
    :chat_composer
  ]

  defmodule Phase1PortableSurface do
    use UnifiedUi.Dsl

    identity do
      id(:ash_ui_widget_portability_phase_1_surface)
      authored_ref([:tests, :ash_ui_widget_portability_phase_1_surface])
    end

    composition do
      root(:ash_ui_widget_portability_phase_1_root)
      mode(:screen)

      disclosure :release_notes do
        label("Release notes")
        open?(true)
      end

      kicker :workflow_kicker do
        value("Workflow")
      end

      avatar :assignee_avatar do
        label("Pat Charbon")
        initials("PC")
      end

      presence_dot :assignee_presence do
        status(:online)
      end

      segmented_button_group :view_modes do
        items(compact: "Compact", detailed: "Detailed")
        active_item(:compact)
      end

      list_item_multi_column :artifact_summary do
        label("Artifact")
        columns(name: "artifact.tar", status: "ready")
      end

      artifact_row :build_artifact do
        title("artifact.tar")
        artifact(%{id: "artifact-1", kind: :archive})
      end

      sticky_header :result_header do
        title("Results")
      end

      pipeline_stepper_horizontal :deploy_pipeline do
        steps([:queued, :building, :deployed])
      end

      segmented_progress_bar :deploy_progress do
        segments(queued: 20, building: 55, deployed: 25)
      end

      workflow_stage_list_vertical :stage_list do
        stages([:plan, :build, :deploy])
      end

      meter_thin :health_meter do
        current(82)
      end

      slide_over_panel :details_panel do
        title("Details")
        visible?(true)
      end

      event_callout :build_event do
        message("Build completed")
      end

      redline_inline :title_redline do
        before_text("Draft")
        after_text("Ready")
      end

      code_block_syntax_highlighted :release_code do
        code("IO.puts(\"ready\")")
      end

      chat_composer :review_composer do
        placeholder("Add a review note")
        submit_intent(:send_review)
      end

      host_form_shell :profile_shell do
        submit_intent(:save_profile)

        form_field :display_name do
          field_name(:display_name)

          text_input :display_name_input do
            placeholder("Pat")
          end
        end
      end
    end
  end

  defmodule Phase1RepeatedCollectionSurface do
    use UnifiedUi.Dsl

    identity do
      id(:ash_ui_widget_portability_phase_1_collection)
      authored_ref([:tests, :ash_ui_widget_portability_phase_1_collection])
    end

    composition do
      root(:ash_ui_widget_portability_phase_1_collection_root)
      mode(:screen)

      repeated_collection :artifact_rows do
        collection_source(binding_ref(:artifacts))
        item_alias(:artifact)
        index_alias(:row)
        key_path([:id])
        empty_state("No artifacts")

        row_template :artifact_row_template do
          template_children([
            %{
              kind: :artifact_row,
              id: :artifact_record,
              title: "Artifact",
              artifact: row_value([:record], alias: :artifact)
            },
            %{
              kind: :list_item_multi_column,
              id: :artifact_summary,
              columns: row_value([:columns], alias: :artifact),
              value: row_index(alias: :row)
            }
          ])
        end
      end
    end
  end

  test "accepts every promoted widget and host-owned form shell in one portable surface" do
    nodes = Extension.get_entities(Phase1PortableSurface, [:composition])
    semantic_kinds = nodes |> Enum.filter(&(&1.family == :semantic)) |> Enum.map(& &1.kind)
    workflow_kinds = nodes |> Enum.filter(&(&1.family == :workflow)) |> Enum.map(& &1.kind)

    assert semantic_kinds == @semantic_kinds
    assert workflow_kinds == @workflow_kinds

    assert Enum.any?(nodes, fn node ->
             node.kind == :host_form_shell and node.owner == :host and
               node.lifecycle == :host_owned
           end)
  end

  test "accepts repeated collections with row-scope data, keys, empty state, and templates" do
    [collection] = Extension.get_entities(Phase1RepeatedCollectionSurface, [:composition])

    assert collection.kind == :repeated_collection
    assert collection.collection_source == %{kind: :binding_ref, id: :artifacts}
    assert collection.item_alias == :artifact
    assert collection.index_alias == :row
    assert collection.key_path == [:id]
    assert collection.empty_state == "No artifacts"
    assert [%{kind: :row, id: :artifact_row_template}] = collection.children

    assert Info.authoring_surface_summary(Phase1RepeatedCollectionSurface).row_scope_refs == [
             %{kind: :row_value, path: [:columns], alias: :artifact},
             %{kind: :row_value, path: [:record], alias: :artifact},
             %{kind: :row_index, alias: :row}
           ]
  end

  test "rejects Ash, Phoenix, and renderer-local leakage at the canonical boundary" do
    assert_compile_dsl_error(
      """
      identity do
        id(:bad_ash_collection)
      end

      composition do
        root(:bad_ash_collection_root)

        repeated_collection :artifact_rows do
          collection_source(%{relationship: :artifacts, ash_resource: :artifact})
          key_path([:id])

          artifact_row :artifact_template do
            title("Artifact")
            artifact(%{id: "artifact"})
          end
        end
      end
      """,
      "must use a portable collection_source"
    )

    assert_compile_dsl_error(
      """
      identity do
        id(:bad_phoenix_form)
      end

      composition do
        root(:bad_phoenix_form_root)

        phoenix_form :profile do
          submit_intent(:save)
        end
      end
      """,
      "cannot compile module"
    )

    assert_compile_dsl_error(
      """
      identity do
        id(:bad_renderer_field)
      end

      composition do
        root(:bad_renderer_field_root)

        artifact_row :artifact_template do
          title("Artifact")
          artifact(%{id: "artifact"})
          phx_click("open")
        end
      end
      """,
      "cannot compile module"
    )
  end

  test "keeps Phase 1 inspection and export output deterministic" do
    assert {:ok, first_inspection} = Export.module(Phase1RepeatedCollectionSurface, :inspection)
    assert {:ok, second_inspection} = Export.module(Phase1RepeatedCollectionSurface, :inspection)
    assert first_inspection == second_inspection
    assert first_inspection =~ "repeated collections:"
    assert first_inspection =~ "row-scope refs:"

    assert {:ok, first_authoring} = Export.module(Phase1RepeatedCollectionSurface, :authoring)
    assert {:ok, second_authoring} = Export.module(Phase1RepeatedCollectionSurface, :authoring)
    assert first_authoring == second_authoring
    assert first_authoring =~ "collection_source"
    assert first_authoring =~ "key_path: [:id]"
  end

  defp compile_module(body) do
    module_name = "Generated#{System.unique_integer([:positive])}"

    Code.compile_string("""
    defmodule UnifiedUi.AshUiWidgetPortabilityPhase1IntegrationTest.#{module_name} do
      use UnifiedUi.Dsl

      #{body}
    end
    """)
  end

  defp assert_compile_dsl_error(body, expected_message) do
    {pid, ref} = spawn_monitor(fn -> compile_module(body) end)

    receive do
      {:DOWN, ^ref, :process, ^pid, :normal} ->
        flunk("expected authored module compilation to fail, but it succeeded")

      {:DOWN, ^ref, :process, ^pid, reason} ->
        assert Exception.format_exit(reason) =~ expected_message
    end
  end
end
