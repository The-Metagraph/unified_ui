defmodule UnifiedUi.PromotedWidgetsAuthoringTest do
  use ExUnit.Case, async: true

  alias Spark.Dsl.Extension

  defmodule PromotedWidgetSurface do
    use UnifiedUi.Dsl

    identity do
      id(:promoted_widget_surface)
      authored_ref([:examples, :promoted_widget_surface])
    end

    composition do
      root(:promoted_widget_root)
      mode(:screen)

      disclosure :release_notes do
        label("Release notes")
        open?(true)
        content_label("Expanded release notes")
      end

      kicker :workflow_kicker do
        value("Workflow")
        icon(:sparkles)
      end

      avatar :assignee_avatar do
        label("Pat Charbon")
        initials("PC")
        status(:online)
      end

      presence_dot :assignee_presence do
        status(:online)
        label("Assignee online")
        pulse?(true)
      end

      segmented_button_group :view_modes do
        items(compact: "Compact", detailed: "Detailed")
        active_item(:compact)
      end

      list_item_multi_column :artifact_item do
        label("Build artifact")
        columns(name: "artifact.tar", status: "ready", size: "42 KB")
        status(:ready)
      end

      artifact_row :build_artifact do
        title("artifact.tar")
        artifact(%{id: "artifact-1", kind: :tarball})
        status(:ready)
        timestamp("2026-05-13T10:30:00Z")
      end

      sticky_header :result_header do
        title("Results")
        stuck?(true)
        elevation(:raised)
      end

      pipeline_stepper_horizontal :deploy_pipeline do
        steps([:queued, :building, :deployed])
        active_item(:building)
        status(:running)
      end

      segmented_progress_bar :deploy_progress do
        segments(queued: 20, building: 55, deployed: 25)
        current(55)
        maximum(100)
      end

      workflow_stage_list_vertical :stage_list do
        stages([:plan, :build, :deploy])
        active_item(:build)
      end

      meter_thin :health_meter do
        current(82)
        maximum(100)
        severity(:success)
      end

      slide_over_panel :details_panel do
        title("Details")
        placement(:end)
        visible?(true)
      end

      event_callout :build_event do
        message("Build completed")
        severity(:success)
        timestamp("2026-05-13T10:35:00Z")
      end

      redline_inline :title_redline do
        before_text("Draft")
        after_text("Ready")
        label("Status change")
      end

      code_block_syntax_highlighted :release_code do
        code("IO.puts(\"ready\")")
        language(:elixir)
        wrap?(true)
      end

      chat_composer :review_composer do
        placeholder("Add a review note")
        submit_intent(:send_review)
        actions(send: "Send")
      end

      host_form_shell :profile_shell do
        owner(:host)
        lifecycle(:host_owned)
        submit_intent(:save_profile)
        validation_summary("Host validates profile changes")
        action_placement(:footer)

        form_field :display_name do
          field_name(:display_name)
          label("Display name")

          text_input :display_name_input do
            placeholder("Pat")
          end
        end
      end
    end
  end

  test "registers promoted widget and host form shell authoring kinds" do
    assert UnifiedUi.Widgets.semantic_kinds() == [
             :disclosure,
             :kicker,
             :avatar,
             :presence_dot,
             :segmented_button_group,
             :list_item_multi_column,
             :artifact_row,
             :sticky_header
           ]

    assert UnifiedUi.Widgets.workflow_kinds() == [
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

    assert UnifiedUi.Forms.kinds() == [
             :form_builder,
             :host_form_shell,
             :field_group,
             :field,
             :form_field
           ]
  end

  test "stores promoted widgets in the authored composition tree" do
    nodes = Extension.get_entities(PromotedWidgetSurface, [:composition])

    assert Enum.map(nodes, &{&1.id, &1.family, &1.kind}) == [
             {:release_notes, :semantic, :disclosure},
             {:workflow_kicker, :semantic, :kicker},
             {:assignee_avatar, :semantic, :avatar},
             {:assignee_presence, :semantic, :presence_dot},
             {:view_modes, :semantic, :segmented_button_group},
             {:artifact_item, :semantic, :list_item_multi_column},
             {:build_artifact, :semantic, :artifact_row},
             {:result_header, :semantic, :sticky_header},
             {:deploy_pipeline, :workflow, :pipeline_stepper_horizontal},
             {:deploy_progress, :workflow, :segmented_progress_bar},
             {:stage_list, :workflow, :workflow_stage_list_vertical},
             {:health_meter, :workflow, :meter_thin},
             {:details_panel, :workflow, :slide_over_panel},
             {:build_event, :workflow, :event_callout},
             {:title_redline, :workflow, :redline_inline},
             {:release_code, :workflow, :code_block_syntax_highlighted},
             {:review_composer, :workflow, :chat_composer},
             {:profile_shell, :forms, :host_form_shell}
           ]
  end

  test "summarizes canonical promoted widget fields without a renderer runtime" do
    summary = UnifiedUi.Info.composition_summary(PromotedWidgetSurface)

    assert Enum.find(summary, &(&1.id == :release_notes)) == %{
             id: :release_notes,
             family: :semantic,
             kind: :disclosure,
             label: "Release notes",
             open?: true,
             content_label: "Expanded release notes"
           }

    assert Enum.find(summary, &(&1.id == :build_artifact)) == %{
             id: :build_artifact,
             family: :semantic,
             kind: :artifact_row,
             title: "artifact.tar",
             artifact: %{id: "artifact-1", kind: :tarball},
             status: :ready,
             timestamp: "2026-05-13T10:30:00Z"
           }

    assert Enum.find(summary, &(&1.id == :release_code)) == %{
             id: :release_code,
             family: :workflow,
             kind: :code_block_syntax_highlighted,
             code: "IO.puts(\"ready\")",
             language: :elixir
           }

    assert Enum.find(summary, &(&1.id == :profile_shell)) == %{
             id: :profile_shell,
             family: :forms,
             kind: :host_form_shell,
             owner: :host,
             lifecycle: :host_owned,
             validation_summary: "Host validates profile changes",
             action_placement: :footer,
             children: [
               %{
                 id: :display_name,
                 family: :forms,
                 kind: :form_field,
                 label: "Display name",
                 children: [
                   %{id: :display_name_input, family: :input, kind: :text_input}
                 ]
               }
             ]
           }
  end

  test "rejects AshUi and Phoenix-specific authoring leakage" do
    assert_compile_dsl_error(
      """
      identity do
        id(:invalid_phoenix_form)
      end

      composition do
        root(:invalid_phoenix_form_root)

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
        id(:invalid_ash_widget_option)
      end

      composition do
        root(:invalid_ash_widget_option_root)

        disclosure :bad_disclosure do
          label("Bad")
          ash_resource(:account)
        end
      end
      """,
      "cannot compile module"
    )
  end

  defp compile_module(body) do
    module_name = "Generated#{System.unique_integer([:positive])}"

    Code.compile_string("""
    defmodule UnifiedUi.PromotedWidgetsAuthoringTest.#{module_name} do
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
