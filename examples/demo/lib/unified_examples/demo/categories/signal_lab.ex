defmodule UnifiedExamples.Demo.Categories.SignalLab do
  @moduledoc """
  Structured signal-lab fragment for the aggregate demo.
  """

  use UnifiedUi.Dsl

  import UnifiedExamples.Shared.Template, only: [shared_theme_definition: 0]

  alias UnifiedExamples.Shared.Template

  @default_theme_id Template.default_theme_id()
  @shared_style_profile Template.default_style_profile()
  @example_directories ["button", "text_input", "select", "toggle"]

  @story_registry [
    %{
      id: :action_to_feedback,
      label: "Action to Feedback",
      family: :click,
      signal_label: "Canonical click intent",
      source_label: "Primary action control",
      outcome_label: "Feedback surface",
      summary_label: "Latest interaction summary",
      summary:
        "A primary authored action should emit a canonical click signal and update a visible feedback surface for reviewers."
    },
    %{
      id: :input_to_preview,
      label: "Input to Preview",
      family: :change,
      signal_label: "Canonical change intent",
      source_label: "Draft input control",
      outcome_label: "Preview surface",
      summary_label: "Latest interaction summary",
      summary:
        "A text-oriented authored input should emit a canonical change signal and update a preview region with the latest draft value."
    },
    %{
      id: :selection_to_filter,
      label: "Selection to Filter",
      family: :selection,
      signal_label: "Canonical selection intent",
      source_label: "Selection control",
      outcome_label: "Filtered target list",
      summary_label: "Latest interaction summary",
      summary:
        "A selection control should emit canonical selection meaning and narrow another content region so the relationship is obvious."
    },
    %{
      id: :toggle_to_visibility_or_enabled_state,
      label: "Toggle to Visibility / Enabled State",
      family: :change,
      signal_label: "Canonical toggle intent",
      source_label: "Toggle control",
      outcome_label: "Visibility or enabled-state target",
      summary_label: "Latest interaction summary",
      summary:
        "A toggle should emit canonical change meaning and clearly change whether another target feels available, visible, or emphasized."
    }
  ]

  @story_registry_by_id Map.new(@story_registry, &{&1.id, &1})
  @action_to_feedback_summary Map.fetch!(@story_registry_by_id, :action_to_feedback).summary
  @input_to_preview_summary Map.fetch!(@story_registry_by_id, :input_to_preview).summary
  @selection_to_filter_summary Map.fetch!(@story_registry_by_id, :selection_to_filter).summary

  @toggle_story_summary Map.fetch!(
                          @story_registry_by_id,
                          :toggle_to_visibility_or_enabled_state
                        ).summary

  @spec default_theme_id() :: atom()
  def default_theme_id, do: @default_theme_id

  @spec shared_style_profile() :: map()
  def shared_style_profile, do: @shared_style_profile

  @spec example_directories() :: [String.t()]
  def example_directories, do: @example_directories

  @spec story_registry() :: [map()]
  def story_registry, do: @story_registry

  @spec story_ids() :: [atom()]
  def story_ids, do: Enum.map(@story_registry, & &1.id)

  @spec story!(atom()) :: map()
  def story!(story_id) when is_atom(story_id) do
    Map.fetch!(@story_registry_by_id, story_id)
  end

  identity do
    id(:signal_lab)
    title("Signal Lab")

    description(
      "Cross-control interaction stories where authored signals visibly change other surfaces."
    )

    authored_ref([:examples, :demo, :categories, :signal_lab])
    tags([:example, :demo, :category_fragment, :signal_lab])
  end

  shared_theme_definition()

  composition do
    root(:signal_lab_category_fragment_root)
    mode(:fragment)
    default_slot(:default)
    summary("Signal lab gallery")

    box :signal_lab_intro do
      theme_ref(@default_theme_id)
      style_refs([:example_panel])
      tone(:surface)
      variant(:panel)

      text :signal_lab_title do
        value("Signal Lab")
        theme_ref(@default_theme_id)
        style_refs([:example_title])
        tone(:accent)
        variant(:headline)
      end

      text :signal_lab_summary do
        value(
          "Review four required interaction stories that will demonstrate authored DSL signals changing other surfaces through the canonical runtime path."
        )

        theme_ref(@default_theme_id)
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end

      text :signal_lab_note do
        value(
          "Each story panel reserves one source-control region, one outcome region, and one latest-interaction summary region so reactive behavior can be added without losing reviewer clarity."
        )

        theme_ref(@default_theme_id)
        style_refs([:example_notes])
        tone(:muted)
        variant(:body)
      end
    end

    grid :signal_lab_story_grid do
      columns(2)
      gap(:md)

      box :signal_lab_action_to_feedback_story do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)
        summary("Action to feedback story panel")

        text :signal_lab_action_to_feedback_title do
          value("Action to Feedback")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :signal_lab_action_to_feedback_summary do
          value(@action_to_feedback_summary)
          theme_ref(@default_theme_id)
          style_refs([:example_summary])
          tone(:muted)
          variant(:body)
        end

        box :signal_lab_action_to_feedback_source_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_action_to_feedback_source_title do
            value("Source control")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_action_to_feedback_source_copy do
            value("Primary action control will render here in the next section.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end

        box :signal_lab_action_to_feedback_outcome_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_action_to_feedback_outcome_title do
            value("Outcome panel")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_action_to_feedback_outcome_copy do
            value("Feedback surface will explain the visible result of the click signal.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end

        box :signal_lab_action_to_feedback_interaction_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_action_to_feedback_interaction_title do
            value("Latest interaction summary")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_action_to_feedback_interaction_copy do
            value("Canonical click meaning will appear here alongside the visible outcome.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end
      end

      box :signal_lab_input_to_preview_story do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)
        summary("Input to preview story panel")

        text :signal_lab_input_to_preview_title do
          value("Input to Preview")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :signal_lab_input_to_preview_summary do
          value(@input_to_preview_summary)
          theme_ref(@default_theme_id)
          style_refs([:example_summary])
          tone(:muted)
          variant(:body)
        end

        box :signal_lab_input_to_preview_source_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_input_to_preview_source_title do
            value("Source control")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_input_to_preview_source_copy do
            value("Draft input control will render here in the next section.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end

        box :signal_lab_input_to_preview_outcome_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_input_to_preview_outcome_title do
            value("Outcome panel")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_input_to_preview_outcome_copy do
            value(
              "Preview content will mirror the latest draft value once change events are wired."
            )

            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end

        box :signal_lab_input_to_preview_interaction_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_input_to_preview_interaction_title do
            value("Latest interaction summary")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_input_to_preview_interaction_copy do
            value(
              "Canonical change meaning will appear here with a reviewer-friendly draft summary."
            )

            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end
      end

      box :signal_lab_selection_to_filter_story do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)
        summary("Selection to filter story panel")

        text :signal_lab_selection_to_filter_title do
          value("Selection to Filter")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :signal_lab_selection_to_filter_summary do
          value(@selection_to_filter_summary)
          theme_ref(@default_theme_id)
          style_refs([:example_summary])
          tone(:muted)
          variant(:body)
        end

        box :signal_lab_selection_to_filter_source_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_selection_to_filter_source_title do
            value("Source control")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_selection_to_filter_source_copy do
            value("Selection control will render here in the next section.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end

        box :signal_lab_selection_to_filter_outcome_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_selection_to_filter_outcome_title do
            value("Outcome panel")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_selection_to_filter_outcome_copy do
            value("Filtered list content will update here when selection meaning is applied.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end

        box :signal_lab_selection_to_filter_interaction_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_selection_to_filter_interaction_title do
            value("Latest interaction summary")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_selection_to_filter_interaction_copy do
            value("Canonical selection meaning will appear here with the chosen filter.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end
      end

      box :signal_lab_toggle_story do
        theme_ref(@default_theme_id)
        style_refs([:example_panel])
        tone(:surface)
        variant(:panel)
        summary("Toggle to visibility or enabled-state story panel")

        text :signal_lab_toggle_title do
          value("Toggle to Visibility / Enabled State")
          theme_ref(@default_theme_id)
          style_refs([:example_title])
          tone(:accent)
          variant(:headline)
        end

        text :signal_lab_toggle_summary do
          value(@toggle_story_summary)
          theme_ref(@default_theme_id)
          style_refs([:example_summary])
          tone(:muted)
          variant(:body)
        end

        box :signal_lab_toggle_source_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_toggle_source_title do
            value("Source control")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_toggle_source_copy do
            value("Toggle control will render here in the next section.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end

        box :signal_lab_toggle_outcome_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_toggle_outcome_title do
            value("Outcome panel")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_toggle_outcome_copy do
            value(
              "A target control will change availability or emphasis here once toggle handling is active."
            )

            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end

        box :signal_lab_toggle_interaction_region do
          theme_ref(@default_theme_id)
          style_refs([:example_panel])
          tone(:surface)
          variant(:panel)

          text :signal_lab_toggle_interaction_title do
            value("Latest interaction summary")
            theme_ref(@default_theme_id)
            style_refs([:example_title])
            tone(:accent)
            variant(:headline)
          end

          text :signal_lab_toggle_interaction_copy do
            value(
              "Canonical toggle meaning will appear here together with the target state change."
            )

            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end
      end
    end
  end
end
