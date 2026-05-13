defmodule UnifiedUi.AshUiWidgetPortabilityPhase2LoweringTest do
  use ExUnit.Case, async: true

  alias UnifiedIUR.{Binding, Tree, Validate}
  alias UnifiedUi.Compiler

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

  defmodule PortableLoweringSurface do
    use UnifiedUi.Dsl

    identity do
      id(:portable_lowering_surface)
      authored_ref([:examples, :portable_lowering_surface])
    end

    composition do
      root(:portable_lowering_root)
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

      repeated_collection :artifact_rows do
        collection_source(binding_ref(:artifacts))
        item_alias(:artifact)
        index_alias(:row)
        key_path([:id])
        empty_state("No artifacts")

        row_template :artifact_row_template do
          gap(:sm)

          template_children([
            %{
              kind: :artifact_row,
              id: :artifact_record,
              title: "Artifact",
              artifact: row_value([:record], alias: :artifact),
              status: :ready
            },
            %{
              kind: :list_item_multi_column,
              id: :artifact_summary,
              label: "Artifact",
              columns: row_value([:columns], alias: :artifact),
              value: row_index(alias: :row),
              status: :ready
            }
          ])
        end
      end
    end
  end

  test "lowers promoted widgets, host form shell, and repeated collection into canonical IUR" do
    result = Compiler.compile!(PortableLoweringSurface)
    elements = Tree.depth_first(result.iur)
    kinds = Enum.map(elements, & &1.kind)

    assert Enum.all?(@semantic_kinds, &(&1 in kinds))
    assert Enum.all?(@workflow_kinds, &(&1 in kinds))
    assert :host_form_shell in kinds
    assert :repeated_collection in kinds
    assert :ok = Validate.element(result.iur)
  end

  test "preserves portable host form and row-scope collection semantics" do
    result = Compiler.compile!(PortableLoweringSurface)

    host_shell = Tree.find_by_id(result.iur, :profile_shell)
    collection = Tree.find_by_id(result.iur, :artifact_rows)
    artifact_summary = Tree.find_by_id(result.iur, :artifact_summary)

    assert host_shell.attributes.form_shell == %{
             owner: :host,
             lifecycle: :host_owned,
             action_placement: :footer
           }

    refute inspect(host_shell) =~ "Phoenix"
    refute inspect(host_shell) =~ "AshPhoenix"

    assert %Binding{
             name: :artifacts,
             path: [:artifacts],
             source: :binding_ref,
             collection?: true
           } = collection.attributes.collection.source

    assert collection.attributes.collection.item_alias == :artifact
    assert collection.attributes.collection.index_alias == :row
    assert collection.attributes.collection.key_path == [:id]

    assert %Binding{source: :row_scope, scope: [:artifact], path: [:columns]} =
             artifact_summary.attributes.list_item.columns

    assert %Binding{source: :row_scope, scope: [:row], path: []} =
             artifact_summary.attributes.list_item.value
  end

  test "lowered canonical output remains deterministic" do
    left = Compiler.compile!(PortableLoweringSurface).iur
    right = Compiler.compile!(PortableLoweringSurface).iur

    assert UnifiedIUR.Reference.snapshot(left) == UnifiedIUR.Reference.snapshot(right)
  end
end
