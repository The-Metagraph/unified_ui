defmodule ElmUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for the native `elm_ui` widget surface.
  """

  alias ElmUi.Widget
  alias ElmUi.Widgets.{Components, Data, Feedback, Forms, Foundational, Input, Layered, Layout}
  alias ElmUi.Widgets.Navigation
  alias ElmUi.Widgets.{Operational, Visualization}

  @type family :: Widget.family()

  @spec families() :: [family()]
  def families do
    kinds()
    |> Enum.map(&family_for_kind/1)
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end

  @spec modules() :: [module()]
  def modules do
    [
      Widget,
      Foundational,
      Input,
      Navigation,
      Layout,
      Layered,
      Forms,
      Data,
      Feedback,
      Visualization,
      Operational,
      Components
    ]
  end

  @spec kinds() :: [atom()]
  def kinds do
    [
      Foundational.kinds(),
      Input.kinds(),
      Navigation.kinds(),
      Layout.kinds(),
      Layered.kinds(),
      Forms.kinds(),
      Data.kinds(),
      Feedback.kinds(),
      Visualization.kinds(),
      Operational.kinds(),
      Components.kinds()
    ]
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end

  @spec family_for_kind(atom() | String.t()) :: family()
  def family_for_kind(kind) when is_binary(kind),
    do: kind |> String.to_atom() |> family_for_kind()

  def family_for_kind(kind), do: Widget.family_for(kind)

  @spec validation_state() :: map()
  def validation_state do
    %{
      widget_definition: :ready,
      family_catalog: :ready,
      metadata_contract: :ready,
      foundational_widgets: :ready,
      input_widgets: :ready,
      navigation_widgets: :ready,
      form_composition: :ready,
      layout_primitives: :ready,
      advanced_data_widgets: :ready,
      advanced_document_widgets: :ready,
      advanced_feedback_widgets: :ready,
      advanced_visualization_widgets: :ready,
      advanced_operational_widgets: :ready,
      display_system_widgets: :ready,
      layered_composition_widgets: :ready,
      layered_runtime_diagnostics: :ready,
      widget_components: :ready
    }
  end

  @spec widget(atom() | String.t(), keyword() | map()) :: Widget.t()
  def widget(kind, attrs \\ [])
  def widget(kind, attrs) when is_binary(kind), do: widget(String.to_atom(kind), attrs)
  def widget(kind, attrs), do: Widget.new(kind, attrs)

  @spec normalize(Widget.t() | map() | keyword()) :: {:ok, Widget.t()} | {:error, term()}
  def normalize(%Widget{} = widget), do: {:ok, widget}

  def normalize(attrs) when is_map(attrs) or is_list(attrs) do
    attrs = normalize_map(attrs)

    case {Map.fetch(attrs, :kind), Map.fetch(attrs, :id)} do
      {{:ok, kind}, {:ok, _id}} ->
        {:ok, Widget.new(kind, attrs)}

      _other ->
        {:error, :invalid_widget}
    end
  end

  @spec normalize_many([Widget.t() | map() | keyword()]) :: {:ok, [Widget.t()]} | {:error, term()}
  def normalize_many(widgets) when is_list(widgets) do
    widgets
    |> Enum.reduce_while({:ok, []}, fn widget, {:ok, acc} ->
      case normalize(widget) do
        {:ok, normalized} -> {:cont, {:ok, [normalized | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, normalized} -> {:ok, Enum.reverse(normalized)}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec text(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def text(id, content, opts \\ []) do
    Foundational.text(id, content, opts)
  end

  @spec label(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def label(id, content, opts \\ []) do
    Foundational.label(id, content, opts)
  end

  @spec icon(String.t() | atom(), atom() | String.t(), keyword()) :: Widget.t()
  def icon(id, name, opts \\ []) do
    Foundational.icon(id, name, opts)
  end

  @spec image(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def image(id, src, opts \\ []) do
    Foundational.image(id, src, opts)
  end

  @spec button(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def button(id, label, opts \\ []) do
    Foundational.button(id, label, opts)
  end

  @spec badge(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def badge(id, label, opts \\ []) do
    Foundational.badge(id, label, opts)
  end

  @spec hero(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) :: Widget.t()
  def hero(id, children, opts \\ []) do
    Foundational.hero(id, children, opts)
  end

  @spec link(String.t() | atom(), String.t(), String.t(), keyword()) :: Widget.t()
  def link(id, label, href, opts \\ []) do
    Foundational.link(id, label, href, opts)
  end

  @spec separator(String.t() | atom(), keyword()) :: Widget.t()
  def separator(id, opts \\ []) do
    Foundational.separator(id, opts)
  end

  @spec spacer(String.t() | atom(), keyword()) :: Widget.t()
  def spacer(id, opts \\ []) do
    Foundational.spacer(id, opts)
  end

  @spec content(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) :: Widget.t()
  def content(id, children, opts \\ []) do
    Foundational.content(id, children, opts)
  end

  @spec text_input(String.t() | atom(), keyword()) :: Widget.t()
  def text_input(id, opts \\ []) do
    Input.text_input(id, opts)
  end

  @spec numeric_input(String.t() | atom(), keyword()) :: Widget.t()
  def numeric_input(id, opts \\ []) do
    Input.numeric_input(id, opts)
  end

  @spec date_input(String.t() | atom(), keyword()) :: Widget.t()
  def date_input(id, opts \\ []) do
    Input.date_input(id, opts)
  end

  @spec time_input(String.t() | atom(), keyword()) :: Widget.t()
  def time_input(id, opts \\ []) do
    Input.time_input(id, opts)
  end

  @spec file_input(String.t() | atom(), keyword()) :: Widget.t()
  def file_input(id, opts \\ []) do
    Input.file_input(id, opts)
  end

  @spec slider(String.t() | atom(), keyword()) :: Widget.t()
  def slider(id, opts \\ []) do
    Input.slider(id, opts)
  end

  @spec toggle(String.t() | atom(), keyword()) :: Widget.t()
  def toggle(id, opts \\ []) do
    Input.toggle(id, opts)
  end

  @spec checkbox(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def checkbox(id, label, opts \\ []) do
    Input.checkbox(id, label, opts)
  end

  @spec radio_group(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def radio_group(id, options, opts \\ []) do
    Input.radio_group(id, options, opts)
  end

  @spec select(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def select(id, options, opts \\ []) do
    Input.select(id, options, opts)
  end

  @spec pick_list(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def pick_list(id, options, opts \\ []) do
    Input.pick_list(id, options, opts)
  end

  @spec field(String.t() | atom(), Widget.t() | map() | keyword(), keyword()) :: Widget.t()
  def field(id, control, opts \\ []) do
    Forms.field(id, control, opts)
  end

  @spec field_group(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def field_group(id, children, opts \\ []) do
    Forms.field_group(id, children, opts)
  end

  @spec form(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) :: Widget.t()
  def form(id, children, opts \\ []) do
    Forms.form(id, children, opts)
  end

  @spec form_builder(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def form_builder(id, children, opts \\ []) do
    Forms.form_builder(id, children, opts)
  end

  @spec form_field(String.t() | atom(), Widget.t() | map() | keyword(), keyword()) :: Widget.t()
  def form_field(id, control, opts \\ []) do
    Forms.form_field(id, control, opts)
  end

  @spec stack(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def stack(id, children, opts \\ []) do
    Layout.stack(id, children, opts)
  end

  @spec panel(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def panel(id, title, children, opts \\ []) do
    Layout.panel(id, title, children, opts)
  end

  @spec row(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) :: Widget.t()
  def row(id, children, opts \\ []) do
    Layout.row(id, children, opts)
  end

  @spec column(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) :: Widget.t()
  def column(id, children, opts \\ []) do
    Layout.column(id, children, opts)
  end

  @spec grid(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) :: Widget.t()
  def grid(id, children, opts \\ []) do
    Layout.grid(id, children, opts)
  end

  @spec viewport(String.t() | atom(), Widget.t() | map() | keyword(), keyword()) :: Widget.t()
  def viewport(id, content, opts \\ []) do
    Layout.viewport(id, content, opts)
  end

  @spec scroll_bar(String.t() | atom(), keyword()) :: Widget.t()
  def scroll_bar(id, opts \\ []) do
    Layout.scroll_bar(id, opts)
  end

  @spec split_pane(
          String.t() | atom(),
          Widget.t() | map() | keyword(),
          Widget.t() | map() | keyword(),
          keyword()
        ) :: Widget.t()
  def split_pane(id, primary, secondary, opts \\ []) do
    Layout.split_pane(id, primary, secondary, opts)
  end

  @spec menu(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def menu(id, items, opts \\ []) do
    Navigation.menu(id, items, opts)
  end

  @spec tabs(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def tabs(id, items, opts \\ []) do
    Navigation.tabs(id, items, opts)
  end

  @spec overlay(
          String.t() | atom(),
          Widget.t() | map() | keyword(),
          [Widget.t() | map() | keyword()],
          keyword()
        ) :: Widget.t()
  def overlay(id, base, layers, opts \\ []) do
    Layered.overlay(id, base, layers, opts)
  end

  @spec dialog(String.t() | atom(), Widget.t() | map() | keyword(), keyword()) :: Widget.t()
  def dialog(id, content, opts \\ []) do
    Layered.dialog(id, content, opts)
  end

  @spec toast(String.t() | atom(), Widget.t() | map() | keyword(), keyword()) :: Widget.t()
  def toast(id, content, opts \\ []) do
    Layered.toast(id, content, opts)
  end

  @spec alert_dialog(String.t() | atom(), Widget.t() | map() | keyword(), keyword()) ::
          Widget.t()
  def alert_dialog(id, content, opts \\ []) do
    Layered.alert_dialog(id, content, opts)
  end

  @spec context_menu(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def context_menu(id, items, opts \\ []) do
    Layered.context_menu(id, items, opts)
  end

  @spec table(String.t() | atom(), [keyword() | map()], [keyword() | map()], keyword()) ::
          Widget.t()
  def table(id, columns, rows, opts \\ []) do
    Data.table(id, columns, rows, opts)
  end

  @spec list(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def list(id, items, opts \\ []) do
    Data.list(id, items, opts)
  end

  @spec tree_view(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def tree_view(id, nodes, opts \\ []) do
    Data.tree_view(id, nodes, opts)
  end

  @spec stat(String.t() | atom(), keyword()) :: Widget.t()
  def stat(id, opts \\ []) do
    Data.stat(id, opts)
  end

  @spec key_value(String.t() | atom(), String.t(), term(), keyword()) :: Widget.t()
  def key_value(id, label, value, opts \\ []) do
    Data.key_value(id, label, value, opts)
  end

  @spec info_list(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def info_list(id, items, opts \\ []) do
    Data.info_list(id, items, opts)
  end

  @spec markdown_viewer(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def markdown_viewer(id, markdown, opts \\ []) do
    Data.markdown_viewer(id, markdown, opts)
  end

  @spec log_viewer(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def log_viewer(id, entries, opts \\ []) do
    Data.log_viewer(id, entries, opts)
  end

  @spec status(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def status(id, text, opts \\ []) do
    Feedback.status(id, text, opts)
  end

  @spec progress(String.t() | atom(), keyword()) :: Widget.t()
  def progress(id, opts \\ []) do
    Feedback.progress(id, opts)
  end

  @spec inline_feedback(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def inline_feedback(id, message, opts \\ []) do
    Feedback.inline_feedback(id, message, opts)
  end

  @spec gauge(String.t() | atom(), keyword()) :: Widget.t()
  def gauge(id, opts \\ []) do
    Visualization.gauge(id, opts)
  end

  @spec sparkline(String.t() | atom(), [number()], keyword()) :: Widget.t()
  def sparkline(id, series, opts \\ []) do
    Visualization.sparkline(id, series, opts)
  end

  @spec bar_chart(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def bar_chart(id, series, opts \\ []) do
    Visualization.bar_chart(id, series, opts)
  end

  @spec line_chart(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def line_chart(id, series, opts \\ []) do
    Visualization.line_chart(id, series, opts)
  end

  @spec canvas(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def canvas(id, operations, opts \\ []) do
    Visualization.canvas(id, operations, opts)
  end

  @spec stream_widget(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def stream_widget(id, entries, opts \\ []) do
    Operational.stream_widget(id, entries, opts)
  end

  @spec process_monitor(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def process_monitor(id, processes, opts \\ []) do
    Operational.process_monitor(id, processes, opts)
  end

  @spec cluster_dashboard(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def cluster_dashboard(id, nodes, opts \\ []) do
    Operational.cluster_dashboard(id, nodes, opts)
  end

  @spec command_palette(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def command_palette(id, commands, opts \\ []) do
    Operational.command_palette(id, commands, opts)
  end

  @spec supervision_tree_viewer(String.t() | atom(), [keyword() | map()], keyword()) ::
          Widget.t()
  def supervision_tree_viewer(id, nodes, opts \\ []) do
    Operational.supervision_tree_viewer(id, nodes, opts)
  end

  @spec inline_rich_text_heading(String.t() | atom(), atom(), [keyword() | map()], keyword()) ::
          Widget.t()
  def inline_rich_text_heading(id, level, segments, opts \\ []) do
    Components.inline_rich_text_heading(id, level, segments, opts)
  end

  @spec disclosure(String.t() | atom(), String.t(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def disclosure(id, summary, children \\ [], opts \\ []) do
    Components.disclosure(id, summary, children, opts)
  end

  @spec kicker(String.t() | atom(), [String.t()], keyword()) :: Widget.t()
  def kicker(id, items, opts \\ []) do
    Components.kicker(id, items, opts)
  end

  @spec avatar(String.t() | atom(), keyword()) :: Widget.t()
  def avatar(id, opts \\ []) do
    Components.avatar(id, opts)
  end

  @spec presence_dot(String.t() | atom(), atom(), keyword()) :: Widget.t()
  def presence_dot(id, state, opts \\ []) do
    Components.presence_dot(id, state, opts)
  end

  @spec segmented_button_group(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def segmented_button_group(id, options, opts \\ []) do
    Components.segmented_button_group(id, options, opts)
  end

  @spec runtime_form_shell(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def runtime_form_shell(id, fields, opts \\ []) do
    Components.runtime_form_shell(id, fields, opts)
  end

  @spec chat_composer(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def chat_composer(id, children \\ [], opts \\ []) do
    Components.chat_composer(id, children, opts)
  end

  @spec list_item_multi_column(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def list_item_multi_column(id, children \\ [], opts \\ []) do
    Components.list_item_multi_column(id, children, opts)
  end

  @spec artifact_row(String.t() | atom(), String.t(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def artifact_row(id, title, children \\ [], opts \\ []) do
    Components.artifact_row(id, title, children, opts)
  end

  @spec pipeline_stepper_horizontal(String.t() | atom(), [keyword() | map()], keyword()) ::
          Widget.t()
  def pipeline_stepper_horizontal(id, steps, opts \\ []) do
    Components.pipeline_stepper_horizontal(id, steps, opts)
  end

  @spec segmented_progress_bar(String.t() | atom(), [keyword() | map()], keyword()) ::
          Widget.t()
  def segmented_progress_bar(id, segments, opts \\ []) do
    Components.segmented_progress_bar(id, segments, opts)
  end

  @spec workflow_stage_list_vertical(String.t() | atom(), [keyword() | map()], keyword()) ::
          Widget.t()
  def workflow_stage_list_vertical(id, stages, opts \\ []) do
    Components.workflow_stage_list_vertical(id, stages, opts)
  end

  @spec meter_thin(String.t() | atom(), number(), keyword()) :: Widget.t()
  def meter_thin(id, current, opts \\ []) do
    Components.meter_thin(id, current, opts)
  end

  @spec sticky_frosted_header(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def sticky_frosted_header(id, children \\ [], opts \\ []) do
    Components.sticky_frosted_header(id, children, opts)
  end

  @spec slide_over_panel(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def slide_over_panel(id, children \\ [], opts \\ []) do
    Components.slide_over_panel(id, children, opts)
  end

  @spec event_callout(
          String.t() | atom(),
          String.t(),
          [Widget.t() | map() | keyword()],
          keyword()
        ) ::
          Widget.t()
  def event_callout(id, message, children \\ [], opts \\ []) do
    Components.event_callout(id, message, children, opts)
  end

  @spec redline_inline(String.t() | atom(), [keyword() | map()], keyword()) :: Widget.t()
  def redline_inline(id, segments, opts \\ []) do
    Components.redline_inline(id, segments, opts)
  end

  @spec code_block_syntax_highlighted(
          String.t() | atom(),
          atom() | String.t(),
          [keyword() | map()],
          keyword()
        ) :: Widget.t()
  def code_block_syntax_highlighted(id, language, tokens, opts \\ []) do
    Components.code_block_syntax_highlighted(id, language, tokens, opts)
  end

  @spec list_repeat(String.t() | atom(), [Widget.t() | map() | keyword()], keyword()) ::
          Widget.t()
  def list_repeat(id, children \\ [], opts \\ []) do
    Components.list_repeat(id, children, opts)
  end

  @spec screen(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: map()
  def screen(id, title, children, opts \\ []) do
    %{
      id: id,
      title: title,
      root:
        stack("#{id}-root", children, direction: :column, styles: Keyword.get(opts, :styles, %{})),
      metadata: %{
        bridge: Keyword.get(opts, :bridge, :phoenix_elm),
        source: Keyword.get(opts, :source, :native),
        theme: Keyword.get(opts, :theme, :default)
      }
    }
  end

  defp normalize_map(map) when is_map(map) do
    Map.new(map, fn {key, value} -> {normalize_key(key), value} end)
  end

  defp normalize_map(list) when is_list(list), do: list |> Enum.into(%{}) |> normalize_map()

  defp normalize_key("id"), do: :id
  defp normalize_key("family"), do: :family
  defp normalize_key("kind"), do: :kind
  defp normalize_key("metadata"), do: :metadata
  defp normalize_key("state"), do: :state
  defp normalize_key("slots"), do: :slots
  defp normalize_key("slot_children"), do: :slot_children
  defp normalize_key("attributes"), do: :attributes
  defp normalize_key("styles"), do: :styles
  defp normalize_key("events"), do: :events
  defp normalize_key("children"), do: :children
  defp normalize_key(key), do: key
end
