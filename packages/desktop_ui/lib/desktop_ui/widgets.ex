defmodule DesktopUi.Widgets do
  @moduledoc """
  Package-facing entrypoint for native `desktop_ui` widgets.
  """

  alias DesktopUi.Widget
  alias DesktopUi.Widgets.{Builder, Data, Feedback, Foundational, Input, Navigation}
  alias DesktopUi.Widgets.{Operational, Visualization}
  alias DesktopUi.Widgets.Portable

  @spec families() :: [Widget.family()]
  def families do
    kinds()
    |> Enum.map(&Widget.family_for/1)
    |> Enum.uniq()
    |> Enum.sort_by(&to_string/1)
  end

  @spec modules() :: [module()]
  def modules do
    [
      __MODULE__,
      Widget,
      Builder,
      Foundational,
      Input,
      Navigation,
      Data,
      Feedback,
      Visualization,
      Operational,
      Portable
    ]
  end

  @spec kinds() :: [atom()]
  def kinds do
    [
      Foundational.kinds(),
      Input.kinds(),
      Navigation.kinds(),
      Data.kinds(),
      Feedback.kinds(),
      Visualization.kinds(),
      Operational.kinds(),
      Portable.kinds(),
      [:column, :row, :sparkline, :stack, :status, :window]
    ]
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  @spec family_for_kind(atom() | String.t()) :: Widget.family()
  def family_for_kind(kind) when is_binary(kind),
    do: kind |> String.to_atom() |> family_for_kind()

  def family_for_kind(kind), do: Widget.family_for(kind)

  @spec validation_state() :: map()
  def validation_state do
    %{
      widget_contract: :ready,
      registration_surface: :ready,
      direct_native_scaffold: :ready,
      foundational_content_widgets: :ready,
      foundational_action_widgets: :ready,
      foundational_form_widgets: :ready,
      foundational_navigation_widgets: :ready,
      focus_metadata: :ready,
      shortcut_metadata: :ready,
      advanced_data_widgets: :ready,
      advanced_feedback_widgets: :ready,
      advanced_visualization_widgets: :ready,
      advanced_operational_widgets: :ready,
      advanced_window_metadata: :ready,
      promoted_portable_widgets: :ready,
      repeated_collection_widgets: :ready,
      slot_contracts: :ready,
      style_contracts: :ready
    }
  end

  @spec registration_model() :: map()
  def registration_model do
    %{
      builder: Builder,
      direct_native_only: true,
      canonical_branching: false,
      supported_kinds: kinds(),
      supported_families: families(),
      shared_focus_model: true,
      multiwindow_metadata: true
    }
  end

  @spec window(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def window(id, title, children \\ [], opts \\ []) do
    Builder.window(id, title, children, opts)
  end

  @spec dialog(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def dialog(id, title, children \\ [], opts \\ []) do
    Builder.dialog(id, title, children, opts)
  end

  @spec content(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def content(id, children \\ [], opts \\ []) do
    Foundational.content(id, children, opts)
  end

  @spec column(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def column(id, children \\ [], opts \\ []) do
    Builder.column(id, children, opts)
  end

  @spec row(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def row(id, children \\ [], opts \\ []) do
    Builder.row(id, children, opts)
  end

  @spec stack(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def stack(id, children \\ [], opts \\ []) do
    Builder.stack(id, children, opts)
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
  def image(id, source, opts \\ []) do
    Foundational.image(id, source, opts)
  end

  @spec badge(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def badge(id, content, opts \\ []) do
    Foundational.badge(id, content, opts)
  end

  @spec hero(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def hero(id, headline, opts \\ []) do
    Foundational.hero(id, headline, opts)
  end

  @spec spacer(String.t() | atom(), keyword()) :: Widget.t()
  def spacer(id, opts \\ []) do
    Foundational.spacer(id, opts)
  end

  @spec separator(String.t() | atom(), keyword()) :: Widget.t()
  def separator(id, opts \\ []) do
    Foundational.separator(id, opts)
  end

  @spec button(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def button(id, label, opts \\ []) do
    Foundational.button(id, label, opts)
  end

  @spec toggle(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def toggle(id, label, opts \\ []) do
    Foundational.toggle(id, label, opts)
  end

  @spec link(String.t() | atom(), String.t(), String.t(), keyword()) :: Widget.t()
  def link(id, label, href, opts \\ []) do
    Foundational.link(id, label, href, opts)
  end

  @spec command(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def command(id, label, opts \\ []) do
    Foundational.command(id, label, opts)
  end

  @spec text_input(String.t() | atom(), keyword()) :: Widget.t()
  def text_input(id, opts \\ []) do
    Input.text_input(id, opts)
  end

  @spec numeric_input(String.t() | atom(), keyword()) :: Widget.t()
  def numeric_input(id, opts \\ []) do
    Input.numeric_input(id, opts)
  end

  @spec slider(String.t() | atom(), keyword()) :: Widget.t()
  def slider(id, opts \\ []) do
    Input.slider(id, opts)
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

  @spec pick_list(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def pick_list(id, options, opts \\ []) do
    Input.pick_list(id, options, opts)
  end

  @spec checkbox(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def checkbox(id, label, opts \\ []) do
    Input.checkbox(id, label, opts)
  end

  @spec radio_group(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def radio_group(id, options, opts \\ []) do
    Input.radio_group(id, options, opts)
  end

  @spec select(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def select(id, options, opts \\ []) do
    Input.select(id, options, opts)
  end

  @spec tabs(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def tabs(id, items, opts \\ []) do
    Navigation.tabs(id, items, opts)
  end

  @spec menu(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def menu(id, items, opts \\ []) do
    Navigation.menu(id, items, opts)
  end

  @spec breadcrumbs(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def breadcrumbs(id, items, opts \\ []) do
    Navigation.breadcrumbs(id, items, opts)
  end

  @spec list(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def list(id, items, opts \\ []) do
    Navigation.list(id, items, opts)
  end

  @spec status(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def status(id, label, opts \\ []) do
    Builder.status(id, label, opts)
  end

  @spec table(String.t() | atom(), [map() | keyword()], [map() | keyword()], keyword()) ::
          Widget.t()
  def table(id, columns, rows, opts \\ []) do
    Data.table(id, columns, rows, opts)
  end

  @spec tree_view(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def tree_view(id, nodes, opts \\ []) do
    Data.tree_view(id, nodes, opts)
  end

  @spec stat(String.t() | atom(), keyword()) :: Widget.t()
  def stat(id, opts \\ []) do
    Data.stat(id, opts)
  end

  @spec key_value(String.t() | atom(), keyword()) :: Widget.t()
  def key_value(id, opts \\ []) do
    Data.key_value(id, opts)
  end

  @spec info_list(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def info_list(id, items, opts \\ []) do
    Data.info_list(id, items, opts)
  end

  @spec inspector(String.t() | atom(), map() | keyword(), keyword()) :: Widget.t()
  def inspector(id, subject, opts \\ []) do
    Data.inspector(id, subject, opts)
  end

  @spec markdown_viewer(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def markdown_viewer(id, markdown, opts \\ []) do
    Data.markdown_viewer(id, markdown, opts)
  end

  @spec toast(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def toast(id, message, opts \\ []) do
    Feedback.toast(id, message, opts)
  end

  @spec inline_feedback(String.t() | atom(), keyword()) :: Widget.t()
  def inline_feedback(id, opts \\ []) do
    Feedback.inline_feedback(id, opts)
  end

  @spec alert_dialog(String.t() | atom(), String.t(), [Widget.t()], keyword()) :: Widget.t()
  def alert_dialog(id, message, children, opts \\ []) do
    Feedback.alert_dialog(id, message, children, opts)
  end

  @spec progress(String.t() | atom(), keyword()) :: Widget.t()
  def progress(id, opts \\ []) do
    Feedback.progress(id, opts)
  end

  @spec sparkline(String.t() | atom(), keyword()) :: Widget.t()
  def sparkline(id, opts \\ []) do
    Feedback.sparkline(id, opts)
  end

  @spec gauge(String.t() | atom(), keyword()) :: Widget.t()
  def gauge(id, opts \\ []) do
    Visualization.gauge(id, opts)
  end

  @spec bar_chart(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def bar_chart(id, series, opts \\ []) do
    Visualization.bar_chart(id, series, opts)
  end

  @spec line_chart(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def line_chart(id, series, opts \\ []) do
    Visualization.line_chart(id, series, opts)
  end

  @spec timeline(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def timeline(id, items, opts \\ []) do
    Visualization.timeline(id, items, opts)
  end

  @spec canvas(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def canvas(id, operations, opts \\ []) do
    Visualization.canvas(id, operations, opts)
  end

  @spec log_viewer(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def log_viewer(id, entries, opts \\ []) do
    Operational.log_viewer(id, entries, opts)
  end

  @spec cluster_dashboard(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def cluster_dashboard(id, nodes, opts \\ []) do
    Operational.cluster_dashboard(id, nodes, opts)
  end

  @spec command_palette(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def command_palette(id, commands, opts \\ []) do
    Operational.command_palette(id, commands, opts)
  end

  @spec stream_widget(String.t() | atom(), keyword()) :: Widget.t()
  def stream_widget(id, opts \\ []) do
    Operational.stream_widget(id, opts)
  end

  @spec supervision_tree_viewer(String.t() | atom(), keyword()) :: Widget.t()
  def supervision_tree_viewer(id, opts \\ []) do
    Operational.supervision_tree_viewer(id, opts)
  end

  @spec process_monitor(String.t() | atom(), [map() | keyword()], keyword()) :: Widget.t()
  def process_monitor(id, processes, opts \\ []) do
    Operational.process_monitor(id, processes, opts)
  end

  @spec window_command(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def window_command(id, label, opts \\ []) do
    Operational.window_command(id, label, opts)
  end

  @spec disclosure(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def disclosure(id, label, opts \\ []) do
    Portable.disclosure(id, label, opts)
  end

  @spec kicker(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def kicker(id, value, opts \\ []) do
    Portable.kicker(id, value, opts)
  end

  @spec avatar(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def avatar(id, label, opts \\ []) do
    Portable.avatar(id, label, opts)
  end

  @spec presence_dot(String.t() | atom(), atom() | String.t(), keyword()) :: Widget.t()
  def presence_dot(id, status, opts \\ []) do
    Portable.presence_dot(id, status, opts)
  end

  @spec segmented_button_group(String.t() | atom(), term(), keyword()) :: Widget.t()
  def segmented_button_group(id, items, opts \\ []) do
    Portable.segmented_button_group(id, items, opts)
  end

  @spec list_item_multi_column(String.t() | atom(), term(), keyword()) :: Widget.t()
  def list_item_multi_column(id, columns, opts \\ []) do
    Portable.list_item_multi_column(id, columns, opts)
  end

  @spec artifact_row(String.t() | atom(), term(), String.t(), keyword()) :: Widget.t()
  def artifact_row(id, artifact, title, opts \\ []) do
    Portable.artifact_row(id, artifact, title, opts)
  end

  @spec sticky_header(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def sticky_header(id, title, opts \\ []) do
    Portable.sticky_header(id, title, opts)
  end

  @spec pipeline_stepper_horizontal(String.t() | atom(), term(), keyword()) :: Widget.t()
  def pipeline_stepper_horizontal(id, steps, opts \\ []) do
    Portable.pipeline_stepper_horizontal(id, steps, opts)
  end

  @spec segmented_progress_bar(String.t() | atom(), term(), keyword()) :: Widget.t()
  def segmented_progress_bar(id, segments, opts \\ []) do
    Portable.segmented_progress_bar(id, segments, opts)
  end

  @spec workflow_stage_list_vertical(String.t() | atom(), term(), keyword()) :: Widget.t()
  def workflow_stage_list_vertical(id, stages, opts \\ []) do
    Portable.workflow_stage_list_vertical(id, stages, opts)
  end

  @spec meter_thin(String.t() | atom(), number(), keyword()) :: Widget.t()
  def meter_thin(id, current, opts \\ []) do
    Portable.meter_thin(id, current, opts)
  end

  @spec slide_over_panel(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def slide_over_panel(id, children \\ [], opts \\ []) do
    Portable.slide_over_panel(id, children, opts)
  end

  @spec event_callout(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def event_callout(id, message, opts \\ []) do
    Portable.event_callout(id, message, opts)
  end

  @spec redline_inline(String.t() | atom(), String.t(), String.t(), keyword()) :: Widget.t()
  def redline_inline(id, before_text, after_text, opts \\ []) do
    Portable.redline_inline(id, before_text, after_text, opts)
  end

  @spec code_block_syntax_highlighted(String.t() | atom(), String.t(), keyword()) :: Widget.t()
  def code_block_syntax_highlighted(id, code, opts \\ []) do
    Portable.code_block_syntax_highlighted(id, code, opts)
  end

  @spec chat_composer(String.t() | atom(), keyword()) :: Widget.t()
  def chat_composer(id, opts \\ []) do
    Portable.chat_composer(id, opts)
  end

  @spec host_form_shell(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def host_form_shell(id, children \\ [], opts \\ []) do
    Portable.host_form_shell(id, children, opts)
  end

  @spec repeated_collection(String.t() | atom(), [Widget.t()], keyword()) :: Widget.t()
  def repeated_collection(id, row_widgets, opts \\ []) do
    Portable.repeated_collection(id, row_widgets, opts)
  end
end
