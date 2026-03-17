defmodule UnifiedExamples.Demo.SignalLab do
  @moduledoc """
  Runtime-side story state and canonical IUR synchronization for the demo app's
  signal lab.
  """

  alias UnifiedExamples.Demo.Categories.SignalLab, as: SignalLabDefinition
  alias LiveUi.Runtime.State
  alias UnifiedIUR.{Binding, Element, Tree}

  @selection_items %{
    all: [
      [id: :button, label: "Button", description: "Primary action and feedback trigger"],
      [id: :text_input, label: "Text Input", description: "Draft preview source control"],
      [id: :select, label: "Select", description: "Selection-driven filter story"],
      [id: :toggle, label: "Toggle", description: "Availability and emphasis gate"]
    ],
    interactive: [
      [id: :button, label: "Button", description: "Primary action and feedback trigger"],
      [id: :text_input, label: "Text Input", description: "Draft preview source control"]
    ],
    operational: [
      [id: :select, label: "Select", description: "Selection-driven filter story"],
      [id: :toggle, label: "Toggle", description: "Availability and emphasis gate"]
    ]
  }

  @story_by_intent %{
    action_to_feedback: :action_to_feedback,
    input_to_preview: :input_to_preview,
    selection_to_filter: :selection_to_filter,
    toggle_to_visibility_or_enabled_state: :toggle_to_visibility_or_enabled_state
  }

  @spec initial_state() :: map()
  def initial_state do
    %{
      action_to_feedback: %{
        feedback_text: "Waiting for action signal.",
        feedback_severity: :warning,
        feedback_status: :idle,
        feedback_note: "Trigger the action control to acknowledge this story visibly.",
        summary: "No click signal captured yet.",
        detail: "Expected: canonical click meaning should update the feedback surface."
      },
      input_to_preview: %{
        draft_value: "",
        preview_value: "Start typing to update the preview.",
        summary: "No change signal captured yet.",
        detail: "Expected: canonical change meaning should mirror the latest draft value."
      },
      selection_to_filter: %{
        selected_filter: :all,
        items: Map.fetch!(@selection_items, :all),
        filter_label: "Showing all linked examples.",
        summary: "No selection signal captured yet.",
        detail: "Expected: canonical selection meaning should filter the linked example list."
      },
      toggle_to_visibility_or_enabled_state: %{
        enabled?: false,
        target_disabled?: true,
        target_label: "Protected follow-up action",
        target_note: "Toggle the source control to enable this follow-up action.",
        summary: "No toggle signal captured yet.",
        detail: "Expected: canonical toggle meaning should enable the follow-up action."
      }
    }
  end

  @spec bootstrap_runtime_state(State.t()) :: State.t()
  def bootstrap_runtime_state(%State{} = runtime_state) do
    state = initial_state()

    runtime_state
    |> put_runtime_assign(:signal_lab_state, state)
    |> put_runtime_assign(:canonical_interaction_hook, &handle_runtime_translation/2)
    |> sync_runtime_state(state)
  end

  @spec handle_runtime_translation(State.t(), map()) :: State.t()
  def handle_runtime_translation(%State{} = runtime_state, translation)
      when is_map(translation) do
    state =
      runtime_state.assigns
      |> Map.get(:signal_lab_state, initial_state())
      |> apply_translation(translation)

    runtime_state
    |> put_runtime_assign(:signal_lab_state, state)
    |> sync_runtime_state(state)
  end

  @spec apply_translation(map(), map()) :: map()
  def apply_translation(state, translation) when is_map(state) and is_map(translation) do
    case story_id(translation) do
      :action_to_feedback ->
        Map.put(state, :action_to_feedback, action_story_state(translation))

      :input_to_preview ->
        Map.put(state, :input_to_preview, input_story_state(translation))

      :selection_to_filter ->
        Map.put(state, :selection_to_filter, selection_story_state(translation))

      :toggle_to_visibility_or_enabled_state ->
        Map.put(
          state,
          :toggle_to_visibility_or_enabled_state,
          toggle_story_state(translation)
        )

      nil ->
        state
    end
  end

  @spec sync_runtime_state(State.t(), map()) :: State.t()
  def sync_runtime_state(%State{} = runtime_state, state) when is_map(state) do
    updated_iur =
      runtime_state.assigns.iur
      |> sync_action_story(state.action_to_feedback)
      |> sync_input_story(state.input_to_preview)
      |> sync_selection_story(state.selection_to_filter)
      |> sync_toggle_story(state.toggle_to_visibility_or_enabled_state)

    %{runtime_state | assigns: Map.put(runtime_state.assigns, :iur, updated_iur)}
  end

  defp story_id(%{intent: intent}) when is_atom(intent), do: Map.get(@story_by_intent, intent)
  defp story_id(_translation), do: nil

  defp action_story_state(translation) do
    %{
      feedback_text: "Action signal acknowledged.",
      feedback_severity: :success,
      feedback_status: :ready,
      feedback_note: "The feedback panel reacted to the authored click signal.",
      summary: "Action to Feedback reacted to a canonical click signal.",
      detail: canonical_detail(translation)
    }
  end

  defp input_story_state(translation) do
    draft_value =
      fetch_payload_value(
        translation,
        [:note, "signal_lab_input_source_input", :signal_lab_input_source_input],
        ""
      )

    %{
      draft_value: draft_value,
      preview_value:
        if(blank?(draft_value), do: "Start typing to update the preview.", else: draft_value),
      summary: "Input to Preview mirrored the latest canonical change signal.",
      detail: canonical_detail(translation)
    }
  end

  defp selection_story_state(translation) do
    selected_filter =
      translation
      |> fetch_payload_value(
        [:filter, "signal_lab_selection_source_select", :signal_lab_selection_source_select],
        :all
      )
      |> normalize_filter()

    items = Map.fetch!(@selection_items, selected_filter)

    %{
      selected_filter: selected_filter,
      items: items,
      filter_label:
        "Showing #{length(items)} linked examples for #{human_filter_label(selected_filter)}.",
      summary:
        "Selection to Filter narrowed the linked example list from a canonical selection signal.",
      detail: canonical_detail(translation)
    }
  end

  defp toggle_story_state(translation) do
    enabled? =
      translation
      |> fetch_payload_value(
        [:enabled, "signal_lab_toggle_source_control", :signal_lab_toggle_source_control],
        false
      )
      |> normalize_boolean()

    %{
      enabled?: enabled?,
      target_disabled?: not enabled?,
      target_label: if(enabled?, do: "Run enabled follow-up", else: "Protected follow-up action"),
      target_note:
        if(
          enabled?,
          do:
            "The follow-up action is now enabled because the toggle story emitted a canonical change signal.",
          else: "Toggle the source control to enable this follow-up action."
        ),
      summary:
        "Toggle to Visibility / Enabled State updated the target control from a canonical change signal.",
      detail: canonical_detail(translation)
    }
  end

  defp sync_action_story(%Element{} = iur, state) do
    iur
    |> put_status(:signal_lab_action_feedback_status, state)
    |> put_text(:signal_lab_action_feedback_note, state.feedback_note)
    |> put_text(:signal_lab_action_feedback_latest_summary, state.summary)
    |> put_text(:signal_lab_action_feedback_latest_detail, state.detail)
  end

  defp sync_input_story(%Element{} = iur, state) do
    iur
    |> put_binding_value(:signal_lab_input_source_input, state.draft_value)
    |> put_text(:signal_lab_input_preview_value, state.preview_value)
    |> put_text(:signal_lab_input_latest_summary, state.summary)
    |> put_text(:signal_lab_input_latest_detail, state.detail)
  end

  defp sync_selection_story(%Element{} = iur, state) do
    iur
    |> put_binding_value(:signal_lab_selection_source_select, state.selected_filter)
    |> put_selection_options(:signal_lab_selection_source_select, state.selected_filter)
    |> put_text(:signal_lab_selection_filter_label, state.filter_label)
    |> put_list_items(:signal_lab_selection_filtered_list, state.items)
    |> put_text(:signal_lab_selection_latest_summary, state.summary)
    |> put_text(:signal_lab_selection_latest_detail, state.detail)
  end

  defp sync_toggle_story(%Element{} = iur, state) do
    iur
    |> put_binding_value(:signal_lab_toggle_source_control, state.enabled?)
    |> put_button_state(
      :signal_lab_toggle_target_button,
      state.target_label,
      state.target_disabled?
    )
    |> put_text(:signal_lab_toggle_target_note, state.target_note)
    |> put_text(:signal_lab_toggle_latest_summary, state.summary)
    |> put_text(:signal_lab_toggle_latest_detail, state.detail)
  end

  defp put_text(%Element{} = iur, element_id, value) do
    Tree.update(iur, element_id, fn element ->
      put_attr(element, [:content, :text], value)
    end)
  end

  defp put_status(%Element{} = iur, element_id, state) do
    Tree.update(iur, element_id, fn element ->
      element
      |> put_attr([:feedback, :text], state.feedback_text)
      |> put_attr([:feedback, :severity], state.feedback_severity)
      |> put_attr([:feedback, :status], state.feedback_status)
    end)
  end

  defp put_list_items(%Element{} = iur, element_id, items) do
    Tree.update(iur, element_id, fn element ->
      put_attr(element, [:list, :items], items)
    end)
  end

  defp put_button_state(%Element{} = iur, element_id, label, disabled?) do
    Tree.update(iur, element_id, fn element ->
      element
      |> put_attr([:content, :text], label)
      |> put_attr([:state, :disabled?], disabled?)
    end)
  end

  defp put_selection_options(%Element{} = iur, element_id, selected_filter) do
    Tree.update(iur, element_id, fn element ->
      options =
        element
        |> get_in([Access.key(:attributes), :selection, :options])
        |> List.wrap()
        |> Enum.map(fn option ->
          option
          |> Map.new()
          |> Map.put(:selected?, normalize_filter(Map.get(option, :value)) == selected_filter)
        end)

      put_attr(element, [:selection, :options], options)
    end)
  end

  defp put_binding_value(%Element{} = iur, element_id, value) do
    Tree.update(iur, element_id, fn element ->
      bindings = List.wrap(Map.get(element.attributes, :bindings, []))

      updated_bindings =
        case bindings do
          [%Binding{} = binding | rest] ->
            [%{binding | value: value, default: value} | rest]

          [binding | rest] when is_map(binding) ->
            [%{binding | value: value, default: value} | rest]

          [] ->
            []
        end

      %{element | attributes: Map.put(element.attributes, :bindings, updated_bindings)}
    end)
  end

  defp put_attr(%Element{} = element, path, value) when is_list(path) do
    %{element | attributes: put_nested(element.attributes, path, value)}
  end

  defp put_nested(attributes, [key], value), do: Map.put(attributes, key, value)

  defp put_nested(attributes, [key | rest], value) do
    nested =
      attributes
      |> Map.get(key, %{})
      |> Map.new()
      |> put_nested(rest, value)

    Map.put(attributes, key, nested)
  end

  defp canonical_detail(translation) do
    story_id = story_id(translation)
    story = story_metadata(story_id)

    signal_type =
      case Map.get(translation, :signal) do
        %Jido.Signal{type: type} -> type
        _other -> "local_only"
      end

    runtime_event = Map.get(translation, :runtime_event, "canonical_interaction")

    payload_summary = payload_summary(story_id, translation)

    "#{story.label} emitted a #{human_family(story.family)} signal (#{signal_type}) from #{story.source_label} to #{story.outcome_label} via #{runtime_event}. #{payload_summary}"
  end

  defp story_metadata(nil) do
    %{
      label: "Unknown interaction",
      family: :change,
      source_label: "source control",
      outcome_label: "outcome panel"
    }
  end

  defp story_metadata(story_id) when is_atom(story_id) do
    SignalLabDefinition.story!(story_id)
  end

  defp fetch_payload_value(translation, keys, default) when is_list(keys) do
    payload = Map.get(translation, :payload, %{})
    missing = sentinel()

    Enum.reduce_while(keys, default, fn key, _acc ->
      key
      |> payload_candidate(payload, missing)
      |> normalize_payload_value()
      |> case do
        nil -> {:cont, default}
        value -> {:halt, value}
      end
    end)
  end

  defp fetch_payload_value(translation, key, default),
    do: fetch_payload_value(translation, [key], default)

  defp payload_summary(:action_to_feedback, translation) when is_map(translation) do
    result = fetch_payload_value(translation, [:result], :acknowledged)
    "Payload detail: result = #{human_value(result)}."
  end

  defp payload_summary(:input_to_preview, translation) when is_map(translation) do
    note =
      fetch_payload_value(
        translation,
        [:note, "signal_lab_input_source_input", :signal_lab_input_source_input],
        ""
      )

    "Payload detail: note = #{human_value(note)}."
  end

  defp payload_summary(:selection_to_filter, translation) when is_map(translation) do
    filter =
      fetch_payload_value(
        translation,
        [:filter, "signal_lab_selection_source_select", :signal_lab_selection_source_select],
        :all
      )

    "Payload detail: filter = #{human_value(filter)}."
  end

  defp payload_summary(:toggle_to_visibility_or_enabled_state, translation)
       when is_map(translation) do
    enabled =
      fetch_payload_value(
        translation,
        [:enabled, "signal_lab_toggle_source_control", :signal_lab_toggle_source_control],
        false
      )

    "Payload detail: enabled = #{human_value(normalize_boolean(enabled))}."
  end

  defp payload_summary(_story_id, translation) when is_map(translation) do
    payload =
      case Map.get(translation, :signal) do
        %Jido.Signal{data: data} -> Map.new(data)
        _other -> Map.get(translation, :payload, %{})
      end

    payload_summary_from_map(payload)
  end

  defp payload_summary_from_map(payload) when map_size(payload) == 0 do
    "Payload detail: no additional payload fields were captured."
  end

  defp payload_summary_from_map(payload) when is_map(payload) do
    payload
    |> Enum.reject(fn {key, _value} -> key in [:story, :source] end)
    |> Enum.map(&payload_detail/1)
    |> Enum.reject(&is_nil/1)
    |> case do
      [] ->
        "Payload detail: the interaction meaning was carried without extra reviewer-visible fields."

      details ->
        "Payload detail: " <> Enum.join(details, "; ") <> "."
    end
  end

  defp payload_detail({_key, %{kind: :binding_ref}}), do: nil
  defp payload_detail({_key, %{"kind" => :binding_ref}}), do: nil

  defp payload_detail({key, value}) do
    "#{human_key(key)} = #{human_value(value)}"
  end

  defp normalize_filter(value)
       when is_atom(value) and value in [:all, :interactive, :operational],
       do: value

  defp normalize_filter(value) when is_binary(value) do
    value
    |> String.to_existing_atom()
    |> normalize_filter()
  rescue
    ArgumentError -> :all
  end

  defp normalize_filter(_other), do: :all

  defp human_family(value) when is_atom(value), do: value |> Atom.to_string() |> humanize()
  defp human_family(value), do: to_string(value)

  defp human_filter_label(:all), do: "all linked examples"
  defp human_filter_label(:interactive), do: "interactive stories"
  defp human_filter_label(:operational), do: "operational stories"

  defp normalize_boolean(value) when is_boolean(value), do: value
  defp normalize_boolean("true"), do: true
  defp normalize_boolean("false"), do: false
  defp normalize_boolean("on"), do: true
  defp normalize_boolean(1), do: true
  defp normalize_boolean(0), do: false
  defp normalize_boolean(_other), do: false

  defp blank?(value), do: value in [nil, ""]

  defp normalize_payload_value(:__missing_payload_value__), do: nil
  defp normalize_payload_value(%{kind: :binding_ref}), do: nil
  defp normalize_payload_value(%{"kind" => :binding_ref}), do: nil
  defp normalize_payload_value(value), do: value

  defp sentinel, do: :__missing_payload_value__

  defp human_key(value) when is_atom(value), do: value |> Atom.to_string() |> humanize()
  defp human_key(value), do: to_string(value)

  defp human_value(value) when is_atom(value), do: value |> Atom.to_string() |> humanize()
  defp human_value(value) when is_binary(value), do: value
  defp human_value(value) when is_boolean(value), do: to_string(value)
  defp human_value(value), do: inspect(value)

  defp humanize(value) do
    value
    |> String.replace("_", " ")
  end

  defp fetch_existing_atom_value(payload, key, default) do
    key
    |> String.to_existing_atom()
    |> then(&Map.get(payload, &1, default))
  rescue
    ArgumentError -> default
  end

  defp payload_candidate(key, payload, missing) do
    case Map.get(payload, key, missing) do
      ^missing ->
        case key do
          key when is_atom(key) -> Map.get(payload, Atom.to_string(key), missing)
          key when is_binary(key) -> fetch_existing_atom_value(payload, key, missing)
        end

      value ->
        value
    end
  end

  defp put_runtime_assign(%State{} = runtime_state, key, value) do
    %{runtime_state | assigns: Map.put(runtime_state.assigns, key, value)}
  end
end
