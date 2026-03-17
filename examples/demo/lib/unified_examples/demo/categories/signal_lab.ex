defmodule UnifiedExamples.Demo.Categories.SignalLab do
  @moduledoc """
  Authored signal-lab fragment for the aggregate demo.
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
      source_label: "Toggle control",
      outcome_label: "Visibility or enabled-state target",
      summary_label: "Latest interaction summary",
      summary:
        "A toggle should emit canonical change meaning and clearly change whether another target feels available, visible, or emphasized."
    }
  ]

  @story_registry_by_id Map.new(@story_registry, &{&1.id, &1})
  @required_story_families %{
    action_to_feedback: :click,
    input_to_preview: :change,
    selection_to_filter: :selection,
    toggle_to_visibility_or_enabled_state: :change
  }

  @story_surface_registry %{
    action_to_feedback: %{
      source_region_id: :signal_lab_action_to_feedback_source_region,
      outcome_region_id: :signal_lab_action_to_feedback_outcome_region,
      summary_id: :signal_lab_action_feedback_latest_summary,
      detail_id: :signal_lab_action_feedback_latest_detail
    },
    input_to_preview: %{
      source_region_id: :signal_lab_input_to_preview_source_region,
      outcome_region_id: :signal_lab_input_to_preview_outcome_region,
      summary_id: :signal_lab_input_latest_summary,
      detail_id: :signal_lab_input_latest_detail
    },
    selection_to_filter: %{
      source_region_id: :signal_lab_selection_to_filter_source_region,
      outcome_region_id: :signal_lab_selection_to_filter_outcome_region,
      summary_id: :signal_lab_selection_latest_summary,
      detail_id: :signal_lab_selection_latest_detail
    },
    toggle_to_visibility_or_enabled_state: %{
      source_region_id: :signal_lab_toggle_source_region,
      outcome_region_id: :signal_lab_toggle_outcome_region,
      summary_id: :signal_lab_toggle_latest_summary,
      detail_id: :signal_lab_toggle_latest_detail
    }
  }

  @action_to_feedback_summary Map.fetch!(@story_registry_by_id, :action_to_feedback).summary
  @input_to_preview_summary Map.fetch!(@story_registry_by_id, :input_to_preview).summary
  @selection_to_filter_summary Map.fetch!(@story_registry_by_id, :selection_to_filter).summary

  @toggle_summary Map.fetch!(
                    @story_registry_by_id,
                    :toggle_to_visibility_or_enabled_state
                  ).summary

  @selection_options [
    all: "All linked examples",
    interactive: "Interactive",
    operational: "Operational"
  ]

  @selection_items [
    [
      id: :button,
      label: "Button",
      description: "Primary action and feedback trigger",
      selected?: true
    ],
    [
      id: :text_input,
      label: "Text Input",
      description: "Draft preview source control"
    ],
    [
      id: :select,
      label: "Select",
      description: "Selection-driven filter story"
    ],
    [
      id: :toggle,
      label: "Toggle",
      description: "Availability and emphasis gate"
    ]
  ]

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

  @spec required_story_families() :: %{atom() => atom()}
  def required_story_families, do: @required_story_families

  @spec story_surface_registry() :: %{atom() => map()}
  def story_surface_registry, do: @story_surface_registry

  @spec story_contract_summary() :: map()
  def story_contract_summary do
    case validate_story_contract() do
      :ok ->
        %{
          valid?: true,
          story_count: length(@story_registry),
          surface_count: map_size(@story_surface_registry),
          errors: []
        }

      {:error, errors} ->
        %{
          valid?: false,
          story_count: length(@story_registry),
          surface_count: map_size(@story_surface_registry),
          errors: errors
        }
    end
  end

  @spec validate_story_contract([map()], %{optional(atom()) => map()}) ::
          :ok | {:error, [String.t()]}
  def validate_story_contract(stories \\ @story_registry, surfaces \\ @story_surface_registry)
      when is_list(stories) and is_map(surfaces) do
    errors =
      []
      |> validate_required_story_ids(stories)
      |> validate_story_definitions(stories)
      |> validate_story_surfaces(stories, surfaces)
      |> Enum.reverse()

    if errors == [], do: :ok, else: {:error, errors}
  end

  @spec validate_story_contract!([map()], %{optional(atom()) => map()}) :: :ok
  def validate_story_contract!(stories \\ @story_registry, surfaces \\ @story_surface_registry) do
    case validate_story_contract(stories, surfaces) do
      :ok ->
        :ok

      {:error, errors} ->
        raise ArgumentError,
              "signal lab story contract invalid: #{Enum.join(errors, "; ")}"
    end
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

  signals do
    namespace(:examples_demo)

    data_binding do
      id(:signal_lab_draft_note)
      path([:signal_lab, :draft_note])
      scope([:fragment])
      default("")
    end

    data_binding do
      id(:signal_lab_selected_filter)
      path([:signal_lab, :selected_filter])
      scope([:fragment])
      default(:all)
    end

    data_binding do
      id(:signal_lab_toggle_enabled)
      path([:signal_lab, :toggle_enabled])
      scope([:fragment])
      default(false)
    end

    interaction do
      id(:signal_lab_action_click)
      family(:click)
      intent(:action_to_feedback)
      source_context(element_id: :signal_lab_action_trigger, scope: :fragment)
      target_intent(panel: :action_to_feedback, action: :update_feedback)
      payload_mapping(story: :action_to_feedback, result: :acknowledged, source: :signal_lab)
      summary("Update the feedback panel from the action story.")
    end

    interaction do
      id(:signal_lab_input_change)
      family(:change)
      intent(:input_to_preview)
      source_context(element_id: :signal_lab_input_source_input, scope: :fragment)
      target_intent(binding: :signal_lab_draft_note, panel: :input_to_preview)

      payload_mapping(
        note: binding_ref(:signal_lab_draft_note),
        story: :input_to_preview,
        source: :signal_lab
      )

      binding_refs([:signal_lab_draft_note])
      summary("Mirror the latest draft value into the preview story.")
    end

    interaction do
      id(:signal_lab_selection_change)
      family(:selection)
      intent(:selection_to_filter)
      source_context(element_id: :signal_lab_selection_source_select, scope: :fragment)
      target_intent(binding: :signal_lab_selected_filter, panel: :selection_to_filter)

      payload_mapping(
        filter: binding_ref(:signal_lab_selected_filter),
        story: :selection_to_filter,
        source: :signal_lab
      )

      binding_refs([:signal_lab_selected_filter])
      summary("Filter the linked example list from the selection story.")
    end

    interaction do
      id(:signal_lab_toggle_change)
      family(:change)
      intent(:toggle_to_visibility_or_enabled_state)
      source_context(element_id: :signal_lab_toggle_source_control, scope: :fragment)

      target_intent(
        binding: :signal_lab_toggle_enabled,
        panel: :toggle_to_visibility_or_enabled_state
      )

      payload_mapping(
        enabled: binding_ref(:signal_lab_toggle_enabled),
        story: :toggle_to_visibility_or_enabled_state,
        source: :signal_lab
      )

      binding_refs([:signal_lab_toggle_enabled])
      summary("Toggle the target control availability from the signal story.")
    end
  end

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
          "Review four required interaction stories that move from authored DSL signals to visible cross-control outcomes inside the aggregate demo."
        )

        theme_ref(@default_theme_id)
        style_refs([:example_summary])
        tone(:muted)
        variant(:body)
      end

      text :signal_lab_note do
        value(
          "Each story keeps one source control region, one outcome region, and one latest-interaction summary so the runtime meaning stays readable."
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

          button :signal_lab_action_trigger do
            label("Acknowledge signal")
            interaction_refs([:signal_lab_action_click])
            theme_ref(@default_theme_id)
            style_refs([:example_primary_button])
            tone(:accent)
            variant(:solid)
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

          status :signal_lab_action_feedback_status do
            value("Waiting for action signal.")
            severity(:warning)
            status(:idle)
            theme_ref(@default_theme_id)
            tone(:surface)
            variant(:quiet)
          end

          text :signal_lab_action_feedback_note do
            value("Trigger the action control to acknowledge this story visibly.")
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

          text :signal_lab_action_feedback_latest_summary do
            value("No click signal captured yet.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end

          text :signal_lab_action_feedback_latest_detail do
            value("Expected: canonical click meaning should update the feedback surface.")
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

          text_input :signal_lab_input_source_input do
            placeholder("Type a demo note")
            value_path([:signal_lab, :draft_note])
            default_value("")
            interaction_refs([:signal_lab_input_change])
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:filled)
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

          text :signal_lab_input_preview_value do
            value("Start typing to update the preview.")
            theme_ref(@default_theme_id)
            style_refs([:example_summary])
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

          text :signal_lab_input_latest_summary do
            value("No change signal captured yet.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end

          text :signal_lab_input_latest_detail do
            value("Expected: canonical change meaning should mirror the latest draft value.")
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

          select :signal_lab_selection_source_select do
            options(@selection_options)
            value_path([:signal_lab, :selected_filter])
            default_value(:all)
            interaction_refs([:signal_lab_selection_change])
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:filled)
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

          text :signal_lab_selection_filter_label do
            value("Showing all linked examples.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end

          list :signal_lab_selection_filtered_list do
            items(@selection_items)
            selection_mode(:single)
            theme_ref(@default_theme_id)
            tone(:surface)
            variant(:quiet)
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

          text :signal_lab_selection_latest_summary do
            value("No selection signal captured yet.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end

          text :signal_lab_selection_latest_detail do
            value("Expected: canonical selection meaning should filter the linked example list.")
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
          value(@toggle_summary)
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

          toggle :signal_lab_toggle_source_control do
            value_path([:signal_lab, :toggle_enabled])
            default_value(false)
            interaction_refs([:signal_lab_toggle_change])
            theme_ref(@default_theme_id)
            style_refs([:example_primary_input])
            tone(:surface)
            variant(:filled)
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

          button :signal_lab_toggle_target_button do
            label("Protected follow-up action")
            disabled?(true)
            theme_ref(@default_theme_id)
            style_refs([:example_primary_button])
            tone(:accent)
            variant(:solid)
          end

          text :signal_lab_toggle_target_note do
            value("Toggle the source control to enable this follow-up action.")
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

          text :signal_lab_toggle_latest_summary do
            value("No toggle signal captured yet.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end

          text :signal_lab_toggle_latest_detail do
            value("Expected: canonical toggle meaning should enable the follow-up action.")
            theme_ref(@default_theme_id)
            style_refs([:example_notes])
            tone(:muted)
            variant(:body)
          end
        end
      end
    end
  end

  defp validate_required_story_ids(errors, stories) do
    story_ids = Enum.map(stories, & &1.id)

    Enum.reduce(Map.keys(@required_story_families), errors, fn story_id, acc ->
      if story_id in story_ids do
        acc
      else
        ["missing required story #{story_id}" | acc]
      end
    end)
  end

  defp validate_story_definitions(errors, stories) do
    Enum.reduce(stories, errors, fn story, acc ->
      acc
      |> maybe_add_blank_error(story.id, :label, story[:label])
      |> maybe_add_blank_error(story.id, :source_label, story[:source_label])
      |> maybe_add_blank_error(story.id, :outcome_label, story[:outcome_label])
      |> maybe_add_blank_error(story.id, :summary_label, story[:summary_label])
      |> maybe_add_blank_error(story.id, :summary, story[:summary])
      |> maybe_add_family_drift_error(story)
    end)
  end

  defp validate_story_surfaces(errors, stories, surfaces) do
    Enum.reduce(stories, errors, fn story, acc ->
      case Map.get(surfaces, story.id) do
        nil ->
          ["missing surface registry for #{story.id}" | acc]

        surface ->
          acc
          |> maybe_add_missing_surface_error(
            story.id,
            :source_region_id,
            surface[:source_region_id]
          )
          |> maybe_add_missing_surface_error(
            story.id,
            :outcome_region_id,
            surface[:outcome_region_id]
          )
          |> maybe_add_missing_surface_error(story.id, :summary_id, surface[:summary_id])
          |> maybe_add_missing_surface_error(story.id, :detail_id, surface[:detail_id])
      end
    end)
  end

  defp maybe_add_blank_error(errors, story_id, field, value) when value in [nil, ""] do
    ["story #{story_id} is missing #{field}" | errors]
  end

  defp maybe_add_blank_error(errors, _story_id, _field, _value), do: errors

  defp maybe_add_family_drift_error(errors, %{id: story_id, family: family}) do
    case Map.get(@required_story_families, story_id) do
      ^family -> errors
      expected -> ["story #{story_id} must use family #{expected}, got #{family}" | errors]
    end
  end

  defp maybe_add_missing_surface_error(errors, _story_id, _key, value)
       when is_atom(value) and not is_nil(value),
       do: errors

  defp maybe_add_missing_surface_error(errors, story_id, key, _value) do
    ["story #{story_id} is missing #{key}" | errors]
  end
end
