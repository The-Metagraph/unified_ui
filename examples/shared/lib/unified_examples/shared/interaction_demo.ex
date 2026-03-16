defmodule UnifiedExamples.Shared.InteractionDemo do
  @moduledoc """
  Shared interaction-demonstration contract for the standalone example-app suite.
  """

  @type mode :: :shared_trigger | :form_shell | :custom
  @type source :: :shared_trigger | :primary_widget | :form_shell
  @type family ::
          :click
          | :change
          | :submit
          | :selection
          | :navigation
          | :open
          | :close
          | :focus
          | :command

  @type t :: %{
          mode: mode(),
          family: family(),
          source: source(),
          widget: atom(),
          source_label: String.t(),
          trigger_label: String.t() | nil,
          idle_prompt: String.t(),
          outcome: String.t(),
          target_surface: String.t(),
          reviewer_hint: String.t()
        }

  @type entry :: %{directory: String.t(), widget: atom(), family: atom()}

  @family_by_widget %{
    button: :content,
    text: :content,
    label: :content,
    icon: :content,
    image: :content,
    link: :content,
    separator: :content,
    spacer: :content,
    box: :layout,
    content: :layout,
    row: :layout,
    column: :layout,
    grid: :layout,
    form_builder: :forms,
    field: :forms,
    field_group: :forms,
    text_input: :input,
    numeric_input: :input,
    checkbox: :input,
    toggle: :input,
    select: :input,
    pick_list: :input,
    radio_group: :input,
    date_input: :input,
    time_input: :input,
    file_input: :input,
    menu: :navigation,
    tabs: :navigation,
    command_palette: :navigation,
    list: :data,
    table: :data,
    tree_view: :data,
    markdown_viewer: :data,
    log_viewer: :data,
    status: :feedback,
    progress: :feedback,
    gauge: :feedback,
    inline_feedback: :feedback,
    sparkline: :feedback,
    bar_chart: :feedback,
    line_chart: :feedback,
    viewport: :display,
    scroll_bar: :display,
    split_pane: :display,
    canvas: :display,
    overlay: :overlay,
    dialog: :overlay,
    alert_dialog: :overlay,
    context_menu: :overlay,
    toast: :overlay,
    stream_widget: :operational,
    process_monitor: :operational,
    supervision_tree_viewer: :operational,
    cluster_dashboard: :operational
  }

  @spec default_for(entry()) :: t()
  def default_for(%{widget: widget, family: family}) do
    widget_label = widget_label(widget)
    interaction_family = interaction_family_for_widget(widget)
    family_label = family_label(interaction_family)
    default_copy = default_copy(family, widget_label, family_label, interaction_family)

    case mode_for_widget(widget, family) do
      :form_shell ->
        %{
          mode: :form_shell,
          family: interaction_family,
          source: :form_shell,
          widget: widget,
          source_label: "Shared form shell",
          trigger_label: nil,
          idle_prompt: default_copy.form_idle_prompt,
          outcome: default_copy.form_outcome,
          target_surface: "#{widget_label} review panel",
          reviewer_hint:
            "Reviewers should be able to understand the example outcome without opening source files or browser devtools."
        }

      :shared_trigger ->
        %{
          mode: :shared_trigger,
          family: interaction_family,
          source: :shared_trigger,
          widget: widget,
          source_label: "Shared interaction trigger",
          trigger_label: default_copy.trigger_label,
          idle_prompt: default_copy.shared_idle_prompt,
          outcome: default_copy.shared_outcome,
          target_surface: "#{widget_label} review panel",
          reviewer_hint:
            "Reviewers should be able to understand the example outcome without opening source files or browser devtools."
        }
    end
  end

  @spec normalize(map() | nil, entry()) :: t()
  def normalize(nil, entry), do: default_for(entry)

  def normalize(overrides, entry) when is_map(overrides) do
    default_for(entry)
    |> Map.merge(overrides)
    |> Map.put_new(:mode, :shared_trigger)
    |> Map.put_new(:family, :click)
    |> Map.put_new(:source, :shared_trigger)
    |> Map.put(:widget, entry.widget)
  end

  @spec family_for_widget(atom()) :: atom()
  def family_for_widget(widget) when is_atom(widget) do
    Map.fetch!(@family_by_widget, widget)
  end

  @spec interaction_family_for_widget(atom()) :: family()
  def interaction_family_for_widget(widget) when is_atom(widget) do
    case widget do
      widget when widget in [:button, :link] ->
        :click

      widget
      when widget in [:text_input, :numeric_input, :date_input, :time_input, :file_input] ->
        :change

      widget when widget in [:checkbox, :toggle] ->
        :change

      widget when widget in [:select, :pick_list, :radio_group] ->
        :selection

      widget when widget in [:field, :field_group, :form_builder] ->
        :change

      widget when widget in [:menu, :tabs] ->
        :navigation

      :command_palette ->
        :command

      widget when widget in [:list, :table, :tree_view] ->
        :selection

      widget
      when widget in [:markdown_viewer, :log_viewer, :viewport, :scroll_bar, :split_pane, :canvas] ->
        :focus

      widget when widget in [:overlay, :dialog, :alert_dialog, :context_menu, :toast] ->
        :open

      widget
      when widget in [
             :stream_widget,
             :process_monitor,
             :supervision_tree_viewer,
             :cluster_dashboard
           ] ->
        :command

      _other ->
        :click
    end
  end

  defp mode_for_widget(widget, family) do
    cond do
      widget in [:button, :text_input] -> :shared_trigger
      family in [:input, :forms] -> :form_shell
      true -> :shared_trigger
    end
  end

  defp default_copy(_family, widget_label, family_label, :command) do
    %{
      trigger_label: "Review the #{widget_label} command story",
      shared_idle_prompt:
        "Use the shared trigger to see how the #{widget_label} example explains #{family_label} intent and the resulting reviewed command outcome.",
      shared_outcome:
        "The review panel should explain how the #{widget_label} example turns an authored canonical interaction into a browser-visible command story reviewers can follow quickly.",
      form_idle_prompt:
        "Interact with the #{widget_label} example to see how its authored #{family_label} signal updates the command review story.",
      form_outcome:
        "The review panel should explain how the #{widget_label} example turns live interaction into a browser-visible command outcome."
    }
  end

  defp default_copy(:navigation, widget_label, family_label, _interaction_family) do
    %{
      trigger_label: "Review the #{widget_label} navigation story",
      shared_idle_prompt:
        "Use the shared trigger to see how the #{widget_label} example explains #{family_label} changes and active-state meaning.",
      shared_outcome:
        "The review panel should explain how the #{widget_label} example turns an authored canonical interaction into a browser-visible navigation story with clear active-state meaning.",
      form_idle_prompt:
        "Interact with the #{widget_label} example to see how its authored #{family_label} signal updates the current navigation story.",
      form_outcome:
        "The review panel should explain how the #{widget_label} example turns live interaction into a browser-visible navigation outcome."
    }
  end

  defp default_copy(:layout, widget_label, family_label, _interaction_family) do
    %{
      trigger_label: "Review the #{widget_label} layout story",
      shared_idle_prompt:
        "Use the shared trigger to see how the #{widget_label} example explains #{family_label} changes in the surrounding composition.",
      shared_outcome:
        "The review panel should explain how the #{widget_label} example turns an authored canonical interaction into a browser-visible layout story.",
      form_idle_prompt:
        "Interact with the #{widget_label} example to see how its authored #{family_label} signal updates the layout review story.",
      form_outcome:
        "The review panel should explain how the #{widget_label} example turns live interaction into a browser-visible layout outcome."
    }
  end

  defp default_copy(:data, widget_label, family_label, _interaction_family) do
    %{
      trigger_label: "Inspect the #{widget_label} data story",
      shared_idle_prompt:
        "Use the shared trigger to see how the #{widget_label} example explains #{family_label} changes such as focus, filtering, or selection.",
      shared_outcome:
        "The review panel should explain how the #{widget_label} example turns an authored canonical interaction into a browser-visible data story reviewers can understand quickly.",
      form_idle_prompt:
        "Interact with the #{widget_label} example to see how its authored #{family_label} signal updates the reviewed data state.",
      form_outcome:
        "The review panel should explain how the #{widget_label} example turns live interaction into a browser-visible data outcome."
    }
  end

  defp default_copy(:feedback, widget_label, family_label, _interaction_family) do
    %{
      trigger_label: "Inspect the #{widget_label} feedback story",
      shared_idle_prompt:
        "Use the shared trigger to see how the #{widget_label} example explains #{family_label} changes in metric or feedback meaning.",
      shared_outcome:
        "The review panel should explain how the #{widget_label} example turns an authored canonical interaction into a browser-visible feedback story.",
      form_idle_prompt:
        "Interact with the #{widget_label} example to see how its authored #{family_label} signal updates the feedback story.",
      form_outcome:
        "The review panel should explain how the #{widget_label} example turns live interaction into a browser-visible feedback outcome."
    }
  end

  defp default_copy(:display, widget_label, family_label, _interaction_family) do
    %{
      trigger_label: "Inspect the #{widget_label} display story",
      shared_idle_prompt:
        "Use the shared trigger to see how the #{widget_label} example explains #{family_label} changes in movement, focus, or rendering context.",
      shared_outcome:
        "The review panel should explain how the #{widget_label} example turns an authored canonical interaction into a browser-visible display-system story.",
      form_idle_prompt:
        "Interact with the #{widget_label} example to see how its authored #{family_label} signal updates the display review story.",
      form_outcome:
        "The review panel should explain how the #{widget_label} example turns live interaction into a browser-visible display outcome."
    }
  end

  defp default_copy(:overlay, widget_label, family_label, _interaction_family) do
    %{
      trigger_label: "Inspect the #{widget_label} overlay story",
      shared_idle_prompt:
        "Use the shared trigger to see how the #{widget_label} example explains #{family_label} changes in layered or contextual UI.",
      shared_outcome:
        "The review panel should explain how the #{widget_label} example turns an authored canonical interaction into a browser-visible overlay story.",
      form_idle_prompt:
        "Interact with the #{widget_label} example to see how its authored #{family_label} signal updates the overlay review story.",
      form_outcome:
        "The review panel should explain how the #{widget_label} example turns live interaction into a browser-visible overlay outcome."
    }
  end

  defp default_copy(:operational, widget_label, family_label, _interaction_family) do
    %{
      trigger_label: "Inspect the #{widget_label} monitoring story",
      shared_idle_prompt:
        "Use the shared trigger to see how the #{widget_label} example explains #{family_label} changes for inspection, refresh, or focus flows.",
      shared_outcome:
        "The review panel should explain how the #{widget_label} example turns an authored canonical interaction into a browser-visible operational story.",
      form_idle_prompt:
        "Interact with the #{widget_label} example to see how its authored #{family_label} signal updates the operational review story.",
      form_outcome:
        "The review panel should explain how the #{widget_label} example turns live interaction into a browser-visible operational outcome."
    }
  end

  defp default_copy(_family, widget_label, family_label, _interaction_family) do
    %{
      trigger_label: "Inspect #{widget_label} interaction",
      shared_idle_prompt:
        "Use the shared interaction trigger to see how the #{widget_label} example explains its #{family_label} behavior and canonical signal meaning.",
      shared_outcome:
        "The review panel should explain how the #{widget_label} example turns an authored canonical interaction into a browser-visible #{family_label} story.",
      form_idle_prompt:
        "Interact with the #{widget_label} example to see how its authored #{family_label} signal updates the shared review story.",
      form_outcome:
        "The review panel should explain how the #{widget_label} example turns live form input into a browser-visible #{family_label} outcome."
    }
  end

  @spec runtime_status(t(), map() | nil) :: String.t()
  def runtime_status(contract, nil) do
    contract.idle_prompt
  end

  def runtime_status(contract, translation) when is_map(translation) do
    payload_summary =
      translation
      |> Map.get(:signal)
      |> case do
        nil -> nil
        signal -> payload_summary(signal.data || %{})
      end

    base =
      "Captured a #{family_label(Map.get(translation, :family, contract.family))} interaction for the #{widget_label(contract.widget)} example."

    cond do
      payload_summary in [nil, ""] ->
        base <> " " <> contract.outcome

      true ->
        base <> " " <> contract.outcome <> " Latest payload highlight: " <> payload_summary <> "."
    end
  end

  @spec runtime_outcome(t()) :: String.t()
  def runtime_outcome(contract), do: contract.outcome

  @spec widget_label(atom()) :: String.t()
  def widget_label(widget) when is_atom(widget) do
    widget
    |> Atom.to_string()
    |> String.replace("_", " ")
  end

  @spec family_label(atom()) :: String.t()
  def family_label(family) when is_atom(family) do
    family
    |> Atom.to_string()
    |> String.replace("_", " ")
  end

  defp payload_summary(payload) when is_map(payload) do
    payload
    |> Enum.reject(fn {key, _value} ->
      key in [:source, :example, :widget, :phase, "source", "example", "widget", "phase"]
    end)
    |> Enum.map(fn {key, value} -> "#{normalize_key(key)}=#{normalize_value(value)}" end)
    |> Enum.reject(&(&1 == ""))
    |> Enum.take(2)
    |> Enum.join(", ")
  end

  defp normalize_key(key) when is_atom(key), do: Atom.to_string(key)
  defp normalize_key(key) when is_binary(key), do: key
  defp normalize_key(key), do: inspect(key)

  defp normalize_value(value) when is_binary(value), do: value
  defp normalize_value(value) when is_atom(value), do: Atom.to_string(value)
  defp normalize_value(%{name: name}) when is_atom(name), do: Atom.to_string(name)
  defp normalize_value(value), do: inspect(value)
end
