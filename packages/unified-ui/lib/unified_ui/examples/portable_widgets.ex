defmodule UnifiedUi.Examples.PortableWidgets do
  @moduledoc """
  Reference surface for portable promoted widgets and repeated collection authoring.
  """

  use UnifiedUi.Dsl

  identity do
    id(:portable_widgets)
    title("Portable Widgets")
    authored_ref([:examples, :portable_widgets])
    tags([:example, :portable_widgets, :ash_ui_portability])
  end

  composition do
    root(:portable_widgets_root)
    mode(:screen)

    column :portable_shell do
      summary("Portable widget shell")

      sticky_header :artifact_header do
        title("Artifacts")
        stuck?(true)
        elevation(:raised)
      end

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

      list_item_multi_column :artifact_summary_card do
        label("Build artifact")
        columns(name: "artifact.tar", status: "ready", size: "42 KB")
        status(:ready)
      end

      artifact_row :latest_artifact do
        title("artifact.tar")
        artifact(%{id: "artifact-1", kind: :tarball})
        status(:ready)
        timestamp("2026-05-13T10:30:00Z")
        action_intent(:review_artifact)
      end

      pipeline_stepper_horizontal :release_pipeline do
        steps([:queued, :building, :reviewing, :deployed])
        active_item(:reviewing)
        status(:running)
      end

      segmented_progress_bar :release_progress do
        segments(queued: 15, building: 35, reviewing: 40, deployed: 10)
        current(90)
        maximum(100)
      end

      workflow_stage_list_vertical :release_stages do
        stages([:plan, :build, :review, :deploy])
        active_item(:review)
        status(:running)
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
        title("Build event")
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
        label("Release hook")
        wrap?(true)
      end

      chat_composer :review_composer do
        placeholder("Add a review note")
        submit_intent(:send_review)
        actions(send: "Send")
      end

      host_form_shell :host_review_shell do
        owner(:host)
        lifecycle(:host_owned)
        validation_summary("Host validates review metadata")
        action_placement(:footer)

        form_field :review_title do
          field_name(:review_title)
          label("Review title")

          text_input :review_title_input do
            placeholder("Release review")
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
              kind: :button,
              id: :artifact_review_action,
              label: "Review artifact",
              action_intent: :review_artifact,
              action_payload: %{
                artifact_id: row_payload([:id], alias: :artifact),
                artifact: row_payload([:record], alias: :artifact),
                row_index: row_payload([], alias: :row)
              }
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

      repeated_collection :workflow_rows do
        collection_source(binding_ref(:workflow_rows))
        item_alias(:workflow)
        index_alias(:workflow_row)
        key_path([:id])
        empty_state("No workflow rows")

        row_template :workflow_row_template do
          gap(:sm)

          template_children([
            %{
              kind: :list_item_multi_column,
              id: :workflow_summary,
              label: "Workflow",
              columns: row_value([:columns], alias: :workflow),
              value: row_index(alias: :workflow_row),
              status: :running
            },
            %{
              kind: :pipeline_stepper_horizontal,
              id: :workflow_pipeline,
              steps: [:queued, :building, :reviewing, :deployed],
              active_item: :reviewing,
              status: :running
            },
            %{
              kind: :button,
              id: :workflow_review_action,
              label: "Open workflow",
              action_intent: :open_workflow,
              action_payload: %{
                workflow_id: row_payload([:id], alias: :workflow),
                workflow: row_payload([:record], alias: :workflow),
                row_index: row_payload([], alias: :workflow_row)
              }
            }
          ])
        end
      end
    end
  end
end
