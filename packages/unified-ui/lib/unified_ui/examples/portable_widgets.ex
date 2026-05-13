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

      artifact_row :latest_artifact do
        title("artifact.tar")
        artifact(%{id: "artifact-1", kind: :tarball})
        status(:ready)
        timestamp("2026-05-13T10:30:00Z")
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

      chat_composer :review_composer do
        placeholder("Add a review note")
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
end
