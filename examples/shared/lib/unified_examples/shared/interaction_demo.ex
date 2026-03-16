defmodule UnifiedExamples.Shared.InteractionDemo do
  @moduledoc """
  Shared interaction-demonstration contract for the standalone example-app suite.
  """

  @type mode :: :shared_trigger | :custom
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
    family_label = family_label(family)

    %{
      mode: :shared_trigger,
      family: :click,
      source: :shared_trigger,
      widget: widget,
      source_label: "Shared interaction trigger",
      trigger_label: "Inspect #{widget_label} interaction",
      idle_prompt:
        "Use the shared interaction trigger to see how the #{widget_label} example explains its #{family_label} behavior and canonical signal meaning.",
      outcome:
        "The review panel should explain how the #{widget_label} example turns an authored canonical interaction into a browser-visible #{family_label} story.",
      target_surface: "#{widget_label} review panel",
      reviewer_hint:
        "Reviewers should be able to understand the example outcome without opening source files or browser devtools."
    }
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
